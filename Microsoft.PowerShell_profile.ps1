Import-Module Pscx
Import-Module AWSPowerShell
. (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
Import-Module $env:github_posh_git\posh-git
#Import-module ActiveDirectory
#Add-PSSnapin Quest.ActiveRoles.ADManagement

#Set Network shares
#$mydrive = $pwd.Drive.Name + ":";	
#$networkShare = (gwmi -class "Win32_MappedLogicalDisk" -filter "DeviceID = '$mydrive'");
#if ($networkShare -ne $null) { $networkPath = $networkShare.ProviderName }
	
#Set title bar
$psMajor = $host.version.major
$psMinor = $host.version.minor
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$currentUser.Owner | % { if ($_.value -eq "S-1-5-32-544") { $userType = "Admin: " } else { $userType = "User: " } }
$host.ui.rawui.WindowTitle = ("PS {0}.{1}  ||  {2}{3}" -f $psMajor, $psMinor, $userType, $currentUser.Name ) # $networkPath

Function Get-Time { 
    return $(get-date | % { $_.ToLongTimeString() } )
}

Function Prompt {
    # Write the time 
    write-host "[" -BackgroundColor Black -foreground Cyan -noNewLine
    write-host $(Get-Time) -BackgroundColor Black -foreground DarkGray -noNewLine
    write-host "]" -BackgroundColor Black -foreground Cyan -noNewLine
    # Write the path
    write-host $($(Get-Location).Path.replace($home," ~").replace("\","/")) -foreground Gray -noNewLine
    write-host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine
    Write-VcsStatus
    return ">"
}

#colorized dir
Function ll {
    param ($dir = ".", $all = $false) 

    $origFg = $host.ui.rawui.foregroundColor 
    if ( $all ) { $toList = ls -force $dir }
    else { $toList = ls $dir }

    foreach ($Item in $toList) { 
        Switch ($Item.Extension) { 
            ".Exe" {$host.ui.rawui.foregroundColor = "Yellow"} 
            ".cmd" {$host.ui.rawui.foregroundColor = "DarkRed"} 
            ".ps1" {$host.ui.rawui.foregroundColor = "DarkBlue"} 
            ".py" {$host.ui.rawui.foregroundColor = "DarkCyan"} 
            ".xls" {$host.ui.rawui.foregroundColor = "DarkGreen"}
            ".xlsx" {$host.ui.rawui.foregroundColor = "DarkGreen"}
            ".doc" {$host.ui.rawui.foregroundColor = "DarkBlue"}
            ".docx" {$host.ui.rawui.foregroundColor = "DarkBlue"}
            Default {$host.ui.rawui.foregroundColor = $origFg} 
        } 
        if ($item.Mode.StartsWith("d")) {$host.ui.rawui.foregroundColor = "Green"}
        $Item 
    }
    $host.ui.rawui.foregroundColor = $origFg 
}

# Command Line RDP
Function RDP {
    param ([Parameter(Mandatory=$true)] [string]$Computer)
    $User = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    if (-not (Test-Path .\RDP.txt)) {
        Read-Host -AsSecureString "Enter Password: " | convertfrom-securestring | out-file .\RDP.txt
    }

    $Password = Get-Content .\RDP.txt | convertto-securestring
    $cred = New-Object System.Management.Automation.PSCredential($User, $Password)
    $Pass = $cred.GetNetworkCredential().Password
    $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
    $Process = New-Object System.Diagnostics.Process
    $ProcessInfo.FileName = "$($env:SystemRoot)\system32\cmdkey.exe"
    write-host $Pass
    $ProcessInfo.Arguments = (" /generic:{0} /user:{1} /pass:{2}" -f $Computer, $User, $Pass)
    $Process.StartInfo = $ProcessInfo
    write-host ("Starting {0}{1}" -f $ProcessInfo.FileName,$ProcessInfo.Arguments)
    $Process.Start()

    $ProcessInfo.FileName = "$($env:SystemRoot)\system32\mstsc.exe"
    $ProcessInfo.Arguments = (" /v {0}" -f $Computer)
    $Process.StartInfo = $ProcessInfo
     write-host ("Starting {0}{1}" -f $ProcessInfo.FileName,$ProcessInfo.Arguments)
    $Process.Start()

    Start-Sleep -s 20
    $ProcessInfo.FileName = "$($env:SystemRoot)\system32\cmdkey.exe"
    $ProcessInfo.Arguments = (" /delete {0}" -f $Computer)
    $Process.StartInfo = $ProcessInfo
     write-host ("Starting {0}{1}" -f $ProcessInfo.FileName,$ProcessInfo.Arguments)
    $Process.Start()
}


#Set Aliases
Set-Alias ss Select-String
Set-Alias wh Write-Host
Set-Alias ssh putty
Set-Alias scp pscp
Set-Alias subl "$env:ProgramFiles\Sublime Text 3\sublime_text.exe"
Set-Alias vi "$env:ProgramFiles\Sublime Text 3\sublime_text.exe"

#Set prompt to docs folder
Set-Location ([environment]::getfolderpath("mydocuments"))

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZDZJ3o0MouaYW5MbOgzw/YC2
# zUugggI9MIICOTCCAaagAwIBAgIQ5fMjrFmdZ55DGZPX7tmhNzAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xMjEwMTIxOTIxMzhaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAofc0SchV9VkM
# rGS2q2Dq4zppJQE1LxNJv6B29tQqPLpROdAD5qL7SjQ5nDtoEn7+o3f4sgnlrFCJ
# 94pztueGn9s24T/Ihv813+E1G9xP8pStmnfMQvtb9lghGIh2IkFoBbrYaIOs+w1E
# YsLrf3tomvzW0wHh4lE4H7UWpgKHR6UCAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwXQYDVR0BBFYwVIAQzMVtQnYaxANZ5Ltsgp5cjaEuMCwxKjAoBgNVBAMT
# IVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQoEw1tI02JrpK13f7
# DRSxfTAJBgUrDgMCHQUAA4GBAD17yvn8RjaPU1sSvB2iG1Om16SMdrqh5LwFI7MM
# PS7GZrtiv0YEYQGKksemGPFukDf1sFeQ55kdYU0drJ7ebtn16/RIybweTRv7S0Ea
# Y3xTO5KObb1L9vdrXX899nPmeDPZsn4L53NKp09HLkGNu9Ld5UMhW85cOPb6gSHm
# YRUsMYIBYDCCAVwCAQEwQDAsMSowKAYDVQQDEyFQb3dlclNoZWxsIExvY2FsIENl
# cnRpZmljYXRlIFJvb3QCEOXzI6xZnWeeQxmT1+7ZoTcwCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FALUFL6B7+ITu7YwTAQiXc6RCqW6MA0GCSqGSIb3DQEBAQUABIGAbKm6eNcOdEXw
# 7bqeAILoEXIHGbx8MpXRncnF1DFT6mgPli2APCuphB4R1LSQV8vNJ1Zocj+X8j0T
# 9DK00jA7gb9oyOg4CF+tdumVj7BhXnkwU/N3kRQjtrJZ3401zP5aXx3sy7C8dMb0
# L5hKCLTBaFjGhdxDqm3hET8/C8AjmwA=
# SIG # End signature block
