#---------------------------------------------------------------------------------
#Snippet to prevent accidental execution of entire demo script by hitting F5
#
#Author: Jana Sattainathan   | Twitter: @SQLJana    | Blog: SQLJana.WordPress.com
#
write-host -foregroundcolor yellow 'You hit F5. This will run this whole script.'
$response = Read-Host -Prompt 'Did you really mean to run the entire script?' 

if ($response -ne 'yes, I dont care about the demo') {
    throw [System.ArgumentException] "Aborting 'Run as script'! This sample file is not intended to be run as a script. Please highlight and run selection with F8."
}
#---------------------------------------------------------------------------------



. C:\1Presentations\2016_PracticalPoSh\OpenSource\Invoke-SQLCmd2.ps1
. C:\1Presentations\2016_PracticalPoSh\OpenSource\Out-DataTable.ps1
. C:\1Presentations\2016_PracticalPoSh\OpenSource\Add-SQLTable.ps1
. C:\1Presentations\2016_PracticalPoSh\OpenSource\Write-DataTable.ps1
. C:\1Presentations\2016_PracticalPoSh\OpenSource\Test-SQLTableExists.ps1
. C:\1Presentations\2016_PracticalPoSh\OpenSource\Collect-SQLDataToTable.ps1


##-----------------------------------------------------------------------
##
#******************* Collect data and save to target *****************************
##
##-----------------------------------------------------------------------


# Create a new database named DC (DataCollector) for us to collect the data into
#----------------------------------------
[string] $sql = @"
CREATE DATABASE [DC]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DC', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\DC.mdf' , SIZE = 4MB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'DC_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\DC_log.ldf' , SIZE = 1024KB , FILEGROWTH = 10%)

IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [DC] MODIFY FILEGROUP [PRIMARY] DEFAULT
"@


$rslt = Invoke-Sqlcmd2 `
            -ServerInstance '(local)' `
            -Database 'master' `
            -Query $sql `
            -ConnectionTimeout 10



##-----------------------------------------------------------------------
#This example saves performance counter data to server and table using an input SQL file
##-----------------------------------------------------------------------
Collect-SQLDataToTable `
        -SourceServerInstance '(local)' `
        -SourceDatabaseName 'master' `
        -InputFile 'C:\1Presentations\2016_PracticalPoSh\OpenSource\dm_os_performance_counters.sql' `
        -TargetServerInstance '(local)' `
        -TargetDatabaseName 'DC' `
        -TargetTableOwner 'dbo' `
        -TargetTableName 'PerfCounters' `
        -Verbose


#Look for a tabled named dbo.PerfCounters



    


##-----------------------------------------------------------------------
#This example saves sp_who data to server and table using an input SQL. Notice the user of pipelining
##-----------------------------------------------------------------------
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

    
#Look for a tabled named dbo.sp_Who_Data




##-----------------------------------------------------------------------
#Let us do it with full pipelining in true PowerShell style
##-----------------------------------------------------------------------

#This CSV has the list source, query and target information

$serverList = Import-Csv -LiteralPath 'C:\1Presentations\2016_PracticalPoSh\04_ServerQueryInputData.csv' -Delimiter ';'


$serverList | Out-GridView -Wait


$serverList | Collect-SQLDataToTable -Verbose






#Check the data in the database!