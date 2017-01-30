

#---------------------
# Parameters and ValidateSets!
#---------------------
#Good reference: https://beatcracker.wordpress.com/2015/08/10/dynamic-parameters-validateset-and-enums/


#___________________________________________________________________________________________
#
#  Safety net to protect against accidentally running the whole script with F5 
#___________________________________________________________________________________________

write-host -foregroundcolor yellow 'You hit F5. This will run this whole script.'
$response = Read-Host -Prompt 'Did you really mean to run the entire script (y/n)?' 
throw [System.ArgumentException] 'You CANNOT run using F5. Period. Please highlight and run selection with F8.'











#Simple function - Ordering a drink
#---------------


FUNCTION Get-Drink($DrinkName)
{
    Write-Verbose ('Ordered {0} for a drink!' -f $DrinkName)
}


## Usage 

$VerbosePreference = 'Continue'
Get-Drink 'Iced-Tea'





Get-Drink 'Brick!'
#Works!

















#Validting drink - Using ValidateSet
#---------------
#Changes:
# 1. Used "param" block
# 2. Added [string] to parmeter data type
# 3. Added "ValidateSet" to make sure only valid values are passed for $Drink!

FUNCTION Get-Drink
{
     param
     (
         [ValidateSet('Leamonde','Iced-Tea','Coffee','Water','Soda')]
         [string] $DrinkName
     )

    Write-Verbose ('Ordered {0}' -f $DrinkName)

}


## Usage - Try to get the value list by typing the Get-Drink interactively

$VerbosePreference = 'Continue'
Get-Drink -DrinkName  




















#Validting drink - using ValidateScript
#---------------
#Changes:
# 1. Using ValidateSet limits us to a static set
#     ...let us use ValidateScript to validate against a set of drink values 
#          coming dynamically from a file (that can be updated outside at anytime)!
#
FUNCTION Get-Drink
{
     param
     (
         [ValidateScript({
            (Get-Content c:\~tmp\drinks.txt) -Contains $_
            })]
         [string] $DrinkName
     )

    Write-Verbose ('Ordered {0}' -f $DrinkName)

}



#Let us see the contents of c:\~tmp\drinks.txt

Get-Content c:\~tmp\drinks.txt

#Coke and Pepsi are now available! So is **** BEER *****.



## Usage - Try to get the value list by typing the Get-Drink interactively

$VerbosePreference = 'Continue'
Get-Drink - 


#Notice we lost the ability for PowerShell to display a list to us!


#However, it does validate our parameter value and errors out if a wrong value is passed in!

Get-Drink -DrinkName Goffee
















#Validting drink - using ValidateScript
#---------------
#Changes:
# 1. Added Age parameter to record the drink and age 
# 2. Added ValidateRange for the Age parameter
#     (age has to be between 4 and 100)
FUNCTION Get-Drink
{
     param
     (
         [ValidateScript({
            (Get-Content c:\~tmp\drinks.txt) -Contains $_
            })]
         [string] $DrinkName,

         [ValidateRange(4,100)]
         [string] $Age
     )

    Write-Verbose ('I am {0} years old and I ordered {1}' -f $Age, $DrinkName)

}






Get-Drink -DrinkName 'Coke' -Age 4

#Toddlers cannot drink anything that is available in this establishment



Get-Drink -DrinkName 'Beer' -Age 5


#Oh no....a 5 year old just ordered Beer for him/herself!













help about_Functions_Advanced_Parameters -ShowWindow

<#
https://technet.microsoft.com/en-us/library/dd347600.aspx

There are other validation types like 
    AllowNull
    AllowEmptyString
    AllowEmptyCollection
    ValidateCount
    ValidateLength
    ValidatePattern, 
    ValidateRange, 
    ValidateNotNull, 
    ValidateNotNullOrEmpty 
    etc..

#>



<#

What we need?

1) Something that does not require us to change code 
   (like ValidateScript with valid values coming from text file/xml or database)

2) Have PowerShell dropdown a list of valid values after "-Parameter" is entered

3) Have PowerShell base its values for parameters based on other parameter values specified
    For example if age is less than 21, cant order beer!


#>












#Dynamic parameters
#---------------
#Changes:
# 1. Added Age as a regular parameter
# 2. Added DrinkName as a dynamic parameter...
# 3. Areas of interest have " ##<<<<<<<<<<<<<<<<<<<<<<<<--------------------"



