#!/bin/bash

# Week 7 Validation Check Script
# Runs all required validation checks for security hardening deliverables

set -e

echo "==================================================="
echo "Week 7 Validation Checks"
echo "==================================================="
echo ""

PASS_COUNT=0
FAIL_COUNT=0

# Check 1: Flask Uses Custom ServiceAccount
echo "[1/4] Checking Flask ServiceAccount..."
SERVICE_ACCOUNT=$(kubectl get pod -l app=flask -o jsonpath='{.items[0].spec.serviceAccountName}' 2>/dev/null || echo "ERROR")

if [ "$SERVICE_ACCOUNT" = "flask-app" ]; then
    echo "  PASS: Flask pod uses 'flask-app' ServiceAccount"
    ((PASS_COUNT++))
else
    echo "  FAIL: Flask ServiceAccount is '$SERVICE_ACCOUNT', expected 'flask-app'"
    ((FAIL_COUNT++))
fi
echo ""

# Check 2: NetworkPolicy Applied
echo "[2/4] Checking NetworkPolicy resources..."
POLICIES=$(kubectl get networkpolicy --no-headers 2>/dev/null | wc -l)
HAS_DEFAULT_DENY=$(kubectl get networkpolicy default-deny-ingress 2>/dev/null && echo "yes" || echo "no")
HAS_ALLOW_NGINX=$(kubectl get networkpolicy allow-nginx-to-flask 2>/dev/null && echo "yes" || echo "no")
HAS_ALLOW_POSTGRES=$(kubectl get networkpolicy allow-flask-to-postgres 2>/dev/null && echo "yes" || echo "no")

if [ "$HAS_DEFAULT_DENY" = "yes" ] && [ "$HAS_ALLOW_NGINX" = "yes" ] && [ "$HAS_ALLOW_POSTGRES" = "yes" ]; then
    echo "  PASS: All three required NetworkPolicies are present"
    ((PASS_COUNT++))
else
    echo "  FAIL: Missing NetworkPolicies"
    echo "    - default-deny-ingress: $HAS_DEFAULT_DENY"
    echo "    - allow-nginx-to-flask: $HAS_ALLOW_NGINX"
    echo "    - allow-flask-to-postgres: $HAS_ALLOW_POSTGRES"
    ((FAIL_COUNT++))
fi
echo ""

# Check 3: Application Works After NetworkPolicy
echo "[3/4] Checking application connectivity..."
RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/response.json http://localhost:8080/incidents 2>/dev/null || echo "000")
HTTP_CODE="${RESPONSE: -3}"

if [ "$HTTP_CODE" = "200" ]; then
    CONTENT=$(cat /tmp/response.json)
    if [[ "$CONTENT" == *"incidents"* ]] || [[ "$CONTENT" == "{}" ]] || [[ "$CONTENT" == "[]" ]]; then
        echo "  PASS: Application responds with valid JSON (HTTP $HTTP_CODE)"
        ((PASS_COUNT++))
    else
        echo "  FAIL: Application returned invalid JSON"
        echo "    Response: $CONTENT"
        ((FAIL_COUNT++))
    fi
else
    echo "  FAIL: Application did not respond (HTTP $HTTP_CODE)"
    ((FAIL_COUNT++))
fi
echo ""

# Check 4: SecurityContext Is Set
echo "[4/4] Checking SecurityContext settings..."
ALLOW_PRIV=$(kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}' 2>/dev/null || echo "NOTSET")
READ_ONLY=$(kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem}' 2>/dev/null || echo "NOTSET")
RUN_NON_ROOT=$(kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.runAsNonRoot}' 2>/dev/null || echo "NOTSET")
RUN_AS_USER=$(kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.runAsUser}' 2>/dev/null || echo "NOTSET")

if [ "$ALLOW_PRIV" = "false" ]; then
    echo "  PASS: allowPrivilegeEscalation is false"
    ((PASS_COUNT++))
else
    echo "  FAIL: allowPrivilegeEscalation is '$ALLOW_PRIV', expected 'false'"
    ((FAIL_COUNT++))
fi
echo ""

echo "==================================================="
echo "Results Summary"
echo "==================================================="
echo "Passed: $PASS_COUNT/4"
echo "Failed: $FAIL_COUNT/4"

if [ $FAIL_COUNT -eq 0 ]; then
    echo ""
    echo "All checks passed!"
    exit 0
else
    echo ""
    echo "Some checks failed. Review the output above and fix the issues."
    exit 1
fi
