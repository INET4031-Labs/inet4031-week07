# Week 7 Lab: Security Hardening and Shift Left

**Sprint 4 Kickoff | Synchronous Lab**

---

## Part 0: Sprint Review - Sprint 3

This is the beginning of every synchronous lab. Before starting new work, review what the team accomplished in Sprint 3 and prepare the environment for Sprint 4.

### Step 1: Review Sprint 3 on the Board

Open the sprint board. Move all Sprint 3 items to Done. The Scrum Master leads this step.

**TODO:** Confirm all Sprint 3 tickets have moved to Done column. If any are still in progress, discuss with the team before proceeding.

### Step 2: Document Sprint 3 Retrospective

In your team Google Doc, create a section titled "Sprint 3 Close." Answer these questions:

- What was the most technically challenging part of Sprint 3?
- Which role was most stressful?
- What one concrete change will the team make in Sprint 4?

**TODO:** Write retrospective answers in Google Doc under "Sprint 3 Close" section.

### Step 3: Environment Checkpoint

The System Admin runs these commands and pastes the output into the Google Doc under "Sprint 4 Kickoff - Environment State":

```bash
k3d cluster list
kubectl get pods
kubectl get pods -n monitoring
git log --oneline -5
```

**TODO:** System Admin to run checkpoint commands and paste output.

### Step 4: Assign Sprint 4 Roles and Open Sprint 4 Issues

Confirm your team's Sprint 4 role assignments from your team charter. The Scrum Master then creates tickets for all parts of this lab and assigns them appropriately.

**TODO:** Scrum Master to confirm role assignments and create Sprint 4 tickets on the board.

---

## Part 1: Kubernetes RBAC

**System Admin leads. Developers implement. QA verifies.**

By default, pods run using the `default` ServiceAccount, which has broad permissions. RBAC restricts what actions identities can take on Kubernetes resources. Least privilege means granting only the permissions required for a specific purpose. Your Flask application does not need to query the Kubernetes API, so it should not have access to do so.

### Step 1: Create the Flask ServiceAccount

Create the file `manifests/flask-serviceaccount.yaml` with the following content:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: flask-app
  namespace: default
