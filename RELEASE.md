# Release & version framework

Used by GitHub Actions, Packit, and **COPR webhooks** (`.copr/Makefile`).

## Channels

| Git ref | Channel | RPM `Version`-`Release` example |
|---------|---------|----------------------------------|
| Branch **`main`** | **beta** | `1.1.0-0.20261104gitabcdef.beta` |
| Branch **`release/*`** or **`release-*`** | **rc** | `1.1.0-0.20261104gitabcdef.rc` |
| Tag **`v1.2.3`** | **stable** | `1.2.3-1` |
| Tag **`v1.2.3-rc.1`** | **rc** | `1.2.3-0.1.rc1gitabcdef` |

Base `X.Y.Z` for beta/rc snapshots comes from the [`VERSION`](VERSION) file
(next intended stable). Update `VERSION` when you start work toward a new release.

Pre-stable sorts before stable in DNF (`0.*.beta` / `0.*.rc` < `1`).

## COPR webhook

Point the **project** webhook (Settings → Integrations) at this GitHub repo.
There is no per-package webhook URL; with one package that is fine.

### Package settings (required for beta)

In the COPR package edit form:

| Field | Value |
|-------|--------|
| Source type | **SCM** |
| Clone URL | `https://github.com/dsedgmen/vim-ai-helper.git` |
| Committish | `main` (or leave empty for webhook tip) |
| Spec File | `vim-ai-helper.spec` |
| SRPM build method | **make_srpm** (uses `.copr/Makefile`) |
| Auto-rebuild | **on** |

If the method is **rpkg** / **tito** / “upload SRPM”, COPR uses the raw
spec defaults → **`1.1.0-1`** (not beta). Beta only happens when
`make_srpm` runs and passes `--define vim_ai_ver` / `vim_ai_rel`.

- Push to **`main`** → `1.1.0-0.<date>git<sha>.beta`
- Tags **`vX.Y.Z`** → `X.Y.Z-1` (stable)
- Tags **`vX.Y.Z-rc.N`** / `release/*` → RC Release strings

Suggested layout: one project packing all refs; users enable the COPR
knowing `main` publishes `.beta` packages.

## GitHub Actions

| Workflow | Trigger | Output |
|----------|---------|--------|
| `rpm.yml` | `main`, `release/**`, PRs | Artifact RPMs labeled by channel |
| `release.yml` | tags `v*` | GitHub Release + stable/rc RPMs attached |
| `security.yml` | push/PR | Bandit / compile / route smoke |

## How to cut a release

1. Ensure `VERSION` matches the release you will tag (e.g. `1.2.0`).
2. Merge to `main` (continues publishing **beta** builds).
3. Optional RC: tag `v1.2.0-rc.1` or push `release/1.2`.
4. Stable: `git tag -a v1.2.0 -m "vim-ai-helper 1.2.0" && git push origin v1.2.0`
5. Bump `VERSION` on `main` to the next patch/minor (e.g. `1.2.1` or `1.3.0`) so betas stay ahead of the just-released tag.

## Local version check

```bash
./scripts/rpm-version.sh
./scripts/rpm-version.sh --shell
```
