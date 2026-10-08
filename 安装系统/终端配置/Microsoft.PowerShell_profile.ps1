
#-------------------------------   Import-Module BEGIN  -------------------------------
# 这个模块是支持dir自带的命令显示图标，但是lsd eza命令已经自带了，无需单独安装
# Import-Module Terminal-Icons 
# Import-Module CompletionPredictor
# 安装模块要导入才会生效
# Import-Module posh-git # git的自动补全
Import-Module Catppuccin

# Import-Module PSReadLine


# Import-Module ZLocation

# Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"

# Import-Module PSFzf 
#-------------------------------  Import-Module END    ---------------------------------
# 查看模块版本和路径
#Get-Module PSReadLine | Select-Object Version, Path
#-------------------------------  Set Hot-keys BEGIN  -------------------------------
# Pwsh catppuccin theme
$Flavor = $Catppuccin['Mocha']
# PSStyle Catppuccin
# Ref: https://github.com/catppuccin/powershell#profile-usage
$PSStyle.Formatting.Debug = $Flavor.Sky.Foreground()
$PSStyle.Formatting.Error = $Flavor.Red.Foreground()
$PSStyle.Formatting.ErrorAccent = $Flavor.Blue.Foreground()
$PSStyle.Formatting.FormatAccent = $Flavor.Teal.Foreground()
$PSStyle.Formatting.TableHeader = $Flavor.Rosewater.Foreground()
$PSStyle.Formatting.Verbose = $Flavor.Yellow.Foreground()
$PSStyle.Formatting.Warning = $Flavor.Peach.Foreground()
# PSREADLINE CONFIG
# $ScriptBlock = {
#   Param([string]$line)
#   if ($line -like " *")
#   {return $false
#   }
#   $ignore_psreadline = @("user", "pass", "account")
#   foreach ($ignore in $ignore_psreadline)
#   {
#     if ($line -match $ignore)
#     {
#       return $false
#     }
#   }
#   return $true
# }
# Ref: https://github.com/catppuccin/powershell#profile-usage
$Colors = @{
  # Largely based on the Code Editor style guide
  # Emphasis, ListPrediction and ListPredictionSelected are inspired by the Catppuccin fzf theme
	
  # Powershell colours
  ContinuationPrompt     = $Flavor.Teal.Foreground()
  Emphasis               = $Flavor.Red.Foreground()
  Selection              = $Flavor.Surface0.Background()
	
  # PSReadLine prediction colours
  InlinePrediction       = $Flavor.Overlay0.Foreground()
  ListPrediction         = $Flavor.Mauve.Foreground()
  ListPredictionSelected = $Flavor.Surface0.Background()

  # Syntax highlighting
  Command                = $Flavor.Blue.Foreground()
  Comment                = $Flavor.Overlay0.Foreground()
  Default                = $Flavor.Text.Foreground()
  Error                  = $Flavor.Red.Foreground()
  Keyword                = $Flavor.Mauve.Foreground()
  Member                 = $Flavor.Rosewater.Foreground()
  Number                 = $Flavor.Peach.Foreground()
  Operator               = $Flavor.Sky.Foreground()
  Parameter              = $Flavor.Pink.Foreground()
  String                 = $Flavor.Green.Foreground()
  Type                   = $Flavor.Yellow.Foreground()
  Variable               = $Flavor.Lavender.Foreground()
}
# Set-PSReadLineOption -HistorySaveStyle SaveAtExit
$PSReadLineOptions = @{
  EditMode = "emacs"
  AddToHistoryHandler = $ScriptBlock
  Color = $Colors
  ExtraPromptLineCount = $true
  HistoryNoDuplicates = $true
  HistorySaveStyle = "SaveAtExit"
  MaximumHistoryCount = 5000
  PredictionSource = "HistoryAndPlugin"
  PredictionViewStyle = "ListView"
  ShowToolTips = $true
  BellStyle = "None"
  HistorySearchCursorMovesToEnd = $true
}

