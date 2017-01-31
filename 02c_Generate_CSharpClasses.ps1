
##-----------------------------------------------------------------------
##
#******************* Third attempt *****************************
##
##-----------------------------------------------------------------------


#Cleanup the old files 
#Get-Item $GeneratorLocation\Output\*.cs | Remove-Item


# We have changed everything that can change into a script parameter!
#   Change the file locations to match where you downloaded the samples to
#-------------------------------------------------------------
param(
        [Parameter(Mandatory=$false)][string]$ServerInstance = 'localhost',
        [Parameter(Mandatory=$true)][string]$DatabaseName,
        [Parameter(Mandatory=$false)][string]$GeneratorSQLFile = 'C:\1Presentations\Practical_PowerShell\02_Generate_CSharpClasses\ModelGenerator.sql',
        [Parameter(Mandatory=$false)][string]$TableListSQL = 'SELECT name FROM sys.tables',        
        [Parameter(Mandatory=$false)][string]$OutputFolder = 'C:\1Presentations\Practical_PowerShell\02_Generate_CSharpClasses\Output',
        [Parameter(Mandatory=$false)][string]$Namespace = 'MyCompany.Business',
        [Parameter(Mandatory=$false)][string]$PlaceHolderSchema = '&Schema',
        [Parameter(Mandatory=$false)][string]$PlaceHolderTableName = '&TableName',
        [Parameter(Mandatory=$false)][string]$PlaceHolderNamespace = '&Namespace'
)


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



#
#Show the output generated and delete the files
#
#Get-Item $GeneratorLocation\Output\*.cs | Remove-Item