#Based on: https://beatcracker.wordpress.com/2015/08/10/dynamic-parameters-validateset-and-enums/
function Get-Drink
{
    [CmdletBinding()]
    Param(
        [ValidateRange(4,100)]
         [string] $Age
     
        )
    DynamicParam
    {
        # Set the dynamic parameters name
        $ParameterName = 'DrinkName'    ##<<<<<<<<<<<<<<<<<<<<<<<<-------------------------------
 
        # Create the dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
 
        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
 
        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.ValueFromPipeline = $true
        $ParameterAttribute.ValueFromPipelineByPropertyName = $true
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 0
 
        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)
 
        # Generate and set the ValidateSet
        $arrSet = Get-Content C:\~Tmp\drinks.txt      ##<<<<<<<<<<<<<<<<<<<<<<<<-------------------------------
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
 
        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)
 
        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }
 
    Begin
    {
        # Bind the parameter to a friendly variable
        $Drink = $PsBoundParameters[$ParameterName]
    }
 
    Process
    {
        Write-Verbose ('I am {0} years old and I ordered {1}' -f $Age, $DrinkName)  #<<<<<<<<<<<<<<<<<<<<--------------------------
    }
}



#Notice how we get prompted with the correct set of values for "DrinkName" parameter
get-drink -Age 5 -DrinkName Beer

#However we get this error!
[53,72] The variable '$DrinkName' cannot be retrieved because it has not been set.











#Dynamic parameters - Referencing dynamic parameters in "Process" code
#---------------
#Changes:
# 1. Changed direct reference to parameter "DrinkName" to the variable reference "Drink" from "Begin block"
# 2. Notice how the dynamic parameter "DrinkName" is referenced in "Begin" block
#        $PsBoundParameters[$ParameterName]


function Get-Drink
{
    [CmdletBinding()]
    Param(
        [ValidateRange(4,100)]
         [string] $Age
     
        )
    DynamicParam
    {
        # Set the dynamic parameters name
        $ParameterName = 'DrinkName'    ##<<<<<<<<<<<<<<<<<<<<<<<<------------------------------- 
                                        #Variable gets used later!
 
        # Create the dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
 
        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
 
        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.ValueFromPipeline = $true
        $ParameterAttribute.ValueFromPipelineByPropertyName = $true
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 0
 
        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)
 
        # Generate and set the ValidateSet
        $arrSet = Get-Content C:\~Tmp\drinks.txt      ##<<<<<<<<<<<<<<<<<<<<<<<<-------------------------------
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
 
        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)
 
        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }
 
    Begin
    {
        # Bind the parameter to a friendly variable
        $Drink = $PsBoundParameters[$ParameterName]
    }
 
    Process
    {
        Write-Verbose ('I am {0} years old and I ordered {1}' -f $Age, $Drink)   #<<<<<<<<<<<<<<<<<<<<--------------------------
    }
}




#Now we get a list dropdrown...and code works!
get-drink -Age 5 -DrinkName Beer


#....except a 5 year old can still order beer!
#
#....and we made our little function 10 times more complex!
# The whole DynamicParam block is a mess!



















# New-DynamicParam - encapsulates all the functionality

#Source:  https://github.com/RamblingCookieMonster/PowerShell/blob/master/New-DynamicParam.ps1

