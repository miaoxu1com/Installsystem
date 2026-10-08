<#
.SYNOPSIS
  Lanzou Cloud CLI downloader.
.DESCRIPTION
  Given a Lanzou share URL (folder or single file) and optional password,
  lists files, lets you pick which to download, and saves to the output dir.
.EXAMPLE
  .\lanzou-dl.ps1 -Url https://www.lanzoum.com/b0o0eakaj -Pwd 2grk
  .\lanzou-dl.ps1 -Url https://www.lanzoum.com/i8Gy74astj4f
  .\lanzou-dl.ps1 -Url <folder> -Pwd <pwd> -Select all
  .\lanzou-dl.ps1 -Url <folder> -Pwd <pwd> -Select 1,3
#>
param(
    [Parameter(Mandatory = $true)][string]$Url,
    [string]$Pwd = '',
    [string]$OutDir = "F:\迅雷下载",
    [string]$Select = '',       # "all" / "1,3" / "1-3" / empty = ask
    [switch]$ListOnly           # only list files, do not download
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ---------- Aliyun WAF acw_sc__v2 solver ----------
function Calc-AcwScV2([string]$arg1) {
    $m = @(0xf,0x23,0x1d,0x18,0x21,0x10,0x1,0x26,0xa,0x9,0x13,0x1f,0x28,0x1b,0x16,0x17,0x19,0xd,0x6,0xb,0x27,0x12,0x14,0x8,0xe,0x15,0x20,0x1a,0x2,0x1e,0x7,0x4,0x11,0x5,0x3,0x1c,0x22,0x25,0xc,0x24)
    $p = '3000176000856006061501533003690027800375'
    $q = New-Object char[] 40
    for ($x = 0; $x -lt 40; $x++) { for ($z = 0; $z -lt 40; $z++) { if ($m[$z] -eq ($x + 1)) { $q[$z] = $arg1[$x] } } }
    $u = -join $q; $v = ''
    for ($x = 0; $x -lt $u.Length -and $x -lt $p.Length; $x += 2) {
        $a = [Convert]::ToInt32($u.Substring($x,2),16); $b = [Convert]::ToInt32($p.Substring($x,2),16)
        $h = ($a -bxor $b).ToString('x'); if ($h.Length -eq 1) { $h = '0' + $h }; $v += $h
    }
    return $v
}

$script:UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36'
$script:Session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$script:Session.UserAgent = $script:UA
$script:BaseHost = ([uri]$Url).Host

function Get-Page([string]$pageUrl, [string]$referer = '') {
    $vs = $null
    for ($i = 0; $i -lt 5; $i++) {
        if ($vs) { $script:Session.Cookies.Add((New-Object System.Net.Cookie('acw_sc__v2', $vs, '/', ([uri]$pageUrl).Host))) }
        $headers = @{}
        if ($referer) { $headers['Referer'] = $referer }
        $r = Invoke-WebRequest -Uri $pageUrl -UseBasicParsing -WebSession $script:Session -Headers $headers -TimeoutSec 30
        $c = $r.Content
        if ($c -match "var arg1='([0-9A-F]+)'") { $vs = Calc-AcwScV2 $Matches[1]; continue }
        return $c
    }
    throw "WAF challenge failed for $pageUrl"
}

function Post-Form([string]$postUrl, [hashtable]$form, [string]$referer) {
    $content = $null
    for ($try = 0; $try -lt 6; $try++) {
        $resp = Invoke-WebRequest -Uri $postUrl -Method Post -Body $form -UseBasicParsing -WebSession $script:Session `
            -Headers @{ 'Referer' = $referer; 'X-Requested-With' = 'XMLHttpRequest' } -TimeoutSec 30
        $content = $resp.Content
        if ($content -match '"zt"\s*:\s*4') { Start-Sleep -Seconds 2; continue }
        break
    }
    return $content
}

# ---------- Folder: list files ----------
function Get-FolderFiles([string]$folderUrl, [string]$pwd) {
    $page = Get-Page $folderUrl
    if ($page -match 'pwdload' -and -not $pwd) { throw 'This folder needs a password. Re-run with -Pwd.' }

    # locate the filemoreajax data block
    $dm = [regex]::Match($page, "(?s)url\s*:\s*'(/filemoreajax\.php\?file=\d+)'\s*,\s*data\s*:\s*\{(.*?)\}")
    if (-not $dm.Success) { return $null }
    $ajaxPath = $dm.Groups[1].Value
    $block = $dm.Groups[2].Value

    $form = @{}
    foreach ($kv in [regex]::Matches($block, "'(\w+)'\s*:\s*('([^']*)'|\w+)")) {
        $key = $kv.Groups[1].Value
        $raw = $kv.Groups[2].Value
        if ($raw -match "^'(.*)'$") { $form[$key] = $Matches[1] }
        elseif ($raw -match '^\d+$') { $form[$key] = $raw }
        elseif ($key -eq 'pwd') { continue }
        else {
            # JS variable -> resolve from page
            $vm = [regex]::Match($page, "var\s+$raw\s*=\s*'?([^;']*)'?\s*;")
            if ($vm.Success) { $form[$key] = $vm.Groups[1].Value }
        }
    }
    $form['pwd'] = $pwd
    $base = "https://$script:BaseHost"

    $files = New-Object System.Collections.ArrayList
    $pg = 1
    while ($true) {
        $form['pg'] = [string]$pg
        $json = Post-Form "$base$ajaxPath" $form $folderUrl | ConvertFrom-Json
        if ($json.zt -ne 1) { throw "folder list failed: $($json.info)" }
        $batch = @($json.text)
        if ($batch.Count -eq 0) { break }
        foreach ($f in $batch) {
            [void]$files.Add([pscustomobject]@{
                Id   = $f.id
                Name = $f.name_all
                Size = $f.size
                Time = $f.time
            })
        }
        if ($batch.Count -lt 50) { break }
        $pg++
    }
    return $files
}

# ---------- Single file: resolve real CDN url ----------
function Get-RealDownloadInfo([string]$fileUrl, [string]$pwd) {
    $page = Get-Page $fileUrl
    $dom = $null; $furl = $null

    if ($page -match 'src="(/fn\?[^"]+)"') {
        # 2026-10 flow: fn inner page carries signed ajax params
        $fnPath = $Matches[1]
        $inner = Get-Page "https://$script:BaseHost$fnPath" $fileUrl
        $dm = [regex]::Match($inner, "var\s+domain1\s*=\s*'([^']*ajaxfile\.php\?file=(\d+)[^']*)'")
        $sm = [regex]::Match($inner, "var\s+wp_sign\s*=\s*'([^']*)'")
        $am = [regex]::Match($inner, "var\s+ajaxdata\s*=\s*'([^']*)'")
        if (-not ($dm.Success -and $sm.Success -and $am.Success)) { throw 'parse fn page failed' }
        $form = @{
            action = 'downprocess'; websignkey = $am.Groups[1].Value; signs = $am.Groups[1].Value
            sign = $sm.Groups[1].Value; websign = ''; kd = '1'; ves = '1'
        }
        $resp = Post-Form $dm.Groups[1].Value $form "https://$script:BaseHost$fnPath"
        $json = $resp | ConvertFrom-Json
        if ($json.zt -ne 1) { throw "apifile failed: $($json.inf)" }
        $dom = $json.dom; $furl = $json.url
    }
    else {
        # classic flow: iframe down page or password page
        if ($page -match 'pwdload|passwddiv') {
            if (-not $pwd) { throw 'This file needs a password. Re-run with -Pwd.' }
            $form = @{}
            foreach ($inp in [regex]::Matches($page, '<input[^>]*>')) {
                $nm = [regex]::Match($inp.Value, "name='([^']+)'"); if (-not $nm.Success) { $nm = [regex]::Match($inp.Value, 'name="([^"]+)"') }
                $vv = [regex]::Match($inp.Value, "value='([^']*)'"); if (-not $vv.Success) { $vv = [regex]::Match($inp.Value, 'value="([^"]*)"') }
                if ($nm.Success -and $nm.Groups[1].Value -ne 'pwd') { $form[$nm.Groups[1].Value] = $vv.Groups[1].Value }
            }
            $form['p'] = $pwd
            $am = [regex]::Match($page, "'(/ajax(?:file|m)\.php\?file=\d+)'")
            if (-not $am.Success) { throw 'not find ajax url' }
            $resp = Post-Form "https://$script:BaseHost$($am.Groups[1].Value)" $form $fileUrl
            $json = $resp | ConvertFrom-Json
            $dom = $json.dom; $furl = $json.url
        }
        else {
            $im = [regex]::Match($page, '<iframe.*?src="(.+?)"')
            if (-not $im.Success) { throw 'not find down page' }
            $inner = Get-Page "https://$script:BaseHost$($im.Groups[1].Value)" $fileUrl
            $am = [regex]::Match($inner, "'(/ajax(?:file|m)\.php\?file=\d+)'")
            if (-not $am.Success) { throw 'not find ajax url' }
            $form = @{}
            foreach ($inp in [regex]::Matches($inner, '<input[^>]*>')) {
                $nm = [regex]::Match($inp.Value, "name='([^']+)'"); if (-not $nm.Success) { $nm = [regex]::Match($inp.Value, 'name="([^"]+)"') }
                $vv = [regex]::Match($inp.Value, "value='([^']*)'"); if (-not $vv.Success) { $vv = [regex]::Match($inp.Value, 'value="([^"]*)"') }
                if ($nm.Success) { $form[$nm.Groups[1].Value] = $vv.Groups[1].Value }
            }
            $resp = Post-Form "https://$script:BaseHost$($am.Groups[1].Value)" $form $fileUrl
            $json = $resp | ConvertFrom-Json
            $dom = $json.dom; $furl = $json.url
        }
    }
    if (-not $dom -or -not $furl) { throw "resolve download info failed" }

    $downloadUrl = "$dom/file/$furl"
    # no-redirect GET -> real CDN url
    $vs2 = $null
    for ($i = 0; $i -lt 4; $i++) {
        $cookie = 'down_ip=1'
        if ($vs2) { $cookie += "; acw_sc__v2=$vs2" }
        $req = [Net.HttpWebRequest]::Create($downloadUrl)
        $req.Method = 'GET'; $req.AllowAutoRedirect = $false
        $req.AutomaticDecompression = [Net.DecompressionMethods]::GZip -bor [Net.DecompressionMethods]::Deflate
        $req.UserAgent = $script:UA; $req.Referer = $dom
        $req.Headers.Add('Cookie', $cookie)
        $req.Headers.Add('accept-language', 'zh-CN,zh;q=0.9')
        $req.Timeout = 30000
        try { $resp2 = $req.GetResponse() } catch [Net.WebException] { $resp2 = $_.Exception.Response }
        $code = [int]$resp2.StatusCode
        if ($code -ge 300 -and $code -lt 400) {
            $real = $resp2.Headers['Location']; $resp2.Close()
            return [pscustomobject]@{ RealUrl = $real; Referer = $dom }
        }
        $sr = New-Object IO.StreamReader($resp2.GetResponseStream())
        $body2 = $sr.ReadToEnd(); $resp2.Close()
        if ($body2 -match "var arg1='([0-9A-F]+)'") { $vs2 = Calc-AcwScV2 $Matches[1]; continue }
        throw "unexpected status $code"
    }
    throw 'real url resolve failed'
}

# ---------- Download ----------
function Save-File([string]$realUrl, [string]$referer, [string]$outPath) {
    $req = [Net.HttpWebRequest]::Create($realUrl)
    $req.UserAgent = $script:UA; $req.Referer = $referer
    $req.Headers.Add('Cookie', 'down_ip=1')
    $req.Timeout = 60000
    $resp = $req.GetResponse()
    $total = $resp.ContentLength
    $stream = $resp.GetResponseStream()
    $fs = [IO.File]::Create($outPath)
    $buffer = New-Object byte[] 262144
    $done = 0
    $sw = [Diagnostics.Stopwatch]::StartNew()
    while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $fs.Write($buffer, 0, $read); $done += $read
        if ($sw.ElapsedMilliseconds -gt 3000) {
            $pct = if ($total -gt 0) { [math]::Round(100.0 * $done / $total, 1) } else { 0 }
            Write-Output "JCODE_PROGRESS {`"percent`":$pct,`"message`":`"$([math]::Round($done/1MB,1)) / $([math]::Round($total/1MB,1)) MB`"}"
            $sw.Restart()
        }
    }
    $fs.Close(); $stream.Close(); $resp.Close()
    return $done
}

function Get-SafeName([string]$name) {
    $bad = [IO.Path]::GetInvalidFileNameChars() -join ''
    return ($name.ToCharArray() | ForEach-Object { if ($bad.Contains([string]$_)) { '_' } else { $_ } }) -join ''
}

# ================= main =================
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

$targets = @()   # each: @{ Url; Name }
$files = @(Get-FolderFiles $Url $Pwd)

if ($files.Count -gt 0) {
    Write-Output ''
    Write-Output ('Found {0} file(s):' -f $files.Count)
    for ($i = 0; $i -lt $files.Count; $i++) {
        Write-Output ('  [{0}] {1}    ({2}, {3})' -f ($i + 1), $files[$i].Name, $files[$i].Size, $files[$i].Time)
    }
    Write-Output ''
    if ($ListOnly) { return }
    $sel = $Select
    if (-not $sel) { $sel = Read-Host 'Select number(s) to download (e.g. 1,3 / 1-3 / all)' }
    $picked = New-Object System.Collections.ArrayList
    if ($sel -eq 'all') { for ($i = 0; $i -lt $files.Count; $i++) { [void]$picked.Add($i) } }
    else {
        foreach ($part in ($sel -split ',')) {
            $part = $part.Trim()
            if ($part -match '^(\d+)-(\d+)$') { for ($i = [int]$Matches[1]; $i -le [int]$Matches[2]; $i++) { [void]$picked.Add($i - 1) } }
            elseif ($part -match '^\d+$') { [void]$picked.Add([int]$part - 1) }
        }
    }
    if ($picked.Count -eq 0) { throw 'nothing selected' }
    foreach ($idx in $picked) {
        if ($idx -lt 0 -or $idx -ge $files.Count) { throw "invalid index: $($idx + 1)" }
        $targets += @{ Url = "https://$script:BaseHost/$($files[$idx].Id)"; Name = $files[$idx].Name }
    }
}
else {
    # single file share
    $targets += @{ Url = $Url; Name = '' }
}

Write-Output ''
foreach ($t in $targets) {
    Write-Output (">> resolving: {0}" -f $t.Url)
    $info = Get-RealDownloadInfo $t.Url $Pwd
    $name = $t.Name
    if (-not $name) {
        $leaf = ([uri]$info.RealUrl).Segments[-1]
        $name = [uri]::UnescapeDataString($leaf)
        if ($name -match '^\d+_') { $name = $name -replace '^\d+_', '' }
    }
    $name = Get-SafeName $name
    $outPath = Join-Path $OutDir $name
    Write-Output (">> downloading -> {0}" -f $outPath)
    $bytes = Save-File $info.RealUrl $info.Referer $outPath
    Write-Output (">> done ({0} bytes)" -f $bytes)
    Write-Output ''
}
Write-Output 'ALL DONE'
