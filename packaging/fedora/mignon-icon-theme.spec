Name:           mignon-icon-theme
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Flat, pastel-colored icon theme for your Linux workspace
License:        GPLv3+
URL:            https://github.com/igorfmoraes/Mignon-icon-theme
VCS:            {{{ git_dir_vcs }}}
Source0:        {{{ git_dir_pack }}}

BuildArch:      noarch
Requires:       hicolor-icon-theme

%description
Flat, pastel-colored icon theme for your Linux workspace (GNOME, Cinnamon, KDE, Cosmic) with Light/Dark variants available. I created it because finding the perfect pastel icon theme for my computer was a struggle, so here it is to fill this void.

%prep
{{{ git_dir_setup_macro }}}

%build

%install
mkdir -p %{buildroot}%{_datadir}/icons/%{name}

cp -a links src %{buildroot}%{_datadir}/icons/%{name}/
cp -a index.theme %{buildroot}%{_datadir}/icons/%{name}/

%files
%license LICENSE
%doc README.md
%{_datadir}/icons/%{name}
