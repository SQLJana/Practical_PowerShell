

#---------------------
# Pipelined functions
#---------------------
#Good reference: https://www.simple-talk.com/dotnet/.net-tools/down-the-rabbit-hole--a-study-in-powershell-pipelines,-functions,-and-parameters/


#___________________________________________________________________________________________
#
#  Safety net to protect against accidentally running the whole script with F5 
#___________________________________________________________________________________________

write-host -foregroundcolor yellow 'You hit F5. This will run this whole script.'
$response = Read-Host -Prompt 'Did you really mean to run the entire script (y/n)?' 
throw [System.ArgumentException] "You CANNOT run using F5. Period. Please highlight and run selection with F8."



#Simple function - Stating the obvious
#---------------


FUNCTION Get-Sum($a, $b)
{
    $a + $b
}


## Usage variations

Get-Sum 9 10


Get-Sum -a 9 -b 10









#Simple function - With parameter default values
#---------------


FUNCTION Get-Sum($a = 0, $b = 0)
{
    $a + $b
}


## Usage variations

Get-Sum


Get-Sum 9 10


Get-Sum -a 9 -b 10











#Simple Function - That accepts pipeline inputs
#---------------


FUNCTION Out-Screen(
        [Parameter(ValueFromPipeline=$True)] $a = 0
    )
{
    $a
}



#What is the expected result here?

1..10 | Out-Screen





#Not what was expected.. What happened?
















#Some things to note:
# 1. The input is an array
# 2. Only the last vaule got output
# 3. Why only the last value?
#     ...because function is treated only having an "End" block, we will see next!











#Pipelined Function - What goes wrong? Try Verbose
#---------------

FUNCTION Out-Screen(
        [Parameter(ValueFromPipeline=$True)] $a = 0
    )
{
    Write-Verbose ('$a = {0}' -f $a)

    $a
}


1..10 | Out-Screen -verbose




#Only the last value from the input is printed...








#Pipelined Functions - NEED "Begin", "Process", "End"
#---------------


FUNCTION Out-Screen(
        [Parameter(ValueFromPipeline=$True)] $a = 0
    )
{
    Begin
    {
        Write-Verbose ('Begin $a = {0}' -f $a)
    }

    Process
    {
        Write-Verbose ('Process $a = {0}' -f $a)
    }
    
    End
    {
        Write-Verbose ('End $a = {0}' -f $a)
        write-host $a
    }    
}


#What is the expected result here?

1..10 | Out-Screen -Verbose










#Things to note:
#
# Begin - Got called exactly once at the beginning
#         Parameter $a is not in the scope of Begin as seen by its default value of 0
#
# Process - Got called once for every pipeline input value
#
# End - Got called exactly once at the end
#         Holds the last value of the parameter $a when control flow gets to it









#Pipelined Functions - Total of pipeline input using "Begin", "Process", "End"
#---------------

FUNCTION Get-SumOfPipelineInput(
        [Parameter(ValueFromPipeline=$True)] $a = 0
    )
{
    Begin
    {
        [int] $sum = 0
        Write-Verbose ('Begin $a = {0}, $sum = {1}' -f $a, $sum)
        
    }

    Process
    {
        $sum += $a
        Write-Verbose ('Process $a = {0}, $sum = {1}' -f $a, $sum)
    }
    
    End
    {
        Write-Verbose ('End $a = {0}, $sum = {1}' -f $a, $sum)
        write-host $sum
    }    
}





#Try it out

1..10 | Get-SumOfPipelineInput -Verbose







#Pipelined Functions - foreach-object shortcut way of doing the same as above
#---------------

@(1..10) | ForEach-Object -Begin{$sum = 0}  -Process{$sum += $_} -End{$sum}




#Note the use of $_ to refer to the values coming from the pipe







#Everyone knows this but now we know what goes behind pipelining (somewhat!)

#Start NotePad 

Invoke-Expression "Notepad.exe"


#Kill the innocent "Notepad"

Get-Process -Name notepad | Stop-Process






#Above, Stop-Process accepts a pipeline input (input being of type "System.Diagnostics.Process")

(Get-Process)[0].GetType()



(Get-Process)[0] | Get-Member










#In fact, we could have written Stop-Process something like this 


FUNCTION Stop-Process-Jana(
        #Note that we are taking an process array as input - [System.Diagnostics.Process[]]
        [Parameter(ValueFromPipeline=$True)] 
        [System.Diagnostics.Process[]] 
        $process = $null
    )
{
    Begin
    {
        [int] $counter = 0

        #We cannot access input parameter here!
        Write-Verbose ('Begin')        
    }

    Process
    {
        Write-Verbose ('Process $process = {0}, ID = {1}' -f $process.Name, $process.Id)

        $process.Kill()
        $counter ++
    }
    
    End
    {
        Write-Verbose ('End')
        Write-Verbose "Killed [$counter] processes!"
    }    
}



#Invoke 3 NotePad's so that we can see all three getting killed!

Invoke-Expression "Notepad.exe"

Invoke-Expression "Notepad.exe"

Invoke-Expression "Notepad.exe"


#Kill all notepads using our new pipelined function

Get-Process -Name notepad | Stop-Process-Jana -Verbose









#Up to now, we saw multiple inputs ....but a single output
#
# What if we wanted a separate output for each of the inputs?
#







#Pipelined Functions - More than 1 pipelined input parameter and separate output for each input
#---------------

