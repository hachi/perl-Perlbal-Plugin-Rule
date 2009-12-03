name:      perl-Perlbal-Plugin-Rule
summary:   perl-Perlbal-Plugin-Rule - Arbitrary rule processing service selector for Perlbal.
version:   0.00_01
release:   1
vendor:    Jonathan Steinert <hachi@sixapart.com>
packager:  Jonathan Steinert <hachi@cpan.org>
license:   Artistic
group:     Applications/CPAN
buildroot: %{_tmppath}/%{name}-%{version}-%(id -u -n)
buildarch: noarch
source:    Perlbal-Plugin-Rule-%{version}.tar.gz
requires:  perl(Perlbal)
autoreq: no

%description
Arbitrary rule processing service selector for Perlbal.

%prep
rm -rf "%{buildroot}"
%setup -n Perlbal-Plugin-Rule-%{version}

%build
%{__perl} Makefile.PL PREFIX=%{buildroot}%{_prefix} INSTALLDIRS=vendor
make all
make test

%install
make pure_install

[ -x /usr/lib/rpm/brp-compress ] && /usr/lib/rpm/brp-compress


# remove special files
find %{buildroot} \(                    \
       -name "perllocal.pod"            \
    -o -name ".packlist"                \
    -o -name "*.bs"                     \
    \) -exec rm -f {} \;

# no empty directories
find %{buildroot}%{_prefix}             \
    -type d -depth -empty               \
    -exec rmdir {} \;

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%files
%defattr(-,root,root)
%{_prefix}/bin/*
%{_prefix}/share/man/man1
