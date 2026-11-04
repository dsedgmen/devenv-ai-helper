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

Point the COPR package webhook at this GitHub repo.

- Builds of **`main`** → install as beta (webhook on push to main).
- Builds of **tags** `v*` → stable/rc packages.
- Optional: also watch **`release/**`** for RC snapshots.

The webhook invokes `.copr/Makefile` → `srpm`, which runs
`scripts/rpm-version.sh` and passes macros into `rpmbuild`.

Suggested COPR layout:

- Project `vim-ai-helper` — webhook for tags only (stable), **or**
- Project `vim-ai-helper` with package packing all refs, and users pin
  `dnf copr enable …` knowing `main` produces `.beta` Release strings.

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
