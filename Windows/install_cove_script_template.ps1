#This is used to install Cove Backup Manager onto Windows

#HOW TO USE: 
    #Change $Client_installer_ID to the full client specific .exe file name in Cove. 
    #Example: #BM123456789-123456789#.exe
#############  Variables to set  #############
$Client_installer_ID= "INSERT ENTIRE EXE FILE NAME HERE"

#############  Script Variables.  #############
$Working_path= '\'
$Installer_path= Join-Path -path $Working_path -ChildPath $Client_installer_ID
$ClientTool= 'C:\Program Files\Backup Manager\ClientTool.exe'

#Check if Cove is installed based on ClientTool.exe in default installation directory
If (Test-Path -Path $ClientTool) {
    Write-Output "Cove Backup already installed"
    Exit 0
}
#Cove not detected, download and install
else {
    Write-Output "Downloading and installing Cove Backup "
    (New-Object Net.WebClient).DownloadFile('https://cdn.cloudbackup.management/maxdownloads/mxb-windows-x86_x64.exe',$env:temp+$Installer_path);Invoke-Expression $env:temp$Installer_path
    Exit 0  
}

Exit 1