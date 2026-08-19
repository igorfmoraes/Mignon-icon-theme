Name:           mignon-icon-theme
Version:        {{{ git_repo_version }}}
Release:        1%{?dist}
Summary:        Flat, pastel-colored icon theme for your Linux workspace
License:        GPLv3+
URL:            https://github.com/igorfmoraes/Mignon-icon-theme
VCS:            {{{ git_repo_vcs }}}
Source0:        {{{ git_repo_pack }}}

BuildArch:      noarch
Requires:       hicolor-icon-theme

%description
Flat, pastel-colored icon theme for your Linux workspace (GNOME, Cinnamon, KDE, Cosmic) with Light/Dark variants available. I created it because finding the perfect pastel icon theme for my computer was a struggle, so here it is to fill this void.

%prep
{{{ git_repo_setup_macro }}}

%build
# No build steps required for SVG icon themes

%install
THEME_COLOR='#99C0ED'
INHERITS='Adwaita,Yaru,Cosmic,Pop,Mint-Y-Blue,breeze,breeze-dark,hicolor'

for VARIANT in "" "-light" "-dark"; do
    THEME_NAME="Mignon-pastel${VARIANT}"
    THEME_DIR="%{buildroot}%{_datadir}/icons/${THEME_NAME}"
    
    if [ "$VARIANT" = "-light" ]; then
        APPS_SRC="src/scalable/apps-light"
    elif [ "$VARIANT" = "-dark" ]; then
        APPS_SRC="src/scalable/apps-dark"
    else
        APPS_SRC="src/scalable/apps"
    fi

    install -d "${THEME_DIR}/scalable"
    
    install -m644 src/index.theme "${THEME_DIR}/"
    sed -i "s/%NAME%/${THEME_NAME//-/ }/g" "${THEME_DIR}/index.theme"
    sed -i "s/%INHERITS%/${INHERITS}/g" "${THEME_DIR}/index.theme"

    cp -a "${APPS_SRC}" "${THEME_DIR}/scalable/apps"
    cp -a src/scalable/devices "${THEME_DIR}/scalable/"
    cp -a src/scalable/mimetypes "${THEME_DIR}/scalable/"
    cp -a src/scalable/places "${THEME_DIR}/scalable/"
    
    sed -i "s/#5294e2/${THEME_COLOR}/g" "${THEME_DIR}/scalable/apps/"*.svg "${THEME_DIR}/scalable/places/"default-*.svg
    sed -i "/ColorScheme-Highlight/s/currentColor/${THEME_COLOR}/" "${THEME_DIR}/scalable/places/"default-*.svg
    sed -i "/ColorScheme-Background/s/currentColor/#ffffff/" "${THEME_DIR}/scalable/places/"default-*.svg

    cp -a links/scalable/* "${THEME_DIR}/scalable/"

    ln -sr "${THEME_DIR}/scalable" "${THEME_DIR}/scalable@2x"
done

%files
%license LICENSE
%doc README.md
%{_datadir}/icons/Mignon-pastel/
%{_datadir}/icons/Mignon-pastel-light/
%{_datadir}/icons/Mignon-pastel-dark/
