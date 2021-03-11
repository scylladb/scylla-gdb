#!/bin/bash -e

. /etc/os-release
print_usage() {
    echo "build_rpm.sh --reloc-pkg build/scylla-gdb-package.tar.gz"
    echo "  --reloc-pkg specify relocatable package path"
    echo "  --builddir specify rpmbuild directory"
    exit 1
}
RELOC_PKG=build/scylla-gdb-package.tar.gz
BUILDDIR=build/redhat
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
RPMBUILD=$(readlink -f $BUILDDIR)
mkdir -p $BUILDDIR/scylla-gdb
tar -C $BUILDDIR -xpf $RELOC_PKG scylla-gdb/SCYLLA-RELOCATABLE-FILE scylla-gdb/SCYLLA-RELEASE-FILE scylla-gdb/SCYLLA-VERSION-FILE scylla-gdb/SCYLLA-PRODUCT-FILE scylla-gdb/dist/redhat
cd $BUILDDIR/scylla-gdb

RELOC_PKG_BASENAME=$(basename "$RELOC_PKG")
SCYLLA_VERSION=$(cat SCYLLA-VERSION-FILE)
SCYLLA_RELEASE=$(cat SCYLLA-RELEASE-FILE)
PRODUCT=$(cat SCYLLA-PRODUCT-FILE)

RPMBUILD=$(readlink -f ../)
mkdir -p "$RPMBUILD"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

parameters=(
    -D"name $PRODUCT-gdb"
    -D"version $SCYLLA_VERSION"
    -D"release $SCYLLA_RELEASE"
    -D"target /opt/scylladb/gdb"
    -D"reloc_pkg $RELOC_PKG_BASENAME"
)

ln -fv "$RELOC_PKG" "$RPMBUILD"/SOURCES/
cp dist/redhat/gdb.spec "$RPMBUILD"/SPECS/
rpmbuild "${parameters[@]}" --nodebuginfo -ba --define '_binary_payload w2.xzdio' --define "_build_id_links none" --define "_topdir ${RPMBUILD}" "$RPMBUILD"/SPECS/gdb.spec
