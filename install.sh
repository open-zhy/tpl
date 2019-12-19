#!/usr/bin/env bash

PROJECT_NAME="tpl"

: ${USE_SUDO:="true"}
: ${INSTALL_DIR:="/usr/local/bin"}
: ${REPO_URL:="https://github.com/open-zhy/tpl"}

# initArch discovers the architecture for this system.
initArch() {
  ARCH=$(uname -m)
  case ${ARCH} in
    armv5*) ARCH="armv5";;
    armv6*) ARCH="armv6";;
    armv7*) ARCH="arm";;
    aarch64) ARCH="arm64";;
    x86) ARCH="386";;
    x86_64) ARCH="amd64";;
    i686) ARCH="386";;
    i386) ARCH="386";;
  esac
}

# initOS discovers the operating system for this system.
initOS() {
  OS=$(echo `uname`|tr '[:upper:]' '[:lower:]')

  case "$OS" in
    # Minimalist GNU for Windows
    mingw*) OS='windows';;
  esac
}

# runs the given command as root (detects if we are root already)
runAsRoot() {
  local CMD="$*"

  if [[ $EUID -ne 0 && ${USE_SUDO} = "true" ]]; then
    CMD="sudo $CMD"
  fi

  ${CMD}
}

# verifySupported checks that the os/arch combination is supported for
# binary builds.
verifySupported() {
  local supported="darwin-386\ndarwin-amd64\nlinux-386\nlinux-amd64\nlinux-arm\nlinux-arm64\nlinux-ppc64le\nwindows-386\nwindows-amd64"
  if ! echo "${supported}" | grep -q "${OS}-${ARCH}"; then
    echo "No prebuilt binary for ${OS}-${ARCH}."
    echo "To build from source, go to https://github.com/helm/helm"
    exit 1
  fi

  if ! type "curl" > /dev/null && ! type "wget" > /dev/null; then
    echo "Either curl or wget is required"
    exit 1
  fi
}

checkDesiredVersion() {
  if [[ "x$DESIRED_VERSION" == "x" ]]; then
    # Get tag from release URL
    local latest_release_url="$REPO_URL/releases/latest"
    if type "curl" > /dev/null; then
      TAG=$(curl -Ls -o /dev/null -w %{url_effective} ${latest_release_url} | grep -oE "[^/]+$")
    elif type "wget" > /dev/null; then
      TAG=$(wget $latest_release_url --server-response -O /dev/null 2>&1 | awk '/^  Location: /{DEST=$2} END{ print DEST}' | grep -oE "[^/]+$")
    fi
  else
    TAG=${DESIRED_VERSION}
  fi
}

checkInstalledVersion() {
  if [[ -f "${INSTALL_DIR}/${PROJECT_NAME}" ]]; then
    local version=$("${INSTALL_DIR}/${PROJECT_NAME}" version | grep Version | sed -r 's/^Version:\ //')
    if [[ "$version" == "$TAG" ]]; then
      echo "tpl ${version} is already ${DESIRED_VERSION:-latest}"
      return 0
    else
      echo "tpl ${TAG} is available. Changing from version ${version}."
      return 1
    fi
  else
    return 1
  fi
}

# downloadFile downloads the latest binary package and also the checksum
# for that binary.
downloadFile() {
  DIST_FILE="tpl-$OS-$ARCH"
  DIST_PATH="$TAG/$DIST_FILE"
  DOWNLOAD_URL="$REPO_URL/releases/download/$DIST_PATH"
  TMP_ROOT="$(mktemp -dt tpl-installer-XXXXXX)"
  TMP_FILE="$TMP_ROOT/$DIST_FILE"
  echo "Downloading $DOWNLOAD_URL"
  if type "curl" > /dev/null; then
    curl -SsL "$DOWNLOAD_URL" -o "$TMP_FILE"
  elif type "wget" > /dev/null; then
    wget -q -O "$TMP_FILE" "$DOWNLOAD_URL"
  fi
}

# installFile verifies the SHA256 for the file, then unpacks and
# installs it.
installFile() {
  echo "Preparing to install $PROJECT_NAME into ${INSTALL_DIR}"
  chmod +x "$TMP_FILE"
  runAsRoot cp "$TMP_FILE" "$INSTALL_DIR/$PROJECT_NAME"
  echo "$PROJECT_NAME installed into $INSTALL_DIR/$PROJECT_NAME"
}

# fail_trap is executed if an error occurs.
fail_trap() {
  result=$?
  if [[ "$result" != "0" ]]; then
    if [[ -n "$INPUT_ARGUMENTS" ]]; then
      echo "Failed to install $PROJECT_NAME with the arguments provided: $INPUT_ARGUMENTS"
      help
    else
      echo "Failed to install $PROJECT_NAME"
    fi
    echo -e "\tFor support, go to https://github.com/open-zhy/tpl."
  fi
  cleanup
  exit ${result}
}

cleanup() {
  if [[ -d "${TMP_ROOT:-}" ]]; then
    rm -rf "$TMP_ROOT"
  fi
}

# Execution

#Stop execution on any error
trap "fail_trap" EXIT
set -e

# Parsing input arguments (if any)
export INPUT_ARGUMENTS="${@}"
set -u
while [[ $# -gt 0 ]]; do
  case $1 in
    '--version'|-v)
       shift
       if [[ $# -ne 0 ]]; then
           export DESIRED_VERSION="${1}"
       else
           echo -e "Please provide the desired version. e.g. --version 1.0.0"
           exit 0
       fi
       ;;
    '--no-sudo')
       USE_SUDO="false"
       ;;
    '--help'|-h)
       help
       exit 0
       ;;
    *) exit 1
       ;;
  esac
  shift
done
set +u

initArch
initOS
verifySupported
checkDesiredVersion
if ! checkInstalledVersion; then
    downloadFile
    installFile
fi
cleanup