Set-PSReadLineOption @PSReadLineOptions

function Show-History {
    Get-Content "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
}
# VIM MODE

# function OnViModeChange
# {
#   if ($args[0] -eq 'Command')
#   {
#     # Set the cursor to a blinking block.
#     Write-Host -NoNewLine "`e[1 q"
#   } else
#   {
#     # Set the cursor to a blinking line.
#     Write-Host -NoNewLine "`e[5 q"
#   }
# }

# Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange
# Get-Content "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" 查看所有历史命令
# Get-Content "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Tail 10 查最近10条


# Set jk to exit vi
# Ref: https://github.com/PowerShell/PSReadLine/issues/1701#issuecomment-1445137723
# Set-PSReadLineKeyHandler -Key j -ViMode Insert -ScriptBlock {
#   if (!$j_timer.IsRunning -or $j_timer.ElapsedMilliseconds -gt 1000)
#   {
#     [Microsoft.PowerShell.PSConsoleReadLine]::Insert("k")
#     $j_timer.Restart()
#     return
#   }

#   [Microsoft.PowerShell.PSConsoleReadLine]::Insert("k")
#   [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode()
#   $line = $null
#   $cursor = $null
#   [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
#   [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor-1, 2)
#   [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor-2)
# }

# ref: https://github.com/PowerShell/PSReadLine/issues/759#issuecomment-518363364
# $j_timer = New-Object System.Diagnostics.Stopwatch
# Set-PSReadLineKeyHandler -Chord 'j' -ScriptBlock {
#   if ([Microsoft.PowerShell.PSConsoleReadLine]::InViInsertMode())
#   {
#     $j_timer.ReStart()
#     $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
#     # $key = [System.Console]::ReadKey()
#     if (($j_timer.ElapsedMilliseconds -lt 500) -and $key.Character -eq 'k')
#     {
#       [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode()
#     } else
#     {
#       [Microsoft.Powershell.PSConsoleReadLine]::Insert('j')
#       [Microsoft.Powershell.PSConsoleReadLine]::Insert($key.Character)
#     }
#     $j_timer.Stop()
#   }
# }

# 设置 Tab 为菜单补全和 Intellisense 本功能和PSCompletions冲突，启用后PSCompletions不生效
# Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete


# Set-PsFzfOption -TabExpansion -EnableAliasFuzzyEdit -EnableAliasFuzzyFasd -EnableAliasFuzzyHistory 
# Set-PsFzfOption -EnableAliasFuzzyKillProcess -EnableAliasFuzzySetLocation -EnableAliasFuzzySetEverything
# Set-PsFzfOption -EnableAliasFuzzyScoop -EnableAliasFuzzyZLocation -EnableAliasFuzzyGitStatus -EnableFd
# 设置向上键为后向搜索历史记录
# Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
# 设置向下键为前向搜索历史纪录
# Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward



# Set-PSReadLineKeyHandler -Key "Ctrl+p" -Function HistorySearchBackward
# Set-PSReadLineKeyHandler -Key "Ctrl+n" -Function HistorySearchForward
# Set-PSReadLineKeyHandler -Key "Ctrl+w" -Function BackwardDeleteWord
# Set-PSReadLineKeyHandler -Key "Ctrl+RightArrow" -Function ForwardWord
# Set-PSReadLineKeyHandler -Key "Ctrl+LeftArrow" -Function BackwardWord

