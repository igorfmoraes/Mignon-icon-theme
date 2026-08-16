#!/usr/bin/env bash

update_theme() {
	local -r REPO_URL='https://github.com/igorfmoraes/Mignon-icon-theme.git'
	local -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

	if ! command -v git >/dev/null 2>&1; then
		return
	fi

	if ! git -C "${SCRIPT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		return
	fi

	local reply
	read -rp "Git repository detected. Check for updates before installing? [y/N] " reply
	[[ "${reply}" =~ ^[Yy]$ ]] || return

	local -r branch="$(git -C "${SCRIPT_DIR}" rev-parse --abbrev-ref HEAD)"

	if [ "${branch}" = "HEAD" ]; then
		echo "Detached HEAD; skipping update."
		return
	fi

	if ! git -C "${SCRIPT_DIR}" diff-index --quiet HEAD -- 2>/dev/null; then
		echo "Local changes present; skipping update to avoid overwriting them."
		return
	fi

	echo "Pulling from ${REPO_URL} (${branch})..."
	if git -C "${SCRIPT_DIR}" pull "${REPO_URL}" "${branch}"; then
		echo "Update complete."
	else
		echo "Update failed; continuing with existing files."
	fi
}

install_theme() {
	local -r DEST_DIR="${HOME}/.local/share/icons"
	local -r theme_color='#99C0ED'

	local -r THEME_NAME="Mignon-pastel"
	local -r THEME_DIR="${DEST_DIR}/${THEME_NAME}"

	if [ -d "${THEME_DIR}" ]; then
		rm -r "${THEME_DIR}"
	fi

	echo "Installing '${THEME_NAME}'..."

	install -d "${THEME_DIR}"

	install -m644 "src/index.theme" "${THEME_DIR}"

	# Update the name in index.theme
	sed -i "s/%NAME%/${THEME_NAME//-/ }/g" "${THEME_DIR}/index.theme"

	mkdir -p "${THEME_DIR}/scalable"
	cp -r src/scalable/{apps,devices,mimetypes} "${THEME_DIR}/scalable"
	cp -r src/scalable/places "${THEME_DIR}/scalable/places"

	sed -i "s/#5294e2/${theme_color}/g" "${THEME_DIR}/scalable/apps/"*.svg "${THEME_DIR}/scalable/places/"default-*.svg
	sed -i "/\ColorScheme-Highlight/s/currentColor/${theme_color}/" "${THEME_DIR}/scalable/places/"default-*.svg
	sed -i "/\ColorScheme-Background/s/currentColor/#ffffff/" "${THEME_DIR}/scalable/places/"default-*.svg

	cp -r links/scalable "${THEME_DIR}"

	ln -sr "${THEME_DIR}/scalable"                                                 "${THEME_DIR}/scalable@2x"

	gtk-update-icon-cache "${THEME_DIR}"
}

update_theme
install_theme
