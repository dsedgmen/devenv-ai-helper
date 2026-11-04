# COPR webhook / make_srpm entrypoint
# https://docs.pagure.org/copr.copr/user_documentation.html#make_srpm
#
# main  → beta RPMs (Release ….beta)
# tags  → stable / rc (see scripts/rpm-version.sh)
#
# IMPORTANT: one shell for the whole recipe so VERSION/RELEASE from eval persist.

SHELL := /bin/bash
.ONESHELL:
.PHONY: srpm

srpm:
	set -euo pipefail
	dnf -y install git rpm-build rpmdevtools python3 2>/dev/null || \
	  yum -y install git rpm-build rpmdevtools python3 2>/dev/null || true
	chmod +x ./scripts/rpm-version.sh
	eval "$$(./scripts/rpm-version.sh --shell)"
	if [[ -z "$${VERSION}" || -z "$${RELEASE}" ]]; then
	  echo "rpm-version.sh produced empty VERSION/RELEASE" >&2
	  ./scripts/rpm-version.sh >&2 || true
	  exit 1
	fi
	# Guard against building the bare spec default (1.1.0-1) by mistake
	if [[ "$${RELEASE}" == "1" && "$${CHANNEL}" != "stable" ]]; then
	  echo "Refusing non-stable Release=1 (channel=$${CHANNEL})" >&2
	  exit 1
	fi
	echo "channel=$${CHANNEL} version=$${VERSION} release=$${RELEASE}"
	mkdir -p "$(outdir)"
	rm -rf /tmp/vim-ai-helper-pack
	mkdir -p "/tmp/vim-ai-helper-pack/vim-ai-helper-$${VERSION}"
	cp -a vim-ai-helper agents.json.example README.md LICENSE \
	  "/tmp/vim-ai-helper-pack/vim-ai-helper-$${VERSION}/"
	cp vim-ai-helper.spec "/tmp/vim-ai-helper-pack/vim-ai-helper-$${VERSION}/"
	tar -C /tmp/vim-ai-helper-pack -czf "/tmp/vim-ai-helper-$${VERSION}.tar.gz" \
	  "vim-ai-helper-$${VERSION}"
	rm -rf /tmp/vim-ai-helper-rpmbuild
	mkdir -p /tmp/vim-ai-helper-rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
	rpmbuild -bs vim-ai-helper.spec \
	  --define "_topdir /tmp/vim-ai-helper-rpmbuild" \
	  --define "_sourcedir /tmp" \
	  --define "_srcrpmdir $(outdir)" \
	  --define "vim_ai_ver $${VERSION}" \
	  --define "vim_ai_rel $${RELEASE}"
	echo "Built SRPM channel=$${CHANNEL} $${VERSION}-$${RELEASE}"