# https://ianmorozoff.com/2023/01/10/predictive-intellisense-on-by-default-in-powershell-7-3/#keybinding
# $parameters = @{
#   Key = 'F4'
#   BriefDescription = 'Toggle PSReadLineOption PredictionSource'
#   LongDescription = 'Toggles the PSReadLineOption PredictionSource option between "None" and "HistoryAndPlugin".'
#   ScriptBlock = {
#
#     # Get current state of PredictionSource
#     $state = (Get-PSReadLineOption).PredictionSource
#
#     # Toggle between None and HistoryAndPlugin
#     switch ($state)
#     {
#       "None"
#       {Set-PSReadLineOption -PredictionSource HistoryAndPlugin
#       } 
#       "History"
#       {Set-PSReadLineOption -PredictionSource None
#       }
#       "Plugin"
#       {Set-PSReadLineOption -PredictionSource None
#       }
#       "HistoryAndPlugin"
#       {Set-PSReadLineOption -PredictionSource None
#       }
#       Default
#       {Write-Host "Current PSReadLineOption PredictionSource is Unknown"
#       }
#     }
#
#     # Trigger autocomplete to appear without changing the line
#     # InvokePrompt() does not cause ListView style suggestions to disappear when toggling off
#     #[Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
#
#     # Trigger autocomplete to appear or disappear while preserving the current input
#     [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
#     [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar()
#
#   }
# }
# Set-PSReadLineKeyHandler @parameters

# Clear PSReadLine history
# function Clear-PSReadLineHistory
# {
#   Get-PSReadlineOption | Select-Object -expand HistorySavePath | Remove-Item
# }
##########################################

function test-render() {
    $text = @("你好你好你好", "😄😎🤔")

    $buffer = $Host.UI.RawUI.NewBufferCellArray($text, 'Cyan', 'Black')
    $Host.UI.RawUI.SetBufferContents($Host.UI.RawUI.CursorPosition, $buffer)

    $null = $host.UI.RawUI.ReadKey() # Suspend the process for easy observation
}

