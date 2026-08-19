## Week 7: Security Hardening and Shift Left

**Sprint 4 Kickoff | Synchronous**

### Overview

In this lab, you apply Kubernetes security controls to your deployed application: RBAC (Role-Based Access Control), NetworkPolicy to restrict pod-to-pod traffic, and SecurityContext to prevent privilege escalation inside containers. You will also add an automated image vulnerability scan to the CI pipeline, making security a gate on every build. After completing this lab, you will have a hardened application deployment with RBAC, NetworkPolicy, SecurityContext, and automated vulnerability scanning all committed to your repository.

### Learning Objectives

- Configure Kubernetes RBAC with a least-privilege ServiceAccount, Role, and RoleBinding
- Apply a NetworkPolicy that restricts pod-to-pod communication to declared paths only
- Configure SecurityContext settings to prevent privilege escalation inside containers
- Add automated image scanning to the GitHub Actions pipeline as a required check
- Understand the difference between authentication and authorization in Kubernetes

### Prerequisites

- Week 6 complete: GitHub Actions CI pipeline passing, branch protection configured
- k3d cluster running with application deployed

### Sprint Review: Sprint 3

**Step 1.** Open the sprint board. Move all Sprint 3 items to Done.

**Step 2.** Retrospective in Google Doc under "Sprint 3 Close": What was the most technically challenging part? Which role was most stressful? What one concrete change will the team make in Sprint 4?

**Step 3.** Environment checkpoint.

```bash
k3d cluster list
kubectl get pods
kubectl get pods -n monitoring
git log --oneline -5
```

Paste into Google Doc under "Sprint 4 Kickoff -- Environment State."

**Step 4.** Assign Sprint 4 roles and open Sprint 4 issues.

---

### Part 1: Kubernetes RBAC

> **Background:** By default, pods run using the `default` ServiceAccount, which has broad permissions. RBAC restricts what actions identities can take on Kubernetes resources. Least privilege means granting only the permissions required for a specific purpose.

**Step 1.** Create `manifests/flask-serviceaccount.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: flask-app
  namespace: default
automountServiceAccountToken: false
```

`automountServiceAccountToken: false` prevents the Kubernetes API token from being automatically mounted inside the container. The Flask app does not call the Kubernetes API, so this token is unnecessary exposure.

**Step 2.** Create `manifests/flask-role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: flask-reader
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list"]
```

**Step 3.** Create `manifests/flask-rolebinding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: flask-reader-binding
  namespace: default
subjects:
  - kind: ServiceAccount
    name: flask-app
    namespace: default
roleRef:
  kind: Role
  name: flask-reader
  apiGroup: rbac.authorization.k8s.io
```

**Step 4.** Update the Flask Deployment to use the new ServiceAccount. Add `serviceAccountName: flask-app` under `spec.template.spec` in `manifests/flask-deployment.yaml`.

**Step 5.** Apply the new manifests.

```bash
kubectl apply -f manifests/flask-serviceaccount.yaml
kubectl apply -f manifests/flask-role.yaml
kubectl apply -f manifests/flask-rolebinding.yaml
kubectl apply -f manifests/flask-deployment.yaml
```

**Discussion (add to Google Doc):** RBAC separates authentication (who are you?) from authorization (what can you do?). Your Flask pod now has a custom ServiceAccount. Does having a custom ServiceAccount mean the pod can do more or less in the cluster than before? What specifically changed?

---

### Part 2: NetworkPolicy

> **Background:** By default, all pods can communicate with all other pods in Kubernetes. A NetworkPolicy restricts which pods can send and receive traffic. Without it, a compromised pod can reach any other pod in the cluster.

**Step 6.** Create `manifests/default-deny.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: default
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

**Step 7.** Apply the deny policy.

```bash
kubectl apply -f manifests/default-deny.yaml
```

**Step 8.** Test that the deny policy blocks traffic. Attempt to reach Flask from a debug pod.

```bash
kubectl run test-pod --image=curlimages/curl:latest --restart=Never --rm -it -- curl --max-time 5 http://flask/health
```

Expected result: the connection times out. **Take a screenshot of the timeout.**

**Step 9.** Create `manifests/allow-nginx-to-flask.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-nginx-to-flask
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: flask
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: nginx
      ports:
        - protocol: TCP
          port: 5000
```

Create `manifests/allow-flask-to-postgres.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-flask-to-postgres
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: postgres
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: flask
      ports:
        - protocol: TCP
          port: 5432
