<#


## Common ports
-----------------------------------------------------------------------------------------------------------------------
Port    Protocol    Service     Description 
-----------------------------------------------------------------------------------------------------------------------
21      TCP         FTP         File Transfer Protocol
22      TCP         SSH         Secure Shell for remote login
23      TCP         Telnet      Unencrypted text communications
53      TCP/UDP     DNS         Domain Name System
80      TCP         HTTP        World Wide Web (Unencrypted)
139     TCP         NetBIOS     NetBIOS Session Service
443     TCP         HTTPS       HTTP over SSL/TLS
445     TCP         SMB         Server Message Block (Windows file sharing)
3389    TCP         RDP         Remote Desktop Protocol (Windows)
8080    TCP         HTTP        Common alternative for web servers

## Mail Ports
-----------------------------------------------------------------------------------------------------------------------
Port    Protocol    Service     Description 
-----------------------------------------------------------------------------------------------------------------------
25      TCP         SMTP        Simple Mail Transfer Protocol
110     TCP         POP3        Post Office Protocol (Email retrieval)
143     TCP         IMAP        Internet Message Access Protocol

## Common Database Ports for Nmap Scanning
-----------------------------------------------------------------------------------------------------------------------
Port        Database Engine                 Default Protocol        Security Note / Common Exploits
-----------------------------------------------------------------------------------------------------------------------
1433        Microsoft SQL Server (MSSQL)    TCP                     Frequently targeted for brute-force attacks.
1521        Oracle Database                 TCP                     Often scanned to find SID names via TNS listener.
3306        MySQL                           TCP                     Unencrypted by default; vulnerable to credential stuffing.
5432        PostgreSQL                      TCP                     Configuration flaws often expose the pg_hba.conf file.
6379        Redis (In-Memory Data)          TCP                     Often deployed without a password; prone to unauthorized access.
7000/7001   Apache Cassandra                TCP                     Cluster communication and SSL-based storage ports.
9200/9300   Elasticsearch                   TCP                     Search engine database; unauthenticated instances leak entire indices.
27017       MongoDB                         TCP                     NoSQL database; historically targeted when left wide open without Auth.

## Common Network Printing Ports
-----------------------------------------------------------------------------------------------------------------------
Port        Protocol    Common Service Name             Description
-----------------------------------------------------------------------------------------------------------------------
631         TCP/UDP     IPP / IPPS                      Internet Printing Protocol. Default for CUPS (Linux/macOS) and modern network printers.
9100        TCP         AppSocket / JetDirect           RAW printing protocol. Simplest and fastest raw data stream, pioneered by HP Jetdirect.
515         TCP         LPD / LPR                       Line Printer Daemon. Legacy Unix/Linux network printing architecture.
139 / 445   TCP         SMB / RPC                       Microsoft Windows printer sharing over Server Message Block.
161 / 162   UDP         SNMP                            Simple Network Management Protocol. Used by computers to monitor toner, ink, and printer status.
5353        UDP         mDNS / Bonjour                  Multicast DNS used for automated mobile printing discovery (e.g., Apple AirPrint).

## Core Management Ports
-----------------------------------------------------------------------------------------------------------------------
Port            Protocol    Service / Technology        Description
-----------------------------------------------------------------------------------------------------------------------
135             TCP         WMI / RPC Endpoint Mapper   The initial connection point for legacy WMI requests.
5985            TCP         WinRM (HTTP)                PowerShell Remoting default unencrypted traffic channel.5
986             TCP         WinRM (HTTPS)               PowerShell Remoting encrypted traffic channel (Recommended).
49152–65535     TCP         WMI Dynamic Ports           The random high ports assigned by RPC after initial handshakes.


 #>
param(
    [string]$Subnet = "192.168.1.0/24",
    [int[]]$Ports = @(22,80,135,443,3389,9100),
    [int]$Timeout = 100
)


function Get-IPRangeFromCIDR {
    param (
        [string]$CIDR
    )

    $parts = $CIDR -split '/'
    $baseIP = $parts[0]
    $prefix = [int]$parts[1]

    # Convert IP to number
    $ipBytes = ([System.Net.IPAddress]::Parse($baseIP)).GetAddressBytes()
    [array]::Reverse($ipBytes)
    $ipInt = [BitConverter]::ToUInt32($ipBytes, 0)

    # Calculating Net Mask
    $maskInt = [uint32]::MaxValue -shl (32 - $prefix)

    # Calculating network and broadcast
    $network = $ipInt -band $maskInt
    $broadcast = $network + ([math]::Pow(2, (32 - $prefix)) - 1)

    # Create IPs list
    for ($i = $network; $i -le $broadcast; $i++) {
        $bytes = [BitConverter]::GetBytes([uint32]$i)
        [array]::Reverse($bytes)
        ([System.Net.IPAddress]::new($bytes)).ToString()
    }
}

Write-Host "Discover Hosts $Subnet..." -ForegroundColor Cyan
#Get-IPRangeFromCIDR -CIDR $Subnet 
$Hosts = Get-IPRangeFromCIDR -CIDR $Subnet
$activeHosts = @()

# 1. Find hosts ative (ping sweep)
$Hosts | ForEach-Object {
    $ip = $_
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        Write-Host "Host with PING: $ip" -ForegroundColor Green
        $activeHosts += $ip
    }
}

Write-Host "Scanning ports..." -ForegroundColor Cyan

# 2. Scan ports in active list
$activeHosts | ? {
    $h = $_
    Write-Host "- Host: $h" -ForegroundColor Yellow

    foreach ($port in $Ports) {
        $tcp = New-Object System.Net.Sockets.TcpClient

        try {
            $async = $tcp.BeginConnect($h, $port, $null, $null)
            $wait = $async.AsyncWaitHandle.WaitOne($Timeout)

            if ($wait -and $tcp.Connected) {
                Write-Host "`t- $port: Open" -ForegroundColor Green
            }
        }
        catch {}
        finally {
            $tcp.Close()
        }
    }
}
