#requires -version 7.2
#requires -module ThreadJob

# THIS FUNCTION SHOULD NOT BE CONSIDERED PRODUCTION-READY

#simulate hash validation errors
Function Copy-VerifiedFileTest {
    [cmdletbinding(SupportsShouldProcess)]
    [alias("cvf")]
    [OutputType("System.IO.FileInfo")]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            ValueFromPipeline
        )]
        [System.IO.FileInfo]$Path,
        [Parameter(Mandatory)]
        [string]$Destination,
        [switch]$Force
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        #specify the hashing algorithm
        $hashing = "MD5"

    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing $($path.fullname)"
        $path | ForEach-Object {
            Start-ThreadJob -Name $_.name -ArgumentList $_.fullname, $Destination, $force -ScriptBlock {
                Param($path, $destination, $force)
                $VerbosePreference = $using:VerbosePreference
                $WhatIfPreference = $using:WhatIfPreference

                #add -Passthru to PSBoundParameters
                $PSBoundParameters.Add("Passthru", $True)

                Write-Verbose "[$((Get-Date).TimeofDay) THREAD ] Hashing $($path)"
                if (-Not $WhatIfPreference) {
                    $origHash = Get-FileHash -Path $path -Algorithm $using:hashing
                }

                Try {
                    #copy file
                    $filecopy = Copy-Item @psboundparameters -ErrorAction Stop
                    if (-Not $WhatIfPreference ) {
                        $copyHash = Get-FileHash -Path $path -Algorithm $using:hashing
                        Get-Item -Path $filecopy | Add-Member -MemberType NoteProperty -Name CopyHash -Value $CopyHash.Hash -PassThru |
                        Add-Member -MemberType NoteProperty -Name OriginalHash -Value $origHash.Hash -PassThru
                        #compare them
                        Write-Verbose "[$((Get-Date).TimeofDay) THREAD ] Comparing original hash: $($origHash.hash) to copy hash: $($copyHash.hash)"
                        if ($origHash.hash -ne $copyHash.hash) {
                            Write-Warning "$path and $($filecopy.fullname) hash mismatch"
                        }
                        else {
                            Write-Verbose "[$((Get-Date).TimeofDay) THREAD ] $path and $($filecopy.fullname) hash OK"
                        }
                    }

                }
                Catch {
                    Throw $_
                }
            } #threadjob script block
        } | Wait-Job | Receive-Job -Keep
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Copy-VerifiedFile