automountServiceAccountToken: false
```

The `automountServiceAccountToken: false` setting prevents the Kubernetes API token from being automatically mounted inside the container. Since Flask does not call the Kubernetes API, this token represents unnecessary exposure.

**TODO:** Create `manifests/flask-serviceaccount.yaml` with the content above.

### Step 2: Create the Flask Role

Create the file `manifests/flask-role.yaml` with the following content:

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

This Role grants only two permissions: the ability to read (`get`) and list ConfigMaps. Nothing more. This is the principle of least privilege in action.

**TODO:** Create `manifests/flask-role.yaml` with the content above.

### Step 3: Create the RoleBinding

Create the file `manifests/flask-rolebinding.yaml` with the following content:

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

The RoleBinding connects the ServiceAccount to the Role. This is how Kubernetes knows: "When someone uses the flask-app ServiceAccount, they can do what the flask-reader Role allows."

**TODO:** Create `manifests/flask-rolebinding.yaml` with the content above.

### Step 4: Update Flask Deployment to Use the ServiceAccount

Open your existing `manifests/flask-deployment.yaml` and find the line `spec.template.spec`. Add the following line under `spec.template.spec` (at the same indentation level as `containers`):

```yaml
serviceAccountName: flask-app
```

This tells Kubernetes: "When this deployment's pods start, use the flask-app ServiceAccount."

**TODO:** Edit `manifests/flask-deployment.yaml` to add `serviceAccountName: flask-app` under `spec.template.spec`.

### Step 5: Apply the RBAC Manifests

Run these commands to apply the manifests:

```bash
kubectl apply -f manifests/flask-serviceaccount.yaml
kubectl apply -f manifests/flask-role.yaml
kubectl apply -f manifests/flask-rolebinding.yaml
kubectl apply -f manifests/flask-deployment.yaml
```

Watch the Flask pods restart:

```bash
kubectl get pods -l app=flask --watch
```

Wait until the new pods are Running and Ready (the Ready column shows 1/1).

**TODO:** Apply all RBAC manifests. Confirm Flask pods restart and reach Ready state.

### Step 6: Understanding the Change

In your Google Doc under "Week 7 - Part 1 Reflection," answer this question:

RBAC separates authentication (who are you?) from authorization (what can you do?). Your Flask pod now has a custom ServiceAccount. Does having a custom ServiceAccount mean the pod can do more or less in the cluster than before? What specifically changed?

**TODO:** Write reflection answer in Google Doc.

---

## Part 2: NetworkPolicy

**System Admin leads. Developers implement. QA verifies.**

By default, all pods can communicate with all other pods in Kubernetes. A NetworkPolicy restricts which pods can send and receive traffic. Without it, a compromised pod could reach any other pod in the cluster and potentially steal data or cause damage.

### Step 6: Create Default Deny Policy

Create the file `manifests/default-deny.yaml` with the following content:

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

This policy says: "In the default namespace, deny all incoming traffic to all pods." It is a blank slate. Everything is blocked until explicitly allowed.

**TODO:** Create `manifests/default-deny.yaml` with the content above.

### Step 7: Apply the Default Deny Policy

```bash
kubectl apply -f manifests/default-deny.yaml
```

**TODO:** Apply the default-deny policy.

### Step 8: Test That Deny Blocks Traffic

Run a temporary test pod and try to reach Flask:

```bash
kubectl run test-pod --image=curlimages/curl:latest --restart=Never --rm -it -- curl --max-time 5 http://flask/health
```

Expected result: the connection will hang, then time out after 5 seconds. This proves the default deny is working.

**Take a screenshot of the timeout and save it for the deliverables.**

**TODO:** Run the test pod command. Screenshot the timeout. Expected: connection timeout after 5 seconds.

### Step 9: Create Allow Policies

Create the file `manifests/allow-nginx-to-flask.yaml`:

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

This policy says: "Allow pods labeled app=nginx to send traffic to pods labeled app=flask on port 5000, and only that traffic."

Create the file `manifests/allow-flask-to-postgres.yaml`:

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

This policy says: "Allow pods labeled app=flask to send traffic to pods labeled app=postgres on port 5432, and only that traffic."

**TODO:** Create both `allow-nginx-to-flask.yaml` and `allow-flask-to-postgres.yaml` with the content above.

### Step 10: Apply the Allow Policies

```bash
kubectl apply -f manifests/allow-nginx-to-flask.yaml
kubectl apply -f manifests/allow-flask-to-postgres.yaml
```

**TODO:** Apply both allow policies.

### Step 11: Verify the Application Still Works

Test that the application responds end-to-end:

```bash
curl http://localhost:8080/incidents
```

Expected: a valid JSON response, such as:

```json
{"incidents": []}
```

or a list of existing incidents.

**Take a screenshot of the successful response for the deliverables.**

**TODO:** Run curl to /incidents endpoint. Screenshot the successful JSON response.

### Step 12: Understanding NetworkPolicy

In your Google Doc under "Week 7 - Part 2 Reflection," answer this question:

If a real attacker compromised your Nginx container, what traffic paths would they have available after your NetworkPolicies are applied? What paths remain that you might want to restrict further?

**TODO:** Write reflection answer in Google Doc.

---

## Part 3: SecurityContext

**System Admin leads. Developers implement. QA verifies.**

A SecurityContext restricts what a container can do at the kernel level. Settings like `allowPrivilegeEscalation: false` and `readOnlyRootFilesystem: true` are required by common production security baselines (CIS Kubernetes Benchmark, NSA hardening guide). These settings are not suggestions; they are industry standards.

### Step 12: Add SecurityContext to Flask Deployment

Open your `manifests/flask-deployment.yaml` and find the container specification. Under the Flask container spec (look for the `name: flask` entry), add this block:

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

This configuration:

- **allowPrivilegeEscalation: false** - Prevents the process from gaining additional privileges
- **readOnlyRootFilesystem: true** - Makes the root filesystem read-only (protects against tampering)
- **runAsNonRoot: true** - Requires the container to run as a non-root user
- **runAsUser: 1000** - Specifies which non-root user ID to use
- **capabilities: drop: ALL** - Removes all Linux capabilities (reduces exploit surface)

**TODO:** Edit `manifests/flask-deployment.yaml` to add the SecurityContext block to the Flask container spec.

### Step 13: Apply the Updated Deployment

```bash
kubectl apply -f manifests/flask-deployment.yaml
```

**TODO:** Apply the updated Flask deployment.

### Step 14: Watch the Pods Restart

```bash
kubectl get pods -l app=flask --watch
```

The pods should terminate and new ones should start. Wait until new pods reach Running and Ready state.

**If pods fail to start**, check the events:

```bash
kubectl describe pod <flask-pod-name>
```

A common failure: the Flask app writes to a path that is now read-only. If this happens, add a writable `emptyDir` volume for that specific path. For example, if Flask writes to `/tmp`, add this to the Flask container spec:

```yaml
volumeMounts:
  - name: tmp-volume
    mountPath: /tmp
