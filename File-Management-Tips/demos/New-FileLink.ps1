#requires -version 5.1

Function New-FileLink {

    <#
    .Synopsis
    Create a symbolic file link
    .Description
    Use this command to copy a file to a target destination as a symoblic link.
    .Parameter TargetPath
    Specify the target DIRECTORY for the new linked file.
    .Parameter SourceFile
    Specify the full path to the source file.
    .Example
    PS C:\> New-FileLink -TargetPath 'C:\Program Files\WindowsPowerShell\Scripts' -SourceFile C:\scripts\HyperVStatus.ps1
    .NOTES
    This command has an alias of nfl.
    #>

    [cmdletbinding(SupportsShouldProcess)]
    [alias("nfl")]
    Param(
        [Parameter(Position = 0, HelpMessage = "Specify the target DIRECTORY for the new linked file.")]
        [string]$TargetPath = ".",
        [Parameter(Mandatory, HelpMessage = "Specify the full path to the source file.", ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [ValidateScript( { Test-Path $_ })]
        [alias("fullname")]
        [string]$SourceFile
    )

    Begin {
        Write-Verbose "Starting $($myinvocation.MyCommand)"

        $params = @{
            ItemType = "SymbolicLink"
            Path     = ""
            Value    = ""
            Force    = $True
        }

    }
    Process {
        $item = Get-Item -Path $sourceFile
        Write-Verbose "Processing $sourcefile"

        $TargetName = Join-Path -Path $TargetPath -ChildPath $item.name
        Write-Verbose "Linking $($item.fullname) to $TargetName"
        $params.Path = $TargetName
        $params.Value = $item.Fullname
        New-Item @params

    }
    End {
        Write-Verbose "Ending $($myinvocation.MyCommand)"
    }
}
