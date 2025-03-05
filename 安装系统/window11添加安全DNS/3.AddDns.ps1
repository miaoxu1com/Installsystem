# 修改脚本执行策略 需要管理员权限
# Set-ExecutionPolicy Unrestricted
#Add-DnsClientDohServerAddress -ServerAddress '223.5.5.5' -DohTemplate 'https://dns.alidns.com/dns-query' -AllowFallbackToUdp $True -AutoUpgrade $True
Add-DnsClientDohServerAddress -ServerAddress '119.29.29.29' -DohTemplate 'https://doh.pub/dns-query' -AllowFallbackToUdp $True -AutoUpgrade $True
Get-DnsClientDohServerAddress