#!/bin/bash
#
# build-deb.sh - Build Debian package for firecracker-containerd
#
# Usage: ./build-deb.sh
#
# This script builds a .deb package for firecracker-containerd including:
# - firecracker-containerd daemon
# - firecracker-agent binary
# - CNI plugins
# - systemd service file
# - Default configuration
#
# Requirements:
# - debhelper >= 13
# - golang-go
# - docker.io (for building submodules)
# - git (for submodules)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Building firecracker-containerd Debian package"

# Check dependencies
check_dep() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: $1 is required but not installed."
        exit 1
    fi
}

check_dep dpkg-buildpackage
check_dep go
check_dep git
check_dep make

echo "==> Cleaning previous builds..."
rm -rf debian/.debhelper debian/firecracker-containerd debian/*.log debian/*.substvars debian/files 2>/dev/null || true

echo "==> Building package..."
# Use dpkg-buildpackage directly instead of debuild
# -us -uc: skip signing
# -b: binary only
# -d: skip build dependency checks (Go is installed via setup-go action, not system package)
dpkg-buildpackage -us -uc -b -d

echo ""
echo "==> Package built successfully!"
echo "==> Check the parent directory for the .deb file:"
ls -lh ../*.deb 2>/dev/null || echo "   (deb file should be in ../)"
echo ""
echo "==> Install with: sudo dpkg -i ../firecracker-containerd_*.deb"
echo "==> Enable service: sudo systemctl enable firecracker-containerd"
echo "==> Start service: sudo systemctl start firecracker-containerd"
