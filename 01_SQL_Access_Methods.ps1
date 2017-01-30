
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





#Everything comes in modules - packaged functionality




##-----------------------------------------------------------------------
##
##******************* Method 1: SQLPS Module *****************************
##
##-----------------------------------------------------------------------



# Module Path
#----------------------------------------
$env:PSModulePath



# A more readable output

$env:PSModulePath -csplit ';'


#Add your own path to the module path as shown below:
#$env:PSModulePath + ";C:\Program Files\WindowsPowerShell\Modules\SQLPSX7"

#To remove a path, restate the whole path but without the path you dont need


# What modules are available to be loaded (in module paths)
#----------------------------------------
Get-Module -ListAvailable





# What modules are already loaded in memory
#----------------------------------------
Get-Module





#If SQLPS module is already loaded, we can unload module and load again
#----------------------------------------
#Remove-Module 'SQLPS'





# Import SQLPS module if that is not loaded
#----------------------------------------
Import-Module 'SQLPS'

#The warnings related to approved "verb" list that 
#   the SQL team kinda ignored 
#   to accomodate unapproved verbs - Backup and Restore






# What commands are available in SQLPS
#----------------------------------------
Get-Command -Module SQLPS







#Invoke-Sqlcmd is the most import cmdlet of the ones offered in SQLPS..
#  It is equivalnet to sqlcmd.exe

Get-Help Invoke-Sqlcmd -Examples




# Let us see what the help has to say
#----------------------------------------

Get-Help *sql*


Get-Help Invoke-Sqlcmd -ShowWindow




# See examples of how to use a certain command
#----------------------------------------
Get-Help Invoke-Sqlcmd -Examples






# Let us try to run the first example! We will replace the instance name though.
#----------------------------------------
Invoke-Sqlcmd `
            -Query "SELECT GETDATE() AS TimeOfQuery;" `
            -ServerInstance "(local)"






# Let us try to run the first example! We will replace the instance name though. 
#    ....and assign the output to a variable
#----------------------------------------
$rslt = Invoke-Sqlcmd `
            -Query "sp_who" `
            -ServerInstance "(local)"


# Format the output as a table
#----------------------------------------
$rslt | FT




# Let us try to get a feel for the hierarchy
#----------------------------------------
Get-ChildItem SQLSERVER:\

Get-ChildItem SQLSERVER:\SQL

Get-ChildItem SQLSERVER:\SQL\$(hostname)

Get-ChildItem SQLSERVER:\SQL\$(hostname)\DEFAULT\






# Explore around the Current instance level values
#----------------------------------------
Get-ChildItem SQLSERVER:\SQL\$(hostname)\DEFAULT\Databases

Get-ChildItem SQLSERVER:\SQL\$(hostname)\DEFAULT\Logins

Get-ChildItem SQLSERVER:\SQL\$(hostname)\DEFAULT\Roles





# Pick a database and explore its characteristics
#----------------------------------------
Get-ChildItem SQLSERVER:\SQL\$(hostname)\DEFAULT\Databases\DataStudio4

Get-ChildItem SQLSERVER:\SQL\$(hostname)\DEFAULT\Databases\DataStudio4\Tables


#Pipelining example
# Get the row counts of all tables in a database and order by RowCount Desc
#----------------------------------------
Get-ChildItem SQLSERVER:\SQL\$(hostname)\DEFAULT\Databases\DataStudio4\Tables | 
    Select-Object Name, RowCount |
    Sort-Object -Descending -Property RowCount |
    Format-Table -AutoSize






# Get the script of all tables in a database
#----------------------------------------
Get-ChildItem SQLSERVER:\SQL\$(hostname)\DEFAULT\Databases\DataStudio4\Tables | 
    ForEach-Object {$_.Script()}







# Get the list of all tables in every database 
#----------------------------------------
$databases = Get-ChildItem SQLSERVER:\SQL\$(hostname)\DEFAULT\Databases

"`n Databases on instance: ***** $(hostname) ***** `n "
$databases | ft


