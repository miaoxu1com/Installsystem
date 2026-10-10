# 来源: scoop/README.md
# 功能: 在 $PROFILE 中配置 argc-completions 与 PSCompletions 结合
# 参考: https://pscompletions.abgox.com/zh-CN/faq/pscompletions-and-argc-completions

# ===== 方式一: 使用 scoop 安装 argc-completions 后 =====
$argc_scripts = $env:ARGC_COMPLETIONS_PATH -split [System.IO.Path]::PathSeparator | Get-ChildItem -File | ForEach-Object { $_.BaseName }
$PSCompletions.argc_completions($argc_scripts)

# ===== 方式二: 手动安装版(多三行环境变量初始化) =====
# $env:ARGC_COMPLETIONS_ROOT = 'D:\argc-completions'
# $env:ARGC_COMPLETIONS_PATH = ($env:ARGC_COMPLETIONS_ROOT + '\completions\windows;' + $env:ARGC_COMPLETIONS_ROOT + '\completions')
# $env:PATH = $env:ARGC_COMPLETIONS_ROOT + '\bin' + [IO.Path]::PathSeparator + $env:PATH
# # 只给指定命令加补全可修改下一行，如 $argc_scripts = @("cargo", "git")
# $argc_scripts = $env:ARGC_COMPLETIONS_PATH -split [System.IO.Path]::PathSeparator | Get-ChildItem -File | ForEach-Object { $_.BaseName }
# $PSCompletions.argc_completions($argc_scripts)

# ===== PSReadLine 和 PSCompletions 同时生效的 $PROFILE 配置 =====
# Set-PSReadLineOption -PredictionViewStyle ListView
# Import-Module PSCompletions
# $argc_scripts = $env:ARGC_COMPLETIONS_PATH -split [System.IO.Path]::PathSeparator | Get-ChildItem -File | ForEach-Object { $_.BaseName }
# argc --argc-completions powershell $argc_scripts | Out-String | Invoke-Expression
