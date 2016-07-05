Import-Module Pscx
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
$currentUser.Owner | % { if($_.value -eq "S-1-5-32-544") { $userType = "Admin: " } else { $userType = "User: " } }
$host.ui.rawui.WindowTitle = ("PS {0}.{1}  ||  {2}{3}" -f $psMajor, $psMinor, $userType, $currentUser.Name ) # $networkPath

Function Get-Time { return $(get-date | % { $_.ToLongTimeString() } ) }
Function Prompt
{
    # Write the time 
    write-host "[" -BackgroundColor Black -foreground Cyan -noNewLine
    write-host $(Get-Time) -BackgroundColor Black -foreground DarkGray -noNewLine
    write-host "]" -BackgroundColor Black -foreground Cyan -noNewLine
    # Write the path
    write-host $($(Get-Location).Path.replace($home," ~").replace("\","/")) -foreground Gray -noNewLine
    write-host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine
    return ">"
}

#colorized dir
Function ll
{
    param ($dir = ".", $all = $false) 

    $origFg = $host.ui.rawui.foregroundColor 
    if ( $all ) { $toList = ls -force $dir }
    else { $toList = ls $dir }

    foreach ($Item in $toList)  
    { 
        Switch ($Item.Extension)  
        { 
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
        $item 
    }  
    $host.ui.rawui.foregroundColor = $origFg 
}

# Command Line RDP
Function RDP{
    param ([Parameter(Mandatory=$true)] [string]$Computer)
    #$User = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $User = 'kirk\$bsparks'

    if (-not (Test-Path .\RDP.txt)) {
        Read-Host -AsSecureString "Enter Password: " | convertfrom-securestring | out-file .\RDP.txt
    }

    $Password = Get-Content .\RDP.txt | convertto-securestring
    $cred = New-Object System.Management.Automation.PSCredential($User, $Password)
    $Pass = $cred.GetNetworkCredential().Password
    $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
    $Process = New-Object System.Diagnostics.Process
    $ProcessInfo.FileName = "$($env:SystemRoot)\system32\cmdkey.exe"
    #write-host $Pass
    $ProcessInfo.Arguments = (" /generic:{0} /user:{1} /pass:{2}" -f $Computer, $User, $Pass)
    $Process.StartInfo = $ProcessInfo
    #write-host ("Starting {0}{1}" -f $ProcessInfo.FileName,$ProcessInfo.Arguments)
    $Process.Start()

    $ProcessInfo.FileName = "$($env:SystemRoot)\system32\mstsc.exe"
    $ProcessInfo.Arguments = (" /v {0}" -f $Computer)
    $Process.StartInfo = $ProcessInfo
    #write-host ("Starting {0}{1}" -f $ProcessInfo.FileName,$ProcessInfo.Arguments)
    $Process.Start()

    $ProcessInfo.FileName = "$($env:SystemRoot)\system32\cmdkey.exe"
    $ProcessInfo.Arguments = (" /delete {0}" -f $Computer)
    $Process.StartInfo = $ProcessInfo
    #write-host ("Starting {0}{1}" -f $ProcessInfo.FileName,$ProcessInfo.Arguments)
    $Process.Start()
}


#Set Aliases
Set-Alias ss Select-String
Set-Alias wh Write-Host
Set-Alias ssh putty
Set-Alias scp pscp
Set-Alias subl "$env:ProgramFiles\Sublime Text 3\sublime_text.exe"
Set-Alias vi "$env:ProgramFiles\Sublime Text 3\sublime_text.exe"

#Set Get-Location
$docs = ([environment]::getfolderpath("mydocuments"))
Set-Location $docs

# SIG # Begin signature block
# MIIFuQYJKoZIhvcNAQcCoIIFqjCCBaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xMjEwMTUwMzAxMjdaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ3uRLED
# WSUP8/DX9nZG79RNHGEsqWil0iC7aJG0LTr9r4fuyUAg9jr7wFnnCIqpG8PfgZAI
# NHQ3tTmPZpyT2Y9G7rPho+vW6P1RvScS900XHZG8i/OTBnkJPbPeNS3O2pO2LbEO
# ZTdOeJLJnpFK/ahclsC55jQR31my33TZHN+OaXwkGFVJPwkl8zKrCvGZSME8F2Po
# 1nhB8ZUpMZUdGy1tFF0652G2p6uTmjXNrS350IfdDDX39PWzy0KL1Bf0oUObc0Ok
# kaVOPa3F17upqV0eWlTVKFHJ6gGlSOdUNWxpGlSEzmvzfV5vq+TzZWlZPwXFh7Y9
# eL4vf00fl8OkOb0CAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwXQYDVR0B
# BFYwVIAQqqEqJvooxpYhFPUcyXw6R6EuMCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwg
# TG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQvgToFvyEn69LwgEtUMni7TAJBgUrDgMC
# HQUAA4IBAQB6NpvHGLXrD3NfPi3iuH4KlC27qnWEpwrHCNsep4wyASU63okYKrlG
# g7iqYE6wpVatT4ew8milFbPqy/Gtn5+wFWURCjK45B4pRR6IuW7scJwR0E7BEXMu
# YKKI0bzx16XGP18rnfyPuh7TcAbWx244TLRBuNLNOj/CNZUNMpDHhmnSdGaviuq8
# QExeCG714YJcYr0bG4tbqdpC9FrFdp9r2qHojL0dbqJEVHsOm4n48Ip7bvb+tb2G
# 2e29c+brmU/75X9XVKDfYgajxqrnfclthxg5Fwntt19Ra5SfXGCgbl0abTpv8MPT
# CfyiWU5uLF0+cyynTFx1o1fpyPcEm/s0MYIB4TCCAd0CAQEwQDAsMSowKAYDVQQD
# EyFQb3dlclNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3QCEE77xHvbXCaaRE6e
# /m5BC4owCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJ
# KoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQB
# SIG # End signature block
