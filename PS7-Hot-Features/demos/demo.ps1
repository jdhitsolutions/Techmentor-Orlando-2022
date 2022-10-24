return "This is a demo script file."

#region new variables

$PSVersiontable
Get-Variable is*
$PSEdition
$PSHome

#endregion
#region PSStyle

#no need to struggle with ANSI escape sequences
$PSStyle
$psstyle | Get-Member
$psstyle.Foreground
$psstyle.Background

"$($psstyle.underline)This is $($psstyle.bold)$($psstyle.italic)PowerShell$($psstyle.Reset): $($psstyle.Foreground.BrightGreen)$($psstyle.background.cyan)$($PSVersiontable.PSVersion)$($psstyle.Reset)"

#formatting
$psstyle.Formatting
$psstyle.Formatting.TableHeader = $PSStyle.Background.Yellow + $PSStyle.Foreground.black
$psstyle.Formatting
Get-Service b*
$psstyle.Formatting.TableHeader = $psstyle.Italic + $PSStyle.Foreground.FromRgb(255, 87, 51)
Get-Process -Id $pid

#Write-Progress
#this works better in the console
$psstyle.Progress
1..10 | ForEach-Object -Begin { $i = 0 } -Process {
    $i++
    Write-Progress -Activity working -Status "Processing $_" -PercentComplete (($i / 10) * 100)
    Start-Sleep -Seconds 1
}

$psstyle.Progress.Style = $PSStyle.Foreground.BrightMagenta
#repeat
#use classic
$psstyle.Progress.View = "classic"
#classic uses $host.privatedata for style
$psstyle.Progress.View = "minimal"

#PSStyle directory listings
# https://4sysops.com/archives/using-powershell-with-psstyle/
Get-ExperimentalFeature PSAnsiRenderingFileInfo

# Enable-ExperimentalFeature PSANSIRenderingFileInfo
$psstyle.FileInfo
#add
$psstyle.FileInfo.Extension.add(".log", $psstyle.Foreground.BrightCyan)
#change
$psstyle.FileInfo.Extension[".txt"] = "`e[38;5;123m"

Get-ChildItem c:\work

#endregion
#region Out-ConsoleGridview

# Install-Module Microsoft.PowerShell.ConsoleGuiTools

Get-Process | Out-ConsoleGridView -Title "Select a process" -OutputMode Multiple

#endregion
#region Get-Error

Get-Service foo
Get-Error -Newest 1

$psstyle.Formatting

#endregion
#region Foreach Parallel

1..10 | ForEach-Object -Parallel {
    Start-Sleep -Seconds (Get-Random -Minimum 2 -Maximum 10)
    $m = "[$(Get-Date -f 'hh:mm:ss.ffff')] $_"
    $m
}

#not always faster
Measure-Command {
    $a = 1..5000 | ForEach-Object { [math]::Sqrt($_) * 2 }
}

Measure-Command {
    $a = 1..5000 | ForEach-Object -Parallel { [math]::Sqrt($_) * 2 }
}

#scriptblock to run in parallel
$t = {
    param ([string]$Path)
    Write-Host "[$(Get-Date)] Processing $Path" -ForegroundColor yellow
    Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |
    Measure-Object -Sum -Property Length -Maximum -Minimum |
    Select-Object @{Name = "Computername"; Expression = { $env:COMPUTERNAME } },
    @{Name = "Path"; Expression = { Convert-Path $path } },
    Count, Sum, Maximum, Minimum
    Write-Host "[$(Get-Date)] Finished processing $Path" -ForegroundColor Yellow
}

#NOT Parallel
# 30 seconds
Measure-Command {
    $out = "c:\work", "c:\windows", "c:\scripts", "$env:temp", "c:\users\jeff\documents" |
    ForEach-Object -Process { Invoke-Command -ScriptBlock $t -ArgumentList $_ }
}

#Parallel
#harder to pass variables to runspaces
# 11 seconds
Measure-Command {
    $out = "c:\work", "c:\windows", "c:\scripts", "$env:temp", "c:\users\jeff\documents" |
    ForEach-Object -Parallel {
        $path = $_
        Write-Host "[$(Get-Date)] Processing $Path" -ForegroundColor yellow
        Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |
        Measure-Object -Sum -Property Length -Maximum -Minimum |
        Select-Object @{Name = "Computername"; Expression = { $env:COMPUTERNAME } },
        @{Name = "Path"; Expression = { Convert-Path $path } },
        Count, Sum, Maximum, Minimum
        Write-Host "[$(Get-Date)] Finished processing $Path" -ForegroundColor Yellow
    }
}

#endregion
#region SSH Remoting

#get ssh working natively before using in PowerShell
#this may not work in VSCode
Enter-PSSession -HostName srv1 -UserName artd -SSHTransport

$PSVersiontable
get-variable is*

Enter-PSSession -HostName fred-company-com -UserName jeff -SSHTransport

New-pssession -computer dom1,srv2
new-pssession -HostName fred-company-com -UserName jeff -SSHTransport
new-pssession -HostName srv1 -UserName artd -SSHTransport
Get-PSSession

#use full cmdlet names to avoid issues
#Sort on linux runs the native command, not Sort-Object
invoke-command { Get-Process | sort-object WS -Descending | select-object -first 1} -session (Get-PSSession)

#endregion
#region PSReadline
#technically this is not limited to PowerShell 7
#Some features won't work in VSCode
Get-Module PSReadline

#inline help
# Get-Service<f1>

#command prediction
#may not work properly in VSCode
get-psreadlineoption | Select-Object prediction*,history*
#demo prediction
#demo changing view

Get-PSReadlineoption |
Select-Object PredictionSource,PredictionViewStyle,
@{Name="ListPrediction";Expression = { "{0}{1}$($psstyle.reset)" -f $_.ListPredictionColor,( $_.ListPredictionColor  -replace [char]27,'`e')}},
@{Name="ListPredictionSelected";Expression = { "{0}{1}$($psstyle.reset)" -f $_.ListPredictionSelectedColor,( $_.ListPredictionSelectedColor  -replace [char]27,'`e')}},
@{Name="InlinePrediction";Expression = {"{0}{1}$($psstyle.reset)" -f $_.InlinePredictionColor,$($_.InlinePredictionColor  -replace [char]27,'`e')}}

#changing colors
Set-PSReadLineOption -Colors @{
   InlinePrediction = $psstyle.Foreground.blue+$psstyle.Underline +$PSStyle.Italic #"`e[4;92m"
   ListPrediction = $psstyle.foreground.brightblue
} -PredictionSource History -PredictionViewStyle ListView


#endregion

