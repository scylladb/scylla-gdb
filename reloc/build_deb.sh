#!/bin/bash -e

. /etc/os-release
print_usage() {
    echo "build_deb.sh --reloc-pkg build/scylla-gdb-package.tar.gz"
    echo "  --reloc-pkg specify relocatable package path"
    echo "  --builddir specify debuild directory"
    exit 1
}

RELOC_PKG=build/scylla-gdb-package.tar.gz
BUILDDIR=build/debian
while [ $# -gt 0 ]; do
    case "$1" in
        "--reloc-pkg")
            RELOC_PKG=$2
            shift 2
            ;;
        "--builddir")
            BUILDDIR="$2"
            shift 2
            ;;
        *)
            print_usage
            ;;
    esac
done

if [ ! -e $RELOC_PKG ]; then
    echo "$RELOC_PKG does not exist."
    echo "Run ./reloc/build_reloc.sh first."
    exit 1
fi
RELOC_PKG=$(readlink -f $RELOC_PKG)
BUILDDIR=$(readlink -f "$BUILDDIR")
rm -rf "$BUILDDIR"/scylla-gdb-package
mkdir -p "$BUILDDIR"/scylla-gdb-package
tar -C "$BUILDDIR"/scylla-gdb-package -xpf "$RELOC_PKG"
cd "$BUILDDIR"/scylla-gdb-package

PRODUCT=$(cat scylla-gdb/SCYLLA-PRODUCT-FILE)
RELOC_PKG_FULLPATH=$(readlink -f $RELOC_PKG)
RELOC_PKG_BASENAME=$(basename $RELOC_PKG)
SCYLLA_VERSION=$(cat scylla-gdb/SCYLLA-VERSION-FILE)
SCYLLA_RELEASE=$(cat scylla-gdb/SCYLLA-RELEASE-FILE)

ln -fv $RELOC_PKG_FULLPATH ../$PRODUCT-gdb_${SCYLLA_VERSION/\.rc/~rc}-$SCYLLA_RELEASE.orig.tar.gz

mv scylla-gdb/debian debian
debuild -rfakeroot -us -uc