```

And add this to `spec.template.spec.volumes`:

```yaml
volumes:
  - name: tmp-volume
    emptyDir: {}
```

**TODO:** Watch pods restart. If any fail, investigate and add emptyDir volumes as needed. Confirm all pods reach Running and Ready.

### Step 15: Understanding SecurityContext

In your Google Doc under "Week 7 - Part 3 Reflection," answer these questions:

- `readOnlyRootFilesystem: true` prevents the Flask container from writing to most of its filesystem. Why is this a security improvement? What operational problem does it introduce, and how did you resolve it?
- Dropping all Linux capabilities removes ambient privileges that many container exploits depend on. Can you think of a legitimate reason a container would need any of the dropped capabilities?

**TODO:** Write reflection answers in Google Doc.

---

## Part 4: Image Vulnerability Scanning in CI

**Developers implement. QA verifies.**

Adding automated image scanning to your CI pipeline means security is checked on every build, not after the fact. If a vulnerability is found, the pipeline fails and the image is not pushed to the registry.

### Step 15: Update GitHub Actions CI Workflow

Open `.github/workflows/ci.yml`. Find the section that defines jobs (the `jobs:` block). Add a new job called `security-scan` after your existing `build-and-push` job. Copy and paste this block:

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

This job:

- Runs after the `build-and-push` job completes (that is what `needs: build-and-push` means)
- Uses Trivy, an automated vulnerability scanner
- Scans the Flask image
- Fails the pipeline (exit-code: 1) if any CRITICAL vulnerabilities are found
- Runs on every push to main (not on pull requests, due to the `if:` condition)

The scanner will check the image against known vulnerability databases. If critical issues are found, the pipeline stops and developers must fix them before the image can be pushed.

**TODO:** Update `.github/workflows/ci.yml` to add the security-scan job after build-and-push.

### Step 16: Commit All Changes

Commit your Week 7 work:

```bash
git add manifests/ .github/workflows/ci.yml
git commit -m "feat: add RBAC, NetworkPolicy, SecurityContext, and Trivy scan to CI"
git push origin main
```

**TODO:** Commit and push all Week 7 changes.

### Step 17: Monitor the CI Pipeline

Wait for the pipeline to run. Visit your GitHub repository and click on the "Actions" tab. Watch the workflow execute. If Trivy finds vulnerabilities:

1. Click on the failed job to see the vulnerability details
2. Review the CVE descriptions
3. Update the base image version in your Flask Dockerfile if needed (e.g., upgrade `python:3.11` to a patched version)
4. Push the change and let the pipeline run again

**TODO:** Monitor GitHub Actions until the full pipeline passes (build, push, and security scan).

**Take a screenshot of the Trivy scan result in GitHub Actions for the deliverables.**

### Step 18: Understanding Image Scanning

In your Google Doc under "Week 7 - Part 4 Reflection," answer this question:

The Trivy scan runs after the image is built and pushed. In a stricter security model, where else in the pipeline might you add scanning? What is the tradeoff of scanning earlier versus later?

**TODO:** Write reflection answer in Google Doc.

---

## Validation Checks

QA runs all validation checks. Every other team member watches and verifies the output.

### Validation Check: Flask Uses Custom ServiceAccount

```bash
kubectl get pod -l app=flask -o jsonpath='{.items[0].spec.serviceAccountName}'
```

Expected output: `flask-app`

If the output is not `flask-app`, the Flask deployment is not using the custom ServiceAccount. Check that you added `serviceAccountName: flask-app` to the deployment and that you ran `kubectl apply -f manifests/flask-deployment.yaml`.

**TODO:** Run this check. Expected: flask-app. Record result in QA report.

### Validation Check: NetworkPolicy Applied

```bash
kubectl get networkpolicy
```

Expected output: three rows with names `default-deny-ingress`, `allow-nginx-to-flask`, and `allow-flask-to-postgres`.

If any are missing, apply them with `kubectl apply -f manifests/<policy-name>.yaml`.

**TODO:** Run this check. Expected: three policies listed. Record result in QA report.

### Validation Check: Application Works After NetworkPolicy

```bash
curl -s http://localhost:8080/incidents
```

Expected output: valid JSON (e.g., `{"incidents": []}` or a list of incidents).

If the response is empty or times out, the NetworkPolicy is blocking traffic. Verify that the allow policies are applied and that your Flask and Nginx pods have the correct labels (`app: flask` and `app: nginx`).

**TODO:** Run this check. Expected: valid JSON. Record result in QA report.

### Validation Check: SecurityContext Is Set

```bash
kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}'
```

Expected output: `false`

If the output is empty or `true`, the SecurityContext was not applied. Check that you added the securityContext block to the Flask container spec and that you ran `kubectl apply -f manifests/flask-deployment.yaml`.

**TODO:** Run this check. Expected: false. Record result in QA report.

### Validation Check: Check Script Passes

```bash
./scripts/check-week7.sh
```

This script runs all the checks above in one command. It should exit with status 0 (success).

If the script fails, it will print which check failed. Fix that issue and re-run until all checks pass.

**TODO:** Run check script. Expected: exit status 0. Record full output in QA report.

---

## Deliverables

Before claiming this lab complete, verify all of the following:

### Manifests Committed

- [ ] `manifests/flask-serviceaccount.yaml` exists and is committed
- [ ] `manifests/flask-role.yaml` exists and is committed
- [ ] `manifests/flask-rolebinding.yaml` exists and is committed
- [ ] `manifests/default-deny.yaml` exists and is committed
- [ ] `manifests/allow-nginx-to-flask.yaml` exists and is committed
- [ ] `manifests/allow-flask-to-postgres.yaml` exists and is committed
- [ ] `manifests/flask-deployment.yaml` is updated with ServiceAccount and SecurityContext

### CI Pipeline Updated

- [ ] `.github/workflows/ci.yml` includes the security-scan job
- [ ] Trivy scanner runs after the build-and-push job
- [ ] Pipeline passes (no CRITICAL vulnerabilities in Flask image)

### Validation Checks Pass

- [ ] All four validation checks pass
- [ ] `./scripts/check-week7.sh` exits with status 0

### Role Artifacts Completed

- [ ] `docs/sprint-4-retrospective.md` filled with Sprint 3 close and Sprint 4 decisions
- [ ] `docs/week-07-environment-log.md` filled with baseline and end-of-sprint snapshots
- [ ] `docs/week-07-acceptance-criteria.md` filled with team's acceptance criteria
- [ ] `docs/qa-report-4.md` filled with check results and sign-off

### Google Doc Reflections

- [ ] Google Doc has "Week 7 - Part 1 Reflection" with ServiceAccount discussion
- [ ] Google Doc has "Week 7 - Part 2 Reflection" with NetworkPolicy threat analysis
- [ ] Google Doc has "Week 7 - Part 3 Reflection" with SecurityContext and emptyDir discussion
- [ ] Google Doc has "Week 7 - Part 4 Reflection" with image scanning tradeoffs

### Screenshots in Google Doc

- [ ] Screenshot 1: Test pod connection timeout after default-deny policy
- [ ] Screenshot 2: Successful curl response after allow policies
- [ ] Screenshot 3: Trivy scan result in GitHub Actions
- [ ] Screenshot 4: `./scripts/check-week7.sh` output passing

---

## Reflection Questions (Answer in Google Doc Under "Week 7 Reflections")

Answer these questions in your team Google Doc:

1. You created a ServiceAccount with no Kubernetes API permissions and disabled automatic token mounting. What attack surface does this reduce compared to the default ServiceAccount behavior?

2. After applying the allow policies, list each communication path that is now permitted (source, destination, port). Which paths remain unrestricted?

3. `readOnlyRootFilesystem: true` prevents the Flask container from writing to most of its filesystem. Why is this a security improvement? What operational problem does it introduce, and how did you resolve it?

4. The Trivy scan runs after the image is built and pushed. In a stricter security model, where else in the pipeline might you add scanning? What is the tradeoff of scanning earlier versus later?

5. (Extend) Kubernetes NetworkPolicy is enforced by the CNI plugin. If the CNI plugin is not NetworkPolicy-aware, the NetworkPolicy objects exist in etcd but have no enforcement effect. How would you verify that your k3d cluster is actually enforcing NetworkPolicies?

**TODO:** Write full answers to all reflection questions in Google Doc.

---

## Storage Check

Before closing Sprint 4, check your disk usage. Run these commands and record the output in your Google Doc under "Week 7 Storage State":

```bash
df -h
docker system df
```

The `df -h` output shows filesystem usage on the container's file system. The `docker system df` output shows space used by Docker images, containers, and volumes. The k3d cluster uses a separate containerd image store that `docker system df` does not report. Both tools consume disk space.

**Note:** Compare these numbers to the storage baseline from Week 1 to see how much space the application, Kubernetes, and monitoring tools have used.

**TODO:** Run storage check commands. Paste output in Google Doc under "Week 7 Storage State".

---

## Sprint 4 Preparation for Week 8

Week 8 is asynchronous work. Before the synchronous lab session ends, the Scrum Master ensures all of the following tickets are created and assigned in the sprint backlog:

- [ ] Provision MinIO container as backup target
- [ ] Configure restic to back up PostgreSQL data volume to MinIO
- [ ] Set up GitHub Actions scheduled backup workflow
- [ ] Simulate data loss and execute recovery drill
- [ ] Write Week 8 runbook documenting backup and recovery procedures
- [ ] Update Google Doc with Week 8 reflections and storage check

**TODO:** Scrum Master to create all Week 8 tickets on the sprint board before lab ends.

---

## End of Week 7

Congratulations! Your application now has:

- RBAC with least-privilege permissions
- NetworkPolicy restricting pod-to-pod communication
- SecurityContext preventing privilege escalation
- Automated image vulnerability scanning in CI

These are the foundational security controls used in production Kubernetes deployments. You have shifted left by catching vulnerabilities early in the pipeline, not after deployment. Your infrastructure is measurably more secure than it was at the start of the week.