# FZF CONFIG
# 使用deepseek把网上linux的配置转换为powersehll的配置
# Ref: https://github.com/catppuccin/powershell#profile-usage 
# https://github.com/catppuccin/fzf - not use background for transparent
$env:FZF_DEFAULT_OPTS=@"
--color=hl:$($Flavor.Red),fg:$($Flavor.Text),header:$($Flavor.Red)
--color=info:$($Flavor.Mauve),pointer:$($Flavor.Rosewater),marker:$($Flavor.Rosewater)
--color=fg+:$($Flavor.Text),prompt:$($Flavor.Mauve),hl+:$($Flavor.Red)
--color=border:$($Flavor.Surface2)
--layout=reverse
--cycle
--scroll-off=5
--border
--preview-window=right,60%,border-left
--preview=`'bat --color=always --line-range :500 {} 2>`$null`'
# --bind ctrl-u:preview-half-page-up
# --bind ctrl-d:preview-half-page-down
# --bind ctrl-f:preview-page-down
# --bind ctrl-b:preview-page-up
# --bind ctrl-g:preview-top
# --bind ctrl-h:preview-bottom
# --bind alt-w:toggle-preview-wrap
# --bind ctrl-e:toggle-preview
"@

# 自动检测系统并选择命令
$env:FZF_DEFAULT_COMMAND = if (Get-Command fd -ErrorAction SilentlyContinue) {
    "fd --type f --hidden --exclude .git"
} else {
    "Get-ChildItem -Recurse -File | Select-Object -ExpandProperty FullName"
}
$env:FZF_COMPLETION_TRIGGER='**'

# 查看所有 ReverseSearchHistory 相关的绑定
# Get-PSReadLineKeyHandler | Where-Object Function -eq 'ReverseSearchHistory'
# 恢复 Ctrl+R 默认功能
# Set-PSReadLineKeyHandler -Key Ctrl+R -Function ReverseSearchHistory

# 再次检查
# Get-PSReadLineKeyHandler -Chord Ctrl+R | Format-List *

# 查看绑定的功能
# (Get-PSReadLineKeyHandler -Chord Ctrl+R).Function

# 检查绑定的功能
# $handler = Get-PSReadLineKeyHandler -Chord Ctrl+R
# if ($handler.Function -eq 'CustomAction') {
#     # 只有通过 -ScriptBlock 绑定的才会进入这里
#     $handler.ScriptBlock.ToString()
# } else {
#     Write-Output "绑定到内置功能: $($handler.Function)"
# }

# 测试自定义脚本块
# Set-PSReadLineKeyHandler -Key Ctrl+R -ScriptBlock { "Do something" }
# (Get-PSReadLineKeyHandler -Chord Ctrl+R).ScriptBlock.ToString()  # 此时才能获取脚本内容

# Get-Command fzf -ErrorAction SilentlyContinue 测试 fzf 是否可用
# Tab 补全触发 (**)
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
#     $line = $null
#     $cursor = $null
#     [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
#
#     try {
#         # 仅在行尾且有 "**" 时触发 fzf
#         if ($cursor -eq $line.Length -and $line -match '\*\*\s*$') {
#             # 删除触发符 (安全删除)
#             if ($line.Length -ge 2) {
#                 [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar(2)
#             }
#
#             # 根据上下文选择补全内容
#             $result = if ($line -match 'git\s') {
#                 git branch --list 2>$null | fzf
#             } else {
#                 Invoke-Expression $env:FZF_DEFAULT_COMMAND | fzf
#             }
#
#             # 插入结果
#             if ($result) {
#                 [Microsoft.PowerShell.PSConsoleReadLine]::Insert($result.Trim())
#             }
#         } else {
#             # 默认 Tab 补全行为
#             [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext()
#         }
#     }
#     catch {
#         # 出错时恢复默认行为
#         [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext()
#     }
# }
# $commandOverride = [ScriptBlock]{ param($Location) Write-Host $Location }
#
# Set-PsFzfOption -AltCCommand $commandOverride

# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

# Set-PsFzfOption -PSReadlineChordProvider "Ctrl+e" -PSReadlineChordReverseHistory "Ctrl+r" -GitKeyBindings -TabExpansion -EnableAliasFuzzyGitStatus -EnableAliasFuzzyEdit -EnableAliasFuzzyFasd -EnableAliasFuzzyKillProcess -EnableAliasFuzzyScoop

# function _fzf_open_path
# {
#   param (
#     [Parameter(Mandatory=$true)]
#     [string]$input_path
#   )
#   if ($input_path -match "^.*:\d+:.*$")
#   {
#     $input_path = ($input_path -split ":")[0]
#   }
#   if (-not (Test-Path $input_path))
#   {
#     return
#   }
#   $cmds = @{
#     'bat' = { bat $input_path }
#     'cat' = { Get-Content $input_path }
#     'cd' = {
#       if (Test-Path $input_path -PathType Leaf)
#       {
#         $input_path = Split-Path $input_path -Parent
#       }
#       Set-Location $input_path
#     }
#     'nvim' = { nvim $input_path }
#     'remove' = { Remove-Item -Recurse -Force $input_path }
#     'echo' = { Write-Output $input_path }
#   }
#   $cmd = $cmds.Keys | fzf --prompt 'Select command> '
#   & $cmds[$cmd]
# }

# function _fzf_get_path_using_fd
# {
#   $input_path = fd --type file --follow --hidden --exclude .git |
#     fzf --prompt 'Files> ' `
#       --header-first `
#       --header 'CTRL-S: Switch between Files/Directories' `
#       --bind 'ctrl-s:transform:if not "%FZF_PROMPT%"=="Files> " (echo ^change-prompt^(Files^> ^)^+^reload^(fd --type file^)) else (echo ^change-prompt^(Directory^> ^)^+^reload^(fd --type directory^))' `
#       --preview 'if "%FZF_PROMPT%"=="Files> " (bat --color=always {} --style=plain) else (eza -T --colour=always --icons=always {})'
#   return $input_path
# }

