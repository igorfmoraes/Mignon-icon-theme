#!/usr/bin/env bash

set -uo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}" || exit 1

update_theme() {
	local -r REPO_URL='https://github.com/igorfmoraes/Mignon-icon-theme.git'

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
	local -r variant_suffix="${1:-}"
	local -r apps_src="${2:-src/scalable/apps}"

	local -r DEST_DIR="${HOME}/.local/share/icons"
	local -r theme_color='#99C0ED'

	local THEME_NAME="Mignon-pastel"
	if [ -n "${variant_suffix}" ]; then
		THEME_NAME="${THEME_NAME}-${variant_suffix}"
	fi
	local -r THEME_DIR="${DEST_DIR}/${THEME_NAME}"

	local -ra REQUIRED_PATHS=(
		"src/index.theme"
		"${apps_src}"
		"src/scalable/devices"
		"src/scalable/mimetypes"
		"src/scalable/places"
		"links/scalable"
	)
	local path
	for path in "${REQUIRED_PATHS[@]}"; do
		if [ ! -e "${path}" ]; then
			echo "Missing expected path: ${path}" >&2
			echo "Run this script from within the Mignon-icon-theme repository." >&2
			exit 1
		fi
	done

	if [ -d "${THEME_DIR}" ]; then
		rm -r "${THEME_DIR}"
	fi

	echo "Installing '${THEME_NAME}'..."

	install -d "${THEME_DIR}"

	install -m644 "src/index.theme" "${THEME_DIR}"

	sed -i "s/%NAME%/${THEME_NAME//-/ }/g" "${THEME_DIR}/index.theme"

	mkdir -p "${THEME_DIR}/scalable"
	cp -r "${apps_src}" "${THEME_DIR}/scalable/apps"
	cp -r src/scalable/devices "${THEME_DIR}/scalable"
	cp -r src/scalable/mimetypes "${THEME_DIR}/scalable"
	cp -r src/scalable/places "${THEME_DIR}/scalable/places"

	sed -i "s/#5294e2/${theme_color}/g" "${THEME_DIR}/scalable/apps/"*.svg "${THEME_DIR}/scalable/places/"default-*.svg
	sed -i "/\ColorScheme-Highlight/s/currentColor/${theme_color}/" "${THEME_DIR}/scalable/places/"default-*.svg
	sed -i "/\ColorScheme-Background/s/currentColor/#ffffff/" "${THEME_DIR}/scalable/places/"default-*.svg

	cp -r links/scalable "${THEME_DIR}"

	ln -sr "${THEME_DIR}/scalable"                                                 "${THEME_DIR}/scalable@2x"

	if command -v gtk-update-icon-cache >/dev/null 2>&1; then
		gtk-update-icon-cache "${THEME_DIR}"
	else
		echo "gtk-update-icon-cache not found; skipping icon cache update." >&2
	fi
}

print_usage() {
	cat <<-EOF
	Usage: ${0##*/} [OPTIONS]

	Installs the Mignon-pastel icon theme to ${HOME}/.local/share/icons.
	With no options, only the base theme (Mignon-pastel) is installed.

	  -l, --light   Also install the Mignon-pastel-light variant
	  -d, --dark    Also install the Mignon-pastel-dark variant
	  -a, --all     Shortcut for --light --dark
	  -h, --help    Show this help and exit
	EOF
}

install_light=0
install_dark=0

while [ $# -gt 0 ]; do
	case "$1" in
		-l|--light) install_light=1 ;;
		-d|--dark)  install_dark=1 ;;
		-a|--all)   install_light=1; install_dark=1 ;;
		-h|--help)  print_usage; exit 0 ;;
		*)
			echo "Unknown option: $1" >&2
			print_usage >&2
			exit 1
			;;
	esac
	shift
done

update_theme

install_theme "" "src/scalable/apps"
[ "${install_light}" -eq 1 ] && install_theme "light" "src/scalable/apps-light"
[ "${install_dark}" -eq 1 ]  && install_theme "dark"  "src/scalable/apps-dark"
