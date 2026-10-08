# npm / pnpm 镜像与目录配置

## npm（.npmrc，用户级 `C:\Users\<用户>\.npmrc`）

```ini
prefix=E:\Develop\Node\global_modules\
cache=E:\Develop\Node\npm_cache\
registry=https://registry.npmmirror.com
```

`registry` 设置为 npmmirror（淘宝镜像）加速下载；`prefix`/`cache` 自定义全局安装与缓存路径，按需修改盘符。

## pnpm（rc 配置）

```ini
store-dir=E:\Develop\Node\pnpm-store\store\
cache-dir=E:\Develop\Node\pnpm-store\cache\
state-dir=E:\Develop\Node\pnpm-store\state\
global-dir=E:\Develop\Node\pnpm-store\global\
```

## 相关

- npm 配置文件位置与缓存命令见 window-dev 仓库 [node/README.md](https://github.com/miaoxu1com/window-dev/tree/main/node)
