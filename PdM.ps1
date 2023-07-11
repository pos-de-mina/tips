<#
.LINK
    https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.3
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.3
 # 
 # Author: https://github.com/pos-de-mina/tips/
 #>

#
Get-PSDrive -PSProvider FileSystem

# 
Get-Volume

# Compress Files Older Than x Days
Get-ChildItem C:\SecurityCenterBackup\ -Exclude *.zip | Sort-Object LastWriteTime | Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddDays(-90)
} | Select-Object -First 10 | ForEach-Object {
    Compress-Archive -Path $_ -Destination "$($_.DirectoryName)\$($_.LastWriteTime.ToString("yyyy-MM")).zip" -Update -CompressionLevel Optimal -ErrorAction Stop
    Remove-Item $_
}

# get oldest files
Get-ChildItem C:\SecurityCenterBackup\ -Exclude *.zip | Sort-Object LastWriteTime

# check size in GB
Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    $drive = "$($_.Name):\"
    $size = 0
    Write-Host "Check Size of *.log files in drive $drive..."
    Get-ChildItem $drive -Recurse -File -Include *.log | ForEach-Object {
        $size += $_.Length
    }
    Write-Host "Total size of .log files on drive $drive is $($size / 1GB)!"
}


# check size in GB
Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    $drive = "$($_.Name):\"
    $size = 0
    $count
    Write-Host "Check Size of *.log files in drive $drive..."
    Get-ChildItem $drive -Recurse -File -Include *.log | ForEach-Object {
        $size += $_.Length
    }
    Write-Host "Total size of .log files on drive $drive is $($size / 1GB)!"
}

# folder size
$size = 0
Get-ChildItem 'C:\Windows\Temp' -Recurse -File -Include *.log | ForEach-Object {
    $size += $_.Length
}
Write-Host "Total size of .log files on drive $drive is $($size / 1GB)!"

# temp files
function Remove-TempFiles (
    $Days = 90
) {
    Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue `
    "$env:SystemDrive\Windows\Temp\", `
    "$env:SystemDrive\Users\*\AppData\Local\Temp\", `
    "$env:SystemDrive\Windows\SoftwareDistribution\Download\", `
    "$env:SystemDrive\Windows\Minidump\", `
    "$env:SystemDrive\$`Recycle.Bin\" | `
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$Days) } | `
    Remove-Item -ErrorAction SilentlyContinue -Verbose
}

# counters
[PSCustomObject]@{
    "Host Name"                 = $env:COMPUTERNAME
    "Processor Utilization [%]" = (Get-Counter  '\Processor(_Total)\% Processor Time' | Select-Object -ExpandProperty CounterSamples).CookedValue
    "Memory Available [GB]"     = (Get-Counter '\Memory\Available MBytes' | Select-Object -ExpandProperty CounterSamples).CookedValue / 1024
    "Memory Total [GB]"         = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Sum -Property Capacity).Sum / 1GB
}

# check size
function Get-TopBiggestFiles (
    $Folder = '.',
    $Top = 10,
    $MinSize = 1MB
) {
    Get-ChildItem -Path $Folder -Recurse -File -ErrorAction SilentlyContinue | 
    Where-Object {
        $_.Length -gt $MinSize
    } |
    Sort-Object Length -Descending | 
    Select-Object -First $Top FullName, Length, LastWriteTime
}

# Powershell du linux like
function Get-DirectorySummary (
    $dir = "."
) {
    Get-ChildItem -Path $dir -Attributes Directory -ErrorAction SilentlyContinue |
    ForEach-Object { 
        $f = $_ ;
        $m = get-childitem -Recurse $_.FullName -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum 

        [PSCustomObject]@{
            Name        = $f.FullName
            "Size [GB]" = [math]::Round($m.Sum / 1GB, 3)
            "Files [#]" = $m.Count
        }
    }
}
