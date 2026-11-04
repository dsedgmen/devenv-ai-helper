# vim-ai-helper

[![RPM](https://github.com/dsedgmen/vim-ai-helper/actions/workflows/rpm.yml/badge.svg)](https://github.com/dsedgmen/vim-ai-helper/actions/workflows/rpm.yml)
[![Security](https://github.com/dsedgmen/vim-ai-helper/actions/workflows/security.yml/badge.svg)](https://github.com/dsedgmen/vim-ai-helper/actions/workflows/security.yml)
[![Release](https://github.com/dsedgmen/vim-ai-helper/actions/workflows/release.yml/badge.svg)](https://github.com/dsedgmen/vim-ai-helper/actions/workflows/release.yml)
[![COPR](https://copr.fedorainfracloud.org/coprs/dsedgmen/Devenv/package/vim-ai-helper/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/dsedgmen/Devenv/package/vim-ai-helper/)
[![GitHub release](https://img.shields.io/github/v/release/dsedgmen/vim-ai-helper?include_prereleases)](https://github.com/dsedgmen/vim-ai-helper/releases)

CLI AI backend for Vim/Neovim with **agent routing** and configurable API endpoints.

Standalone project (extracted from [vim-ai-assistant](https://github.com/dsedgmen/vim-ai-assistant)) so it can be packaged as a Fedora RPM and built on COPR.

## Features

- Backends: **Ollama**, **Claude**, **Gemini**, **OpenAI-compatible** (internal gateways)
- Configurable `base_url` for corporate / internal APIs
- **Agent routing** — pick different backends/models per command
- Fedora deps only: `python3-openai`, `python3-ollama` (+ optional `python3-google-genai`)

## Install

### From source

```bash
sudo install -m 0755 vim-ai-helper /usr/local/bin/vim-ai-helper
# or: cp vim-ai-helper ~/.local/bin/ && chmod +x ~/.local/bin/vim-ai-helper
sudo dnf install -y python3-openai python3-ollama
```

### Build RPM locally

```bash
VERSION=$(rpmspec -q --qf '%{version}\n' vim-ai-helper.spec | head -1)
tar czf /tmp/vim-ai-helper-${VERSION}.tar.gz \
  --transform "s,^,vim-ai-helper-${VERSION}/," \
  vim-ai-helper agents.json.example README.md LICENSE vim-ai-helper.spec
rpmbuild -ba vim-ai-helper.spec --define "_sourcedir /tmp"
sudo dnf install ~/rpmbuild/RPMS/noarch/vim-ai-helper-*.rpm
```

### COPR / Packit

This repo includes `.packit.yaml` and `.copr/Makefile` for Fedora COPR builds.
Point a **COPR webhook** at the GitHub repo (builds use `.copr/Makefile`).

Versioning: **`main` = beta**, tags **`vX.Y.Z` = stable**, **`vX.Y.Z-rc.N`** /
`release/*` branches = RC. Details in **[RELEASE.md](RELEASE.md)**.

## Agent routing

```bash
# List agents and routes
vim-ai-helper agents

# Show which agent handles a command
vim-ai-helper route review

# Force an agent for one call
vim-ai-helper --agent local complete ./file.py python
vim-ai-helper --agent internal chat "Explain this service mesh"
```

Config file (first found wins):

1. `$VIM_AI_AGENTS_FILE`
2. `~/.config/vim-ai-helper/agents.json`
3. `/etc/vim-ai-helper/agents.json`

See [agents.json.example](agents.json.example).

Env overrides:

| Variable | Purpose |
|----------|---------|
| `VIM_AI_AGENT` | Default agent for all commands |
| `VIM_AI_ROUTE_COMPLETE` | Route `complete` → agent name |
| `VIM_AI_ROUTE_REVIEW` | Route `review` → agent name |
| `VIM_AI_DEBUG_ROUTE=1` | Print route to stderr |

Default routes: completion/generate → `local` (Ollama); explain/review/refactor/chat → `claude`.

## Internal API

```bash
export VIM_AI_BACKEND=openai
export VIM_AI_BASE_URL=https://llm.internal.example/v1
export VIM_AI_API_KEY=your-token
export VIM_AI_MODEL=corp-model

# Or keep Claude semantics with a proxy:
export VIM_AI_BACKEND=claude
export VIM_AI_CLAUDE_BASE_URL=https://llm.internal.example/anthropic/v1
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
| [vim-ai-assistant](https://github.com/dsedgmen/vim-ai-assistant) | Vim/Neovim configs that invoke this CLI |
| [vim-ai-packaging](https://github.com/dsedgmen/vim-ai-packaging) | Container/Flatpak builds (stages this binary) |
| [devenv](https://github.com/dsedgmen/devenv) | Stages helper into images/VMs |

## Contributing / coding agents

See **[AGENTS.md](AGENTS.md)** for how automated coding agents and humans should
modify this project (Fedora packaging rules, CLI stability, no prompt/secret
commits, verification checklist).

## License

MIT
