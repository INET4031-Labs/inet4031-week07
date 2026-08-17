# Sprint 4 Acceptance Criteria

**Quality Assurance:** [TODO: Fill in name]

**Written:** [TODO: Date] (must be completed before implementation begins)

---

## RBAC Implementation

### ServiceAccount Criteria

[TODO: Define what "correct" ServiceAccount configuration looks like]

- [ ] Flask uses a custom ServiceAccount named `flask-app`
- [ ] ServiceAccount has `automountServiceAccountToken: false`
- [ ] Token is not mounted in the Flask pod

### Role and RoleBinding Criteria

[TODO: Define minimum permissions the Role should grant]

- [ ] A Role named `flask-reader` exists with limited permissions
- [ ] RoleBinding connects the ServiceAccount to the Role
- [ ] Flask pod can read configmaps but cannot perform other actions

---

## NetworkPolicy Implementation

### Default Deny Policy Criteria

[TODO: Verify the default-deny policy blocks all ingress]

- [ ] Default-deny policy is applied
- [ ] Traffic from external pods is blocked (test pod connection times out)
- [ ] Kubernetes API calls to verify policy state succeed

### Allow Policies Criteria

[TODO: Verify communication paths are precisely defined]

- [ ] Allow policy for Nginx-to-Flask exists on port 5000
- [ ] Allow policy for Flask-to-Postgres exists on port 5432
- [ ] Application responds end-to-end after policies applied
- [ ] No unnecessary communication paths are permitted

---

## SecurityContext Implementation

### Container Security Criteria

[TODO: Verify container cannot escalate privileges or write to filesystem]

- [ ] Flask container runs as non-root user (runAsUser: 1000)
- [ ] Privilege escalation is disabled
- [ ] Root filesystem is read-only
- [ ] All Linux capabilities are dropped (DROP: ALL)
- [ ] Any required writable paths use emptyDir volumes

### Deployment Health Criteria

- [ ] Flask pods restart successfully with new SecurityContext
- [ ] Pods reach Running and Ready state
- [ ] Application remains functional

---

## Image Vulnerability Scanning in CI

### Trivy Integration Criteria

[TODO: Verify scanning is added to the pipeline]

- [ ] `.github/workflows/ci.yml` includes a security-scan job
- [ ] Trivy scans the Flask image after build
- [ ] Scan runs on every push (not just PRs)
- [ ] Critical vulnerabilities cause the pipeline to fail
- [ ] Scan results are visible in GitHub Actions UI

---

## Cross-Check (QA Signs Off Before Deliverables Claimed)

- [ ] All RBAC manifests follow Kubernetes API version and naming conventions
- [ ] All NetworkPolicy manifests use correct podSelector and port syntax
- [ ] SecurityContext applies to all containers running untrusted code
- [ ] CI pipeline update does not break existing functionality
- [ ] All validation checks pass without manual intervention
- [ ] Check script `./scripts/check-week7.sh` exits with status 0

---

## Notes

[TODO: Add any clarifications or edge cases the team should be aware of]