# function _fzf_get_path_using_rg
# {
#   $INITIAL_QUERY = "${*:-}"
#   $RG_PREFIX = "rg --column --line-number --no-heading --color=always --smart-case"
#   $input_path = "" |
#     fzf --ansi --disabled --query "$INITIAL_QUERY" `
#       --bind "start:reload:$RG_PREFIX {q}" `
#       --bind "change:reload:sleep 0.1 & $RG_PREFIX {q} || rem" `
#       --bind 'ctrl-s:transform:if not "%FZF_PROMPT%" == "1. ripgrep> " (echo ^rebind^(change^)^+^change-prompt^(1. ripgrep^> ^)^+^disable-search^+^transform-query:echo ^{q^} ^> %TEMP%\rg-fzf-f ^& type %TEMP%\rg-fzf-r) else (echo ^unbind^(change^)^+^change-prompt^(2. fzf^> ^)^+^enable-search^+^transform-query:echo ^{q^} ^> %TEMP%\rg-fzf-r ^& type %TEMP%\rg-fzf-f)' `
#       --color 'hl:-1:underline,hl+:-1:underline:reverse' `
#       --delimiter ':' `
#       --prompt '1. ripgrep> ' `
#       --preview-label 'Preview' `
#       --header 'CTRL-S: Switch between ripgrep/fzf' `
#       --header-first `
#       --preview 'bat --color=always {1} --highlight-line {2} --style=plain' `
#       --preview-window 'up,60%,border-bottom,+{2}+3/3'
#   return $input_path
# }

# function fdg
# {
#   _fzf_open_path $(_fzf_get_path_using_fd)
# }

# function rgg
# {
#   _fzf_open_path $(_fzf_get_path_using_rg)
# }
# 在 PowerShell 中，Set-PSReadLineKeyHandler 用于自定义键盘快捷键的行为
# Set-PSReadLineKeyHandler -Key "Ctrl+f" -ScriptBlock {
#   [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
#   [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fdg")
#   [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
# }

# Set-PSReadLineKeyHandler -Key "Ctrl+g" -ScriptBlock {
#   [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
#   [Microsoft.PowerShell.PSConsoleReadLine]::Insert("rgg")
#   [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
# }

##########################################

# BAT CONFIG
# function List-BatThemes
# {
#   $file = fzf --prompt="Select a file to preview  " --preview  "bat --color=always {1} --style=numbers --line-range=:500 {}" --header "Bat preview themes" --header-first
#   bat --list-themes | fzf --preview "bat theme={} --color=always $file"
# }

##########################################

# 设置 Ctrl+d 为退出 PowerShell
# Set-PSReadlineKeyHandler -Key "Ctrl+d" -Function ViExit
# 设置 Ctrl+z 为撤销
# Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo
# auto suggestions
# 设置编辑模式为 Emacs
# Set-PSReadLineOption -EditMode Emacs
# 设置预测文本来源为历史记录
# Set-PSReadLineOption -PredictionSource HistoryAndPlugin
# Set-PSReadLineOption -PredictionSource History
# 命令历史ListView
# Set-PSReadLineOption -PredictionViewStyle ListView
# 禁用提示音
# Set-PSReadLineOption -BellStyle None
# 每次回溯输入历史，光标定位于输入内容末尾
# Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
#Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
# example command - use $Location with a different command:
#$commandOverride = [ScriptBlock]{ param($Location) Write-Host $Location }
# pass your override to PSFzf:
#Set-PsFzfOption -AltCCommand $commandOverride
#  下面的都是启用别名调用函数 tab调用fzf模糊查询  替代PSCompletions listview菜单形式的补全, 和命令参数的智能补全冲突，tab触发模糊搜索覆盖了智能补全命令参数
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
# Set-PsFzfOption -TabExpansion -EnableAliasFuzzyEdit -EnableAliasFuzzyFasd -EnableAliasFuzzyHistory 
# Set-PsFzfOption -EnableAliasFuzzyKillProcess -EnableAliasFuzzySetLocation -EnableAliasFuzzySetEverything
# Set-PsFzfOption -EnableAliasFuzzyScoop -EnableAliasFuzzyZLocation -EnableAliasFuzzyGitStatus -EnableFd

#-------------------------------  Set Hot-keys END    -------------------------------

