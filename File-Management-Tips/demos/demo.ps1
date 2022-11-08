return "This is a demo script file."

#region PSStyle File Display

Dir c:\work
Get-ExperimentalFeature

Enable-ExperimentalFeature PSAnsiRenderingFileInfo -WhatIf
#reboot
$psstyle.FileInfo

<#
Directory    : `e[44;3m
SymbolicLink : `e[38;5;227m
Executable   : `e[32;1m
Extension    : .zip    = "`e[35;1m"
               .tgz    = "`e[31;1m"
               .gz     = "`e[31;1m"
               .tar    = "`e[31;1m"
               .nupkg  = "`e[31;1m"
               .cab    = "`e[31;1m"
               .7z     = "`e[31;1m"
               .ps1    = "`e[38;5;12m"
               .psd1   = "`e[94m"
               .psm1   = "`e[94m"
               .ps1xml = "`e[90m"
               .md     = "`e[38;5;201m"
               .xml    = "`e[38;5;204m"
               .txt    = "`e[38;5;195m"
               .json   = "`e[38;5;204m"
               .csv    = "`e[38;5;204m"
               .gif    = "`e[38;5;111m"
               .bmp    = "`e[38;5;111m"
               .png    = "`e[38;5;111m"
               .jpg    = "`e[38;5;111m"
               .jpeg   = "`e[38;5;111m"
#>
$psstyle
$psstyle | Get-Member
$psstyle.Foreground
$psstyle.Background
$psstyle.fileinfo.Directory = $psstyle.Background.Yellow+$psstyle.Foreground.green+$psstyle.Bold+$psstyle.Italic
dir c:\work -Directory

#changing file extensions
$psstyle.FileInfo.Extension
#you can use any ANSI sequence
$psstyle.FileInfo.Extension[".ps1"] = "`e[38;5;51m"

#Install-Module PSScripttools
Show-ANSISequence -Foreground

#add an extension
#using an RGB color
$psstyle.FileInfo.Extension.Add(".db",$psstyle.Foreground.FromRgb(241,196,15))

dir C:\work

#add to profile to persist changes
# run $PSStyle.reset to reset goofs

#read more: https://4sysops.com/archives/using-powershell-with-psstyle/

<# more fun
# https://github.com/devblackops/Terminal-Icons
# requirement: https://github.com/ryanoasis/nerd-fonts
Install-Module Terminal-Icons

Import--Module Terminal-Icons
#>

#endregion
#region Symbolic Links

Get-Item c:\scripts
Get-Item $profile

help New-Item -Parameter ItemType
psedit .\New-OneDriveLink.ps1

New-OneDriveLink -Path c:\work -Name Scratch -WhatIf
dir C:\work\scratch
get-item c:\work\scratch | select target
#original unchanged
dir C:\users\jeff\OneDrive\scratch

remove-item c:\work\scratch

psedit .\New-FileLink.ps1
New-FileLink -TargetPath c:\work -SourceFile $env:OneDrive\tools\du.exe -verbose
c:\work\du
c:\work\du -c -q -nobanner c:\work | convertfrom-csv

remove-item C:\work\du.exe

#I use this to run scripts without specifying the path
# install-script winfetch
get-command winfetch | select commandtype,name,source
$env:path -split ";" | sort | select -unique

New-FileLink -TargetPath C:\Users\Jeff\Documents\PowerShell\Scripts -SourceFile c:\scripts\show-weatherinfo.ps1
get-command show-weatherinfo.ps1 | select name,source
cls
show-weatherinfo.ps1 32801


#endregion
#region scripting System.IO

$d = get-item C:\work
$d | get-member -MemberType method

$d.getfiles.OverloadDefinitions
$d.EnumerateFiles.OverloadDefinitions

<#
The EnumerateFiles and GetFiles methods differ as follows: When you use EnumerateFiles,
you can start enumerating the collection of names before the whole collection is returned;
 when you use GetFiles, you must wait for the whole array of names to be returned
 before you can access the array. Therefore, when you are working with many files
 and directories, EnumerateFiles can be more efficient.

https://stackoverflow.com/questions/5669617/what-is-the-difference-between-directory-enumeratefiles-vs-directory-getfiles
#>

$d.EnumerateFiles()

#Added in PS 7
#most noticeable on large directories
$opt = [System.IO.EnumerationOptions]::new()
$opt
$opt.RecurseSubdirectories = $True
$d = Get-Item c:\scripts
Measure-command {$d.EnumerateFiles("*.*",$opt)}
Measure-Command { dir c:\scripts\ -file -recurse}

<#
Windows PowerShell
$d.enumerateFiles.overloaddefinitions

System.Collections.Generic.IEnumerable[System.IO.FileInfo] EnumerateFiles()
System.Collections.Generic.IEnumerable[System.IO.FileInfo] EnumerateFiles(string searchPattern)
System.Collections.Generic.IEnumerable[System.IO.FileInfo] EnumerateFiles(string searchPattern, System.IO.SearchOption
searchOption)

$d.enumerateFiles("*.txt","AllDirectories") | measure

#>

cls
#endregion
#region Usage reporting

#Install-Module PSScriptTools
# https://github.com/jdhitsolutions/PSScriptTools
psedit C:\scripts\psscripttools\functions\Get-FolderSizeInfo.ps1
Get-FolderSizeInfo C:\Scripts
get-history -count 1

Show-Tree C:\work
Show-Tree c:\work -ansi
Show-Tree c:\work -ansi -files -ShowProperty Name,Length | more

Get-FileExtensionInfo -Path c:\work

Get-LastModifiedFile -Path c:\scripts -Filter *.ps1 -Interval Days -IntervalCount 7

#custom formatting
psedit .\Get-FileAgeGroup.ps1
. C:\scripts\Get-FileAgeGroup.ps1
help Get-FileAgeGroup

dir c:\work\*.ps1 | get-fileagegroup -GroupBy Days
#endregion
#region File hashes

Get-FileHash -Path $profile
help Get-fileHash -parameter Algorithm

dir c:\work -file | Get-FileHash

#copy with validation
$file =  "C:\scripts\PSMusicFiles.zip"
$dest = $env:TEMP

Get-Item $file | ForEach-Object {
    #calculate current hash
    Write-Host "Copying $($_.fullname) to $dest" -ForegroundColor Yellow
    $origHash = Get-FileHash -Path $_.FullName -Algorithm MD5

    #copy file
    $filecopy = $_ | Copy-Item -Destination $dest -PassThru

    #get hash of copied file
    $copyHash = Get-FileHash -Path $filecopy.FullName -Algorithm MD5

    #compare them
    Write-Host "Comparing original hash: $($origHash.hash) to copy hash: $($copyHash.hash)" -ForegroundColor cyan
    if ($origHash.hash -ne $copyHash.hash) {
       Write-Warning "$($_.Fullname) and $($filecopy.fullname) hash mismatch"
    }
    else {
       Write-Host "$($_.Fullname) and $($filecopy.fullname) hash ok" -ForegroundColor Green
    }
   } #foreach



psedit .\Copy-VerifiedFile.ps1
. .\Copy-VerifiedFile.ps1
$f = Get-Childitem c:\scripts\*.zip -OV Z | Copy-VerifiedFile -Destination $env:temp -force -verbose #-WhatIf

$f | select name,*hash

Get-Job | Remove-Job

#test with failures
. .\Copy-VerifiedFileTest.ps1
$x = Get-Childitem c:\scripts\*.xml | Copy-VerifiedFileTest -Destination $env:temp -force -verbose
$x
$x | where {$_.copyhash -ne $_.originalhash} | select name,*hash

get-job -State Failed
get-job -State Failed | receive-job -keep -Verbose

#endregion

#region Finding duplicates

# https://github.com/psDevUK/PSDupes
# Install-Module PSDupes -scope allusers -force

Invoke-PSDupes -Path C:\work
$r =Invoke-PSDupes -Path C:\work -ShowSize -JSONoutput | ConvertFrom-Json
$r
Foreach ($set in $r.matchSets) {
    $set.filelist |  format-table -group @{Name="Size";Expression={$set.filesize}} -Property Filepath,
    @{Name="Created";Expression={ (Get-Item $_.filepath).Creationtime}},
    @{Name="Modified";Expression={ (Get-Item $_.filepath).LastWritetime}}
}

help invoke-PSDupes

#endregion
