# COPR webhook / make_srpm entrypoint
# https://docs.pagure.org/copr.copr/user_documentation.html#make_srpm
#
# main  → beta RPMs (Release ….beta)
# tags  → stable / rc (see scripts/rpm-version.sh)

.PHONY: srpm

srpm:
	dnf -y install git rpm-build rpmdevtools python3 2>/dev/null || \
	  yum -y install git rpm-build rpmdevtools python3 2>/dev/null || true
	# BuildRequires: python3 (satisfied above)
	chmod +x ./scripts/rpm-version.sh
	eval "$$(./scripts/rpm-version.sh --shell)"
	mkdir -p $(outdir) /tmp/vim-ai-helper-src
	# Source tarball name must match Version: (macro-expanded)
	rm -rf /tmp/vim-ai-helper-pack
	mkdir -p /tmp/vim-ai-helper-pack/vim-ai-helper-$${VERSION}
	cp -a vim-ai-helper agents.json.example README.md LICENSE \
	  /tmp/vim-ai-helper-pack/vim-ai-helper-$${VERSION}/
	# Spec inside tarball for reference; build uses top-level with macros
	cp vim-ai-helper.spec /tmp/vim-ai-helper-pack/vim-ai-helper-$${VERSION}/
	tar -C /tmp/vim-ai-helper-pack -czf /tmp/vim-ai-helper-$${VERSION}.tar.gz \
	  vim-ai-helper-$${VERSION}
	rpmbuild -bs vim-ai-helper.spec \
	  --define "_sourcedir /tmp" \
	  --define "_srcrpmdir $(outdir)" \
	  --define "vim_ai_ver $${VERSION}" \
	  --define "vim_ai_rel $${RELEASE}"
	@echo "Built SRPM channel=$${CHANNEL} $${VERSION}-$${RELEASE}"
