# PLAN — secure-supply-chain-pipeline

## Goal
One pipeline that produces and verifies a software supply chain for a small Spring Boot service,
and measures the effect of container hardening (v1 unhardened vs v2 hardened).

## Pipeline
1. Maven build + unit tests.
2. SBOM in SPDX and CycloneDX with Syft.
3. Vulnerability scan with Grype; the gate fails on Critical for the hardened image.
4. Build and push the hardened image to GHCR.
5. Keyless signature with cosign (Sigstore OIDC).
6. SLSA build provenance with `actions/attest-build-provenance`.
7. Policy-as-code with Conftest/OPA on the Kubernetes manifests.
8. kube-linter on the same manifests.
9. Verification commands are run and their real output is saved.

## Experiment
- `Dockerfile.v1`: single stage, full JDK base image, root user.
- `Dockerfile`: multi-stage, JRE Alpine base pinned by digest, non-root user, healthcheck.
- Same application jar in both.
- Metrics: unique CVEs by severity, image size, SBOM package count, Conftest failures,
  kube-linter findings, and whether the Critical gate passes.

## Ground truth
This project does not evaluate detections, so the "ground truth first" rule does not apply.
The equivalent is that both manifests and the policy are committed before the scan, and the
scan output is machine-generated (`results/metrics.json`), never hand-written.

## Time box
2-3 hours. Local machine has no Docker or Java; the experiment runs on GitHub Actions and the
results artifact is committed back.
