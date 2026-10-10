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

脚本已提取至: [配置git全局URL替换-insteadOf.sh](配置git全局URL替换-insteadOf.sh)(含设置/查看/取消命令)

> 注意：insteadOf 会影响**所有** git 拉取操作（包括 scoop bucket 同步），镜像站失效后会导致所有 git 操作报错，不建议长期使用。
>
> 对 scoop 的影响：**bucket 的添加/同步生效**（走的是 git），但 **scoop 下载软件安装包不走 git**（用的是内置 HTTP 下载器），所以 `scoop install` 的下载地址不受此配置影响。scoop 的下载加速要用 [scoop/README.md](../scoop/README.md) 里的 URL 替换方案。

## 相关

- scoop 场景下的 URL 替换方案见本仓库 [scoop/README.md](../scoop/README.md)
- winget 下载加速见本仓库 [winget/README.md](../winget/README.md)

## 脚本

### 配置类

- [git_config.bat](git_config.bat)：一键配置 insteadOf 全局替换（谨慎，见上文注意事项）
- [配置git全局URL替换-insteadOf.sh](配置git全局URL替换-insteadOf.sh)：insteadOf 设置/查看/取消

### 仓库管理工具（PowerShell）

| 脚本 | 作用 | 依赖 |
|---|---|---|
| [github_sync_gitee.ps1](github_sync_gitee.ps1) | GitHub 仓库一键同步到 Gitee：代码全 ref + Wiki + Release 二进制附件 | **PowerShell 7+**、gh CLI（已登录）、git、**Gitee 私人令牌** |
| [github_make_repo_public.ps1](github_make_repo_public.ps1) | 单个仓库私有转公开（GitHub / Gitee 双平台，默认需 yes 确认，`-Force` 跳过） | PowerShell 5.1+；GitHub 模式需 gh CLI，Gitee 模式需 Gitee 令牌 |
| [github_batch_make_public.ps1](github_batch_make_public.ps1) | 按清单批量私有转公开（一次性批处理，逐仓库报成功/失败） | PowerShell 5.1+、gh CLI、清单文件 `%TEMP%\priv.json` |

**依赖说明**：

1. **gh CLI**：GitHub 官方命令行，`gh auth login` 登录一次即可。脚本自动探测 `D:\tools\gh\bin\gh.exe` 或 PATH 中的 gh。
2. **Gitee 私人令牌**：[gitee.com](https://gitee.com) → 设置 → 私人令牌 → 生成（勾选 `projects` 权限）。用 `-GiteeToken` 传入或设环境变量 `$env:GITEE_TOKEN`。
3. **PowerShell 7**：`github_sync_gitee.ps1` 用了 PS7 的 `Invoke-RestMethod -Form` 上传 release 附件，需 [pwsh](https://github.com/PowerShell/PowerShell)；其余两个脚本 PS 5.1 即可。
4. **加速**：`github_sync_gitee.ps1` 克隆/推送默认走 `https://gh-proxy.com/` 前缀，可用 `-ProxyPrefix` 换自建反代或置空直连。

**用法**：

```powershell
# ① 同步单个仓库到 Gitee（先 DryRun 看计划，免令牌）
pwsh -File github_sync_gitee.ps1 -GitHubRepo owner/repo -GiteeOwner <gitee用户名> -DryRun
pwsh -File github_sync_gitee.ps1 -GitHubRepo owner/repo -GiteeOwner <gitee用户名> -GiteeToken <令牌>

# ② 单个仓库转公开
pwsh -File github_make_repo_public.ps1 -Repo owner/repo            # GitHub
pwsh -File github_make_repo_public.ps1 -Repo owner/repo -Platform gitee -GiteeToken <令牌>

# ③ 批量转公开（先生成清单）
gh repo list <用户名> --visibility private --limit 100 --json name,description,diskUsage,pushedAt > $env:TEMP\priv.json
pwsh -File github_batch_make_public.ps1
```

**注意**：`github_batch_make_public.ps1` 会读取固定的 `$env:TEMP\priv.json` 清单文件并逐个翻转可见性，属于一次性批处理工具，运行前请人工核对清单内容；公开操作不可逆，注意历史中的敏感信息。
