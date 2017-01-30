
####################### 
<# 
.SYNOPSIS 
    Checks against the given connection details to see if the table exists

.DESCRIPTION 
    Checks against the given connection details to see if the table exists

    Returns $true if table exists else false. Writes out a warning with message about why table does not exist (if access denied, etc)

.INPUTS 
    Connection details and table name

.OUTPUTS 
    Returns $True if table exists. $False otherwise.

.EXAMPLE 

    $connString = 'Server=(local);Integrated Security=True;Connection Timeout=10;Database=master'

    Test-SQLTableExists `
                -ServerInstance '(local)' `
                -Database 'master' `
                -TableOwner "sys" `
                -TableName "tables"

.NOTES 

    Depends on "Invoke-Sqlcmd2" which is Chad Miller's version available at:
    https://gallery.technet.microsoft.com/scriptcenter/7985b7ef-ed89-4dfd-b02a-433cc4e30894

    Use to check table existence before creating new tables for example

Version History 
    v1.0  - Jana Sattainathan [Twitter: @SQLJana] [Blog: sqljana.wordpress.com] - Initial Release

.LINK 
    N/A
#> 

    function Test-SQLTableExists
    { 
        [CmdletBinding()] 
        param( 
            [Parameter(Mandatory=$true)] [string]$ServerInstance, 
            [Parameter(Mandatory=$false)] [string]$Database, 

            #------Other parameters--------------------
            [Parameter(Mandatory=$true)] [string]$TableOwner,
            [Parameter(Mandatory=$true)] [string]$TableName
        ) 

        [string] $tableOwnerDotName = if ($TableOwner.Trim().Length -eq 0){ $TableName } else { "[$TableOwner].[$TableName]"}
        [string] $sql = $null
        [bool] $return = $false

        #Validations
        if ($true)
        {
            #Add parameter validations if there are any...
        }

        try
        { 
    
            $stepName = "Try to select from table"
            #--------------------------------------------        
            Write-Verbose $stepName  

            try
            {

                $sql = "SELECT COUNT(1) FROM $tableOwnerDotName WHERE 0=1"
                $dataTable = Invoke-Sqlcmd2  -ServerInstance $ServerInstance -Database $Database -Query $sql -Verbose

                if ($dataTable)
                {
                    #Table exists if we got to this point
                    $return = $true
                }
                else
                {
                    $return = $false
                }

            }
            catch
            {            
                # Msg 208, Level 16, State 1, Line 1 Invalid object name 'gdasfas'.
                if ($_.Exception.ToString().Contains("Invalid object name"))
                {                
                    $return = $false  
                }
                else
                {
                    #Say it is "Insuffcient priviledges" or something else, someone has to know so that they can do the right grants
                    Write-Warning "Error when selecting from $tableOwnerDotName"
                    Write-Warning $_.Exception
                }
            }

            $stepName = "End"
            Write-Verbose $stepName
        }
        catch
        {
            #Difference between Write-Error and Throw is that, 
            #   Write-Error will write the error and continue to run unless $ErrorActionPreference is overridden. 
            #   Throw is hard-break if left unhandled.

            $ex = $_.Exception
            Write-Error ("Error in step: `n{0} `n{1}" -f `
                            $stepName, $ex.ToString())
            throw $ex
        }
        finally
        {
            #Return the return value
            $return
        }

    }
