# Build Log - Week 7 Student Repository Scaffold

**Date Built:** 2026-08-14

**Built By:** Week 7 Builder Agent

**Sprint:** Sprint 4 (Weeks 7-8)

**Week Number:** 7

---

## Build Overview

This document logs every assumption made and ambiguity encountered while building the Week 7 Student Repository scaffold. This log is the authoritative record of what the scaffold builder did not infer or assume silently.

---

## Assumptions Logged

### ASSUMPTION 1: Prerequisites Met as Stated in Lab Directions

**Text:** "Week 6 complete: GitHub Actions CI pipeline passing, branch protection configured. k3d cluster running with application deployed."

**Assumption:** The scaffold assumes students have completed Week 6 and arrive at Week 7 with:
- A GitHub Actions CI pipeline that runs successfully
- Branch protection rules in place on the main branch
- A running k3d cluster
- Flask, Nginx, and PostgreSQL pods already deployed and functional

**Status:** NO ACTUAL VERIFICATION. The scaffold builder did not check for the existence of Week 6 outputs because this is the Week 7 builder, working in isolation, not assuming the real output of Week 6.

**Implication:** If Week 6's actual deliverables differ from the stated prerequisites, students may not be able to complete Week 7 as written. The QA pass will verify this dependency chain.

---

### ASSUMPTION 2: Kubernetes Labels Are Already Set on Pods

**Text:** From Part 2 of the lab: "Allow policies reference pods with labels `app: flask`, `app: nginx`, and `app: postgres`."

**Assumption:** The scaffold assumes all application pods (Flask, Nginx, PostgreSQL) already have the required labels set in their Deployments or StatefulSets from Week 6.

**Specific Labels Required:**
- Flask pods: `app: flask`
- Nginx pods: `app: nginx`
- PostgreSQL pods: `app: postgres`

**Status:** NOT VERIFIED AGAINST WEEK 6 DELIVERABLES. The scaffold assumes these labels exist based on the lab directions, but does not verify that Week 6 actually set them.

**Implication:** If Week 6 did not set these labels (e.g., if pods use different label keys), the NetworkPolicies in Week 7 will not match any pods and traffic will remain blocked. The validation check for "Application Works After NetworkPolicy" will fail.

**TODO for QA Pass:** Confirm Week 6's Deployments include the label statements. If not, document this as a cross-week defect.

---

### ASSUMPTION 3: Flask Container Accepts read-only Root Filesystem

**Text:** From Part 3 Step 12: "Add SecurityContext with readOnlyRootFilesystem: true"

**Assumption:** The Flask application (provided by the professor in Week 2) can run with a read-only root filesystem without requiring writes to the filesystem beyond temporary directories.

**Rationale:** The lab directions state: "A common failure: the Flask app writes to a path that is now read-only. If this happens, add a writable emptyDir volume for that specific path." This indicates the lab directions anticipate potential failures.

**Status:** ASSUMPTION BASED ON LAB DIRECTIONS. The scaffold does not know whether the actual Flask application has filesystem write requirements.

**Implication:** If the Flask application requires writes to paths other than `/tmp` (e.g., logging to `/var/log`, caching to `/app/.cache`), students will need to identify and add emptyDir volumes. The lab directions provide guidance for this scenario, but the exact fix depends on the actual application code.

**Mitigation:** The lab includes troubleshooting steps for this exact scenario. Students are instructed to use `kubectl describe pod` to identify failures and add emptyDir volumes as needed.

---

### ASSUMPTION 4: Trivy Scanner Can Access GitHub Container Registry

**Text:** From Part 4 Step 15: "image-ref: 'ghcr.io/${{ github.repository }}/flask-app:latest'"

**Assumption:** The Trivy action can authenticate to and pull the Flask image from GitHub Container Registry (ghcr.io) after it is pushed by the `build-and-push` job.

**Status:** STANDARD GITHUB ACTIONS BEHAVIOR. The scaffold assumes GitHub Actions provides default GITHUB_TOKEN permissions that allow Trivy to access public images. If the team's repository is private or if image push failed, Trivy may not be able to pull the image.

**Implication:** If Trivy cannot access the image, the security-scan job will fail with an authentication error. The lab does not address private registry authentication, so this is out of scope for Week 7.

**Mitigation:** The lab assumes the team's registry is configured correctly from Week 6. If the push job passes, Trivy should be able to pull.

---

### ASSUMPTION 5: Namespace Is `default`

**Text:** All RBAC, NetworkPolicy, and SecurityContext manifests specify `namespace: default`.

**Assumption:** The student application is deployed in the Kubernetes `default` namespace and will remain there throughout Week 7.

**Status:** CONSISTENT WITH LAB DIRECTIONS FROM EARLIER WEEKS. The scaffold assumes the default namespace based on earlier week directions which do not mention custom namespaces.

