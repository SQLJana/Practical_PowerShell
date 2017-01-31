
#
# Like EntityFramework, goal is to generate C# classes for each of the tables in the database 
# 






##-----------------------------------------------------------------------
##
#******************* Dot-Source Functions *****************************
##
##-----------------------------------------------------------------------

#My Default location = C:\1Presentations\Practical_PowerShell\OpenSource
# Please input the location where you have the open-source files 
#   on your computer after you download the demos!

$OpenSourcePS1FilesLocation = Read-Host -Prompt 'Input the location of the open-source ps1 files for demo'

if ((Test-Path -LiteralPath $OpenSourcePS1FilesLocation) -eq $false)
{
    throw 'Path does not exist! Enter a valid path'
}
else
{
    "About to dot-source from $OpenSourcePS1FilesLocation"
}

. $OpenSourcePS1FilesLocation\Invoke-SQLCmd2.ps1
. $OpenSourcePS1FilesLocation\Out-DataTable.ps1
. $OpenSourcePS1FilesLocation\Add-SQLTable.ps1
. $OpenSourcePS1FilesLocation\Write-DataTable.ps1
. $OpenSourcePS1FilesLocation\Test-SQLTableExists.ps1
#. $OpenSourcePS1FilesLocation\Collect-SQLDataToTable.ps1
#. $OpenSourcePS1FilesLocation\Collect-SQLListDataToTable.ps1
#. $OpenSourcePS1FilesLocation\Invoke-Async.ps1

