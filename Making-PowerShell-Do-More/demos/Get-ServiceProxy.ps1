#requires -version 7.2

<#
This is a copy of:

Verb Noun    HelpFile                                              PSSnapIn Version ImplementingType
---- ----    --------                                              -------- ------- ----------------
Get  Service Microsoft.PowerShell.Commands.Management.dll-Help.xml          7.0.0.0 Microsoft.PowerShell.Com…

Created: 08 November 2022
Author : Jeff Hicks

#>

Function Get-Service2 {
    <#
    .ForwardHelpTargetName Microsoft.PowerShell.Management\Get-Service
    .ForwardHelpCategory Cmdlet

    #>
    [CmdletBinding(DefaultParameterSetName='Default', HelpUri='https://go.microsoft.com/fwlink/?LinkID=2096496', RemotingCapability='SupportedByCommand')]
    Param(

        [Parameter(
            ParameterSetName='Default',
            Position=0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
         )]
        [Alias('ServiceName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Name,

        [Alias('DS')]
        [switch]$DependentServices,

        [Alias('SDO','ServicesDependedOn')]
        [switch]$RequiredServices,

        [Parameter(ParameterSetName='DisplayName', Mandatory)]
        [string[]]$DisplayName,

        [ValidateNotNullOrEmpty()]
        [string[]]$Include,

        [ValidateNotNullOrEmpty()]
        [string[]]$Exclude,

        [Parameter(ParameterSetName='InputObject', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.ServiceProcess.ServiceController[]]$InputObject,

        [ValidateNotNullOrEmpty()]
        [System.ServiceProcess.ServiceControllerStatus]$Status,

        [ValidateNotNullOrEmpty()]
        [System.ServiceProcess.ServiceStartMode]$StartType
    )

    Begin {

        Write-Verbose "[BEGIN  ] Starting $($MyInvocation.Mycommand)"
        Write-Verbose "[BEGIN  ] Using parameter set $($PSCmdlet.ParameterSetName)"
        Write-Verbose ($PSBoundParameters | Out-String)

        #define a filter scriptblock
        $filterString = '$_'
        #remove bound parameters that don't belong to Get-Service
        ("Status","StartType").ForEach({
            if ($PSBoundParameters.ContainsKey($_)) {
                $filterstring+= " -AND `$_.$_ -eq '$($PSBoundParameters[$_])'"
                [void]$PSBoundParameters.Remove($_)
            }
        })
        Write-Verbose "[BEGIN  ] Creating filter $filterString"
        $filterSB = [scriptblock]::Create($filterString)
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-Service', [System.Management.Automation.CommandTypes]::Cmdlet)
            #Filter output from Get-Service based on the custom parameters
            $scriptCmd = {& $wrappedCmd @PSBoundParameters | Where-Object $filterSB}

            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    } #begin

    Process {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    } #process

    End {
        Write-Verbose "[END    ] Ending $($MyInvocation.Mycommand)"

        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    } #end

} #end function Get-Service