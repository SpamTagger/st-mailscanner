#!/usr/bin/env bash
# vim: set ts=2 sw=2 expandtab :
set -euo pipefail

MAILSCANNER_VERSION="${1:-5.5.3-2}"
DISTRO="${2:-trixie}"
BUILD_DIR="${4:-$(pwd)/build}"
EXPORT_DIR="${4:-$(pwd)/dist}"
FINAL_DEB="st-mailscanner_${MAILSCANNER_VERSION}+${DISTRO}_all.deb"
IMAGE="st-mailscanner:${MAILSCANNER_VERSION}-${DISTRO}"
CPUS="$(nproc)"
SELINUX=""
if [[ -e /sys/fs/selinux ]]; then
  SELINUX=":z"
fi

echo "Building MailScanner $MAILSCANNER_VERSION for ${DISTRO}"
mkdir -p "${BUILD_DIR}"

if [[ ! -d "${EXPORT_DIR}" ]]; then
  mkdir -p "${EXPORT_DIR}"
fi

podman build \
  --build-arg MAILSCANNER_VERSION=$MAILSCANNER_VERSION \
  --build-arg DISTRO=$DISTRO \
  --build-arg CPUS=$CPUS \
  --output type=local,dest="${BUILD_DIR}" \
  -t "$IMAGE" .

if [[ ! -f "${BUILD_DIR}/root/msbuilds/MailScanner-${MAILSCANNER_VERSION}.noarch.deb" ]]; then
  echo "✘ Failed to build package"
  exit 1
fi

mv ${BUILD_DIR}/root/msbuilds/MailScanner-${MAILSCANNER_VERSION}.noarch.deb ${EXPORT_DIR}/${FINAL_DEB}

cd "${EXPORT_DIR}"
sha256sum "${FINAL_DEB}" > "${FINAL_DEB}.sha256"
echo "Package available at ${EXPORT_DIR}/${FINAL_DEB}"
echo "SHA256 checksum written to ${EXPORT_DIR}/${FINAL_DEB}.sha256"

rm -rf ${BUILD_DIR}
