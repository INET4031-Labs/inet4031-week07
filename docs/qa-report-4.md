# QA Report - Sprint 4

**Quality Assurance:** [TODO: Fill in name]

**Report Date:** [TODO: Date]

**Sprint:** Sprint 4 (Weeks 7-8)

---

## Check Script Results

### Command Executed

```bash
./scripts/check-week7.sh
```

**Exit Status:** [TODO: Fill in exit code - should be 0 for pass]

**Output:**

```
[TODO: Paste full check script output]
```

---

## Validation Checks - Detailed Results

### Flask Uses Custom ServiceAccount

**Command:**
```bash
kubectl get pod -l app=flask -o jsonpath='{.items[0].spec.serviceAccountName}'
```

**Expected Output:** `flask-app`

**Actual Output:** [TODO: Fill in actual result]

**Status:** [TODO: PASS or FAIL]

---

### NetworkPolicy Applied

**Command:**
```bash
kubectl get networkpolicy
```

**Expected Output:** Rows for `default-deny-ingress`, `allow-nginx-to-flask`, `allow-flask-to-postgres`

**Actual Output:**

```
[TODO: Paste output]
```

**Status:** [TODO: PASS or FAIL]

---

### Application Works After NetworkPolicy

**Command:**
```bash
curl -s http://localhost:8080/incidents
```

**Expected Output:** Valid JSON response

**Actual Output:** [TODO: Paste response]

**Status:** [TODO: PASS or FAIL]

---

### SecurityContext Is Set

**Command:**
```bash
kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}'
```

**Expected Output:** `false`

**Actual Output:** [TODO: Fill in actual result]

**Status:** [TODO: PASS or FAIL]

---

## Acceptance Criteria Coverage

| Criterion | Status | Notes |
|-----------|--------|-------|
| RBAC ServiceAccount configured | [TODO] | |
| Role and RoleBinding created | [TODO] | |
| NetworkPolicy default-deny applied | [TODO] | |
| NetworkPolicy allow-nginx-to-flask applied | [TODO] | |
| NetworkPolicy allow-flask-to-postgres applied | [TODO] | |
| SecurityContext settings enforced | [TODO] | |
| Trivy scanning added to CI | [TODO] | |
| Application functional end-to-end | [TODO] | |

---

## Issues Found and Rework Required

### Issue 1

**Description:** [TODO: Describe any issue found]

**Severity:** [TODO: Critical / High / Medium / Low]

**Root Cause:** [TODO: Explain why it occurred]

**Resolution:** [TODO: What was done to fix it]

**Rework Cycle:** [TODO: How many iterations to resolve]

---

### Issue 2

[TODO: Add additional issues if found]

---

## Summary

**Total Validation Checks:** 4

**Passed:** [TODO: Count]

**Failed:** [TODO: Count]

**Rework Cycles Required:** [TODO: Count]

**Overall Assessment:** [TODO: APPROVED FOR DELIVERY or REQUIRES ADDITIONAL WORK]

---

## Appendix: Screenshots

### Screenshot 1: Default Deny Test Pod Timeout

[TODO: Paste or reference screenshot of connection timeout]

### Screenshot 2: Application After Allow Policies

[TODO: Paste or reference screenshot of successful curl response]

### Screenshot 3: Trivy Scan in GitHub Actions

[TODO: Paste or reference screenshot of scan job passing/results]

### Screenshot 4: Check Script Passing

[TODO: Paste or reference screenshot of check-week7.sh output]
