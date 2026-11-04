# Release & version framework

Used by GitHub Actions, Packit, and **COPR webhooks** (`.copr/Makefile`).

## Channels

| Git ref | Channel | RPM `Version`-`Release` example |
|---------|---------|----------------------------------|
| Branch **`main`** | **beta** | `1.1.0-0.20261104gitabcdef.beta` |
| Branch **`release/*`** or **`release-*`** | **rc** | `1.1.0-0.20261104gitabcdef.rc` |
| Tag **`v1.2.3`** or **`1.2.3`** | **stable** | `1.2.3-1` |
| Tag **`v1.2.3-rc.1`** or **`1.2.3-rc.1`** | **rc** | `1.2.3-0.1.rc1gitabcdef` |

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
| Clone URL | `https://github.com/dsedgmen/devenv-ai-helper.git` |
| Committish | `main` (or leave empty for webhook tip) |
| Spec File | `devenv-ai-helper.spec` |
| SRPM build method | **make_srpm** (uses `.copr/Makefile`) |
| Auto-rebuild | **on** |

If the method is **rpkg** / **tito** / “upload SRPM”, COPR uses the raw
spec defaults → **`1.1.0-1`** (not beta).

`make_srpm` **bakes** `Version` / `Release` into the spec inside the SRPM.
COPR’s binary rebuild does not re-apply our macros; an unbaked
`%{!?devenv_ai_rel:1}` spec becomes **`1.1.0-1`** even when the SRPM
filename still ends in `.beta`.

- Push to **`main`** → `1.1.0-0.<date>git<sha>.beta`
- Tags **`vX.Y.Z`** or **`X.Y.Z`** → `X.Y.Z-1` (stable)
- Tags **`…-rc.N`** / `release/*` → RC Release strings

A tag points at a **commit**. COPR builds that commit’s tree — so the tag must
sit on a revision that already includes the current `.copr/Makefile`. After
fixing packaging, move/recreate the tag onto the fixed commit before rebuilding.

Suggested layout: one project packing all refs; users enable the COPR
knowing `main` publishes `.beta` packages.

## GitHub Actions

| Workflow | Trigger | Output |
|----------|---------|--------|
| `rpm.yml` | `main`, `release/**`, PRs | Artifact RPMs labeled by channel |
| `release.yml` | version tags (see below) | **GitHub Release** + RPM assets |
| `security.yml` | push/PR | Bandit / compile / route smoke |

### Automating GitHub Releases

Nothing extra to enable: [`.github/workflows/release.yml`](.github/workflows/release.yml)
runs on tag push (and can be run manually via **Actions → Release → Run workflow**).

On a matching tag it will:

1. Resolve channel via `scripts/rpm-version.sh` (`stable` or `rc` only).
2. Build binary + source RPMs in a Fedora container.
3. Create a GitHub Release named `devenv-ai-helper <version>`, attach the RPMs,
   and mark **pre-release** when the channel is `rc`.

Tag patterns that trigger it:

- `v1.2.3` / `1.2.3` → stable release  
- `v1.2.3-rc.1` / `1.2.3-rc.1` → pre-release  

Uses the default `GITHUB_TOKEN` (`permissions: contents: write`). No secrets to add
unless the repo blocks workflow runs on tags.

COPR is separate: the same tag push can also hit the COPR webhook if configured.

## How to cut a release

```bash
# 1. main is green; VERSION file = the version you are about to ship
git checkout main && git pull
echo 1.2.0 > VERSION   # if not already
git add VERSION && git commit -m "Set VERSION 1.2.0" && git push

# 2. Tag the commit you want shipped (must include current packaging)
git tag -a 1.2.0 -m "devenv-ai-helper 1.2.0"
git push origin 1.2.0
# → Actions "Release" workflow creates the GitHub Release + RPM assets
# → COPR rebuilds if the project webhook is set

# 3. Bump baseline for following betas
echo 1.2.1 > VERSION
git add VERSION && git commit -m "Bump VERSION to 1.2.1" && git push
```

Re-run without a new tag: **Actions → Release → Run workflow** (optional dry-run
builds RPMs only). To refresh an existing tag’s release, delete/move the tag onto
the fixed commit and `git push origin <tag>` again (force-push tag if it moved).

## Local version check

```bash
./scripts/rpm-version.sh
./scripts/rpm-version.sh --shell
```
