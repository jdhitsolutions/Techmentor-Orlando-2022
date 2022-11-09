#My custom aliases
[cmdletbinding()]
Param()

#my PowerShell command aliases
Set-Alias -Name sign -Value Set-AuthenticodeSignature
Set-Alias -Name now -Value Get-Date
Set-Alias -Name so -Value Select-Object -Option ReadOnly -Force
Set-Alias -Name wh -Value Write-Host
Set-Alias -Name grok -Value Get-Help
Set-Alias -Name cb -Value Set-Clipboard
Set-Alias -Name cl -Value Clear-HostFancily

#these scripts have been copied to  C:\Program Files\WindowsPowerShell\Scripts
Set-Alias -Name mbp -Value mybackuppending.ps1
Set-Alias -Name mbr -Value mybackupreport.ps1
Set-Alias -Name mbs -Value myBackupPendingSummary.ps1
Set-Alias -Name ubp -Value UpdateBackupPending.ps1
Set-Alias -Name hvs -Value hypervstatus.ps1

#define aliases if the command exists
$hash = @{
    daily      = 'C:\scripts\dailysummary.ps1'
    adsvw      = 'C:\scripts\exes\ADSVW.exe'
    wd         = 'C:\Program Files\Microsoft Office\Root\Office16\winword.exe'
    xl         = 'C:\Program Files\Microsoft Office\Root\Office16\EXCEL.EXE'
    pp         = 'C:\Program Files\Microsoft Office\Root\Office16\Powerpnt.exe'
    pe         = "$env:OneDrive\tools\procexp.exe"
    du         = "$env:OneDrive\tools\du.exe"
    pia        = 'C:\Program Files\Private Internet Access\pia-client.exe'
    rdcman     = 'C:\Program Files (x86)\Microsoft\Remote Desktop Connection Manager\RDCMan.exe'
    sed        = 'C:\Program Files\Git\usr\bin\sed.exe'
    awk        = 'C:\Program Files\Git\usr\bin\awk.exe'
    grep       = 'C:\Program Files\Git\usr\bin\grep.exe'
    ff         = 'C:\Program Files\Mozilla Firefox\firefox.exe'
    sqlite     = 'C:\scripts\sqlite3.exe'
    chr        = "$env:localappdata\Google\Chrome\Application\chrome.exe"
    qb         = "C:\Program Files\Intuit\QuickBooks 2022\QBWPro.exe"
    tb         = "C:\Program Files\Mozilla Thunderbird\thunderbird.exe"
    rar        = "C:\Program Files\WinRAR\rar.exe"
    np         = "$env:WinDir\notepad.exe"
    musescore3 = "C:\Program Files\MuseScore 3\bin\MuseScore3.exe"
    nano       = "C:\Scripts\nano.exe"
}

$hash.Keys | ForEach-Object {
    if (Test-Path $hash[$_]) {
        Write-Verbose "Creating alias $_"
        Set-Alias -Name $_ -Value $hash[$_] -Force -Option ReadOnly -Description "profile-defined"
    }
    else {
        Write-Verbose "Could not find $($hash[$_])."
    }
}

#set PS7 aliases
if ($isCoreClr -AND $IsWindows) {
    Set-Alias -Name ise -Value powershell_ise
}

#remove variables that shouldn't be exported
Remove-Variable hash
