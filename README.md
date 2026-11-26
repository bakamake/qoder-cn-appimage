# Qoder CN AppImage

基于 [pkgforge-dev/Anylinux-AppImages](https://github.com/pkgforge-dev/Anylinux-AppImages) 的 `quick-sharun.sh` 将 [Qoder CN deb](https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest/Qoder-CN-linux-amd64.deb) 打包为 AppImage。

产物位于仓库根目录，通过 Git LFS 存储。Release 中提供直接下载的 AppImage。

## 更新

在已安装 `curl`、`dpkg-deb`、`podman`、`distrobox` 和 Git LFS 的 Linux 机器上创建 Arch 容器：

```sh
distrobox create -n archbox -i archlinux
./update-qoder.sh
git add .
git commit -m 'Update Qoder CN to 0.5.20'
git tag v0.5.20
git push origin master
git push origin v0.5.20
```

将命令中的版本替换为本次脚本输出的版本。推送版本标签后，GitHub Actions 从仓库的 Git LFS 下载该版本 AppImage 并发布 Release。脚本会清理临时构建目录；旧版本产物可按需从工作树删除并正常提交删除记录。
