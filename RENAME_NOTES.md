# Rename / publish notes

Local directories (under `~/claude/`):

- `devenv-ai-assistant` (was `vim-ai-assistant`)
- `devenv-ai-helper` (was `vim-ai-helper`)
- `devenv-ai-packaging` (was `vim-ai-packaging`)
- `devenv-lsp-setup` (new)

## Shell env (user machine)

Prefer:

```bash
export DEVENV_AI_BACKEND=ollama
export DEVENV_AI_OLLAMA_MODEL=granite-code:latest
```

`VIM_AI_*` still works as fallback in the helper and devenv SendEnv.

## Remotes / COPR / ghcr

Creating or renaming GitHub/GitLab remotes, COPR package names, and
`ghcr.io/dsedgmen/devenv-ai-packaging/...` images is a **manual publish step**.
Do not push or rename remotes until explicitly approved.
