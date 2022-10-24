return "This is a demo script file."

#region PSStyle File Display


#endregion
#region Symbolic Links


#endregion
#region System.IO scripting


#endregion
#region Usage reporting


#endregion
#region Select-String


#endregion
#region File hashes

#copy with validation
#endregion
#region Using CIM


#endregion
#region Finding duplicates

# https://github.com/psDevUK/PSDupes
Install-Module PSDupes scope allusers -force

Invoke-PSDupes -Path C:\work
$r =Invoke-PSDupes -Path C:\work -ShowSize -JSONoutput | ConvertFrom-Json

Foreach ($set in $r.matchSets) {
    $set.filelist |  format-table -group @{Name="Size";Expression={$set.filesize}} -Property Filepath,
    @{Name="Created";Expression={ (Get-Item $_.filepath).Creationtime}},
    @{Name="Modified";Expression={ (Get-Item $_.filepath).LastWritetime}}
}


#endregion
