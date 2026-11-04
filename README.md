# devenv-ai-helper

[![RPM](https://github.com/dsedgmen/devenv-ai-helper/actions/workflows/rpm.yml/badge.svg)](https://github.com/dsedgmen/devenv-ai-helper/actions/workflows/rpm.yml)
[![Security](https://github.com/dsedgmen/devenv-ai-helper/actions/workflows/security.yml/badge.svg)](https://github.com/dsedgmen/devenv-ai-helper/actions/workflows/security.yml)
[![Release](https://github.com/dsedgmen/devenv-ai-helper/actions/workflows/release.yml/badge.svg)](https://github.com/dsedgmen/devenv-ai-helper/actions/workflows/release.yml)
[![COPR](https://copr.fedorainfracloud.org/coprs/dsedgmen/Devenv/package/devenv-ai-helper/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/dsedgmen/Devenv/package/devenv-ai-helper/)
[![GitHub release](https://img.shields.io/github/v/release/dsedgmen/devenv-ai-helper?include_prereleases)](https://github.com/dsedgmen/devenv-ai-helper/releases)

CLI AI backend for Vim/Neovim with **agent routing** and configurable API endpoints.

Standalone project (extracted from [devenv-ai-assistant](https://github.com/dsedgmen/devenv-ai-assistant)) so it can be packaged as a Fedora RPM and built on COPR.

## Features

- Backends: **Ollama**, **Claude**, **Gemini**, **OpenAI-compatible** (internal gateways)
- Configurable `base_url` for corporate / internal APIs
- **Agent routing** — pick different backends/models per command
- Fedora deps only: `python3-openai`, `python3-ollama` (+ optional `python3-google-genai`)


Legacy names: `VIM_AI_*` env vars and a `vim-ai-helper` binary symlink are still
accepted during the rename from `vim-ai-helper`. Prefer `DEVENV_AI_*` and
`devenv-ai-helper`.

## Install

### From source

```bash
sudo install -m 0755 devenv-ai-helper /usr/local/bin/devenv-ai-helper
# or: cp devenv-ai-helper ~/.local/bin/ && chmod +x ~/.local/bin/devenv-ai-helper
sudo dnf install -y python3-openai python3-ollama
```

### Build RPM locally

```bash
VERSION=$(rpmspec -q --qf '%{version}\n' devenv-ai-helper.spec | head -1)
tar czf /tmp/devenv-ai-helper-${VERSION}.tar.gz \
  --transform "s,^,devenv-ai-helper-${VERSION}/," \
  devenv-ai-helper agents.json.example README.md LICENSE devenv-ai-helper.spec
rpmbuild -ba devenv-ai-helper.spec --define "_sourcedir /tmp"
sudo dnf install ~/rpmbuild/RPMS/noarch/devenv-ai-helper-*.rpm
```

### COPR / Packit

This repo includes `.packit.yaml` and `.copr/Makefile` for Fedora COPR builds.
Point a **COPR webhook** at the GitHub repo (builds use `.copr/Makefile`).

Versioning: **`main` = beta**, tags **`vX.Y.Z` = stable**, **`vX.Y.Z-rc.N`** /
`release/*` branches = RC. Details in **[RELEASE.md](RELEASE.md)**.

## Agent routing

```bash
# List agents and routes
devenv-ai-helper agents

# Show which agent handles a command
devenv-ai-helper route review

# Force an agent for one call
devenv-ai-helper --agent local complete ./file.py python
devenv-ai-helper --agent internal chat "Explain this service mesh"
```

Config file (first found wins):

1. `$DEVENV_AI_AGENTS_FILE`
2. `~/.config/devenv-ai-helper/agents.json`
3. `/etc/devenv-ai-helper/agents.json`

See [agents.json.example](agents.json.example).

Env overrides:

| Variable | Purpose |
|----------|---------|
| `DEVENV_AI_AGENT` | Default agent for all commands |
| `DEVENV_AI_ROUTE_COMPLETE` | Route `complete` → agent name |
| `DEVENV_AI_ROUTE_REVIEW` | Route `review` → agent name |
| `DEVENV_AI_DEBUG_ROUTE=1` | Print route to stderr |

Default routes: completion/generate → `local` (Ollama); explain/review/refactor/chat → `claude`.

## Internal API

```bash
export DEVENV_AI_BACKEND=openai
export DEVENV_AI_BASE_URL=https://llm.internal.example/v1
export DEVENV_AI_API_KEY=your-token
export DEVENV_AI_MODEL=corp-model

# Or keep Claude semantics with a proxy:
export DEVENV_AI_BACKEND=claude
export DEVENV_AI_CLAUDE_BASE_URL=https://llm.internal.example/anthropic/v1
```

## CI

GitHub Actions:

- **Security** — Bandit, pip-audit (advisory), Python compile, route smoke tests
- **RPM** — `rpmbuild` inside a Fedora container; artifacts uploaded

## Releases

| Ref | Channel |
|-----|---------|
| `main` | beta |
| `release/*` | rc |
| tag `v1.2.3` | stable |
| tag `v1.2.3-rc.1` | rc |

```bash
./scripts/rpm-version.sh    # show Version/Release for current ref
```

Full process: **[RELEASE.md](RELEASE.md)**.

## Consumers

| Project | Role |
|---------|------|
| [devenv-ai-assistant](https://github.com/dsedgmen/devenv-ai-assistant) | Vim/Neovim configs that invoke this CLI |
| [devenv-ai-packaging](https://github.com/dsedgmen/devenv-ai-packaging) | Container/Flatpak builds (stages this binary) |
| [devenv](https://github.com/dsedgmen/devenv) | Stages helper into images/VMs |

## Contributing / coding agents

See **[AGENTS.md](AGENTS.md)** for how automated coding agents and humans should
modify this project (Fedora packaging rules, CLI stability, no prompt/secret
commits, verification checklist).

## License

MIT
