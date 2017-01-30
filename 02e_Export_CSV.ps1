param(
        [string]$ServerInstance = 'localhost',
        [string]$DatabaseName = 'DataStudio4',        
        [string]$TableListSQL = 'SELECT name FROM sys.tables',
        [string]$OutputFolder = 'C:\1Presentations\2016_PracticalPoSh\02_Generate_CSharpClasses\Output'        
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
    $outputFile = "$OutputFolder\$tableName.csv"
    Write-Verbose "Generating for $tableName to file $outputFile"
    
    "Ouputing for $tableName to $outputFile"

    #----------------------------------------------------
    #Only selecting the top 100 rows....for illustration
    #----------------------------------------------------
    Invoke-Sqlcmd2 `
                    -ServerInstance $ServerInstance `
                    -Database $DatabaseName `
                    -Query "SELECT TOP 100 * FROM $tableName" `
                    -as DataRow `
                    -Verbose | 
            Select-Object * |
            Export-Csv `
                    -LiteralPath $outputFile `
                    -Force `
                    -NoTypeInformation
}
