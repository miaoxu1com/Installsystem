# Scoop 国内镜像源配置

国内使用 Scoop 的完整方案：安装本体、配置 Gitee 镜像 buckets、GitHub 下载加速。

## 脚本一览

| 脚本 | 作用 | 使用场景 |
|---|---|---|
| [工作流-Scoop国内环境一键配置.ps1](工作流-Scoop国内环境一键配置.ps1) | 按依赖顺序编排下面所有步骤(`-All` 一键) | 新机器推荐 |
| [Install-Scoop.ps1](Install-Scoop.ps1) | 通过 Gitee 镜像安装 Scoop 本体 | 新机器首次安装 |
| [Add-ScoopBuckets.ps1](Add-ScoopBuckets.ps1) | 添加 Gitee 镜像 buckets（main/extras/versions/scoopcn） | 安装后必做 |
| [Install-ScoopTools.ps1](Install-ScoopTools.ps1) | abgox scoop-tools 加速方案，GitHub 下载自动走代理 | 可选，推荐 |
| [启用scoop命令补全-PSCompletions.ps1](启用scoop命令补全-PSCompletions.ps1) | $PROFILE 中启用 scoop 命令补全 | 可选 |
| [配置scoop的HTTP代理.ps1](配置scoop的HTTP代理.ps1) | scoop HTTP 代理设置/删除 | 有代理时 |
| [设置SCOOP_REPO镜像源.ps1](设置SCOOP_REPO镜像源.ps1) | SCOOP_REPO 备选镜像 | 可选 |
| [配置url_proxy-仅Gitee修改版scoop.ps1](配置url_proxy-仅Gitee修改版scoop.ps1) | 自建 url_proxy | 仅 Gitee 修改版 |
| [添加spc-bucket并切换main分支.ps1](添加spc-bucket并切换main分支.ps1) | spc bucket(约 1 万软件清单) | 可选 |
| [添加apps-bucket更多软件清单.ps1](添加apps-bucket更多软件清单.ps1) | apps bucket | 可选 |
| [配置argc-completions结合PSCompletions.ps1](配置argc-completions结合PSCompletions.ps1) | argc-completions 与 PSCompletions 结合 | 可选 |
| [修复bucket仓库地址变更.ps1](修复bucket仓库地址变更.ps1) | bucket 上游地址变更后的迁移修复 | 出错时 |

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

> 可选：如果想要更多软件清单（约 1 万个），还可以添加 spc bucket，见 [添加spc-bucket并切换main分支.ps1](添加spc-bucket并切换main分支.ps1)。
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

启用命令补全需在 `$PROFILE` 中添加配置，见 [启用scoop命令补全-PSCompletions.ps1](启用scoop命令补全-PSCompletions.ps1)。

## 已失效/受限方案（存档）

- ❌ **scoop-cn bucket**（`scoop bucket add scoop-cn https://mirror.ghproxy.com/https://github.com/duzyn/scoop-cn`）：已停止更新，测试确认已失效
- ⚠️ **git insteadOf 替换**：对 scoop 只能加速 bucket 同步，`scoop install` 下载不受影响，详细说明和用法见 [git/README.md](../git/README.md)
- ❌ **已失效镜像站**（存档勿用）：`github.com.cnpmjs.org`（阿里镜像）、`hub.fastgit.org`、`download.fastgit.org`、`github.91chifun.workers.dev`（Cloudflare Workers）

## 进阶配置

### HTTP 代理

脚本已提取至: [配置scoop的HTTP代理.ps1](配置scoop的HTTP代理.ps1)

### scoop config 配置文件位置

```
X:\Scoop\config\scoop    # 安装目录下的 config\scoop
```

### SCOOP_REPO 备选镜像

脚本已提取至: [设置SCOOP_REPO镜像源.ps1](设置SCOOP_REPO镜像源.ps1)

> 注意：私有仓库无法通过镜像站下载 release（镜像只代理公开资源）。

相关项目：[lzwme/scoop-proxy-cn](https://github.com/lzwme/scoop-proxy-cn)

### 自建 url_proxy（仅 Gitee 修改版 scoop 支持）

> 注意：只有 [Gitee 修改版 scoop](https://gitee.com/scoop-installer-mirrors) 才支持 `url_proxy` 配置，archive 分支和原版 scoop 设置无效。

脚本已提取至: [配置url_proxy-仅Gitee修改版scoop.ps1](配置url_proxy-仅Gitee修改版scoop.ps1)

可供设置的代理站：

- [pd.zwc365.com](https://pd.zwc365.com)（文件大小限制 2G）
- [pd.zwc365.com/cfworker](https://pd.zwc365.com/cfworker)（CloudFlare 加速，文件大小无限制）

### spc bucket 使用细节

脚本已提取至: [添加spc-bucket并切换main分支.ps1](添加spc-bucket并切换main分支.ps1)

注意：该仓库默认分支不是 master，不切换会导致清单拉取异常。

### PSCompletions 与 argc-completions 结合

参考 [官方 FAQ](https://pscompletions.abgox.com/zh-CN/faq/pscompletions-and-argc-completions)。

脚本已提取至: [配置argc-completions结合PSCompletions.ps1](配置argc-completions结合PSCompletions.ps1)(含 scoop 安装版、手动版、以及与 PSReadLine 同时生效的 $PROFILE 配置)

### bucket 仓库地址变更后的迁移修复

当 bucket 上游仓库地址变化时，`scoop list` 和 `scoop install` 会报错，需要把已安装 app 记录的仓库地址替换为新地址。

脚本已提取至: [修复bucket仓库地址变更.ps1](修复bucket仓库地址变更.ps1)

### apps bucket（更多软件清单）

脚本已提取至: [添加apps-bucket更多软件清单.ps1](添加apps-bucket更多软件清单.ps1)

## 参考链接

- [abgox/scoop-tools 中文文档](https://scoop-tools.abgox.com/zh-CN/) / [GitHub 仓库](https://github.com/abgox/scoop-tools/blob/main/readme.zh-CN.md)
- [abyss bucket 应用列表](https://abyss.abgox.com/zh-CN/app-list/)
- [duzyn/scoop-cn](https://github.com/duzyn/scoop-cn)（已失效，仅存档）
- [lzwme/scoop-proxy-cn](https://github.com/lzwme/scoop-proxy-cn) / [作者说明](https://lzw.me/a/scoop.html)
- [gitee.com/scoop-installer 组织](https://gitee.com/scoop-installer?skip_mobile=true)
- [gitee.com/xrgzs/scoop](https://gitee.com/xrgzs/scoop)
- [BBDXF/scoopex](https://github.com/BBDXF/scoopex?tab=readme-ov-file)

## 环境要求

- Windows 10/11
- PowerShell 5.1+ 或 PowerShell 7+
