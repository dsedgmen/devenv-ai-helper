# Macros (set by CI / COPR Makefile / rpmbuild --define):
#   vim_ai_ver  — RPM Version  (default: from VERSION file baseline)
#   vim_ai_rel  — RPM Release without dist tag (%%{?dist} appended below)
Name:           vim-ai-helper
Version:        %{?vim_ai_ver}%{!?vim_ai_ver:1.1.0}
Release:        %{?vim_ai_rel}%{!?vim_ai_rel:1}%{?dist}
Summary:        AI CLI backend for Vim/Neovim with agent routing

License:        MIT
URL:            https://github.com/dsedgmen/vim-ai-helper
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
# Pure script package — no compiled extensions
BuildRequires:  python3

Requires:       python3 >= 3.11
Requires:       python3-openai
Requires:       python3-ollama
Recommends:     python3-google-genai

%description
Command-line AI backend for Vim/Neovim plugins.

Supports Ollama, Claude, Gemini, and OpenAI-compatible APIs (including
internal corporate gateways via VIM_AI_BASE_URL).

Agent routing selects backends/models per command via agents.json,
--agent, or VIM_AI_ROUTE_* environment variables.

Versioning: main branch builds are beta (Release 0.*.beta); tags vX.Y.Z
are stable. See RELEASE.md.

%prep
%autosetup -n %{name}-%{version}

%build
# no-op (single script)

%install
install -D -m 0755 vim-ai-helper %{buildroot}%{_bindir}/vim-ai-helper
install -D -m 0644 agents.json.example %{buildroot}%{_datadir}/vim-ai-helper/agents.json.example

%files
%{_bindir}/vim-ai-helper
%{_datadir}/vim-ai-helper/agents.json.example
%doc README.md
%license LICENSE

%changelog
* Wed Nov 04 2026 David Sedgmen <dsedgmen@users.noreply.github.com> - 1.1.0-1
- Initial separate project with agent routing and configurable base_url
