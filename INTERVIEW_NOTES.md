# Interview notes — secure-supply-chain-pipeline

## What this project demonstrates

- Running a full supply-chain chain in CI: build, two container variants, Syft SBOM, Grype,
  Conftest, kube-linter, GHCR push, keyless cosign signature, SLSA provenance and
  `gh attestation verify` — with the verification output committed.
- Measuring a hardening change instead of asserting it: 477.2 MiB/430 findings down to
  221.0 MiB/86 findings, and the policy-failure count from 8 to 0.
- Reading a result honestly. The High count went **up** because the Alpine base brings
  `sqlite-libs` and `libexpat`; the README says so instead of quoting only the total.
- Choosing a gate that can be enforced: `--only-fixed` fails on a Critical with a fix and keeps
  two upstream-unfixed `spring-webmvc` advisories visible without a permanently red pipeline.

## Questions I expect

**Why is the image smaller but the High count higher?**
The application is the same in both images; the base changed. `eclipse-temurin:21-jdk` carries
more packages but fewer High-severity matches in this database snapshot, while Alpine's
`sqlite-libs` and `libexpat` add eight. Size and CVE count are different axes, and the table
shows both. The follow-up would be to pick the base by findings, not by MB alone.

**What exactly does the signature prove?**
That the image digest was signed by this workflow's identity through GitHub's OIDC issuer. It
does not prove the code is safe. `results/cosign_verify.json` and
`results/attestation_verify.txt` are the real outputs, not a screenshot.

**How do you keep the SBOM out of git without losing the evidence?**
The raw SPDX document is ~6 MB and changes every build, so it is uploaded as the
`supply-chain-results` workflow artifact. The package counts and the raw Grype/Conftest/
kube-linter JSON are committed, so each README number can be traced.

**What would you add for a real service?**
A dependency-track or OSV continuous scan (the current scan is build-time), admission control
that consumes the signature (Kyverno/Connaisseur), and a rebuild policy when the vulnerability
database changes — the current image is only as fresh as its last build.

**What broke during the work?**
Signing needs `id-token: write` and the image must be pushed before cosign can sign the digest;
`gh attestation verify` needs the exact repository and `oci://` prefix. Both are pinned in the
workflow so the next person does not rediscover them.