**Implication:** If the application was deployed to a different namespace (e.g., `production` or `app`), the RBAC and NetworkPolicy manifests will not apply to those pods. Students will need to update the manifests manually.

**Mitigation:** The lab includes validation checks that verify policies are applied. If namespace is wrong, validation will fail.

---

### ASSUMPTION 6: Kubernetes CNI Plugin Supports NetworkPolicy

**Text:** From Part 2 background: "By default, all pods can communicate with all other pods in Kubernetes. A NetworkPolicy restricts which pods can send and receive traffic."

**Assumption:** The k3d cluster uses a CNI plugin that enforces NetworkPolicy (e.g., Cilium, Flannel with NetworkPolicy support, or Calico). Without a NetworkPolicy-aware CNI, the policies will not be enforced.

**Status:** NOT VERIFIED. The scaffold assumes k3d's default CNI is NetworkPolicy-aware, but this depends on k3d's configuration and version.

**Implication:** If the CNI does not support NetworkPolicy, the default-deny policy will not actually block traffic. The test in Step 8 (curl timeout) will not show a timeout; instead, the curl will succeed, indicating enforcement is not working. The lab includes a reflection question (extend question 5) asking students to verify enforcement, but does not provide a definitive test for this week.

**TODO for QA Pass:** Confirm k3d's CNI is NetworkPolicy-aware. If not, this is a blocking issue.

---

### ASSUMPTION 7: GitHub Actions Workflow File Exists and Has Existing Jobs

**Text:** From Part 4 Step 15: "Find the section that defines jobs (the `jobs:` block). Add a new job called `security-scan` after your existing `build-and-push` job."

**Assumption:** A `.github/workflows/ci.yml` file already exists from Week 6 with at least a `build-and-push` job.

**Status:** NOT VERIFIED. The scaffold assumes Week 6 created a CI workflow with a specific structure.

**Implication:** If the CI workflow does not exist or uses a different job structure, students will not be able to add the security-scan job as directed. They may need to create the workflow from scratch or modify the instructions.

**Mitigation:** Week 6's lab directions should define the CI workflow structure. The QA pass will verify this.

---

### ASSUMPTION 8: `exit-code: 1` Behavior in Trivy Action

**Text:** From Part 4 Step 15: "exit-code: '1'" in the Trivy action configuration.

**Assumption:** Setting `exit-code: '1'` in the Trivy action makes the job fail if CRITICAL vulnerabilities are found. The action version `aquasecurity/trivy-action@master` supports this configuration.

**Status:** BASED ON TRIVY ACTION DOCUMENTATION. The scaffold assumes the standard Trivy GitHub Action behavior.

**Implication:** If the action version or configuration format changes, the behavior may differ. Students may need to debug the action if it does not fail as expected.

**Mitigation:** The lab includes a monitoring step for students to review the pipeline. If the behavior is unexpected, they can view the GitHub Actions UI to understand what happened.

---

## Ambiguities Encountered

### AMBIGUITY 1: Which Paths Should Have Read-Only Filesystem Enforcement?

**Text:** From Part 3: "Add SecurityContext settings to the Flask Deployment... readOnlyRootFilesystem: true"

**Ambiguity:** The lab directions do not specify whether readOnlyRootFilesystem should apply only to the Flask container or to other containers as well (e.g., Nginx, PostgreSQL).

**Resolution in Scaffold:** The lab directions specifically show the SecurityContext being added to the Flask container only. The scaffold follows this and does not mention applying it to other containers.

**Implication:** Students may apply SecurityContext inconsistently across containers. The validation check only verifies Flask's settings, so other containers will not be checked.

**Note:** This is consistent with the principle of least privilege for the application tier, but may leave other components with more permissive security settings.

---

### AMBIGUITY 2: Should NetworkPolicy Apply to the Monitoring Namespace?

**Text:** From Part 0 Step 3: Students run `kubectl get pods -n monitoring` as part of the environment checkpoint.

**Ambiguity:** The lab mentions the monitoring namespace but does not specify whether NetworkPolicy rules should be applied there as well.

**Resolution in Scaffold:** The scaffold assumes all NetworkPolicy manifests should be limited to the `default` namespace only (as specified in each manifest). The monitoring namespace is observed but not subject to NetworkPolicy changes.

**Implication:** If monitoring pods (e.g., Prometheus scraping Flask) are in the monitoring namespace, they may not have permissions to communicate with the Flask pod in the default namespace. However, the lab does not mention monitoring scrapers communicating with application pods directly, so this is likely not an issue.

**TODO for QA Pass:** Verify whether monitoring and application are in the same namespace or separate namespaces, and whether cross-namespace pod-to-pod communication is required.

---

### AMBIGUITY 3: Trivy Scan Failure on Critical Vulnerabilities - What Happens Next?

