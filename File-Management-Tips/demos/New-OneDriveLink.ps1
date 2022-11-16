#requires -version 5.1

#add junctions to OneDrive folders using the OneDrive folder name and the specified local path.
#items should correspond to OneDrive folder names

Function New-OneDriveLink {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("odl")]
    [OutputType("System.IO.DirectoryInfo")]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Enter the OneDrive folder name to link to."
            )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name,
        [Parameter(
            ValueFromPipelineByPropertyName,
            HelpMessage = "Enter the path for the new item. The default is C:\"
            )]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path = "C:\",
        [Parameter(HelpMessage = "Force overwriting an existing location.")]
        [switch]$Force
    )

    Begin {
        Write-Verbose "Starting $($myinvocation.MyCommand)"
        #get the OneDrive folder location
        #You could probably also use the OneDrive environtmet variable
        Try {
            $onedrive = (Get-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\OneDrive -Name UserFolder -ErrorAction Stop).userFolder
        }
        Catch {
            Write-Warning "Failed to get a location for OneDrive from the registry under HKCU:\SOFTWARE\Microsoft\OneDrive"
            Write-Verbose "Ending $($myinvocation.MyCommand)"
            Throw $_
        }
        Write-Verbose "Found a OneDrive location at $onedrive"
    } #begin

    Process {
        Write-Verbose "Using these bound parameters"
        $PSBoundParameters | Out-String | Write-Verbose
        if (Test-Path $onedrive) {
            foreach ($item in $Name) {
                $source = Join-Path -Path $OneDrive -ChildPath $Item
                Write-Verbose "Using source $source"

                $target = Join-Path -path $Path -ChildPath $item
                Write-Verbose "Setting target to $target"
                if ((Test-Path $Target) -AND (-not $Force)) {
                    Write-Warning "A folder called $Item already exists at $Target. Use -Force to overwrite."
                }
                elseif (Test-Path $Source) {
                    Write-Verbose "Creating junction $item at $path from source $source."
                    New-Item -Name $item -Path $Path -ItemType Junction -Value $source -force:$force
                }
                else {
                    Write-Warning "Failed to find $source. Check the name and try again."
                }
            }
        }
        else {
            Write-Warning "Failed to find a OneDrive folder at $onedrive"
        }
    } #Process
    End {
        Write-Verbose "Ending $($myinvocation.MyCommand)"
    } #end
} #close function