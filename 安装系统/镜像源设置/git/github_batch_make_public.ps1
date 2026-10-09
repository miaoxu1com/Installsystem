$ErrorActionPreference = 'Continue'
$gh = 'D:\tools\gh\bin\gh.exe'
$repos = (Get-Content "$env:TEMP\priv.json" -Raw | ConvertFrom-Json).name
$ok = @(); $fail = @()
$i = 0
foreach ($r in $repos) {
    $i++
    Write-Host ("[{0}/{1}] {2} ... " -f $i, $repos.Count, $r) -NoNewline
    & $gh repo edit "miaoxu1com/$r" --visibility public --accept-visibility-change-consequences *> $null
    if ($LASTEXITCODE -eq 0) { $ok += $r; Write-Host 'OK' -ForegroundColor Green }
    else { $fail += $r; Write-Host 'FAIL' -ForegroundColor Red }
}
Write-Host ''
Write-Host ("成功 {0} / {1}，失败 {2}" -f $ok.Count, $repos.Count, $fail.Count) -ForegroundColor Cyan
if ($fail) { Write-Host ('失败列表: ' + ($fail -join ', ')) -ForegroundColor Red }
