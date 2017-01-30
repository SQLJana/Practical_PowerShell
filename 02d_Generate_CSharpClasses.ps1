
##-----------------------------------------------------------------------
##
#******************* Fourth attempt *****************************
##
##-----------------------------------------------------------------------


#Cleanup the old files 
#Get-Item C:\1Presentations\2016_PracticalPoSh\02_Generate_CSharpClasses\Output\*.cs | Remove-Item


# Let us make a function by parameterizing key inputs
#-----------------------------------------------------------------------

####################### 
<# 
.SYNOPSIS 
    Generates C# classes based on table structures - one for each table

.DESCRIPTION 
    Pass in the appropriate inputs. DatabaseName can come from the pipleline

.EXAMPLE 
    
    Out-CSharpClass `
        -Database 'DataStudio4' `
        -Verbose

    Example takes the defaults except for the DatabaseName parameter

.EXAMPLE 
    
    Out-CSharpClass `
        -Database 'DataStudio4' `
        -GeneratorSQLFile 'C:\1Presentations\2016_PracticalPoSh\02_Generate_CSharpClasses\ModelGenerator.sql' `
        -TableListSQL 'SELECT name FROM sys.tables' `
        -OutputFolder 'C:\1Presentations\2016_PracticalPoSh\02_Generate_CSharpClasses\Output' `
        -Namespace 'MyCompany.Business' `
        -PlaceHolderSchema '&Schema' `
        -PlaceHolderTableName '&TableName' `
        -PlaceHolderNamespace '&Namespace' `
        -Verbose

    This simple example generates classes for database DataStudio4 and specifies each parameter


.NOTES 

    This function is for illustration purposes only!

Version History 
    v1.0  - Jana Sattainathan [Twitter: @SQLJana] [Blog: sqljana.wordpress.com] - Initial Release
#> 
function Out-CSharpClass
{                 
 
    [CmdletBinding()] 
    param(
            [Parameter(Mandatory=$false)][string]$ServerInstance = 'localhost',

            [Parameter(Mandatory=$true)][string]$DatabaseName,

            [ValidateScript({Test-Path $_ -PathType ‘Leaf’})]
            [Parameter(Mandatory=$false)][string]$GeneratorSQLFile = 'C:\1Presentations\2016_PracticalPoSh\02_Generate_CSharpClasses\ModelGenerator.sql',

            [Parameter(Mandatory=$false)][string]$TableListSQL = 'SELECT name FROM sys.tables',

            [ValidateScript({Test-Path $_ -PathType ‘Container’})]
            [Parameter(Mandatory=$false)][string]$OutputFolder = 'C:\1Presentations\2016_PracticalPoSh\02_Generate_CSharpClasses\Output',

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
        #Decide on the file name for table
        $tableName = $table[0]
        $outputFile = "$OutputFolder\$tableName.cs"
        Write-Verbose "Generating for $tableName to file $outputFile"

        #Warn if the file already exists!
        if (Test-Path -LiteralPath $outputFile)
        {
            Write-warning "$outputFile already exists. Overwriting!"
        }

        #Replace variables with values (returns an array that we convert to a string to use as query)
        $GeneratorSQLFileWSubstitutions = (Get-Content $GeneratorSQLFile).
                                                Replace($PlaceHolderSchema,'dbo').
                                                Replace($PlaceHolderTableName, $tableName).
                                                Replace($PlaceHolderNamespace, $Namespace) | Out-String

        Write-verbose 'Ouputing for $tableName to $outputFile'

        #The command generates .cs file content for model using "PRINT" statements which then gets written to verbose output (stream 4)
        # ...capture the verbose output and redirect to a file
        (Invoke-Sqlcmd2 `
                -ServerInstance $ServerInstance `
                -Database $DatabaseName `
                -Query $GeneratorSQLFileWSubstitutions `
                -Verbose) 4> $outputFile

    }
}