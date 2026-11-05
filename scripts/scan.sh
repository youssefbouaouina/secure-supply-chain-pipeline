#!/usr/bin/env bash
# Measure v1 vs v2: SBOMs, CVEs, image size and policy violations.
# Runs after both images have been built as app:v1 and app:v2.
set -euo pipefail
mkdir -p results

for v in v1 v2; do
  echo "== app:$v =="
  syft "app:$v" -o spdx-json > "results/sbom-$v.spdx.json"
  syft "app:$v" -o cyclonedx-json > "results/sbom-$v.cdx.json"
  grype "app:$v" -o json > "results/grype-$v.json"
  docker image inspect "app:$v" --format '{{.Size}}' > "results/size-$v.txt"
done

conftest test k8s/deployment-v1.yaml --policy policy --output json > results/conftest-v1.json || true
conftest test k8s/deployment-v2.yaml --policy policy --output json > results/conftest-v2.json || true
kube-linter lint k8s/deployment-v1.yaml --format json > results/kubelinter-v1.json || true
kube-linter lint k8s/deployment-v2.yaml --format json > results/kubelinter-v2.json || true

python scripts/summarize.py

# Quality gate: the hardened image must not contain a Critical vulnerability.
grype "app:v2" --fail-on critical
echo "gate passed: no Critical CVE in app:v2"
