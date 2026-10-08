# 终端配置（PowerShell）

## 文件说明

| 文件 | 说明 |
|---|---|
| [Microsoft.PowerShell_profile.ps1](Microsoft.PowerShell_profile.ps1) | PowerShell $PROFILE 完整配置（Catppuccin 配色、PSReadLine、fzf、别名、oh-my-posh 等） |
| [powershell.config.json](powershell.config.json) | PowerShell 全局配置 |
| [PSFzf用法.md](PSFzf用法.md) | PSFzf 快捷键与用法 |
| [配色.md](配色.md) | 日志级别配色 RGB 值 |

## Maple Mono 字体注意事项

配合 [Maple Mono](https://github.com/subframe7536/maple-font/blob/variable/README_CN.md) 使用。

Maple Mono 要显示连字效果时，**PSReadLine 不能开启补全以列表展示**（ListView 会干扰渲染）。

## PSReadLine 与 PSCompletions

- PSReadLine 是 Terminal 自带的自动补全模块，**不支持第三方命令**，只支持 terminal 内部命令；外部命令需要安装第三方模块实现自动补全
- PSCompletions 和 PSReadLine **冲突**：设置 Tab 为 MenuComplete 后 PSCompletions 不生效
- 参考：[让你的命令行自动补全功能更强大（知乎）](https://zhuanlan.zhihu.com/p/634110021)、[PSCompletions（Gitee）](https://gitee.com/abgox/PSCompletions)、[配置 PowerShell PSReadLine 模块](https://www.fournoas.com/posts/configuring-psreadline-module-of-powershell/)

## 常用模块清单

原仓库备份的模块二进制未并入（可通过 `Install-Module` 重装）：

```
Catppuccin, CompletionPredictor, Fasdr, GuiCompletion, posh-git,
PowerShellGet, PSCompletions, PSEverything, PSReadLine,
PSWindowsUpdate, Terminal-Icons, ZLocation
```
