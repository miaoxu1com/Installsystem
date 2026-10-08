@echo off
echo 正在开始批量安装软件...

:: 定义要安装的软件列表
set "packages=7zip aria2 bat bottom cacert ccache chsrc dark dog doggo duf fastfetch fd file fzf gcc git innounp jq lazygit lsd lua luarocks neovide neovim nmap oh-my-posh pandoc pnpm poppler procs PSFzf pyrepack rclone ripgrep scoop-completion scoop-search tldr tree-sitter unar unzip uv wget winfsp wxac yazi zoxide gsudo"

:: 循环遍历每个软件包，并使用Scoop进行安装
for %%i in (%packages%) do (
    echo 正在安装 %%i...
    scoop install %%i
)

echo 软件安装完成！
pause