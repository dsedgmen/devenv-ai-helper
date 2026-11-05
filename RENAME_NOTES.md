# Rename / publish notes

## Local directories (`~/claude/`)

- `devenv-ai-assistant` (was `vim-ai-assistant`)
- `devenv-ai-helper` (was `vim-ai-helper`)
- `devenv-ai-packaging` (was `vim-ai-packaging`)
- `devenv-lsp-setup` (new)
- `devenv` (unchanged name)

## GitHub (done)

| Repo | URL |
|------|-----|
| devenv-ai-assistant | https://github.com/dsedgmen/devenv-ai-assistant |
| devenv-ai-helper | https://github.com/dsedgmen/devenv-ai-helper |
| devenv-ai-packaging | https://github.com/dsedgmen/devenv-ai-packaging |
| devenv-lsp-setup | https://github.com/dsedgmen/devenv-lsp-setup |

## GitLab CEE (done)

- https://gitlab.cee.redhat.com/dsedgmen/devenv-ai-assistant

## COPR (done)

- Project: https://copr.fedorainfracloud.org/coprs/dsedgmen/devenv/ (was `Devenv`)
- Package: `devenv-ai-helper` from https://github.com/dsedgmen/devenv-ai-helper
- Enable: `sudo dnf copr enable dsedgmen/devenv && sudo dnf install devenv-ai-helper`

## Shell env

```bash
export DEVENV_AI_BACKEND=ollama
export DEVENV_AI_OLLAMA_MODEL=granite-code:latest
# VIM_AI_* still exported as compat aliases in ~/.bashrc
```

## Still optional

- Old ghcr tags under `vim-ai-packaging` — leave or delete after cutover.
