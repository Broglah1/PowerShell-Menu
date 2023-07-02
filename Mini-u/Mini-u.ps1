if (!(Get-Module -Name DrawMenu)) {
    Import-Module $PSScriptRoot\DrawMenu.ps1
}
<#
.SYNOPSIS
	This function serves as an example of how I implement command line 
    interface menus in PowerShell. To use this, run 
    'Import-Module .\Mini-u.ps1' from within this project's directory.
.DESCRIPTION
    Using a JSON file, a main menu is generated which contain names to
    objects within the JSON file that serve as submenus. Each submenu 
    has addition objects that can be selected. Edit the JSON file to 
    create your desired menu layout, currently limited to a depth of
    2.

    DrawMenu.ps1 allows the user to select menu options with the 
    Up/Down arrow keys and make a selection with 'Enter'.
.NOTES
    Version:    v1.0 -- 07 Dec 2022
                v1.1 -- 23 Jun 2023
	Author:     Lucas McGlamery
.EXAMPLE
	PS> mini-u
#>
function mini_u {
    #Save the old ProgressPreference
    $oldProgressPreference = $ProgressPreference
    #Set the ProgressPreference to SilentlyContinue to suppress the progress bar
    $script:ProgressPreference = 'SilentlyContinue'

    do {
        Clear-Host # Clear the screen before drawing the main menu
        $MainMenu = (Get-Content .\menus\MainMenu.json | ConvertFrom-Json).PSObject.Properties
        $MainMenuSelection = Menu $MainMenu.Name "Main Menu" $MainMenu
        
        if ($MainMenuSelection -eq "Exit") { break }
        
        $SubMenuOptions = $MainMenu | Where-Object{
            $_.Name -eq $MainMenuSelection
        }
        $SubMenu = ($SubMenuOptions.Value | ForEach-Object{$_.PSObject.Properties | Where-Object{$_.Name -ne 'Description'}})
        $MenuOptionSelection = Menu ($SubMenu.Name + "Back to Main Menu") "Select a sub menu option" $SubMenu
        
        #Retrieve the command for the selected submenu option
        $selectedOptionCommand = ($SubMenu | Where-Object { $_.Name -eq $MenuOptionSelection }).Value.Command
        
        #Execute the command if it exists
        if ($MenuOptionSelection -eq "Back to Main Menu") { continue }
        if ($selectedOptionCommand) {
            Write-Host "Executing command: $selectedOptionCommand"
            $scriptBlock = [scriptblock]::Create($selectedOptionCommand)
            Invoke-Command -ScriptBlock $scriptBlock
            
            #Add a pause here
            Read-Host "Press Enter to return to main menu"
            Clear-Host #Clear the screen again before returning to the main menu
        } else {
            Write-Host $MenuOptionSelection
        }
    } while ($true)

    #Reset the ProgressPreference back to its original state
    $script:ProgressPreference = $oldProgressPreference
}