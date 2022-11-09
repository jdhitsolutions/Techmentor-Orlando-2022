return "This is a demo script file."

#I'm using PowerShell 7.3. Most of these techniques will also work in Windows PowerShell 5.1.

$PSVersionTable

#region Using PSReadline

#demo in the console
Get-Module PSReadline
Get-PSReadlineOption

#tab-completion

#inline help

#command prediction

#endregion
#region Using Aliases and shortcuts
Get-Process
ps
#create your own
Set-Alias -Name np -Value notepad.exe -Force -Description 'Techmentor demo'
np
Get-Alias | where description -EQ 'profile-defined' | select name, definition

#I call this in my profile script
psedit .\jdh-aliases.ps1
#limitations
np S:\garp.json
#create a cheater function
Remove-Item alias:np
function np {
    Param([string]$Path)
    notepad.exe (Convert-Path $path)
}
np S:\garp.json

function time { Get-Date -Format t }
time

function dirw {
    Param([string]$Path = ".")
    Get-ChildItem $path -Directory | Format-Wide -AutoSize
}
dirw c:\work

#endregion
#region type extensions
Get-Item .\demo.ps1 | Get-Member

Update-TypeData -TypeName System.IO.FileInfo -MemberType ScriptProperty -MemberName IsPowerShell -Value { $this.extension -match "ps(d)?1(xml)?" } -Force

dir -file | select name, IsPowershell

# Install-Module PSTypeExtensionTools
# https://github.com/jdhitsolutions/PSTypeExtensionTools
Get-Content .\fileinfo-extensions.json
Import-PSTypeExtension -Path .\fileinfo-extensions.json
dir -file | select name, sizekb, Created, modified, createdAge | Format-Table

#property sets
$paramHash = @{
    typename   = "System.IO.FileInfo"
    name       = "info"
    properties = "Directory","Name", "IsReadOnly", "CreationTime", "LastWriteTime"
    filepath   = ".\myfileinfo.type.ps1xml"
}

New-PSPropertySet @paramHash
psedit .\myfileinfo.type.ps1xml
Update-TypeData -appendpath .\myfileinfo.type.ps1xml
dir  -file | get-member info
dir  -file | Select Info

dir  -file | Select Info | ft -GroupBy directory -Property Name,Is*,*time
#endregion
#region custom views

Get-Alias | select Name, definition, Options, ModuleName, Version
psedit .\alias.format.ps1xml
Update-FormatData .\alias.format.ps1xml
Get-Alias | Format-Table -View Options
Get-Alias | sort ModuleName | Format-Table -View source

psedit .\myfileinfo.format.ps1xml
Update-FormatData .\myfileinfo.format.ps1xml

#Install-Module PSScriptTools
Get-FormatView system.io.fileinfo-extensions
dir . | ft -View ansi
dir . | fl -View age

#create your own
help new-psformatxml
#get a sample object with no null or empty property values
#default format is a table

$paramHash = @{
    ViewName = "Age"
    Path = ".\process.format.ps1xml"
    Properties = "ID","Name","WS","Handles","StartTime",@{Name="Age";Expression={New-Timespan -start $_.starttime -end (Get-Date)}}
}
Get-Process -id $pid | New-PSFormatXML @paramHash
psedit .\process.format.ps1xml
#my revisions
psedit .\revised-process.format.ps1xml
Update-FormatData -AppendPath .\revised-process.format.ps1xml

Get-process p* | format-table -view Age

#endregion
#region PSDefaultParameterValues

#clear my defaults
$PSDefaultParameterValues.Clear()
Get-winevent -logname System -MaxEvents 1
$PSDefaultParameterValues.Add("Get-Winevent:Logname","System")
Get-WinEvent -MaxEvents 1
# you can override it
get-winevent application -MaxEvents 1
#alternative
$PSDefaultParameterValues["Receive-Job:Keep"] = $True
#you can use wildcards
$PSDefaultParameterValues.Add("*-AD*:Server","DOM1")
$cred = Get-Credential company\artd
$PSDefaultParameterValues.Add("*-AD*:Credential",$cred)
$PSDefaultParameterValues
get-addomain

#disable
$PSDefaultParameterValues | get-member
$PSDefaultParameterValues.disabled = $True
Get-Winevent -MaxEvents 1
$PSDefaultParameterValues["Disabled"] = $false
Get-Winevent -MaxEvents 1

#clear
$PSDefaultParameterValues.Clear()
help about_Parameters_Default_Values
#endregion
#region Argument completers

<#
Register-ArgumentCompleter -CommandName CommandName -ParameterName ParamName -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    #PowerShell code to populate $wordtoComplete
    Code | ForEach-Object {
        # completion text,listitem text,result type,Tooltip
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
#>

Register-ArgumentCompleter -CommandName Get-Command -ParameterName Verb -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Get-Verb "$wordToComplete*" |
    ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Verb, $_.Verb, 'ParameterValue', ("Group: $($_.Group)"))
    }
}

#dynamically get a list of commands with the common parameter to be auto-completed
$cmd = (Get-Command -Noun VM -Module Hyper-V | Where-Object { $_.parameters["name"] }).Name
Register-ArgumentCompleter -CommandName $cmd -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Get-VM -vmname "$wordToComplete*" |
    ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', ("State: $($_.State)"))
    }
}

#endregion
#region Proxy functions

$cmd = Get-Command Get-Service
$metadata = New-Object System.Management.Automation.CommandMetaData ($cmd)
[System.Management.Automation.ProxyCommand]::Create($metadata) | Set-Clipboard
#paste into a new file

#from PSScriptTools module
#the starting poing
Copy-Command -Command Get-Service -IncludeDynamic -AsProxy -UseForwardHelp
#my final proxy function
psedit .\Get-ServiceProxy.ps1

get-service2 -Status Stopped -StartType Automatic -Verbose | select name,status,start*
#documentation must be addressed
#do you want to overwrite the existing command?
#would you be better off with a wrapper function under a different name?

#endregion
