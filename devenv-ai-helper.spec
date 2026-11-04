# Macros (set by CI / COPR Makefile / rpmbuild --define):
#   devenv_ai_ver  — RPM Version  (default: from VERSION file baseline)
#   devenv_ai_rel  — RPM Release without dist tag (%%{?dist} appended below)
Name:           devenv-ai-helper
Version:        %{?devenv_ai_ver}%{!?devenv_ai_ver:1.1.0}
Release:        %{?devenv_ai_rel}%{!?devenv_ai_rel:1}%{?dist}
Summary:        AI CLI backend for Vim/Neovim with agent routing

License:        MIT
URL:            https://github.com/dsedgmen/devenv-ai-helper
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
# Pure script package — no compiled extensions
BuildRequires:  python3

Requires:       python3 >= 3.11
Requires:       python3-openai
Requires:       python3-ollama
Recommends:     python3-google-genai
# Transition from vim-ai-helper
Provides:       vim-ai-helper = %{version}-%{release}
Obsoletes:      vim-ai-helper < 2.0.0

%description
Command-line AI backend for Vim/Neovim plugins (devenv stack).

Supports Ollama, Claude, Gemini, and OpenAI-compatible APIs (including
internal corporate gateways via DEVENV_AI_BASE_URL; VIM_AI_* still accepted).

Agent routing selects backends/models per command via agents.json,
--agent, or DEVENV_AI_ROUTE_* environment variables.

Versioning: main branch builds are beta (Release 0.*.beta); tags vX.Y.Z
are stable. See RELEASE.md.

%prep
%autosetup -n %{name}-%{version}

%build
# no-op (single script)

%install
install -D -m 0755 devenv-ai-helper %{buildroot}%{_bindir}/devenv-ai-helper
ln -s devenv-ai-helper %{buildroot}%{_bindir}/vim-ai-helper
install -D -m 0644 agents.json.example %{buildroot}%{_datadir}/devenv-ai-helper/agents.json.example

%files
%{_bindir}/devenv-ai-helper
%{_bindir}/vim-ai-helper
%{_datadir}/devenv-ai-helper/agents.json.example
%doc README.md
%license LICENSE

%changelog
* Thu Nov 05 2026 David Sedgmen <dsedgmen@users.noreply.github.com> - 1.1.0-2
- Rename package to devenv-ai-helper; keep vim-ai-helper symlink

* Wed Nov 04 2026 David Sedgmen <dsedgmen@users.noreply.github.com> - 1.1.0-1
- Initial separate project with agent routing and configurable base_url
