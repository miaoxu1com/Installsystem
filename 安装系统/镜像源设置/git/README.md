# Git 代理与 GitHub 加速

## ghproxy 类加速站说明

ghproxy 类加速站支持终端命令行 `git clone`、`wget`、`curl` 等工具下载，支持 `raw.githubusercontent.com`、`gist.github.com`、`gist.githubusercontent.com` 文件下载。**不支持 SSH Key 方式 git clone**。**私有仓库无法通过镜像站下载 release**（镜像只代理公开资源）。

## GitHub 加速站列表

- [ghspeedup.com](https://ghspeedup.com)
- [gitwarp.com](https://www.gitwarp.com)
- [7ed.net/gitmirror](https://www.7ed.net/gitmirror/hub.html)
- [proxy.pipers.cn](https://proxy.pipers.cn)
- [github.akams.cn](https://github.akams.cn)
- [gh.xmly.dev](https://gh.xmly.dev)
- [gh.jasonzeng.dev](https://gh.jasonzeng.dev)
- [doget.nocsdn.com](https://doget.nocsdn.com/#/)

## git 全局 URL 替换（insteadOf）

```bash
# 方式一（地址容易失效，且会影响所有 git 拉取操作，谨慎使用）
git config --global url."https://hub.fastgit.org".insteadOf https://github.com

# 方式二
git config --global url."https://ghproxy.com/https://github.com".insteadOf "https://github.com"

# GitHub 登录凭据走加速站
git config --global credential."https://githubfast.com".provider github
git config --global credential.https://githubfast.com.provider github

# 查看当前配置
git config --global --list

# 取消设置
git config --global --unset url.https://github.com/.insteadof
```

> 注意：insteadOf 会影响**所有** git 拉取操作（包括 scoop bucket 同步），镜像站失效后会导致所有 git 操作报错，不建议长期使用。
>
> 对 scoop 的影响：**bucket 的添加/同步生效**（走的是 git），但 **scoop 下载软件安装包不走 git**（用的是内置 HTTP 下载器），所以 `scoop install` 的下载地址不受此配置影响。scoop 的下载加速要用 [scoop/README.md](../scoop/README.md) 里的 URL 替换方案。

## 相关

- scoop 场景下的 URL 替换方案见本仓库 [scoop/README.md](../scoop/README.md)
- winget 下载加速见本仓库 [winget/README.md](../winget/README.md)