#Notice that above when using the pipeline we referenced using "$_" 
#  but when using foreach loop, we reference using the loop variable as in  "$db."
#----------------------------------------
foreach ($db in $databases)
{
    "`n Tables in Database: ***** $($db.Name) ***** `n "

    Get-ChildItem SQLSERVER:\SQL\$(hostname)\DEFAULT\Databases\$($db.name)\Tables |
                Select-Object DisplayName, RowCount | 
                Format-Table -AutoSize
}



#Backup and restore
#----------------------------------------
get-help Backup-SqlDatabase -Examples


# Backup a database to C:\Temp
Backup-SqlDatabase -ServerInstance LocalHost -Database DataStudio4 -BackupFile C:\temp\DataStudio4.bak  -CopyOnly

<#
# Restore the just backed-up database and relocate the files
$RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("DataStudio4", "c:\Temp\DataStudio_Restore_Demo.mdf")
$RelocateLog = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("DataStudio4_Log", "c:\Temp\DataStudio_Restore_Demo.ldf")
Restore-SqlDatabase -ServerInstance LocalHost -Database DataStudio_Restore_Demo -BackupFile C:\temp\DataStudio4.bak -ReplaceDatabase -RelocateFile @($RelocateData,$RelocateLog)
#>


#Is our backup there?
Get-Item C:\temp\DataStudio4.bak

#Drop the temporary backup
Remove-Item C:\temp\DataStudio4.bak

    




##-----------------------------------------------------------------------
##
##******************* METHOD 2 - SQLPSX - PowerShell Extensions  *********
##
##-----------------------------------------------------------------------


# Open-source project 
#    From the website: SQLPSX consists of 13 modules with 
#      163 advanced functions, 2 cmdlets and 7 scripts for working with 
#      ADO.NET, SMO, Agent, RMO, SSIS, SQL script files, PBM, Oracle and MySQL 
#      and using Powershell ISE as a SQL and Oracle query tool.
#
#    https://sqlpsx.codeplex.com/
#



$env:PSModulePath + ";C:\Program Files\WindowsPowerShell\Modules\SQLPSX7"


# Let us add the pat to the $Profile so that it gets added automtically!

notepad $Profile

#SQLMaint is somewhat the equivalent of SQL Maintenance Wizard
Get-Command -module sqlmaint

Get-Command -module sqlserver


#Functions from SQLMaint
Get-SqlDatabase -sqlserver localhost

Get-SqlLogin -sqlserver localhost


