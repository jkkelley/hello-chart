#!/usr/bin/env bash
set -eou pipefail

CHART="."
RELEASE="hello"
NAMESPACE="default"
CLEANUP_AFTER=false   # set true with --cleanup
KEEP_ON_ERROR=false   # set true with --keep-on-error

usage() {
  cat <<EOF

Usage: $(basename "$0") [options]

    Options:
    -n, --namespace <ns>   Kubernetes namespace (default: default)
    -r, --release <name>   Helm release name (default: hello)
    -c, --cleanup          Uninstall after successful run
    -k, --keep-on-error    Do NOT clean up if the script fails
    -h, --help             Show this help

EOF
}

# ---- parse args ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--namespace) NAMESPACE="$2"; shift 2;;
    -r|--release)   RELEASE="$2";   shift 2;;
    -c|--cleanup)   CLEANUP_AFTER=true; shift;;
    -k|--keep-on-error) KEEP_ON_ERROR=true; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown option: $1"; usage; exit 1;;
  esac
done

# ---- helpers ----
cleanup() {
  echo -e "\n🧹 Cleaning up release '$RELEASE' in ns '$NAMESPACE'...\n"
  helm uninstall "$RELEASE" -n "$NAMESPACE" 2>/dev/null | sed 's/^/\t/' || true
  kubectl delete svc/"$RELEASE" deploy/"$RELEASE" -n "$NAMESPACE" --ignore-not-found
}

on_error() {
  echo -e "\n❌ Error occurred."
  if [[ "$KEEP_ON_ERROR" == "true" ]]; then
    echo "Keeping resources for debugging."
  else
    cleanup
  fi
}

trap on_error ERR INT

echo ""
echo -e "🔍 Linting Helm chart...\n"
helm lint $CHART | sed 's/^/\t/'
echo ""

echo -e "🧰 Rendering template...\n"
helm template $RELEASE $CHART | grep -E "kind:|metadata:|image:" | sed 's/^/\t/' || true
echo ""

echo -e "🧼 Cleaning previous release (if any)...\n"
helm uninstall $RELEASE -n $NAMESPACE 2>/dev/null | sed 's/^/\t/' || true
kubectl delete svc/$RELEASE deploy/$RELEASE -n $NAMESPACE --ignore-not-found
echo ""

echo -e "🚀 Installing Helm chart...\n"
helm install $RELEASE $CHART -n $NAMESPACE | sed 's/^/\t/'
echo ""

echo -e "⏳ Waiting for deployment...\n"
kubectl rollout status deployment/$RELEASE -n $NAMESPACE | sed 's/^/\t/'
echo ""

echo -e "✅ Resources:\n"
kubectl get all -l app=$RELEASE -n $NAMESPACE | sed 's/^/\t/'
echo ""

# Optional post-run cleanup
if [[ "$CLEANUP_AFTER" == "true" ]]; then
  cleanup
  echo -e "\n✅ Done. Resources were created, verified, and removed.\n"
else
  echo -e "\nℹ️ Done. Resources are left running. Use --cleanup to auto-remove, or run this to clean manually:\n"
  echo -e "\thelm uninstall $RELEASE -n $NAMESPACE"
  echo -e "\tkubectl delete svc/$RELEASE deploy/$RELEASE -n $NAMESPACE --ignore-not-found"
fi