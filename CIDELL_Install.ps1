# Required Scripts
#===[  ]===#

Write-Host('Defining Required Scripts...') -Fore White

##  Create the Citoc_Running.bat script, that will monitor if CITOC is running.
    Set-Content -Path 'C:\temp\Citoc_Running.bat' -Value '
@echo off
title IS CITOC RUNNING?
color 67
:CITOC
tasklist.exe | findstr "irsetup.exe" > nul
cls
if errorlevel 1 (
echo "CITOC IS NOT RUNNING!!"
GOTO END
) ELSE (
echo "CITOC IS RUNNING"
GOTO CITOC
:END
exit
)
'

##  Create Start_Citoc.ps1 script.
    Set-Content -Path 'C:\temp\Start_CITOC.ps1' -Value {

$Citoc_App = "C:\Temp\CITOC.exe"
$app_arguments = "arg0"

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = $Citoc_App
$pinfo.Arguments = $app_arguments
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start()
$p.ProcessorAffinity=0x3
}

#   Path to this directory.
        cd C:\temp\Apps\01

##  Create the Download Citoc.ps1 script. 
    Set-Content -Path 'C:\temp\Apps\01\Download-Citoc.ps1' -Value {

    ### Define Title
    $host.ui.RawUI.WindowTitle = 'CITOC'
    $CitocURL = "https://www.mediafire.com/file/tvqubab384cnfnu/EnvoyMortgage_176287_DPMA_SILENT_549.exe/file"
    $URL = $CitocURL
    $STRING = 'innerText : Download'
    $DIR = $(get-location).Path;
    $DIRAPP = $DIR + "\" + $APP
    $File1 = $DIR + "\file1.txt"
    $File2 = $DIR + "\file2.txt"
    $File3 = $DIR + "\file3.txt"
    $APPSTRING = $DIR + "\APPSTRING.txt"          
    $APPSTRING1 = $DIR + "\APPSTRING1.txt"    
    $APPSTRING2 = $DIR + "\APPSTRING2.txt"
    $APPSTRING3 = $DIR + "\APPSTRING3.txt"


(Invoke-WebRequest -Uri $URL).Links | sort-object href -Unique | Format-List innerText, href > $File1
        Get-Content $File1 | Select-String $STRING -Context 0,1 | ForEach-Object{
				$Info = $_.Context.PostContext
									                                            }

                $info -split "https:",2, "simplematch" | select -last 1 > $File2
                    (Get-Content "$File2") | foreach {"https:" + $_ } > $File3
                        $Source = Get-Content "$File3" 

                $APPSTRING = Get-Content $File2
                $APPSTRING -split "//",2, "simplematch" | select -last 1 > $APPSTRING1

                $APPSTRING2 = Get-Content $APPSTRING1 -Raw 
                $APPSTRING3 = ($APPSTRING2.Split('/',4) | Select -Index 3)
                $APP = $APPSTRING3

                    Start-BitsTransfer -Source $Source -Destination $DIRAPP
                    Start-Sleep -s 5
                    Get-ChildItem -Path $DIR *.txt | foreach { Remove-Item -Path $_.FullName }
                    Get-Variable -Exclude PWD,*Preference | Remove-Variable -EA 0
        Start-Sleep -s 5
        Rename-Item -Path "c:\temp\Apps\01\EnvoyMortgage_176287_DPMA_SILENT_549.exe" -NewName "CITOC.exe"
  
}

#   Path to this directory.
        cd C:\temp\Apps\03

##  Create the dell download script for installation.
    Set-Content -Path 'C:\temp\Apps\03\Download-DELL-COMMAND.ps1' -Value {

    $DELL_URL = 'https://www.mediafire.com/file/qbwasvxtk1s4uc8/Dell_Command.exe/file'
    $URL = $DELL_URL
    $STRING = 'innerText : Download'
    $DIR = $(get-location).Path;
    $DIRAPP = $DIR + "\" + $APP
    $File1 = $DIR + "\file1.txt"
    $File2 = $DIR + "\file2.txt"
    $File3 = $DIR + "\file3.txt"
    $APPSTRING = $DIR + "\APPSTRING.txt"          
    $APPSTRING1 = $DIR + "\APPSTRING1.txt"    
    $APPSTRING2 = $DIR + "\APPSTRING2.txt"
    $APPSTRING3 = $DIR + "\APPSTRING3.txt"


    (Invoke-WebRequest -Uri $URL).Links | sort-object href -Unique | Format-List innerText, href > $File1
        Get-Content $File1 | Select-String $STRING -Context 0,1 | ForEach-Object{
				$Info = $_.Context.PostContext
									                                            }

                $info -split "https:",2, "simplematch" | select -last 1 > $File2
                (Get-Content "$File2") | foreach {"https:" + $_ } > $File3
                $Source = Get-Content "$File3" 

                $APPSTRING = Get-Content $File2
                $APPSTRING -split "//",2, "simplematch" | select -last 1 > $APPSTRING1

                $APPSTRING2 = Get-Content $APPSTRING1 -Raw 
                $APPSTRING3 = ($APPSTRING2.Split('/',4) | Select -Index 3)
                $APP = $APPSTRING3

                Start-BitsTransfer -Source $Source -Destination $DIRAPP
                Start-Sleep -s 5
                Get-ChildItem -Path $DIR *.txt | foreach { Remove-Item -Path $_.FullName }
                Get-Variable -Exclude PWD,*Preference | Remove-Variable -EA 0

}

#   Download Programs
Write-Host('Downloading CITOC...') -Fore White
Invoke-Expression 'cmd /c start powershell -Command { powershell.exe "C:\temp\Apps\01\Download-Citoc.ps1"}'

Write-Host('Downloading Dell COMMAND Update...') -Fore White
Invoke-Expression 'cmd /c start powershell -Command { powershell.exe C:\Temp\Apps\03\Download-DELL-COMMAND.ps1 }'

#   Create the ENVIT Script
    Set-Content -Path 'C:\temp\ENVIT.ps1' -Value {

# Push Updates to the machine
Install-WindowsUpdate -AcceptAll -MicrosoftUpdate

#Push Recovery Password AAD
BackupToAAD-BitLockerKeyProtector $env:systemdrive -KeyProtectorId $RecoveryProtector.KeyProtectorID

#  Backup BitLocker to Azure Active Directory
$AllProtectors = (Get-BitlockerVolume -MountPoint $env:SystemDrive).KeyProtector 
$RecoveryProtector = ($AllProtectors | where-object { $_.KeyProtectorType -eq "RecoveryPassword" })

#   Start the installation
Invoke-Expression 'cmd /c start powershell -Command { powershell.exe "C:\Temp\Start_CITOC.ps1"}' 
Start-Sleep -s 40
#   Start the Monitor
cmd /c start C:\temp\Citoc_Running.bat

#Start Dell Installation
cmd /c start C:\temp\RunDell.bat

#END

      }

#   Set the registry key for Active-Setup
reg add "HKLM\Software\Microsoft\Active Setup\Installed Components\EVIT" /v "StubPath" /d "Powershell.exe C:\Temp\ENVIT.ps1" /t REG_SZ /f
