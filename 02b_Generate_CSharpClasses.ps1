
##-----------------------------------------------------------------------
##
#******************* Second attempt *****************************
##
##-----------------------------------------------------------------------

#Cleanup the old files 
Get-Item $ClassGenOutputLocation\*.cs | Remove-Item


# We have moved up everything that can change into variables! 
#-------------------------------------------------------------
# Change the below to point to where you have the ModelGenerator.sql file
[string]$GeneratorLocation = 'C:\1Presentations\Practical_PowerShell\02_Generate_CSharpClasses\'
[string]$ServerInstance = 'localhost'
[string]$DatabaseName = 'DataStudio4'
[string]$GeneratorSQLFile = "$GeneratorLocation\ModelGenerator.sql"
[string]$TableListSQL = 'SELECT name FROM sys.tables'
[string]$OutputFolder = $ClassGenOutputLocation
[string]$Namespace = 'MyCompany.Business'
[string]$PlaceHolderSchema = '&Schema'
[string]$PlaceHolderTableName = '&TableName'
[string]$PlaceHolderNamespace = '&Namespace'


#Get the list of tables in the database to generate c# models for
$tables = Invoke-Sqlcmd2 `
            -ServerInstance $ServerInstance `
            -Database $DatabaseName `
            -Query $TableListSQL `
            -As DataRow `
            -Verbose


foreach ($table in $tables)
{
    $tableName = $table[0]
    $outputFile = "$OutputFolder\$tableName.cs"
    Write-Verbose "Generating for $tableName to file $outputFile"

    #Replace variables with values (returns an array that we convert to a string to use as query)
    $GeneratorSQLFileWSubstitutions = (Get-Content $GeneratorSQLFile).
                                            Replace($PlaceHolderSchema,'dbo').
                                            Replace($PlaceHolderTableName, $tableName).
                                            Replace($PlaceHolderNamespace, $Namespace) | Out-String

    "Ouputing for $tableName to $outputFile"

    #The command generates .cs file content for model using "PRINT" statements which then gets written to verbose output (stream 4)
    # ...capture the verbose output and redirect to a file
    (Invoke-Sqlcmd2 `
            -ServerInstance $ServerInstance `
            -Database $DatabaseName `
            -Query $GeneratorSQLFileWSubstitutions `
            -Verbose) 4> $outputFile

}