#-------------------------------    Functions BEGIN   -------------------------------
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
# $env:PYTHONIOENCODING = "utf-8"  # 修复 thefuck 的编码问题
# 性能不如eza 可以看社区github 的 benchmark
# function getlist {
#       lsd -al
# }
# function JumpTo-Folder {
#     param(
#         [Parameter(Mandatory=$false)]
#         [string]$Path = "."
#     )
#
#     # 使用Fzf选择目录，并跳转到所选目录
#     $selectedFolder = Get-ChildItem -Path $Path -Recurse -Directory | Invoke-Fzf
#     if($selectedFolder){
#         Set-Location -Path $selectedFolder
#     }
# }

# 为函数设置别名
# Set-Alias -Name jtf -Value JumpTo-Folder
# function Edit-WithFzf {
#     [CmdletBinding()]
#     param(
#         [Parameter(Mandatory=$false)]
#         [string]$Path = "."
#     )
#
#     # 查找所有非目录项，并使用 Fzf 选择
#     $selectedFile = Get-ChildItem -Path $Path -Recurse -Attributes !Directory | Invoke-Fzf
#     if($selectedFile){
#         # 使用 vim 打开选中的文件
#         & vim $selectedFile
#     }
# }

# 为函数设置别名
# Set-Alias -Name efzf -Value Edit-WithFzf
# function Go-To-FuzzyDirectory {
#     [CmdletBinding()]
#     param(
#         [Parameter(Mandatory=$false)]
#         [string]$Path = "."
#     )
#
#     # 使用 PSFzf 的 Select-FzfItem 来实现模糊搜索目录
#     $selectedDirectory = Set-LocationFuzzyEverything -Directory $Path
#     if ($selectedDirectory) {
#         Set-Location -Path $selectedDirectory
#     }
# }
# 为函数设置别名
# Set-Alias gtd Go-To-FuzzyDirectory
#
# function yy {
#     $tmp = [System.IO.Path]::GetTempFileName()
#     yazi $args --cwd-file="$tmp"
#     $cwd = Get-Content -Path $tmp
#     if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
#         Set-Location -LiteralPath $cwd
#     }
#     Remove-Item -Path $tmp
# }

# winget 输入命令直接tab自动补全
# Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
#     param($wordToComplete, $commandAst, $cursorPosition)
#         [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
#         $Local:word = $wordToComplete.Replace('"', '""')
#         $Local:ast = $commandAst.ToString().Replace('"', '""')
#         winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
#             [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
#         }
# }
# function Make-Link {
#       cmd /C mklink $args
# } 


# function md5
# { Get-FileHash -Algorithm MD5 $args 
# }
# function sha1
# { Get-FileHash -Algorithm SHA1 $args 
# }
# function sha256
# { Get-FileHash -Algorithm SHA256 $args 
# }


# Quick Access to System Information
# function sysinfo
# {
#   Get-ComputerInfo 
# }

# Networking Utilities
function flushdns
{
  Clear-DnsClientCache 
}

# function Get-Fonts
# {
#   param (
#     $regex
#   )
#   $AllFonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
#   if ($null -ne $regex)
#   {
#     $FilteredFonts = $($AllFonts | Select-String -Pattern ".*${regex}.*")
#     return $FilteredFonts
#   }
#   return $AllFonts
# }

# function Update-PowershellModules
# {
#   # Update-Module -Name $POWERSHELL_MODULES_TO_UPDATE -AcceptLicense -Force
#   Update-Module -AcceptLicense -Force
# }
##########################################
# APP MANAGE
# function Select-Apps
# {
#   param (
#     [string[]] $apps
#   )
#   $apps = $apps | fzf --prompt="Select Apps  " --height=~80% --layout=reverse --border --cycle --margin="2,20" --padding=1 --multi
#   return $apps
# }
#
# function List-ScoopApps
# {
#   $apps = $(scoop list | Select-Object -ExpandProperty "Name").Split("\n")
#   $apps = $apps[1..($apps.Length - 1)]
#   return $apps
# }
#
# function Uninstall-ScoopApps
# {
#   $apps = Select-Apps $(List-ScoopApps)
#   if ($apps.Length -eq 0)
#   {
#     Write-Host "No app was selected"!
#     return 
#   }
#   scoop uninstall $apps
# }

