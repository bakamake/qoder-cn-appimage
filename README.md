# Qoder CN AppImage

从 [Qoder CN 官方 deb](https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest/Qoder-CN-linux-amd64.deb) 打包。构建工具：[quick-sharun](https://github.com/pkgforge-dev/Anylinux-AppImages)。

```sh
distrobox create -n archbox -i archlinux
./update-qoder.sh
```

产物位于仓库根目录，使用 Git LFS 存储；推送对应版本标签后，Action 发布 Release。
