
#
# Like EntityFramework, goal is to generate C# classes for each of the tables in the database 
# 






##-----------------------------------------------------------------------
##
#******************* Dot-Source Functions *****************************
##
##-----------------------------------------------------------------------

. C:\1Presentations\2016_PracticalPoSh\OpenSource\Invoke-SQLCmd2.ps1
. C:\1Presentations\2016_PracticalPoSh\OpenSource\Out-DataTable.ps1
. C:\1Presentations\2016_PracticalPoSh\OpenSource\Add-SQLTable.ps1
. C:\1Presentations\2016_PracticalPoSh\OpenSource\Write-DataTable.ps1
. C:\1Presentations\2016_PracticalPoSh\OpenSource\Test-SQLTableExists.ps1
#. C:\1Presentations\2016_PracticalPoSh\OpenSource\Collect-SQLDataToTable.ps1
#. C:\1Presentations\2016_PracticalPoSh\OpenSource\Collect-SQLListDataToTable.ps1
#. C:\1Presentations\2016_PracticalPoSh\OpenSource\Invoke-Async.ps1



# This is the class generator
# C:\1Presentations\2016_PracticalPoSh\02_Generate_CSharpClasses\Generate-Classes.ps1

<#
#Run the class generator - for msdb database!
#------------------------------------------------
C:\1Presentations\2016_PracticalPoSh\02_Generate_CSharpClasses\Generate-Classes.ps1 `
    -ServerInstance 'localhost' `
    -DatabaseName 'msdb' `
    -OutputFolder 'C:\1Presentations\2016_PracticalPoSh\02_Generate_CSharpClasses\Output\'





#Run the class generator - For ANOTHER database!
#------------------------------------------------
C:\1Presentations\2016_PracticalPoSh\02_Generate_CSharpClasses\Generate-Classes.ps1 `
    -ServerInstance 'localhost' `
    -DatabaseName 'DataStudio4' `
    -OutputFolder 'C:\1Presentations\2016_PracticalPoSh\02_Generate_CSharpClasses\Output\'
#>