Function New-DynamicParam {
<#
    .SYNOPSIS
        Helper function to simplify creating dynamic parameters
    
    .DESCRIPTION
        Helper function to simplify creating dynamic parameters
        Example use cases:
            Include parameters only if your environment dictates it
            Include parameters depending on the value of a user-specified parameter
            Provide tab completion and intellisense for parameters, depending on the environment
        Please keep in mind that all dynamic parameters you create will not have corresponding variables created.
           One of the examples illustrates a generic method for populating appropriate variables from dynamic parameters
           Alternatively, manually reference $PSBoundParameters for the dynamic parameter value
    .NOTES
        Credit to http://jrich523.wordpress.com/2013/05/30/powershell-simple-way-to-add-dynamic-parameters-to-advanced-function/
            Added logic to make option set optional
            Added logic to add RuntimeDefinedParameter to existing DPDictionary
            Added a little comment based help
        Credit to BM for alias and type parameters and their handling
    .PARAMETER Name
        Name of the dynamic parameter
    .PARAMETER Type
        Type for the dynamic parameter.  Default is string
    .PARAMETER Alias
        If specified, one or more aliases to assign to the dynamic parameter
    .PARAMETER ValidateSet
        If specified, set the ValidateSet attribute of this dynamic parameter
    .PARAMETER Mandatory
        If specified, set the Mandatory attribute for this dynamic parameter
    .PARAMETER ParameterSetName
        If specified, set the ParameterSet attribute for this dynamic parameter
    .PARAMETER Position
        If specified, set the Position attribute for this dynamic parameter
    .PARAMETER ValueFromPipelineByPropertyName
        If specified, set the ValueFromPipelineByPropertyName attribute for this dynamic parameter
    .PARAMETER HelpMessage
        If specified, set the HelpMessage for this dynamic parameter
    
    .PARAMETER DPDictionary
        If specified, add resulting RuntimeDefinedParameter to an existing RuntimeDefinedParameterDictionary (appropriate for multiple dynamic parameters)
        If not specified, create and return a RuntimeDefinedParameterDictionary (appropriate for a single dynamic parameter)
        See final example for illustration
    .EXAMPLE
        
        function Show-Free
        {
            [CmdletBinding()]
            Param()
            DynamicParam {
                $options = @( gwmi win32_volume | %{$_.driveletter} | sort )
                New-DynamicParam -Name Drive -ValidateSet $options -Position 0 -Mandatory
            }
            begin{
                #have to manually populate
                $drive = $PSBoundParameters.drive
            }
            process{
                $vol = gwmi win32_volume -Filter "driveletter='$drive'"
                "{0:N2}% free on {1}" -f ($vol.Capacity / $vol.FreeSpace),$drive
            }
        } #Show-Free
        Show-Free -Drive <tab>
    # This example illustrates the use of New-DynamicParam to create a single dynamic parameter
    # The Drive parameter ValidateSet populates with all available volumes on the computer for handy tab completion / intellisense
    .EXAMPLE
    # I found many cases where I needed to add more than one dynamic parameter
    # The DPDictionary parameter lets you specify an existing dictionary
    # The block of code in the Begin block loops through bound parameters and defines variables if they don't exist
        Function Test-DynPar{
            [cmdletbinding()]
            param(
                [string[]]$x = $Null
            )
            DynamicParam
            {
                #Create the RuntimeDefinedParameterDictionary
                $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
                New-DynamicParam -Name AlwaysParam -ValidateSet @( gwmi win32_volume | %{$_.driveletter} | sort ) -DPDictionary $Dictionary
                #Add dynamic parameters to $dictionary
                if($x -eq 1)
                {
                    New-DynamicParam -Name X1Param1 -ValidateSet 1,2 -mandatory -DPDictionary $Dictionary
                    New-DynamicParam -Name X1Param2 -DPDictionary $Dictionary
                    New-DynamicParam -Name X3Param3 -DPDictionary $Dictionary -Type DateTime
                }
                else
                {
                    New-DynamicParam -Name OtherParam1 -Mandatory -DPDictionary $Dictionary
                    New-DynamicParam -Name OtherParam2 -DPDictionary $Dictionary
                    New-DynamicParam -Name OtherParam3 -DPDictionary $Dictionary -Type DateTime
                }
        
                #return RuntimeDefinedParameterDictionary
                $Dictionary
            }
            Begin
            {
                #This standard block of code loops through bound parameters...
                #If no corresponding variable exists, one is created
                    #Get common parameters, pick out bound parameters not in that set
                    Function _temp { [cmdletbinding()] param() }
                    $BoundKeys = $PSBoundParameters.keys | Where-Object { (get-command _temp | select -ExpandProperty parameters).Keys -notcontains $_}
                    foreach($param in $BoundKeys)
                    {
                        if (-not ( Get-Variable -name $param -scope 0 -ErrorAction SilentlyContinue ) )
                        {
                            New-Variable -Name $Param -Value $PSBoundParameters.$param
                            Write-Verbose "Adding variable for dynamic parameter '$param' with value '$($PSBoundParameters.$param)'"
                        }
                    }
                #Appropriate variables should now be defined and accessible
                    Get-Variable -scope 0
            }
        }
    # This example illustrates the creation of many dynamic parameters using New-DynamicParam
        # You must create a RuntimeDefinedParameterDictionary object ($dictionary here)
        # To each New-DynamicParam call, add the -DPDictionary parameter pointing to this RuntimeDefinedParameterDictionary
        # At the end of the DynamicParam block, return the RuntimeDefinedParameterDictionary
        # Initialize all bound parameters using the provided block or similar code
    .FUNCTIONALITY
        PowerShell Language
#>
param(
    
    [string]
    $Name,
    
    [System.Type]
    $Type = [string],

    [string[]]
    $Alias = @(),

    [string[]]
    $ValidateSet,
    
    [switch]
    $Mandatory,
    
    [string]
    $ParameterSetName="__AllParameterSets",
    
    [int]
    $Position,
    
    [switch]
    $ValueFromPipelineByPropertyName,
    
    [string]
    $HelpMessage,

    [validatescript({
        if(-not ( $_ -is [System.Management.Automation.RuntimeDefinedParameterDictionary] -or -not $_) )
        {
            Throw "DPDictionary must be a System.Management.Automation.RuntimeDefinedParameterDictionary object, or not exist"
        }
        $True
    })]
    $DPDictionary = $false
 
)
    #Create attribute object, add attributes, add to collection   
        $ParamAttr = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttr.ParameterSetName = $ParameterSetName
        if($mandatory)
        {
            $ParamAttr.Mandatory = $True
        }
        if($Position -ne $null)
        {
            $ParamAttr.Position=$Position
        }
        if($ValueFromPipelineByPropertyName)
        {
            $ParamAttr.ValueFromPipelineByPropertyName = $True
        }
        if($HelpMessage)
        {
            $ParamAttr.HelpMessage = $HelpMessage
        }
 
        $AttributeCollection = New-Object 'Collections.ObjectModel.Collection[System.Attribute]'
        $AttributeCollection.Add($ParamAttr)
    
    #param validation set if specified
        if($ValidateSet)
        {
            $ParamOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList $ValidateSet
            $AttributeCollection.Add($ParamOptions)
        }

    #Aliases if specified
        if($Alias.count -gt 0) {
            $ParamAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList $Alias
            $AttributeCollection.Add($ParamAlias)
        }

 
    #Create the dynamic parameter
        $Parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList @($Name, $Type, $AttributeCollection)
    
    #Add the dynamic parameter to an existing dynamic parameter dictionary, or create the dictionary and add it
        if($DPDictionary)
        {
            $DPDictionary.Add($Name, $Parameter)
        }
        else
        {
            $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $Dictionary.Add($Name, $Parameter)
            $Dictionary
        }
}