**Text:** From Part 4 Step 17: "If Trivy finds vulnerabilities: 1. Click on the failed job to see the vulnerability details... 3. Push the change and let the pipeline run again."

**Ambiguity:** The lab does not specify how students should resolve vulnerabilities if they find them. Should they:
1. Update the base image (e.g., from `python:3.11` to `python:3.11-slim` or a patched version)?
2. Update Flask dependencies in requirements.txt?
3. Apply OS-level patches inside the container?

**Resolution in Scaffold:** The lab suggests updating the base image version as the primary approach. The scaffold does not provide step-by-step vulnerability remediation instructions beyond this general guidance.

**Implication:** If the current Flask image has critical vulnerabilities, students will need to determine the right remediation approach. This could take significant time and is not scripted.

**Mitigation:** This is a learning opportunity. Students will understand vulnerability scanning and remediation as part of the security hardening process. The lab allows time for this iteration.

---

### AMBIGUITY 4: Flask Deployment Already Updated or Starting Fresh?

**Text:** From Part 1 Step 4: "Update the Flask Deployment to use the new ServiceAccount. Add `serviceAccountName: flask-app` under `spec.template.spec`"

**Ambiguity:** The lab does not specify whether students are editing an existing Flask Deployment from Week 6 or creating a new one. The exact location and content of `manifests/flask-deployment.yaml` depends on Week 6's output.

**Resolution in Scaffold:** The scaffold assumes `manifests/flask-deployment.yaml` exists from Week 6 and needs to be updated in place. Students are instructed to open the file and add the serviceAccountName field.

**Implication:** If the Flask Deployment structure differs from what the lab expects (e.g., different indentation, embedded ConfigMap, or different container name), the update steps may fail or produce incorrect YAML.

**Mitigation:** The validation checks verify the final state (Flask using the custom ServiceAccount), not the intermediate steps. If the update is done incorrectly, validation will catch it.

---

### AMBIGUITY 5: When Should emptyDir Volumes Be Added?

**Text:** From Part 3 Step 14: "If pods fail to start, check the events... If this happens, add a writable emptyDir volume for that specific path."

**Ambiguity:** The lab provides guidance for troubleshooting but does not specify upfront which paths the Flask application will try to write to. Students discover this when the pod fails.

**Resolution in Scaffold:** The scaffold treats this as a debugging task. Students are instructed to use `kubectl describe pod` to identify the write path, then add an emptyDir volume accordingly.

**Implication:** This adds an iterative step to the lab. The pod must fail first before students know what to fix.

**Mitigation:** This is the intended learning process. Students understand the read-only filesystem constraint by encountering the failure and fixing it.

---

### AMBIGUITY 6: How Strict Should the SecurityContext Be?

**Text:** From Part 3: "capabilities: drop: ALL"

**Ambiguity:** The lab drops all Linux capabilities as a hardening best practice. However, if the Flask application requires any specific capability (e.g., NET_BIND_SERVICE to bind to ports below 1024), this will fail.

**Resolution in Scaffold:** The scaffold assumes Flask does not require any capabilities and follows the full-drop approach.

**Implication:** If Flask unexpectedly requires capabilities, the pod will fail to start. Students will need to add back specific capabilities.

**Mitigation:** The Flask application should run on port 5000 (above 1024) and not require capabilities. This is the expected application design.

---

## Cross-Week Dependencies

### Dependency on Week 6

**What Week 7 Needs from Week 6:**

1. GitHub Actions CI pipeline with a `build-and-push` job
2. Kubernetes Deployment for Flask with proper labels (`app: flask`)
3. Kubernetes Deployment for Nginx with proper labels (`app: nginx`)
4. Kubernetes Deployment for PostgreSQL with proper labels (`app: postgres`)
5. Application running and responding to requests

**How This Was Verified:**

The Week 7 scaffold was built against the stated prerequisites in the lab directions. The actual Week 6 output was not checked, following the instruction: "Do not read or assume the real output of any other week's agent."

**What Will Be Verified in QA Pass:**

The QA solver will verify that Week 6 actually produced all required artifacts. If any are missing or incorrectly labeled, the QA pass will document this as a defect and flag it for fixing in Week 6.

---

## Files and Directories Created

### Directory Structure

```
Student Repositories/week-07/
├── README.md
├── WEEK-7-LAB.md
├── docs/
│   ├── sprint-4-retrospective.md
│   ├── environment-log.md
│   ├── acceptance-criteria.md
│   └── qa-report-4.md
├── manifests/
│   └── .gitkeep
└── scripts/
    └── check-week7.sh
```

### File Descriptions

