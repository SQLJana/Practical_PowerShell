
#---------------------------------------------------------------------------------
#Snippet to prevent accidental execution of entire demo script by hitting F5
#
#Author: Jana Sattainathan   | Twitter: @SQLJana    | Blog: SQLJana.WordPress.com
#
write-host -foregroundcolor yellow 'You hit F5. This will run this whole script.'
$response = Read-Host -Prompt 'Did you really mean to run the entire script?' 

if ($response -ne 'yes, I dont care about the demo') {
    throw [System.ArgumentException] "Aborting 'Run as script'! This sample file is not intended to be run as a script. Please highlight and run selection with F8."
}
#---------------------------------------------------------------------------------





##----------------------------------------
#What version of PowerShell am I running?
#----------------------------------------

$PSVersionTable 


##----------------------------------------
#Basic examples
#----------------------------------------


"This text get written as is!"



$var = "I am a string variable"
$var



$tableName = 'Employees'
$var = "I am a string var to display [$tableName]"
$var




$tableName = 'Employees'
$var = 'I am a single quoted string 
        variable holding only literals...[$tableName]'
$var


#Notice how we escape with ` if we wanted to print out $var without substitution

"`$var is now available forever 
    (or until undefined) and its value is : `n $var"




# HereString's are special. They retain all formatting (tabs etc).

$varHereString = @"
Some text whose 
    characteristics are
        preserved
"@

$varHereString



# Verb-noun structure
#----------------------------------------
Get-Process 



# Parameters
#----------------------------------------
Get-Process -Name *sql*




# Assign to a variable
#----------------------------------------
$processes = Get-Process




# Piping output to a grid
#----------------------------------------
$processes | Out-GridView 



# Piping output to a grid and making a selection for further use
#----------------------------------------
$processes | Out-GridView -PassThru


# Piping output to a other functions
#----------------------------------------
Invoke-Expression "$($env:windir)\system32\notepad.exe"
Invoke-Expression "$($env:windir)\system32\notepad.exe"
Invoke-Expression "$($env:windir)\system32\notepad.exe"

Get-Process -Name notepad | Out-GridView -PassThru | Stop-Process





# Getting the process list of another computer 
#   For this example, we use the current computer!
#----------------------------------------

Get-Process -ComputerName (hostname)



