# winget-fast.ps1 — winget GitHub 加速安装脚本

## winget source 换源（USTC 镜像）

脚本已提取至: [winget源换为USTC镜像.ps1](winget源换为USTC镜像.ps1)(官方源: `https://cdn.winget.microsoft.com/cache`)

> 配置软件包的默认安装路径：执行 `winget settings` 自动打开配置文件，在其中加入安装路径相关配置。

## winget-fast 脚本

解决 winget 社区源中 **GitHub 系安装包下载慢** 的问题：拉取官方清单 → 将清单里的 `github.com` 下载地址拼接 `https://gh-proxy.com/` → 用修改后的本地清单执行 `winget install --manifest`。

gh-proxy 是字节级透传反代，下载的安装包与原始地址**完全一致**，因此 winget 的 SHA256 校验照常通过（已实测验证）。

## 用法

推荐使用工作流脚本(自动完成前置条件 + 可选换源 + 加速安装): [工作流-winget加速安装.ps1](工作流-winget加速安装.ps1)

```powershell
powershell -ExecutionPolicy Bypass -File .\工作流-winget加速安装.ps1 -Id GitHub.cli -SwitchSource
```

单独使用 winget-fast:

```powershell
powershell -ExecutionPolicy Bypass -File .\winget-fast.ps1 -Id <包ID>

# 示例
powershell -ExecutionPolicy Bypass -File .\winget-fast.ps1 -Id GitHub.cli
powershell -ExecutionPolicy Bypass -File .\winget-fast.ps1 -Id Neovim.Neovim -Version 0.11.0
```

参数：

| 参数 | 默认 | 说明 |
|---|---|---|
| `-Id` | （必填） | winget 包 ID，`winget search` 可查 |
| `-Version` | 最新版 | 指定版本，缺省自动解析 |
| `-ProxyPrefix` | `https://gh-proxy.com/` | 可换成自建或其他反代前缀 |
| `-WorkDir` | `%TEMP%\winget-fast` | 清单下载目录 |

远程一键执行，见 [远程下载并执行winget-fast.ps1](远程下载并执行winget-fast.ps1)。

## 前置条件（一次性）

1. **开启本地清单安装**（需管理员，仅需一次），见 [启用winget本地清单安装.ps1](启用winget本地清单安装.ps1)。

2. 若 `winget` 命令无响应/exit 255（应用执行别名损坏）：
   - 脚本已内置自动回退到真实路径，无需处理；
   - 永久修复：设置 → 应用 → 高级应用设置 → 应用执行别名 → 「应用安装程序」关闭再开启。

## 适用范围

- ✅ winget 社区源中 InstallerUrl 为 `github.com` / `objects.githubusercontent.com` 的包（最慢的一批，正是本脚本目标）
- ➖ 其他厂商 CDN 地址保持直连，不受影响
- ❌ msstore 源的包（不走清单，无法加速）

## 原理

```
winget show 解析版本
  → 从 microsoft/winget-pkgs 拉取清单 YAML（gh-proxy 加速）
  → 清单内 https://github.com 替换为 https://gh-proxy.com/https://github.com
  → winget install --manifest <本地目录>
  → 哈希校验通过（字节一致）→ 正常安装并纳入 winget 管理
```
