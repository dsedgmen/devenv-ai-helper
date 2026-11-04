#!/usr/bin/env bash
# Derive RPM Version / Release / channel from git ref.
#
# Channels:
#   stable  — tag vX.Y.Z
#   rc      — tag vX.Y.Z-rc.N  OR  branch release/* / release-*
#   beta    — branch main (default development)
#
# Usage:
#   ./scripts/rpm-version.sh              # human-readable
#   ./scripts/rpm-version.sh --shell      # VERSION=... RELEASE=... CHANNEL=...
#   ./scripts/rpm-version.sh --github-env # append to $GITHUB_OUTPUT
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE="$(tr -d '[:space:]' < "$ROOT/VERSION")"
[[ "$BASE" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "VERSION file must be X.Y.Z, got: $BASE" >&2
  exit 1
}

VERSION="$BASE"
RELEASE="1"
CHANNEL="stable"
DIST_VERSION="$VERSION"

if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REF="${GITHUB_REF:-}"
  REF_NAME="${GITHUB_REF_NAME:-}"
  SHA="${GITHUB_SHA:-$(git -C "$ROOT" rev-parse HEAD)}"
  SHORT="$(echo "$SHA" | cut -c1-7)"
  DATE="$(date -u +%Y%m%d)"

  if [[ -z "$REF" ]]; then
    if git -C "$ROOT" describe --exact-match --tags HEAD >/dev/null 2>&1; then
      REF_NAME="$(git -C "$ROOT" describe --exact-match --tags HEAD)"
      REF="refs/tags/$REF_NAME"
    else
      REF_NAME="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)"
      REF="refs/heads/$REF_NAME"
    fi
  fi

  CHANNEL="beta"
  VERSION="$BASE"
  RELEASE="0.${DATE}git${SHORT}.beta"

  if [[ "$REF" == refs/tags/* ]]; then
    TAG="${REF_NAME:-${REF#refs/tags/}}"
    if [[ "$TAG" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
      CHANNEL="stable"
      VERSION="${BASH_REMATCH[1]}"
      RELEASE="1"
    elif [[ "$TAG" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)-rc\.([0-9]+)$ ]]; then
      CHANNEL="rc"
      VERSION="${BASH_REMATCH[1]}"
      RELEASE="0.${BASH_REMATCH[2]}.rc${BASH_REMATCH[2]}git${SHORT}"
    else
      echo "Unsupported tag '$TAG' (use vX.Y.Z or vX.Y.Z-rc.N)" >&2
      exit 1
    fi
  elif [[ "$REF" == refs/heads/release/* || "$REF_NAME" == release/* || "$REF_NAME" == release-* ]]; then
    CHANNEL="rc"
    VERSION="$BASE"
    RELEASE="0.${DATE}git${SHORT}.rc"
  elif [[ "$REF_NAME" == main || "$REF_NAME" == master ]]; then
    CHANNEL="beta"
    VERSION="$BASE"
    RELEASE="0.${DATE}git${SHORT}.beta"
  else
    CHANNEL="beta"
    VERSION="$BASE"
    SAFE_BRANCH="$(echo "$REF_NAME" | tr '/_' '-' | tr -cd '[:alnum:].-' | cut -c1-32)"
    RELEASE="0.${DATE}git${SHORT}.${SAFE_BRANCH:-snap}"
  fi

  DIST_VERSION="$VERSION"
fi

case "${1:-}" in
  --shell)
    printf 'VERSION=%q\nRELEASE=%q\nCHANNEL=%q\nDIST_VERSION=%q\n' \
      "$VERSION" "$RELEASE" "$CHANNEL" "$DIST_VERSION"
    ;;
  --github-env)
    {
      echo "version=$VERSION"
      echo "release=$RELEASE"
      echo "channel=$CHANNEL"
      echo "dist_version=$DIST_VERSION"
      echo "rpm_evr=${VERSION}-${RELEASE}"
    } >> "${GITHUB_OUTPUT:?GITHUB_OUTPUT not set}"
    echo "channel=$CHANNEL version=$VERSION-$RELEASE"
    ;;
  *)
    echo "channel=$CHANNEL"
    echo "version=$VERSION"
    echo "release=$RELEASE"
    echo "evr=${VERSION}-${RELEASE}"
    ;;
esac
