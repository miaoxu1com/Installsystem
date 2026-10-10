# 整合自: GitProxy.bat / UnsetGitProxy.bat / ScoopProxy.ps1 / UnsetScoopProxy.bat
# 功能: 一键设置或取消 Git 和 Scoop 的代理(默认 127.0.0.1:7890，按实际代理端口修改)
# 用法:
#   .\网络代理开关-Git与Scoop.ps1 -On                # 设置 Git + Scoop 代理
#   .\网络代理开关-Git与Scoop.ps1 -Off               # 取消 Git + Scoop 代理
#   .\网络代理开关-Git与Scoop.ps1 -On -Target Git    # 只设置 Git
#   .\网络代理开关-Git与Scoop.ps1 -On -ProxyAddr "127.0.0.1:10809"
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'On')]
    [switch]$On,

    [Parameter(Mandatory = $true, ParameterSetName = 'Off')]
    [switch]$Off,

    [ValidateSet('Git', 'Scoop', 'All')]
    [string]$Target = 'All',

    [string]$ProxyAddr = '127.0.0.1:7890'
)

$httpProxy  = "http://$ProxyAddr"
$socksProxy = "socks5://$ProxyAddr"

if ($On) {
    if ($Target -in 'Git', 'All') {
        # Git 代理(https 走 http 代理，github.com 走 socks5)
        git config --global http.proxy $httpProxy
        git config --global https.proxy $httpProxy
        git config --global http.https://github.com.proxy $socksProxy
        Write-Host "✓ Git 代理已设置为 $ProxyAddr" -ForegroundColor Green
    }
    if ($Target -in 'Scoop', 'All') {
        # 当前会话环境变量 + scoop 持久配置
        $env:http_proxy  = $httpProxy
        $env:https_proxy = $httpProxy
        scoop config proxy $ProxyAddr
        Write-Host "✓ Scoop 代理已设置为 $ProxyAddr(环境变量仅当前会话)" -ForegroundColor Green
    }
}
else {
    if ($Target -in 'Git', 'All') {
        git config --global --unset http.proxy
        git config --global --unset https.proxy
        git config --global --unset http.https://github.com.proxy
        Write-Host "✓ Git 代理已取消" -ForegroundColor Green
    }
    if ($Target -in 'Scoop', 'All') {
        Remove-Item Env:http_proxy -ErrorAction SilentlyContinue
        Remove-Item Env:https_proxy -ErrorAction SilentlyContinue
        scoop config rm proxy
        Write-Host "✓ Scoop 代理已取消" -ForegroundColor Green
    }
}

# 显示当前状态
Write-Host "`n当前配置:"
git config --global --get http.proxy
git config --global --get https.proxy
scoop config proxy
