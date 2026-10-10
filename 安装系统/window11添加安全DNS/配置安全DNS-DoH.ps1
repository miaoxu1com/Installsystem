# 整合自: 3.AddDns.ps1 / 4.PrintDnsList.ps1
# 功能: 添加 DoH(安全 DNS)服务器并列出当前 DoH 配置
# 注意: 需要管理员权限; 如执行策略受限先运行 Set-ExecutionPolicy Unrestricted

# 阿里 DNS(按需取消注释)
# Add-DnsClientDohServerAddress -ServerAddress '223.5.5.5' -DohTemplate 'https://dns.alidns.com/dns-query' -AllowFallbackToUdp $True -AutoUpgrade $True

# 腾讯 DNS
Add-DnsClientDohServerAddress -ServerAddress '119.29.29.29' -DohTemplate 'https://doh.pub/dns-query' -AllowFallbackToUdp $True -AutoUpgrade $True

# 列出当前 DoH 服务器
Get-DnsClientDohServerAddress