```

**Step 10.** Apply the allow policies.

```bash
kubectl apply -f manifests/allow-nginx-to-flask.yaml
kubectl apply -f manifests/allow-flask-to-postgres.yaml
```

**Step 11.** Verify the application still works end to end.

```bash
curl http://localhost:8080/incidents
```

Expected: valid JSON response.

**Discussion (add to Google Doc):** If a real attacker compromised your Nginx container, what traffic paths would they have available after your NetworkPolicies are applied? What paths remain that you might want to restrict further?

---

### Part 3: SecurityContext

**Step 12.** Add SecurityContext settings to the Flask Deployment. Open `manifests/flask-deployment.yaml` and add under the container spec:

```yaml
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
              - ALL
```

**Step 13.** Apply the updated deployment.

```bash
kubectl apply -f manifests/flask-deployment.yaml
```

**Step 14.** Verify the pods restart and come back healthy.

```bash
kubectl get pods -l app=flask --watch
```

If pods fail to start, check:

```bash
kubectl describe pod <flask-pod-name>
```

A common failure: the Flask app writes to a path that is now read-only. If this happens, add a writable `emptyDir` volume for that specific path.

> **Enterprise Pattern:** Settings like `allowPrivilegeEscalation: false` and `readOnlyRootFilesystem: true` are required by common production security baselines (CIS Kubernetes Benchmark, NSA hardening guide). Dropping all Linux capabilities removes ambient privileges that many container exploits depend on.

---

### Part 4: Image Vulnerability Scanning in CI

**Step 15.** Update `.github/workflows/ci.yml` to add a Trivy scan job after the build.

```yaml
  security-scan:
    runs-on: ubuntu-latest
    needs: build-and-push
    if: github.event_name != 'pull_request'

    steps:
      - name: Run Trivy vulnerability scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'ghcr.io/${{ github.repository }}/flask-app:latest'
          format: 'table'
          exit-code: '1'
          severity: 'CRITICAL'
```

**Step 16.** Commit all changes.

```bash
git add .github/workflows/ci.yml manifests/
git commit -m "feat: add RBAC, NetworkPolicy, SecurityContext, and Trivy scan to CI"
git push origin main
```

---

### Validation Checks

#### Validation Check: Flask Uses Custom ServiceAccount

```bash
kubectl get pod -l app=flask -o jsonpath='{.items[0].spec.serviceAccountName}'
```

Expected output: `flask-app`

#### Validation Check: NetworkPolicy Applied

```bash
kubectl get networkpolicy
```

Expected: rows for `default-deny-ingress`, `allow-nginx-to-flask`, `allow-flask-to-postgres`.

#### Validation Check: Application Works After NetworkPolicy

```bash
curl -s http://localhost:8080/incidents
```

Expected: valid JSON.

#### Validation Check: SecurityContext Is Set

```bash
kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}'
```

Expected output: `false`

#### Validation Check: Check Script Passes

```bash
./scripts/check-week7.sh
```

---

### Deliverables

- `manifests/flask-serviceaccount.yaml`, `flask-role.yaml`, `flask-rolebinding.yaml` committed
- `manifests/default-deny.yaml`, `allow-nginx-to-flask.yaml`, `allow-flask-to-postgres.yaml` committed
- `manifests/flask-deployment.yaml` updated with SecurityContext
- `.github/workflows/ci.yml` updated with Trivy scan job
- `./scripts/check-week7.sh` runs clean

**Screenshot requirements:**

- **Screenshot 1:** Connection timeout from test pod after default-deny policy applied
- **Screenshot 2:** Application responding successfully after allow policies applied
- **Screenshot 3:** Trivy scan result in GitHub Actions
- **Screenshot 4:** `./scripts/check-week7.sh` passing

---

### Reflection Questions (Answer in Google Doc)

1. You created a ServiceAccount with no Kubernetes API permissions and disabled automatic token mounting. What attack surface does this reduce compared to the default ServiceAccount behavior?
2. After applying the allow policies, list each communication path that is now permitted (source, destination, port). Which paths remain unrestricted?
3. `readOnlyRootFilesystem: true` prevents the Flask container from writing to most of its filesystem. Why is this a security improvement? What operational problem does it introduce, and how did you resolve it?
4. The Trivy scan runs after the image is built and pushed. In a stricter security model, where else in the pipeline might you add scanning? What is the tradeoff of scanning earlier versus later?
5. (Extend) Kubernetes NetworkPolicy is enforced by the CNI plugin. If the CNI plugin is not NetworkPolicy-aware, the NetworkPolicy objects exist in etcd but have no enforcement effect. How would you verify that your k3d cluster is actually enforcing NetworkPolicies?

---

### Sprint Backlog: Preparing for Week 8

Week 8 is asynchronous. Before leaving, the Scrum Master ensures the following tickets are open:

- Provision MinIO container as backup target
- Configure restic to back up PostgreSQL data volume to MinIO
- Set up GitHub Actions scheduled backup workflow
- Simulate data loss and execute recovery drill
- Write Week 8 runbook
- Update Google Doc with Week 8 reflections and storage check

---

---

