# Agent guide — devenv-ai-helper

How coding agents (Cursor, Claude Code, Copilot, etc.) should work in this repository.

This file is **for developers/agents modifying the project**. It is not the runtime
`agents.json` routing used by the CLI for end-user AI backends.

## Project purpose

`devenv-ai-helper` is a small CLI that Vim/Neovim configs call for AI tasks
(complete, explain, review, refactor, generate, chat). It routes those calls to
Ollama / Claude / Gemini / OpenAI-compatible APIs, including internal gateways.

Consumers: `devenv-ai-assistant` (editor), `devenv-ai-packaging` (images/Flatpak),
`devenv` images/VMs, and local installs via RPM or `~/.local/bin`.

## Non-negotiable constraints

1. **Fedora packaging first**  
   Runtime dependencies must be installable as Fedora RPMs (`python3-openai`,
   `python3-ollama`, optionally `python3-google-genai`). Do not add pip-only
   runtime deps or vendor PyPI wheels into the RPM.

2. **No secrets or live prompt configs in git**  
   Never commit API keys, tokens, `.env`, local `agents.json`, `*.prompt`,
   chat/history dumps, or files under `prompts/`. Only `agents.json.example`
   may document routing shape. See `.gitignore`.

3. **No prompt injection into committed examples**  
   Do not put untrusted or user-supplied text into `agents.json.example`,
   README samples, tests, or CI fixtures as `system_prefix` / system prompts
   that would run for other users. Examples stay short, fixed, and instructional.

4. **Stable CLI contract**  
   Keep existing subcommands working unless the change is intentionally
   breaking and documented in README + changelog/spec version.
   Editors call: `complete`, `explain`, `review`, `refactor`, `generate`,
   `chat`, plus `agents` / `route`. Prefer `DEVENV_AI_*` env names; accept
   `VIM_AI_*` as fallback during transition. Ship `vim-ai-helper` symlink.

5. **Security CI must stay green**  
   Do not disable Bandit, compile checks, or RPM build workflows without an
   explicit, reviewed reason. Prefer fixing findings over skipping them.

## How to change the code

| Area | Guidance |
|------|----------|
| Core CLI | Single entry script `devenv-ai-helper` (Python 3). Prefer clear functions over new packages unless size forces a split. |
| Routing | Built-in agents + `agents.json` + `--agent` + `DEVENV_AI_ROUTE_*`. Keep resolution order documented in README. |
| HTTP clients | Use Fedora-packaged libraries only. Configurable `base_url` / host via env and agent config. |
| Spec / Packit | Do not hardcode release Version in the spec for CI — use `devenv_ai_ver` / `devenv_ai_rel` macros from `scripts/rpm-version.sh`. Bump the `VERSION` file for the next beta baseline. Packit targets = rawhide + two newest stables. |
| CI / COPR | `main` → beta; tags `v*` → stable/rc (see `RELEASE.md`). COPR webhook uses `.copr/Makefile`. Do not break `scripts/rpm-version.sh`. |

## Allowed agent actions

- Read and edit tracked source, docs, spec, workflows, examples.
- Run local checks: `python3 -m py_compile devenv-ai-helper`, `./devenv-ai-helper agents`, `./devenv-ai-helper route <cmd>`.
- Add tests as plain scripts or CI steps that use **fixed fixtures** only.
- Update README when CLI, env vars, or packaging change.

## Disallowed agent actions

- Commit or suggest committing ignored secret/prompt paths.
- Introduce network calls in CI that send repo content to third-party AI APIs.
- Soften `.gitignore` to re-allow `agents.json`, prompts, or credential patterns.
- Add “helpful” default system prompts that exfiltrate environment, credentials,
  or workspace paths.
- Rewrite Packit targets to EOL Fedora releases.
- Force-push, amend published history, or skip hooks unless the human explicitly asks.

## Interaction with sibling projects

- **devenv-ai-assistant** — editor configs; PATH/RPM/sibling-resolve this binary.
- **devenv-lsp-setup** — LSP/Treesitter/plugins (not this CLI).
- **devenv-ai-packaging** — stages this binary into container/Flatpak build context via `prepare-build-context.sh`.
- **devenv** — stages or installs the helper into isolated envs from sibling/`DEVENV_AI_HELPER_DIR`/PATH. Keep env var names (`DEVENV_AI_*`, with `VIM_AI_*` fallback, `ANTHROPIC_API_KEY`, …) stable for SSH `SendEnv`.

When a change needs coordinated updates in those repos, say so explicitly; do not silently diverge CLI flags.

## Verification checklist (before finishing a task)

- [ ] `python3 -m py_compile devenv-ai-helper`
- [ ] `./devenv-ai-helper agents` and `./devenv-ai-helper route complete` succeed
- [ ] No new secrets/prompt files staged
- [ ] Spec/`Requires` still Fedora RPMs only
- [ ] README updated if user-facing behavior changed

## Asking the human

Ask before: publishing releases, changing license, adding non-Fedora runtime deps,
weakening security controls, or destructive git operations.
