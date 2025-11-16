#!/bin/bash
set -e

echo "======================================================================"
echo "RUNNING ALL TESTS FOR MONITORING STACK"
echo "======================================================================"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."

echo "Running Kubernetes manifest tests..."
echo "----------------------------------------------------------------------"
python3 tests/kubernetes/monitoring/test_monitoring_stack.py
KUBE_RESULT=$?

echo ""
echo ""
echo "Running documentation tests..."
echo "----------------------------------------------------------------------"
python3 tests/documentation/test_markdown_documentation.py
DOC_RESULT=$?

echo ""
echo ""
echo "======================================================================"
echo "OVERALL TEST RESULTS"
echo "======================================================================"

if [ $KUBE_RESULT -eq 0 ] && [ $DOC_RESULT -eq 0 ]; then
    echo "✅ ALL TESTS PASSED!"
    exit 0
else
    echo "❌ SOME TESTS FAILED"
    [ $KUBE_RESULT -ne 0 ] && echo "  - Kubernetes manifest tests: FAILED"
    [ $DOC_RESULT -ne 0 ] && echo "  - Documentation tests: FAILED"
    exit 1
fi