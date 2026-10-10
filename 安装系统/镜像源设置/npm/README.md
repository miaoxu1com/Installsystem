# npm / pnpm 镜像与目录配置

## npm（.npmrc，用户级 `C:\Users\<用户>\.npmrc`）

配置模板已提取至: [npmrc模板-淘宝镜像与自定义目录.ini](npmrc模板-淘宝镜像与自定义目录.ini)

`registry` 设置为 npmmirror（淘宝镜像）加速下载；`prefix`/`cache` 自定义全局安装与缓存路径，按需修改盘符。

## pnpm（rc 配置）

配置模板已提取至: [pnpmrc模板-store与缓存目录.ini](pnpmrc模板-store与缓存目录.ini)

## 相关

- npm 配置文件位置与缓存命令见 window-dev 仓库 [node/README.md](https://github.com/miaoxu1com/window-dev/tree/main/node)

## 脚本

- [node_js_mirror.bat](node_js_mirror.bat)：chsrc 一键切 npm 到 npmmirror
- [pnpm目录配置.bat](pnpm目录配置.bat)：pnpm store/cache/global 目录初始化与配置