#Validting drink - using ValidateScript
#---------------
#Changes:
# 1. Changed to use the New-DynamicParam function

Function Get-Drink
{
    [CmdletBinding()]
    Param(
        [ValidateRange(4,100)]
         [string] $Age     
        )
    DynamicParam {
        $options = Get-Content C:\~Tmp\drinks.txt
        New-DynamicParam -Name DrinkName -ValidateSet $options -Position 1 -Mandatory
    }
    begin{
        #have to manually populate
        $drink = $PSBoundParameters.DrinkName
    }
    process{
        Write-Verbose ('I am {0} years old and I ordered {1}' -f $Age, $drink)
    }
}



 get-drink -Age 5 -DrinkName Beer


#Simper and we get the drop down...but Age + Drink validation is not there yet!

















#http://blog.enowsoftware.com/solutions-engine/bid/185867/Powershell-Upping-your-Parameter-Validation-Game-with-Dynamic-Parameters-Part-II


#Reference: http://www.powershellmagazine.com/2014/05/29/dynamic-parameters-in-powershell/

Function Get-Drink
{
    [CmdletBinding()]
    Param(
        [ValidateRange(4,100)]
         [int] $Age     
        )

    DynamicParam {
                       
        #Add dynamic parameters to $dictionary
        if($Age -lt 21)
        {
            $options = (Get-Content C:\~Tmp\drinks.txt)  | Where-Object {$_ -ne 'Beer'}
            #write-verbose $options.Join(',')
        }
        else
        {
            $options = (Get-Content C:\~Tmp\drinks.txt) 
        }

        New-DynamicParam -Name DrinkName -ValidateSet $options -Position 1 -Mandatory -HelpMessage 'Type in the drink name:'

    }
    begin{
        #have to manually populate
        $drink = $PSBoundParameters.DrinkName
    }
    process{
        Write-Verbose "I am $Age years old and I ordered $drink"
    }
}






#Finally 5 year olds are not offered the option of beer!

get-drink -Age 5 -DrinkName 