##########################################
# EZA CONFIG

# if ((Get-Command -Name "eza" -ErrorAction SilentlyContinue))
# {
#   $DEFAULT_EZA_ARGS = @(
#     "--colour=always",
#     "--git",
#     "--group-directories-first",
#     "--icons=always",
#     "--ignore-glob=.DS_Store",
#     "--no-quotes",
#     "--sort=type"
#   )
#
#   function _ls
#   {
#     eza -1 @DEFAULT_EZA_ARGS @args
#   }
#
#   function l
#   {
#     eza -l @DEFAULT_EZA_ARGS @args
#   }
#
#   function ll
#   {
#     eza -lag @DEFAULT_EZA_ARGS @args
#   }
#
#   function ld
#   {
#     eza -lD @DEFAULT_EZA_ARGS @args
#   }
#
#   function lt
#   {
#     eza --tree @DEFAULT_EZA_ARGS @args
#   }
#
#   function llt
#   {
#     eza --tree -lag @DEFAULT_EZA_ARGS @args
#   }
#
#   Set-Alias -Name ls -Value _ls -Force
# }

##########################################
# dotfile管理软件
# CHEZMOI CONFIG
# Set-Alias -Name cm -Value chezmoi -Option AllScope
# 检查 chezmoi 命令是否可用
# if (Get-Command "chezmoi" -ErrorAction SilentlyContinue)
# {
#   # 加载自动补全
#   Invoke-Expression (& { (chezmoi completion powershell | Out-String) })
# }
#
# 提交并推送更改
# function cmc {
#   param (
#     [string] $msg
#   )
#   if ($msg) {
#     chezmoi git commit -m "$msg"
#   } else {
#     chezmoi git commit
#   }
#   if ($LASTEXITCODE -eq 0) {
#     chezmoi git push
#   }
# }
#
# 添加文件到 chezmoi
# function cma {
#   param (
#     [string[]] $files
#   )
#   $current_dir = Get-Location
#   foreach ($file in $files) {
#     $full_path = Join-Path -Path $current_dir -ChildPath $file
#     chezmoi add $full_path
#   }
#   Set-Location $current_dir
# }
#
# 推送更改
# function cmp {
#   chezmoi git push
# }
##########################################
# YAZI CONFIG
Set-Alias -Name yz -Value yazi

# function yzcd
# {
#   $tmp = [System.IO.Path]::GetTempFileName()
#   yazi $args --cwd-file="$tmp"
#   $cwd = Get-Content -Path $tmp
#   if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path)
#   {
#     Set-Location -LiteralPath $cwd
#   }
#   Remove-Item -Path $tmp
# }

# Set-PSReadLineKeyHandler -Key "Ctrl+d" -ScriptBlock { 
#   [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
#   [Microsoft.PowerShell.PSConsoleReadLine]::Insert("yzcd")
#   [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
# }
##########################################
# 定义命令字典
# $_EVALX_COMMANDS = @{
#   source_chezmoi_completion = 'Invoke-Expression (& { (chezmoi completion powershell | Out-String) })'
#   source_docker_completion = 'Import-Module DockerCompletion'
#   source_gh_autocompletion = 'Invoke-Expression (& { (gh completion -s powershell | Out-String) })'
#   source_posh_wakatime = 'Import-Module posh-wakatime'
#   source_rclone_completion = 'Invoke-Expression (& { (rclone completion powershell | Out-String) })'
#   source_scoop_completion = 'Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"'
#   source_terminal_icon = 'Import-Module Terminal-Icons'
# }