##-----------------------------------------------------------------------
##
##******************* Method 3: Custom functions using ADO.net *********
##
##-----------------------------------------------------------------------


    #https://gallery.technet.microsoft.com/scriptcenter/7985b7ef-ed89-4dfd-b02a-433cc4e30894
    #
    # Invoke-SQLCmd2
    #

    ####################### 
    <# 
    .SYNOPSIS 
    Runs a T-SQL script. 
    .DESCRIPTION 
    Runs a T-SQL script. Invoke-Sqlcmd2 only returns message output, such as the output of PRINT statements when -verbose parameter is specified 
    .INPUTS 
    None 
        You cannot pipe objects to Invoke-Sqlcmd2 
    .OUTPUTS 
       System.Data.DataTable 
    .EXAMPLE 
    Invoke-Sqlcmd2 -ServerInstance "MyComputer\MyInstance" -Query "SELECT login_time AS 'StartTime' FROM sysprocesses WHERE spid = 1" 
    This example connects to a named instance of the Database Engine on a computer and runs a basic T-SQL query. 
    StartTime 
    ----------- 
    2010-08-12 21:21:03.593 
    .EXAMPLE 
    Invoke-Sqlcmd2 -ServerInstance "MyComputer\MyInstance" -InputFile "C:\MyFolder\tsqlscript.sql" | Out-File -filePath "C:\MyFolder\tsqlscript.rpt" 
    This example reads a file containing T-SQL statements, runs the file, and writes the output to another file. 
    .EXAMPLE 
    Invoke-Sqlcmd2  -ServerInstance "MyComputer\MyInstance" -Query "PRINT 'hello world'" -Verbose 
    This example uses the PowerShell -Verbose parameter to return the message output of the PRINT command. 
    VERBOSE: hello world 
    .NOTES 
    Version History 
    v1.0   - Chad Miller - Initial release 
    v1.1   - Chad Miller - Fixed Issue with connection closing 
    v1.2   - Chad Miller - Added inputfile, SQL auth support, connectiontimeout and output message handling. Updated help documentation 
    v1.3   - Chad Miller - Added As parameter to control DataSet, DataTable or array of DataRow Output type 
    #> 
    function Invoke-Sqlcmd2 
    { 
        [CmdletBinding()] 
        param( 
        [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
        [Parameter(Position=1, Mandatory=$false)] [string]$Database, 
        [Parameter(Position=2, Mandatory=$false)] [string]$Query, 
        [Parameter(Position=3, Mandatory=$false)] [string]$Username, 
        [Parameter(Position=4, Mandatory=$false)] [string]$Password, 
        [Parameter(Position=5, Mandatory=$false)] [Int32]$QueryTimeout=600, 
        [Parameter(Position=6, Mandatory=$false)] [Int32]$ConnectionTimeout=15, 
        [Parameter(Position=7, Mandatory=$false)] [ValidateScript({test-path $_})] [string]$InputFile, 
        [Parameter(Position=8, Mandatory=$false)] [ValidateSet("DataSet", "DataTable", "DataRow")] [string]$As="DataRow" 
        ) 
 
        if ($InputFile) 
        { 
            $filePath = $(resolve-path $InputFile).path 
            $Query =  [System.IO.File]::ReadAllText("$filePath") 
        } 
 
        $conn=new-object System.Data.SqlClient.SQLConnection 
      
        if ($Username) 
        { $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout } 
        else 
        { $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerInstance,$Database,$ConnectionTimeout } 
 
        $conn.ConnectionString=$ConnectionString 
     
        #Following EventHandler is used for PRINT and RAISERROR T-SQL statements. Executed when -Verbose parameter specified by caller 
        if ($PSBoundParameters.Verbose) 
        { 
            $conn.FireInfoMessageEventOnUserErrors=$true 
            $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {Write-Verbose "$($_)"} 
            $conn.add_InfoMessage($handler) 
        } 
     
        $conn.Open() 
        $cmd=new-object system.Data.SqlClient.SqlCommand($Query,$conn) 
        $cmd.CommandTimeout=$QueryTimeout 
        $ds=New-Object system.Data.DataSet 
        $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd) 
        [void]$da.fill($ds) 
        $conn.Close() 
        switch ($As) 
        { 
            'DataSet'   { Write-Output ($ds) } 
            'DataTable' { Write-Output ($ds.Tables) } 
            'DataRow'   { Write-Output ($ds.Tables[0]) } 
        } 
 
    } #Invoke-Sqlcmd2











# Let us try to run the first example! 
#----------------------------------------
#  Notice that we are also "print"ing a line...which gets captured in Verbose output

$rslt = Invoke-Sqlcmd2 `
            -ServerInstance "(local)" `
            -Query "print 'About to run sp_who'; exec sp_who; " `
            -Verbose


# Format the output as a table

$rslt | Format-Table



##-----------------------------------------------------------------------
##
##******************* Method 4: DBATools from www.dbatools.io *********
##
##-----------------------------------------------------------------------


#Install-Module dbatools



Get-Command -Module dbatools


Get-DbaDiskSpace -ComputerName (hostname) -Unit GB |ft


Get-SqlMaxMemory -SqlServer localhost


#Get-Help '*whoisactive*'


Show-SqlWhoIsActive -SqlServer localhost -ShowOwnSpid



# Let us unload SQLPS. It is a memory hog.
#----------------------------------------


#Move to a different PSDrive so that SQLPS is no longer in use
Set-Location c:\
Remove-Module 'SQLPS'