FUNCTION Get-Sum-EachPair(
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true)] 
        [int]$a = 0,
        
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true)] 
        [int]$b = 0
    )
{    
    Begin
    {
        [int[]] $sums = @()
        Write-Verbose ('Begin $a = {0}, $b = {1}' -f $a, $b)
        
    }

    Process
    {
        $sum = $a + $b
        Write-Verbose ('Process $a = {0}, $b = {1}' -f $a, $b)
        $sums += $sum
    }
    
    End
    {
        Write-Verbose ('End $a = {0}, $b = {1}' -f $a, $b)
        $sums
    }    
}









#What is expected here?

1,2 | Get-Sum-EachPair -Verbose











#This is wrong on so many fronts
# 1. This is an array - we are trying to pass it to two input parameters 
#     (1,2).GetType()
# 2. Each input value from the pipeline gets sent to every pipelined parameter
# 3. Results will be unpredictable
#      Combine this with pipeline + non-pipeline input + defaults + parameter sets!


#So, how is it done?








#Custom objects!


#Input Pair1 - Sum values in this pair
#
$pair1 = New-Object -TypeName PSObject
$pair1 | Add-Member -MemberType NoteProperty -Name a -Value 1
$pair1 | Add-Member -MemberType NoteProperty -Name b -Value 2

#How does $pair1 look?
$pair1 | ft -auto

#Get the sum of values 
$pair1 | Get-Sum-EachPair -Verbose





#Input Pair2
#
$pair2 = New-Object -TypeName PSObject
$pair2 | Add-Member -MemberType NoteProperty -Name a -Value 3
$pair2 | Add-Member -MemberType NoteProperty -Name b -Value 4


#Make an array with Pair1 and Pair2
"`$pair1 = $pair1"
"`$pair2 = $pair2"

$pairs = @($pair1, $pair2)





#Did you notice above? A mix of pipelined input and non-pipelined input in the same line?
#$pair2 | Add-Member -MemberType NoteProperty -Name a -Value 3

#Above, what is implied in the call to Add-Member is "-InputObject $pair2". Same as above is below:
#Add-Member -InputObject $pair2 -MemberType NoteProperty -Name a -Value 3




#Get the sum of values of two pairs that are in $pairs
$pairs | Get-Sum-EachPair -Verbose





#Should return 4 results

@($pair1, $pair2, $pair1, $pair2) | Get-Sum-EachPair -Verbose





#Scroll up to the function and notice 
# 1. The additional parameter decoration "ValueFromPipelineByPropertyName"
# 2. We are collecting results into an array in "Process"
# 3. We just output what was already done, in "End"














#Pipelined Functions - Greater than 1 pipelined parameter, separate output for each input + non-pipelined input parameter
#---------------

FUNCTION Get-Sum-EachPair(
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true)] 
        [int]$a = 0,
        
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$true)] 
        [int]$b = 0,

        #This is a non-piplelined input parameter
        [Parameter(ValueFromPipeline=$False, Mandatory=$false)] 
        [bool]$WriteOutputAsCSV = $True

    )
{    
    Begin
    {
        [int[]] $sums = @()
        Write-Verbose ('Begin $a = {0}, $b = {1}' -f $a, $b)
        
    }

    Process
    {
        $sum = $a + $b
        Write-Verbose ('Process $a = {0}, $b = {1}' -f $a, $b)
        $sums += $sum
    }
    
    End
    {
        Write-Verbose ('End $a = {0}, $b = {1}' -f $a, $b)
        $sums

        if ($WriteOutputAsCSV -eq $True)
        {
            "Sums (from non-pipelined parameter input!) : {0}" -f ($sums -join ',')
        }
    }    
}



#Usage examples

Get-Sum-EachPair 




@($pair1, $pair2, $pair1, $pair2) | Get-Sum-EachPair -WriteOutputAsCSV: $true












#PowerShell automatic variable - $input 
#---------------------------------------
# Example is a variation of what I found online


FUNCTION Make-HTML
(
    [string] $FileName
)
{
    # process the input from pipeline using automatic variable $input
    $input | ConvertTo-HTML > $FileName
}





$file = 'c:\Temp\Test.html' 
Get-Process | Make-HTML -FileName $file
Invoke-Item $file
#Remove-Item $file


#Notice the the input came from the pipeline into the function via automatic variable $input!







#Above is "hiding" the usage of $input automatic variable...good idea to be explicit


FUNCTION Make-HTML
(
    [string] $FileName,
    [object[]] $InputObject
)
{
    #If input is coming from the pipeline, use that, else set $input to the value passed in as parameter explicitly
    if ($InputObject) { $input = $InputObject }

    # process the input from pipeline using automatic variable $input
    $input | ConvertTo-HTML > $FileName
}



#Usage variation 1 - Using pipelined method

$file = 'c:\Temp\Test.html' 
Get-Process | Make-HTML -FileName $file
Invoke-Expression $file
#Remove-Item $file


#Usage variation 2 - Using non-pipelined method

$file = 'c:\Temp\Test.html' 
Make-HTML -FileName $file -InputObject (Get-Process)
Invoke-Expression $file
#Remove-Item $file



#WARNING: $input is not an array but rather an enumerator
#        ..which only moves forward on each access and does not reset itself 
#   ...so, one can get weird results if iterating through multiple times.


#https://dmitrysotnikov.wordpress.com/2008/11/26/input-gotchas/
