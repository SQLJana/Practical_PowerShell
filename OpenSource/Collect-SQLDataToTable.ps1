
# Let us make a function by parameterizing key inputs
#-----------------------------------------------------------------------

####################### 
<# 
.SYNOPSIS 
    Collects data and saves to target table

.DESCRIPTION 
    Given a list of SQL Servers, loops through and collects data based on input SQL
        and saves the results to given target table

.EXAMPLE 
    
    Collect-SQLDataToTable `
        -SourceServerInstance '(local)' `
        -SourceDatabaseName 'master' `
        -InputFile 'C:\1Presentations\2016_PracticalPoSh\OpenSource\dm_os_performance_counters.sql' `
        -TargetServerInstance '(local)' `
        -TargetDatabaseName 'DC' `
        -TargetTableOwner 'dbo' `
        -TargetTableName 'PerfCounters' `
        -Verbose

    This example saves performance counter data to server and table using an input SQL file

.EXAMPLE 
    
    $pair1 = New-Object -TypeName PSObject
    $pair1 | Add-Member -MemberType NoteProperty -Name SourceServerInstance -Value '(local)'
    $pair1 | Add-Member -MemberType NoteProperty -Name SourceDatabaseName -Value 'Master'

    $pair2 = New-Object -TypeName PSObject
    $pair2 | Add-Member -MemberType NoteProperty -Name SourceServerInstance -Value '(LOCAL)'
    $pair2 | Add-Member -MemberType NoteProperty -Name SourceDatabaseName -Value 'Master'

    @($pair1, $pair2) |
        Collect-SQLDataToTable `
            -Query 'sp_who' `
            -TargetServerInstance '(local)' `
            -TargetDatabaseName 'DC' `
            -TargetTableOwner 'dbo' `
            -TargetTableName 'sp_Who_Data' `
            -Verbose

    This example saves sp_who data to server and table using an input SQL. Notice the user of pipelining


.NOTES 
    Functions similar to this can be found at sqljana.wordpress.com to use as a model

    This function is for illustration purposes only!

Version History 
    v1.0  - Jana Sattainathan [Twitter: @SQLJana] [Blog: sqljana.wordpress.com] - Initial Release
#> 
Function Collect-SQLDataToTable
{ 
 
    [CmdletBinding()] 
    param( 

        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true, Mandatory=$true)] 
        [string]$SourceServerInstance,

        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true, Mandatory=$true)] 
        [string]$SourceDatabaseName,

        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true, Mandatory=$true, ParameterSetName='SQL')]
        [string]$Query,

        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true, Mandatory=$true, ParameterSetName='File')] 
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$InputFile,

        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true, Mandatory=$true)] 
        [string]$TargetServerInstance,

        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true, Mandatory=$true)] 
        [string]$TargetDatabaseName,

        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true, Mandatory=$false)] 
        [String]$TargetTableOwner = 'dbo',

        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true, Mandatory=$true)] 
        [String]$TargetTableName
    
    ) 

    Begin
    {
        #We cannot access input parameter here!
        Write-Verbose ('Begin')        
    }

    Process
    {
        Write-Verbose ('Process $SourceServerInstance = {0}, SourceDatabaseName = {1}' -f $SourceServerInstance, $SourceDatabaseName)

        [int] $counter = 0
        [bool] $tableCreated = $false
        [string] $tableOwnerDotName = if (($TargetTableOwner.Trim().Length -eq 0) -or ($TargetTableOwner.Trim() -eq 'dbo')){ $TargetTableName } else { "[$TargetTableOwner].[$TargetTableName]"}
        [string] $sql = ''

        try
        {
            Write-Verbose 'Use the SQL as is (or) from the file'
            #--------------------------------------------------------

            $sql = if ($Query)
                    {
                        $Query
                    } 
                    else 
                    { 
                        $filePath = $(resolve-path $InputFile).path 
                        [System.IO.File]::ReadAllText("$filePath") 
                    }                    

            Write-Verbose "Get the data for [$SourceServerInstance]"
            #--------------------------------------------------------
            # Get the data. Add Database to the "server list" table if it is custom

            $resultDataTable = Invoke-Sqlcmd2 `
                                        -ServerInstance $SourceServerInstance `
                                        -Database $SourceDatabaseName `
                                        -Query $sql `
                                        -Verbose
    

            Write-Verbose 'Add ServerName and DateTimeStamp columns'
            #--------------------------------------------------------
            
            $resultDataTable = $resultDataTable | 
                                SELECT `
                                    @{Label='ServerName';Expression={$SourceServerInstance}},
                                    @{Label='DateTimeStamp';Expression={Get-Date}},
                                    * |                     
                                Out-DataTable


            Write-Verbose 'Create target table if it does not exist'
            #--------------------------------------------------------

            if ($tableCreated -eq $false)
            {
                # Let us not do this for every iteration of server list loop using $tableCreated

                if ((Test-SQLTableExists `
                        -ServerInstance $TargetServerInstance `
                        -Database $TargetDatabaseName `
                        -TableOwner $TargetTableOwner `
                        -TableName $TargetTableName) `
                        -eq $false)
                {
                    Write-Verbose "Creating target table [$TargetTableName] as it does not exist"
                    #--------------------------------------------------------

                    Add-SqlTable `
                            -ServerInstance $TargetServerInstance `
                            -Database $TargetDatabaseName `
                            -TableName $tableOwnerDotName `
                            -DataTable $resultDataTable `
                            -MaxLength 255
                }
                
                $tableCreated = $true
            }


            Write-Verbose 'Write the data to the DB'
            #--------------------------------------------------------
    
            Write-DataTable `
                -ServerInstance $TargetServerInstance `
                -Database $TargetDatabaseName `
                -TableName $tableOwnerDotName `
                -Data $resultDataTable

            Write-Verbose "Completed collection for [$SourceServerInstance]"
            Write-Verbose '-------------------------------------------------'                    

        }
        catch 
        {
            $message = $_.Exception.GetBaseException().Message
            Write-Error $message
        }
        
        $counter ++
    }
    
    End
    {
        Write-Verbose ('End')
        Write-Verbose "Collected from [$counter] SQL instances!"
    }    
} #Collect-SQLDataToTable
