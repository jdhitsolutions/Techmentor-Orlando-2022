#requires -version 5.1

# dir *.ps1 | gfa -GroupBy days

#declaring a namespace here makes the code simpler later on
Using namespace System.Collections.Generic

#define an enumeration that will be used in a new custom property
Enum FileAge {
    YearPlus
    Year
    NineMonth
    SixMonth
    ThreeMonth
    OneMonth
    OneWeek
    OneDay
}
Function Get-FileAgeGroup {
    [cmdletbinding()]
    [alias("gfa")]
    [OutputType("FileAgingInfo")]
    Param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,HelpMessage = "The path to a file. If you pipe from a Get-ChildItem command, be sure to use the -File parameter.")]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]$FilePath,
        [Parameter(HelpMessage = "Specify if grouping by the file's CreationTime or LastWriteTime property. The default is LastWriteTime.")]
        [ValidateSet("CreationTime","LastWritetime")]
        [ValidateNotNullOrEmpty()]
        [string]$Property = "LastWriteTime",
        [Parameter(HelpMessage = "How do you want the files organized? The default is Month.")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Month","Year","Days")]
        [string]$GroupBy = "Month"
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Grouping by $GroupBy on the $Property property"

        #initialize a list to contain all piped in files
        #this code is shorter because of the Using statement at the beginning of this file
        $list = [List[System.IO.FileInfo]]::new()

        #get a static value for now
        $now = Get-Date
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Adding $FilePath"
        #add each file to the list
        $list.Add($FilePath)
    } #process

    End {
        #now process all the files and add aging properties
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Sorting $($list.count) files"

        #add custom properties based on the age grouping
        foreach ($file in $list) {
            switch ($GroupBy) {
                "Month" {
                    $value = "$($file.$property.month)/$($file.$property.year)"
                    $sort = {$_.AgeGroup -as [datetime]}
                }
                "Year" {
                    $value = $file.$property.year
                    $sort = "AgeGroup"
                }
                "Days" {
                    $age = New-TimeSpan -start $file.$property -end $now
                    $value = switch ($age.totaldays -as [int]) {
                        {$_ -ge 365} {[FileAge]::YearPlus ; break}
                        {$_ -gt 270 -AND $_ -lt 365 }{[FileAge]::Year;break}
                        {$_ -gt 180 -AND $_ -le 270 }{[FileAge]::NineMonth;break}
                        {$_ -gt 90 -AND $_ -le 180} {[FileAge]::SixMonth;break}
                        {$_ -gt 30 -AND $_ -le 90} {[FileAge]::ThreeMonth;break}
                        {$_ -gt 7 -AND $_ -le 30} {[FileAge]::OneMonth;break}
                        {$_ -gt 1 -And $_ -le 7} {[FileAge]::OneWeek;break}
                        {$_ -le 1} {[FileAge]::OneDay;break}
                    }
                    $sort = "AgeGroup"
                }
            } #switch

            #add a custom property to each file object
            $file | Add-Member -MemberType NoteProperty -Name AgeGroup -Value $value

            #insert a custom type name which will be used by the custom format file
            $file.psobject.TypeNames.insert(0,"FileAgingInfo")
        } #foreach file

        #write the results to the pipeline. Sorting results so that the default
        #formatting will be displayed properly
        $list | Sort-Object -Property $sort,DirectoryName,$property,Name

        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Get-FileAgeGroup

#load the custom format file into the PowerShell session
Update-FormatData $psscriptroot\FileAge.format.ps1xml
