Name: %{name}
Version: %{version}
Release: %{release}
Summary: A standalone gdb that can be moved around different Linux machines
AutoReqProv: no
Provides: %{name}

License: GPLv3
Source0: %{reloc_pkg}

%global __brp_python_bytecompile %{nil}
%global __brp_mangle_shebangs %{nil}
%global __brp_ldconfig %{nil}
%global __brp_strip %{nil}
%global __brp_strip_comment_note %{nil}
%global __brp_strip_static_archive %{nil}

%description
This is a self-contained gdb that can be moved around
different Linux machines as long as they run a new enough kernel (where
new enough is defined by whichever Python module uses any kernel
functionality). All shared libraries needed for gdb to
operate are shipped with it.

%prep
%setup -q -n scylla-gdb

%install
./install.sh --root "$RPM_BUILD_ROOT"

%files
%dir %{target}
%{target}/*

%changelog

