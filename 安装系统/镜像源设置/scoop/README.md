# Scoop 国内镜像源配置

国内使用 Scoop 的完整方案：安装本体、配置 Gitee 镜像 buckets、GitHub 下载加速。

## 脚本一览

| 脚本 | 作用 | 使用场景 |
|---|---|---|
| [Install-Scoop.ps1](Install-Scoop.ps1) | 通过 Gitee 镜像安装 Scoop 本体 | 新机器首次安装 |
| [Add-ScoopBuckets.ps1](Add-ScoopBuckets.ps1) | 添加 Gitee 镜像 buckets（main/extras/versions/scoopcn） | 安装后必做 |
| [Install-ScoopTools.ps1](Install-ScoopTools.ps1) | abgox scoop-tools 加速方案，GitHub 下载自动走代理 | 可选，推荐 |

## 方法一：Gitee 镜像安装 Scoop（推荐）

```powershell
powershell -ExecutionPolicy Bypass -File .\Install-Scoop.ps1
powershell -ExecutionPolicy Bypass -File .\Install-Scoop.ps1 -ScoopDir "E:\scoop"   # 自定义目录
```

脚本会自动完成：

1. 设置执行策略 `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
2. 从 Gitee 镜像下载并执行安装脚本
3. 配置 `scoop config scoop_repo https://gitee.com/scoop-installer-mirrors/Scoop`
4. 开启 `scoop config use_sqlite_cache true`（优化 scoop search 性能）

> 安装完成后还需要 **7zip 和 git**。如果网络问题无法通过 scoop 安装它们，请手动下载安装，然后运行 `scoop config use_external_7zip true`。

## 方法二：添加 Gitee 镜像 buckets

```powershell
powershell -ExecutionPolicy Bypass -File .\Add-ScoopBuckets.ps1
```

添加的 buckets（全部为 Gitee 纯净官方镜像库）：

| Bucket | 地址 |
|---|---|
| main | https://gitee.com/scoop-installer/Main |
| extras | https://gitee.com/scoop-installer/Extras |
| versions | https://gitee.com/scoop-installer/Versions |
| scoopcn | https://gitee.com/scoop-installer/scoopcn |

已存在的同名 bucket 会先移除再按新源添加，保证源地址正确。

> 可选：如果想要更多软件清单（约 1 万个），还可以添加 spc bucket：
> `scoop bucket add spc https://gitee.com/wlzwme/scoop-proxy-cn.git`
> 它是 [lzwme/scoop-proxy-cn](https://github.com/lzwme/scoop-proxy-cn) 的 Gitee 镜像。

## 方法三：abgox scoop-tools 加速（解决 GitHub 下载失败）

不具备特殊网络条件时，无法正常下载托管在 GitHub 上的软件。使用 [abgox/scoop-tools](https://scoop-tools.abgox.com/zh-CN/) 提供的 `scoop-install` 和 `scoop-update`，下载时自动替换为代理 URL：

```powershell
powershell -ExecutionPolicy Bypass -File .\Install-ScoopTools.ps1
powershell -ExecutionPolicy Bypass -File .\Install-ScoopTools.ps1 -ProxyPrefix "https://your-proxy.com/"  # 自定义代理
```

脚本会自动完成：

1. 添加 abyss bucket：`scoop bucket add abyss https://gitee.com/abgox/abyss`
2. 安装 `scoop-install` 和 `scoop-update`
3. 配置 URL 替换规则（多个值用 `|||` 分割）：
   - `^https://github.com` → `https://gh-proxy.com/github.com`
   - `^https://raw.githubusercontent.com` → `https://gh-proxy.com/raw.githubusercontent.com`
4. 安装 [scoop-i18n](https://github.com/abgox/scoop-i18n) 中文支持
5. 安装 [PSCompletions](https://github.com/abgox/PSCompletions) 命令补全

之后日常使用：

```powershell
scoop-install <软件名>   # 替代 scoop install
scoop-update <软件名>    # 替代 scoop update
scoop-update *           # 更新全部
```

启用命令补全需在 `$PROFILE` 中添加：

```powershell
Import-Module PSCompletions
psc add scoop scoop-install scoop-update
```

## 已失效/受限方案（存档）

- ❌ **scoop-cn bucket**（`scoop bucket add scoop-cn https://mirror.ghproxy.com/https://github.com/duzyn/scoop-cn`）：已停止更新，测试确认已失效
- ⚠️ **git insteadOf 替换**（`git config --global url."https://gh.llkk.cc/https://github.com".insteadOf "https://github.com"`）：**git 操作会走**此配置（`git clone` / `git fetch`，包括 `scoop bucket add`、`scoop update` 时的 bucket 仓库同步都生效），但 **scoop 下载软件安装包不走 git**（用的是内置 HTTP 下载器），所以 `scoop install` 的下载地址不受此配置影响。它只能加速 bucket 同步，不能解决软件下载慢的问题

## 参考链接

- [abgox/scoop-tools 中文文档](https://scoop-tools.abgox.com/zh-CN/) / [GitHub 仓库](https://github.com/abgox/scoop-tools/blob/main/readme.zh-CN.md)
- [abyss bucket 应用列表](https://abyss.abgox.com/zh-CN/app-list/)
- [duzyn/scoop-cn](https://github.com/duzyn/scoop-cn)（已失效，仅存档）
- [lzwme/scoop-proxy-cn](https://github.com/lzwme/scoop-proxy-cn) / [作者说明](https://lzw.me/a/scoop.html)
- [gitee.com/scoop-installer 组织](https://gitee.com/scoop-installer?skip_mobile=true)
- [gitee.com/xrgzs/scoop](https://gitee.com/xrgzs/scoop)
- [github.akams.cn 加速服务](https://github.akams.cn)
- [BBDXF/scoopex](https://github.com/BBDXF/scoopex?tab=readme-ov-file)

## 环境要求

- Windows 10/11
- PowerShell 5.1+ 或 PowerShell 7+
