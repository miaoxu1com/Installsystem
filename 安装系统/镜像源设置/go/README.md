# Go 代理（GOPROXY）

```bash
# Bash (Linux or macOS)
export GOPROXY=https://goproxy.io,direct
# 不走 proxy 的私有仓库或组，多个用逗号相隔（可选）
export GOPRIVATE=git.mycompany.com,github.com/my/private
```

```powershell
# PowerShell (Windows)
$env:GOPROXY = "https://goproxy.io,direct"
$env:GOPRIVATE = "git.mycompany.com,github.com/my/private"
```

## Arch 安装 AUR 助手 yay 时走 GOPROXY

```bash
git clone https://aur.archlinux.org/yay
cd yay
GOPROXY=https://goproxy.cn makepkg -si
```
