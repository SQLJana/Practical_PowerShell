#My Default location = C:\1Presentations\Practical_PowerShell\02_Generate_CSharpClasses\Output
# Please input the location where you want the output to go
#   on your computer after you download the demos!

$ClassGenOutputLocation = Read-Host -Prompt 'What is the output folder to generate classes?'


if ((Test-Path -LiteralPath $ClassGenOutputLocation) -eq $false)
{
    throw 'Path does not exist! Enter a valid path'
}
else
{
    "About to generate output to $ClassGenOutputLocation"
}


##-----------------------------------------------------------------------
##
#******************* First attempt *****************************
##
##-----------------------------------------------------------------------

#
#SQL Returns the code to use for a class. One class per table.
#
[string]$sql = @"
            ------------------------------------------------------------------------------------------------------------
            --These three things have to be substituted (when called from Powershell, they are replaced before execution)
            ------------------------------------------------------------------------------------------------------------
            DECLARE @Schema VARCHAR(MAX) = N'&Schema'
            DECLARE @TableName VARCHAR(MAX) = N'&TableName'
            DECLARE @Namespace VARCHAR(MAX) = N'&Namespace'

            DECLARE @CRLF VARCHAR(2) = CHAR(13) + CHAR(10);
            DECLARE @result VARCHAR(max) = ' '

            DECLARE @PrivateProp VARCHAR(100) = @CRLF + 
                            CHAR(9) + CHAR(9) + 'private <ColumnType> _<ColumnName>;';
            DECLARE @PublicProp VARCHAR(255) = @CRLF + 
                            CHAR(9) + CHAR(9) + 'public <ColumnType> <ColumnName> '  + @CRLF +
                            CHAR(9) + CHAR(9) + '{ ' + @CRLF +
                            CHAR(9) + CHAR(9) + '   get { return _<ColumnName>; } ' + @CRLF +
                            CHAR(9) + CHAR(9) + '   set ' + @CRLF +
                            CHAR(9) + CHAR(9) + '   { ' + @CRLF +
                            CHAR(9) + CHAR(9) + '       _<ColumnName> = value;' + @CRLF +
                            CHAR(9) + CHAR(9) + '       base.RaisePropertyChanged();' + @CRLF +
                            CHAR(9) + CHAR(9) + '   } ' + @CRLF +
                            CHAR(9) + CHAR(9) + '}' + @CRLF;

            DECLARE @RPCProc VARCHAR(MAX) = @CRLF +         
                            CHAR(9) + CHAR(9) + 'public event PropertyChangedEventHandler PropertyChanged; ' + @CRLF +
                            CHAR(9) + CHAR(9) + 'private void RaisePropertyChanged( ' + @CRLF +
                            CHAR(9) + CHAR(9) + '       [CallerMemberName] string caller = "" ) ' + @CRLF +
                            CHAR(9) + CHAR(9) + '{  ' + @CRLF +
                            CHAR(9) + CHAR(9) + '   if (PropertyChanged != null)  ' + @CRLF +
                            CHAR(9) + CHAR(9) + '   { ' + @CRLF +
                            CHAR(9) + CHAR(9) + '       PropertyChanged( this, new PropertyChangedEventArgs( caller ) );  ' + @CRLF +
                            CHAR(9) + CHAR(9) + '   } ' + @CRLF +
                            CHAR(9) + CHAR(9) + '}';

            DECLARE @PropChanged VARCHAR(200) =  @CRLF +            
                            CHAR(9) + CHAR(9) + 'protected override void AfterPropertyChanged(string propertyName) ' + @CRLF +
                            CHAR(9) + CHAR(9) + '{ ' + @CRLF +
                            CHAR(9) + CHAR(9) + '   System.Diagnostics.Debug.WriteLine("' + @TableName + ' property changed: " + propertyName); ' + @CRLF +
                            CHAR(9) + CHAR(9) + '}';

            SET @result = 'using System;' + @CRLF + @CRLF +
                            'using MyCompany.Business;' + @CRLF + @CRLF +
                            'namespace ' + @Namespace  + @CRLF + '{' + @CRLF +
                            '   public class ' + @TableName + ' : ObservableObject' + @CRLF + 
                            '   {' + @CRLF +
                            '   #region Instance Properties' + @CRLF 

            SELECT @result = @result
                             + 
                            REPLACE(
                                        REPLACE(@PrivateProp
                                        , '<ColumnName>', ColumnName)
                                    , '<ColumnType>', ColumnType)
                            +                           
                            REPLACE(
                                        REPLACE(@PublicProp
                                        , '<ColumnName>', ColumnName)
                                    , '<ColumnType>', ColumnType)                   
            FROM
            (
                SELECT  c.COLUMN_NAME   AS ColumnName 
                    , CASE c.DATA_TYPE   
                        WHEN 'bigint' THEN
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'Int64?' ELSE 'Int64' END
                        WHEN 'binary' THEN 'Byte[]'
                        WHEN 'bit' THEN 
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'Boolean?' ELSE 'Boolean' END            
                        WHEN 'char' THEN 'String'
                        WHEN 'date' THEN
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'DateTime?' ELSE 'DateTime' END                        
                        WHEN 'datetime' THEN
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'DateTime?' ELSE 'DateTime' END                        
                        WHEN 'datetime2' THEN  
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'DateTime?' ELSE 'DateTime' END                        
                        WHEN 'datetimeoffset' THEN 
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'DateTimeOffset?' ELSE 'DateTimeOffset' END                                    
                        WHEN 'decimal' THEN  
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'Decimal?' ELSE 'Decimal' END                                    
                        WHEN 'float' THEN 
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'Single?' ELSE 'Single' END                                    
                        WHEN 'image' THEN 'Byte[]'
                        WHEN 'int' THEN  
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'Int32?' ELSE 'Int32' END
                        WHEN 'money' THEN
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'Decimal?' ELSE 'Decimal' END                                                
                        WHEN 'nchar' THEN 'String'
                        WHEN 'ntext' THEN 'String'
                        WHEN 'numeric' THEN
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'Decimal?' ELSE 'Decimal' END                                                            
                        WHEN 'nvarchar' THEN 'String'
                        WHEN 'real' THEN 
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'Double?' ELSE 'Double' END                                                                        
                        WHEN 'smalldatetime' THEN 
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'DateTime?' ELSE 'DateTime' END                                    
                        WHEN 'smallint' THEN 
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'Int16?' ELSE 'Int16'END            
                        WHEN 'smallmoney' THEN  
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'Decimal?' ELSE 'Decimal' END                                                                        
                        WHEN 'text' THEN 'String'
                        WHEN 'time' THEN 
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'TimeSpan?' ELSE 'TimeSpan' END                                                                                    
                        WHEN 'timestamp' THEN 
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'DateTime?' ELSE 'DateTime' END                                    
                        WHEN 'tinyint' THEN 
                            CASE C.IS_NULLABLE
                                WHEN 'YES' THEN 'Byte?' ELSE 'Byte' END                                                
                        WHEN 'uniqueidentifier' THEN 'Guid'
                        WHEN 'varbinary' THEN 'Byte[]'
                        WHEN 'varchar' THEN 'String'
                        ELSE 'Object'
                    END AS ColumnType
                    , c.ORDINAL_POSITION 
            FROM    INFORMATION_SCHEMA.COLUMNS c
            WHERE   c.TABLE_NAME = @TableName 
                AND ISNULL(@Schema, c.TABLE_SCHEMA) = c.TABLE_SCHEMA  
            ) t
            ORDER BY t.ORDINAL_POSITION

            SELECT @result = @result + @CRLF + 
                            CHAR(9) + '#endregion Instance Properties' + @CRLF +
                            --CHAR(9) + @RPCProc + @CRLF +
                            CHAR(9) + @PropChanged + @CRLF +
                            CHAR(9) + '}' + @CRLF +
                            @CRLF + '}' 
            --SELECT @result
            PRINT @result
"@



#Get the list of tables in the database to generate c# models for
$tables = Invoke-Sqlcmd2 `
            -ServerInstance 'localhost' `
            -Database 'DataStudio4' `
            -Query 'SELECT name FROM sys.tables' `
            -As DataRow `
            -Verbose


foreach ($table in $tables)
{
    $tableName = $table[0]
    $outputFile = "$ClassGenOutputLocation\$tableName.cs"
    Write-Verbose "Generating for $tableName to file $outputFile"

    #Replace variables with values (returns an array that we convert to a string to use as query)
    $GeneratorSQLFileWSubstitutions = ($sql.
                                            Replace('&Schema','dbo').
                                            Replace('&TableName', $tableName).
                                            Replace('&Namespace', 'MyCompany.Business') | Out-String)

    "Ouputing for $tableName to $outputFile"

    #The command generates .cs file content for model using "PRINT" statements which then gets written to verbose output (stream 4)
    # ...capture the verbose output and redirect to a file
    (Invoke-Sqlcmd2 `
            -ServerInstance 'localhost' `
            -Database 'DataStudio4' `
            -Query $GeneratorSQLFileWSubstitutions `
            -Verbose) 4> $outputFile

}