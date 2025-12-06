#!/bin/bash
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

# Zig Update; Check and download the latest zig master branch build
# Inspired by: https://gist.github.com/MasterQ32/1f27081d8a7dd109fc290bd6729d97a8

# INSTALL_DIR=/usr/local/bin
INSTALL_DIR="${HOME}/.local/bin"
# Underscore to prevent conflict with system zig binary
BIN_NAME="${BIN_NAME:-zig_}"
TMP_DIR=/tmp/zigup
REPO_URL=https://ziglang.org/download/index.json
REPO_ARCH=x86_64-linux

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  rm -r "${TMP_DIR}"
}

msg() { echo >&2 -e "${1-}"; }
die() { msg "$@"; exit 1; }

mkdir -p "${TMP_DIR}"

test -d "${INSTALL_DIR}" || die "Directory \"${INSTALL_DIR}\" does not exist!"
type curl >/dev/null 2>&1 || die "curl is required but not available!"
type jq >/dev/null 2>&1 || die "jq is required but not available!"
type shasum >/dev/null 2>&1 || die "shasum is required but not available!"

msg "Getting version info..."

msg "Current install: $([[ -x "${INSTALL_DIR}/zig-latest/zig" ]] && "${INSTALL_DIR}/zig-latest/zig" version || echo none)"

repo=$(curl -s "${REPO_URL}" | jq ".master[\"${REPO_ARCH}\"]") || die "Failed to acquire version info!"
tarball=$(echo "${repo}" | jq --raw-output '.tarball')
shasum=$(echo "${repo}" | jq --raw-output '.shasum')
size=$(echo "${repo}" | jq --raw-output '.size')
filename=${tarball##*/} # basename
version=${filename%.tar.xz}

# May be nightly build (/builds/) or stable release (/download/)
test "${tarball:0:27}" == "https://ziglang.org/builds/" || test "${tarball:0:29}" == "https://ziglang.org/download/" || die "Unexpected download path!"
test -z "${version}" && die "Failed to extract version info!"

if test "${INSTALL_DIR}/zig-latest/zig" -ef "${INSTALL_DIR}/${version}/zig"; then
  msg "${version} is already the latest version!"
else
  msg "Updating to ${version}"

  curl "${tarball}" -o "${TMP_DIR}/${filename}" || die "Failed to download!"
  echo "${shasum}  ${TMP_DIR}/${filename}" | shasum -c - || die "Failed to verify checksum!"
  test "${size}" -eq "$(stat -c '%s' "${TMP_DIR}/${filename}")" || die "Download size mismatch!"

  tar --no-ignore-command-error -xJC "${INSTALL_DIR}" -f "${TMP_DIR}/${filename}" || die "Failed to extract!"
  rm -rf "${INSTALL_DIR?}/zig-latest" "${INSTALL_DIR:?}/${BIN_NAME:?}" || die "Failed to remove old symlinks!"
  ln -s "${version}" "${INSTALL_DIR}/zig-latest" || die "Failed to set new symlink!"
  ln -s zig-latest/zig "${INSTALL_DIR}/${BIN_NAME}" || die "Failed to set new symlink!"

  # Clean up old zig files; sort by version and keep the 5 latest
  find "${INSTALL_DIR}" -maxdepth 1 -type d -name "zig-${REPO_ARCH}-*" | \
    sed -E 's/.*(0\.[0-9]+\.0-dev)\.([0-9]+)\+.*/\1 \2 &/' | \
    sort -t ' ' -k1,1 -k2,2n | \
    cut -d' ' -f3- | \
    head -n -5 | \
    xargs -r rm -rf

  msg "Installed version: $("${INSTALL_DIR}/zig-latest/zig" version)"
fi
