#!/usr/bin/env bash
set -euo pipefail

source_url='https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest/Qoder-CN-linux-amd64.deb'
sharun_url='https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/main/useful-tools/quick-sharun.sh'
output_dir=$(cd -- "$(dirname -- "$0")" && pwd)
cd "$output_dir"

for tool in curl dpkg-deb distrobox sha256sum; do
    command -v "$tool" >/dev/null || { printf '缺少命令：%s\n' "$tool" >&2; exit 1; }
done

distrobox list | grep -Eq '^[^|]*\|[[:space:]]*archbox[[:space:]]*\|' || {
    printf '未找到 archbox 容器，请先创建：distrobox create -n archbox -i archlinux\n' >&2
    exit 1
}

work=$(mktemp -d "$output_dir/.qoder-build.XXXXXXXX")
trap 'rm -rf -- "$work"' EXIT
curl -fL --retry 3 -o "$work/qoder.deb" "$source_url"
curl -fL --retry 3 -o "$work/quick-sharun" "$sharun_url"
chmod +x "$work/quick-sharun"
package=$(dpkg-deb -f "$work/qoder.deb" Package)
[[ "$package" == qoder-cn ]] || { printf '软件包名称不符：%s\n' "$package" >&2; exit 1; }
version=$(dpkg-deb -f "$work/qoder.deb" Version)
version=${version#*:}
[[ "$version" =~ ^[a-zA-Z0-9.+~-]+$ ]] || { printf '软件包版本格式不符：%s\n' "$version" >&2; exit 1; }
dpkg-deb -x "$work/qoder.deb" "$work/deb-root"

cat > "$work/build-in-archbox.sh" <<'BUILD'
#!/usr/bin/env bash
set -euo pipefail
work=$1
version=$2
cd "$work"
sudo pacman -Syu --noconfirm --needed strace patchelf gtk3 libnotify nss libxss libxtst xdg-utils at-spi2-core libsecret desktop-file-utils alsa-lib

mkdir -p AppDir/bin
cp -a deb-root/opt/Qoder-CN/. AppDir/bin/
rm -- AppDir/bin/qoder-cn
sed 's@^Exec=/opt/Qoder-CN/qoder-cn@Exec=qoder-cn@' deb-root/usr/share/applications/qoder-cn.desktop > qoder-cn.desktop
grep -q '^Exec=qoder-cn ' qoder-cn.desktop

export APPDIR="$work/AppDir"
export DESKTOP="$work/qoder-cn.desktop"
export ICON="$work/deb-root/usr/share/icons/hicolor/512x512/apps/qoder-cn.png"
export OUTPATH="$work"
export OUTNAME="Qoder-CN-${version}-x86_64.AppImage"
export NO_STRIP=1
export STRACE_MODE=0
export I_WANT_FAT_APPIMAGE=1
./quick-sharun "$work/deb-root/opt/Qoder-CN/qoder-cn"
./quick-sharun --make-appimage
test -s "$OUTPATH/$OUTNAME"
BUILD

distrobox enter archbox -- bash "$work/build-in-archbox.sh" "$work" "$version"
image="Qoder-CN-${version}-x86_64.AppImage"
mv -f -- "$work/$image" "$output_dir/$image"
sha256sum "$output_dir/$image"
printf '打包完成：%s\n' "$output_dir/$image"