1. **README.md** - Overview and instructions for getting started with Week 7
2. **WEEK-7-LAB.md** - Full lab directions with detailed steps, TODOs, and reflection questions
3. **docs/sprint-4-retrospective.md** - Blank template for Scrum Master to fill with sprint reflections
4. **docs/environment-log.md** - Blank template for System Admin to document infrastructure state
5. **docs/acceptance-criteria.md** - Blank template for QA to define acceptance criteria before implementation
6. **docs/qa-report-4.md** - Blank template for QA to report validation results after implementation
7. **manifests/.gitkeep** - Placeholder to preserve the manifests directory in Git
8. **scripts/check-week7.sh** - Automated validation script that runs all checks

---

## Architecture Status Notice

Every file in the scaffold that is meant to be read by students (README.md, WEEK-7-LAB.md) includes the required notice:

> "This week's lab assumes your team container allows Docker containers to run in privileged mode (`--privileged` flag). This architecture has not been approved by the professor."

This notice is placed at the top of the README and repeated in the introduction where appropriate.

---

## Writing Style and Conventions

### Applied Rules from inet4031-course-rules

1. **No em dashes except in headers** - Verified throughout the scaffold. Used hyphens for clause separation instead.
2. **Plain, step-following language** - Scaffold assumes students have general technical background but no prior exposure to Kubernetes security controls. Instructions are numbered, concrete, and progress linearly.
3. **No Terraform, only OpenTofu** - Not applicable to Week 7 (OpenTofu is introduced later, if at all). Verified no Terraform references appear.
4. **Preserve lab patterns** - The scaffold preserves:
   - Sprint rhythm (review prior sprint, close it, snapshot environment, open next sprint)
   - Verification-before-deliverable ordering (validation checks precede deliverables checklist)
   - Storage-pruning sidebar (`df -h`, `docker system df` in storage check)
5. **Role-specific task distribution** - Verified that no single role can complete the lab solo:
   - Scrum Master: Leads sprint review, board management
   - System Admin: Leads environment documentation, infrastructure decisions
   - Developers: Implement RBAC, NetworkPolicy, SecurityContext, CI changes
   - QA: Writes acceptance criteria before implementation, runs validation checks

---

## Known Issues and Unresolved Questions

### Issue 1: EmptyDir Volume Path Unknown Until Pod Fails

**Status:** DOCUMENTED BUT UNRESOLVED

**Description:** The lab assumes Flask will fail if it needs to write to a read-only filesystem. The exact path is not known until the pod fails and students inspect logs.

**Severity:** Low - this is the intended debugging experience

**Resolution:** No change needed. Students follow the troubleshooting steps provided.

---

### Issue 2: CNI NetworkPolicy Support Not Verified

**Status:** UNVERIFIED

**Description:** The lab assumes k3d's CNI supports NetworkPolicy enforcement. This is not verified in the scaffold.

**Severity:** Medium - if CNI does not support NetworkPolicy, the entire Part 2 will fail silently

**Resolution:** QA pass should verify k3d CNI configuration.

---

### Issue 3: Trivy Vulnerability Remediation Steps Not Scripted

**Status:** UNRESOLVED

**Description:** If Trivy finds critical vulnerabilities, the lab provides guidance but not step-by-step fix instructions.

**Severity:** Low - this is expected to be rare; most base images are reasonably secure

**Resolution:** If this becomes a blocker, update the lab with common vulnerability fixes. For now, rely on student research and instructor guidance.

---

## Validation Checklist for QA Pass

When the QA solver processes Week 7, it should verify:

- [ ] Flask pods use the `app: flask` label (required for NetworkPolicy)
- [ ] Nginx pods use the `app: nginx` label (required for NetworkPolicy)
- [ ] PostgreSQL pods use the `app: postgres` label (required for NetworkPolicy)
- [ ] k3d CNI plugin is NetworkPolicy-aware
- [ ] `.github/workflows/ci.yml` exists with a `build-and-push` job
- [ ] All four role-artifact files are present and have correct structure
- [ ] Validation checks are accurate and match actual cluster state
- [ ] RBAC manifests follow Kubernetes v1 API conventions
- [ ] NetworkPolicy manifests use correct podSelector syntax
- [ ] SecurityContext settings do not break Flask application startup
- [ ] Trivy action syntax is correct for the chosen version

---

## Summary

The Week 7 Student Repository scaffold was built to guide students through:

1. Implementing least-privilege RBAC (ServiceAccount, Role, RoleBinding)
2. Restricting pod-to-pod communication with NetworkPolicy
3. Hardening container security with SecurityContext
4. Adding automated vulnerability scanning to the CI pipeline

The scaffold includes:

- Clear, step-by-step lab directions with embedded reflection questions
- Four role-specific artifact templates for team collaboration
- Automated validation checks and a shell script runner
- Architecture status notice about unconfirmed privileged mode
- Comprehensive logging of assumptions and ambiguities

All assumptions have been explicitly documented in this build log. The QA pass will verify dependencies on Week 6 and identify any defects or ambiguities that need resolution.

---

**End of Build Log**