# function evalx
# {
#   # 使用 fzf 选择一个或多个命令
#   $commands = $_EVALX_COMMANDS.Keys | fzf --multi
#
#   # 执行选定的命令
#   foreach ($key in $commands)
#   {
#     Invoke-Expression $_EVALX_COMMANDS[$key]
#   }
# }
##########################################
#  Utils
# Function Test-CommandExists
# {
#   Param ($command)
#   $oldPreference = $ErrorActionPreference
#   $ErrorActionPreference = 'SilentlyContinue'
#   try
#   { if (Get-Command $command)
#     { RETURN $true 
#     } 
#   } Catch
#   { Write-Host "$command does not exist"; RETURN $false 
#   } Finally
#   { $ErrorActionPreference = $oldPreference 
#   }
# }
#
# if (Test-CommandExists nvim)
# {
#   if (Test-Path "$env:LOCALAPPDATA/$env:DEFAULT_NVIM_CONFIG" -PathType Container)
#   {
#     $env:NVIM_APPNAME = $env:DEFAULT_NVIM_CONFIG
#   }
#   $EDITOR='nvim'
# } elseif (Test-CommandExists notepad)
# {
#   $EDITOR='notepad'
# } elseif (Test-CommandExists code)
# {
#   $EDITOR='code'
# } elseif (Test-CommandExists pvim)
# {
#   $EDITOR='pvim'
# } elseif (Test-CommandExists vim)
# {
#   $EDITOR='vim'
# } elseif (Test-CommandExists vi)
# {
#   $EDITOR='vi'
# } elseif (Test-CommandExists notepad++)
# {
#   $EDITOR='notepad++'
# } elseif (Test-CommandExists sublime_text)
# {
#   $EDITOR='sublime_text'
# }
# Set-Alias -Name v -Value $EDITOR
#
# function Edit-Profile
# {
#   # notepad $profile.CurrentUserAllHosts
#   v $PROFILE
# }

function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
#-------------------------------    Functions END     -------------------------------

#-------------------------------   InitShell BEGIN    -------------------------------
# 主题
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/powerlevel10k_rainbow.omp.json" | Invoke-Expression
#Invoke-Expression (&starship init powershell)
# &后台执行
# & "fastfetch"
#-------------------------------    InitShell END     -------------------------------

#-------------------------------   Set Alias BEGIN    -------------------------------
#Remove-Item alias:\ls
# Remove-Item alias:\cd
# Set-Alias br broot
$env:_ZO_DATA_DIR = "D:\scoop\apps\zoxide\data"
# ==================================================================
# lsd别名
Set-Alias ls lsd
Set-Alias ll getlist
####################################################################
# Set-Alias ls _l
Set-Alias find fd
# Set-Alias mklink Make-Link 

Set-Alias grep rg
# Set-Alias vim nvim
Set-Alias top btm
Set-Alias man tldr
Set-Alias cat bat


# 纯净启动
# D:\PowerShell7\pwsh.exe -nologo -noprofile 

# 添加到你的 $PROFILE 文件
# $env:FZF_DEFAULT_OPTS = @'
# --bind="ctrl-y:execute-silent(powershell -NoProfile -Command \"Set-Clipboard -LiteralPath '{}'\")+abort"
# --height 80%
# --border rounded
# --preview="bat --color=always --style=numbers --line-range :500 {} 2>$null"
# '@
$env:FZF_DEFAULT_COMMAND="fd --type f --hidden --no-ignore --exclude .git"

# Set-Alias cd z
# New-Alias -Name setenv -Value "setenv.ps1"
#Set-Alias cd zoxide
#-------------------------------    Set Alias END     -------------------------------
# Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
Invoke-Expression (& { (zoxide init powershell | Out-String) })
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }(& uv generate-shell-completion powershell) | Out-String | Invoke-Expression
# 解决补全乱码
# psc menu symbol SpaceTab ""
# psc menu symbol OptionTab ""
# psc menu symbol WriteSpaceTab ""
# 设置安全目录
# git config --global --add safe.directory "*"
Import-Module PSCompletions

