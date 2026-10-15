#!/bin/bash
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

# Zig Update; Download a specific Zig release or the latest stable release or the latest master build.
# Usage: zigup.sh [master|stable|<version>] (defaults to master)
# Inspired by: https://gist.github.com/MasterQ32/1f27081d8a7dd109fc290bd6729d97a8

# INSTALL_DIR=/usr/local/bin
INSTALL_DIR="${HOME}/.local/bin"
# Underscore to prevent conflict with system zig binary
BIN_NAME="${BIN_NAME:-zig_}"
TMP_DIR=/tmp/zigup
REPO_URL=https://ziglang.org/download/index.json
REPO_ARCH=x86_64-linux
REPO_VERSION="${1:-master}"

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  rm -r "${TMP_DIR}"
}

msg() { echo >&2 -e "${1-}"; }
die() { printf '\033[31merror: \033[0m' >&2; msg "$@"; exit 1; }
success() { printf '\033[32msuccess: \033[0m' >&2; msg "$@"; }

mkdir -p "${TMP_DIR}"

test -d "${INSTALL_DIR}" || die "Directory \"${INSTALL_DIR}\" does not exist"
type curl >/dev/null 2>&1 || die "curl is required but not available"
type jq >/dev/null 2>&1 || die "jq is required but not available"
type shasum >/dev/null 2>&1 || die "shasum is required but not available"

msg "Getting version info..."

msg "Current install: $([[ -x "${INSTALL_DIR}/zig-latest/zig" ]] && "${INSTALL_DIR}/zig-latest/zig" version || echo none)"

repo=$(curl -s "${REPO_URL}" | jq -e --arg version "${REPO_VERSION}" --arg arch "${REPO_ARCH}" '
  (if $version == "stable" then
    keys | map(select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$")))
    | max_by(split(".") | map(tonumber))
    | . // error("No stable releases found")
  else $version end) as $selected
  | .[$selected][$arch] // empty
') || die "Failed to acquire version info for ${REPO_VERSION}"
tarball=$(echo "${repo}" | jq --raw-output '.tarball')
shasum=$(echo "${repo}" | jq --raw-output '.shasum')
size=$(echo "${repo}" | jq --raw-output '.size')
filename=${tarball##*/} # basename
version=${filename%.tar.xz}

# May be nightly build (/builds/) or stable release (/download/)
test "${tarball:0:27}" == "https://ziglang.org/builds/" || test "${tarball:0:29}" == "https://ziglang.org/download/" || die "Unexpected download path"
test -z "${version}" && die "Failed to extract version info"

if test "${INSTALL_DIR}/zig-latest/zig" -ef "${INSTALL_DIR}/${version}/zig"; then
  success "${version} is already the latest version"
else
  msg "Updating to ${version}"

  if test -x "${INSTALL_DIR}/${version}/zig"; then
    msg "Using existing installation"
  else
    curl "${tarball}" -o "${TMP_DIR}/${filename}" || die "Failed to download"
    echo "${shasum}  ${TMP_DIR}/${filename}" | shasum -c - || die "Failed to verify checksum"
    test "${size}" -eq "$(stat -c '%s' "${TMP_DIR}/${filename}")" || die "Download size mismatch"

    tar --no-ignore-command-error -xJC "${INSTALL_DIR}" -f "${TMP_DIR}/${filename}" || die "Failed to extract"

    # Keep the 5 latest releases and 5 latest master builds, plus the selected version
    for version_pattern in '^[0-9]+\.[0-9]+\.[0-9]+$' '^[0-9]+\.[0-9]+\.[0-9]+-dev\.[0-9]+\+[[:xdigit:]]+$'; do
      find "${INSTALL_DIR}" -mindepth 1 -maxdepth 1 -type d -name "zig-${REPO_ARCH}-*" -printf '%f\0' | \
        while IFS= read -r -d '' installation; do
          if [[ "${installation#"zig-${REPO_ARCH}-"}" =~ ${version_pattern} ]]; then
            printf '%s\0' "${installation}"
          fi
        done | \
        sort -zV | \
        head -z -n -5 | \
        while IFS= read -r -d '' installation; do
          if [[ "${installation}" != "${version}" ]]; then
            rm -rf -- "${INSTALL_DIR:?}/${installation}"
          fi
        done
    done
  fi

  rm -rf "${INSTALL_DIR?}/zig-latest" "${INSTALL_DIR:?}/${BIN_NAME:?}" || die "Failed to remove old symlinks"
  ln -s "${version}" "${INSTALL_DIR}/zig-latest" || die "Failed to set new symlink"
  ln -s zig-latest/zig "${INSTALL_DIR}/${BIN_NAME}" || die "Failed to set new symlink"

  success "Installed version: $("${INSTALL_DIR}/zig-latest/zig" version)"
fi
