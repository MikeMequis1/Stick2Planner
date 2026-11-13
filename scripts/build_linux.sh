#!/usr/bin/env bash
# Gera o bundle Linux x64, tar.gz portátil, pacote .deb e (opcional) AppImage.
#
# Uso:
#   ./scripts/build_linux.sh
#   FLUTTER_BIN=/opt/flutter/bin/flutter ./scripts/build_linux.sh
#
# Pré-requisitos (Ubuntu/Debian):
#   clang cmake ninja-build pkg-config libgtk-3-dev libsecret-1-dev
#   dpkg-deb (pacote dpkg) para o .deb
#   appimagetool no PATH para o AppImage (opcional)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
FULL_VERSION="$(sed -n 's/^version:[[:space:]]*//p' pubspec.yaml | head -n 1 | tr -d '\r')"
if [[ -z "$FULL_VERSION" ]]; then
  echo "Versão não encontrada em pubspec.yaml" >&2
  exit 1
fi
VERSION="${FULL_VERSION%%+*}"

BUNDLE="$ROOT/build/linux/x64/release/bundle"
DIST="$ROOT/dist/linux"
# A montagem acontece em /tmp: permissões e ownership não podem ser
# normalizados em sistemas de arquivos como drvfs/WSL (/mnt/c).
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/stick2planner-package.XXXXXX")"
STAGE="$WORK_DIR/Stick2Planner-$VERSION-linux-x64"
trap 'rm -rf "$WORK_DIR"' EXIT

normalize_bundle_permissions() {
  local dir="$1"
  find "$dir" -type d -exec chmod 0755 {} +
  find "$dir" -type f -exec chmod 0644 {} +
  if [[ -f "$dir/stick2planner" ]]; then
    chmod 0755 "$dir/stick2planner"
  fi
}

"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" build linux --release

if [[ ! -x "$BUNDLE/stick2planner" ]]; then
  echo "Bundle Linux não encontrado em $BUNDLE" >&2
  exit 1
fi

rm -rf "$STAGE"
mkdir -p "$STAGE"
cp -a "$BUNDLE/." "$STAGE/"
normalize_bundle_permissions "$STAGE"

cat > "$STAGE/README.txt" <<EOF
Stick2Planner $VERSION - bundle Linux x64

Execute ./stick2planner. Mantenha a pasta lib/ e data/ ao lado do executável.

Os dados do usuário ficam em \$XDG_DATA_HOME/com.mikemequis1.planner e
permanecem ao substituir este bundle.
EOF

TAR_FILE="$DIST/Stick2Planner-$VERSION-linux-x64.tar.gz"
tar -C "$WORK_DIR" --owner=0 --group=0 --numeric-owner \
  -czf "$TAR_FILE" "$(basename "$STAGE")"
echo "Bundle portátil: $TAR_FILE"

# ---- .deb ---------------------------------------------------------------
DEB_ROOT="$WORK_DIR/deb/Stick2Planner-$FULL_VERSION"
mkdir -p \
  "$DEB_ROOT/DEBIAN" \
  "$DEB_ROOT/opt/stick2planner" \
  "$DEB_ROOT/usr/bin" \
  "$DEB_ROOT/usr/share/applications" \
  "$DEB_ROOT/usr/share/icons/hicolor/256x256/apps"

cp -a "$BUNDLE/." "$DEB_ROOT/opt/stick2planner/"
normalize_bundle_permissions "$DEB_ROOT/opt/stick2planner"
ln -s /opt/stick2planner/stick2planner "$DEB_ROOT/usr/bin/stick2planner"
cp packaging/linux/stick2planner.desktop "$DEB_ROOT/usr/share/applications/"
cp packaging/linux/stick2planner.png \
  "$DEB_ROOT/usr/share/icons/hicolor/256x256/apps/stick2planner.png"

installed_kb="$(du -sk "$DEB_ROOT/opt/stick2planner" | cut -f1)"
cat > "$DEB_ROOT/DEBIAN/control" <<EOF
Package: stick2planner
Version: $FULL_VERSION
Section: office
Priority: optional
Architecture: amd64
Maintainer: MikeMequis1 <mikemequis1@users.noreply.github.com>
Installed-Size: $installed_kb
Depends: libc6, libstdc++6, libgtk-3-0 | libgtk-3-0t64, libglib2.0-0 | libglib2.0-0t64, libsecret-1-0 | libsecret-1-0t64
Description: Offline-first visual planner for Android, Windows and Linux
 Calendar, inbox, notes and routines stored locally in SQLite.
 Synchronization with your own server is optional.
EOF

chmod 0755 "$DEB_ROOT/opt/stick2planner/stick2planner"
chmod 0644 "$DEB_ROOT/usr/share/applications/stick2planner.desktop"
chmod 0644 "$DEB_ROOT/usr/share/icons/hicolor/256x256/apps/stick2planner.png"
find "$DEB_ROOT" -type d -exec chmod 0755 {} +

DEB_FILE="$DIST/stick2planner_${FULL_VERSION}_amd64.deb"
if command -v dpkg-deb >/dev/null 2>&1; then
  dpkg-deb --root-owner-group --build "$DEB_ROOT" "$DEB_FILE"
  echo "Pacote Debian: $DEB_FILE"
else
  echo "dpkg-deb não encontrado; .deb não foi gerado." >&2
fi

# ---- AppImage (opcional) ------------------------------------------------
if command -v appimagetool >/dev/null 2>&1; then
  APPDIR="$WORK_DIR/AppDir"
  mkdir -p \
    "$APPDIR/usr/bin" \
    "$APPDIR/usr/lib/stick2planner" \
    "$APPDIR/usr/share/applications" \
    "$APPDIR/usr/share/icons/hicolor/256x256/apps"
  cp -a "$BUNDLE/." "$APPDIR/usr/lib/stick2planner/"
  normalize_bundle_permissions "$APPDIR/usr/lib/stick2planner"
  cp packaging/linux/stick2planner.desktop "$APPDIR/"
  cp packaging/linux/stick2planner.desktop \
    "$APPDIR/usr/share/applications/"
  cp packaging/linux/stick2planner.png "$APPDIR/stick2planner.png"
  cp packaging/linux/stick2planner.png \
    "$APPDIR/usr/share/icons/hicolor/256x256/apps/stick2planner.png"
  cat > "$APPDIR/AppRun" <<'EOF'
#!/usr/bin/env bash
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/lib/stick2planner/stick2planner" "$@"
EOF
  chmod +x "$APPDIR/AppRun"
  ARCH=x86_64 appimagetool \
    "$APPDIR" "$DIST/Stick2Planner-$VERSION-linux-x64.AppImage"
  echo "AppImage: $DIST/Stick2Planner-$VERSION-linux-x64.AppImage"
else
  echo "appimagetool não encontrado; AppImage não foi gerado." >&2
fi
