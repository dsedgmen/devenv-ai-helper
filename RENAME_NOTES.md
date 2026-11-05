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

`vim-ai-helper` redirects to `devenv-ai-helper`. Images will publish under
`ghcr.io/dsedgmen/devenv-ai-packaging/...` on the next packaging release workflow.

## Shell env (done on this machine)

```bash
export DEVENV_AI_BACKEND=ollama
export DEVENV_AI_OLLAMA_MODEL=granite-code:latest
# VIM_AI_* still exported as compat aliases in ~/.bashrc
```

## Still manual

1. **GitLab CEE** — `gitlab.cee.redhat.com:dsedgmen/vim-ai-assistant` still uses the old
   project name; `glab` token expired. Rename the project in the GitLab UI (or
   create `devenv-ai-assistant`), update the local `gitlab` remote, then push
   (may need pull/rebase — history diverged; do **not** force-push unless intended).
2. **COPR** — Point package build at `https://github.com/dsedgmen/devenv-ai-helper`
   and rename package to `devenv-ai-helper` when ready (`copr-cli` not installed here).
3. **Old ghcr tags** under `vim-ai-packaging` — leave or delete after cutover.
