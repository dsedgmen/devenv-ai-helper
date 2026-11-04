# COPR webhook / make_srpm entrypoint
# https://docs.pagure.org/copr.copr/user_documentation.html#make_srpm
#
# main  → beta RPMs (Release ….beta)
# tags  → stable / rc (see scripts/rpm-version.sh)
#
# IMPORTANT:
# - One shell for the whole recipe so VERSION/RELEASE from eval persist.
# - Bake Version/Release into the spec shipped in the SRPM. COPR rebuilds
#   binaries from that spec WITHOUT our --define macros; leaving
#   %{!?vim_ai_rel:1} produces 1.1.0-1 even when the SRPM filename is .beta.

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
	if [[ "$${RELEASE}" == "1" && "$${CHANNEL}" != "stable" ]]; then
	  echo "Refusing non-stable Release=1 (channel=$${CHANNEL})" >&2
	  exit 1
	fi
	echo "channel=$${CHANNEL} version=$${VERSION} release=$${RELEASE}"

	# Literal Version/Release so binary rebuilds keep the beta/rc/stable EVR
	SPEC_BUILT=/tmp/vim-ai-helper-built.spec
	sed \
	  -e "s/^Version:.*/Version:        $${VERSION}/" \
	  -e "s/^Release:.*/Release:        $${RELEASE}%{?dist}/" \
	  vim-ai-helper.spec > "$${SPEC_BUILT}"
	grep -E '^(Version|Release):' "$${SPEC_BUILT}"

	mkdir -p "$(outdir)"
	rm -rf /tmp/vim-ai-helper-pack
	mkdir -p "/tmp/vim-ai-helper-pack/vim-ai-helper-$${VERSION}"
	cp -a vim-ai-helper agents.json.example README.md LICENSE \
	  "/tmp/vim-ai-helper-pack/vim-ai-helper-$${VERSION}/"
	cp "$${SPEC_BUILT}" "/tmp/vim-ai-helper-pack/vim-ai-helper-$${VERSION}/vim-ai-helper.spec"
	tar -C /tmp/vim-ai-helper-pack -czf "/tmp/vim-ai-helper-$${VERSION}.tar.gz" \
	  "vim-ai-helper-$${VERSION}"

	rm -rf /tmp/vim-ai-helper-rpmbuild
	mkdir -p /tmp/vim-ai-helper-rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
	rpmbuild -bs "$${SPEC_BUILT}" \
	  --define "_topdir /tmp/vim-ai-helper-rpmbuild" \
	  --define "_sourcedir /tmp" \
	  --define "_srcrpmdir $(outdir)"
	echo "Built SRPM channel=$${CHANNEL} $${VERSION}-$${RELEASE}"
	# Sanity: shipped spec must not still carry conditional macro defaults
	tmpdir=$$(mktemp -d)
	rpm2cpio "$(outdir)"/vim-ai-helper-*.src.rpm | (cd "$$tmpdir" && cpio -id --quiet)
	if grep -E '^(Version|Release):' "$$tmpdir"/*.spec | grep -q 'vim_ai_'; then
	  echo "ERROR: SRPM Version/Release still use vim_ai_* macros; binaries would be 1.1.0-1" >&2
	  exit 1
	fi
	grep -E '^(Version|Release):' "$$tmpdir"/*.spec
	rm -rf "$$tmpdir"
