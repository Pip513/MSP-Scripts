#fine tune for your environment. "restart-service" can be commented out/deleted, this is written to be a login/startup printer check script with Ricoh StreamlineNX in mind. 


$SLNXDriverinstallpath = "z00960L1b\disk1\oemsetup.inf"
$SLNXService = "RICOH Streamline NX PC Client Service"
$SLNXPort = "SLNX Server Secure Print Port"
$PrinterDrivername = "PCL6 Driver for Universal Print"
$PrinterDriverManufacturer = "Ricoh"
$PrinterName = "SLNX"

#Check if printer exists, is using correct port and driver
if ($null -eq (get-printer -Name $PrinterName | Where-Object {($_.PortName -eq $SLNXPort) -and ($_.DriverName -eq $PrinterDrivername)})) {
    Write-Output "Printer doesn't exist or not properly configured"
} else {
    Write-Output "SLNX Printer is installed correctly"
    exit
}
#Check if SLNX is installed
if ($null -eq (Get-Service -Name $SLNXService)) {
    Write-Output "SLNX service does not exist"
    exit
 }  else {
    Write-Output "SLNX service found"
 }
 #Confirm port exists
 if ($null -eq (Get-PrinterPort -Name $SLNXPort)) {
    Write-Output "SLNX port does not exist"
    exit
 }  else {
    Write-Output "SLNX port exists"
 }
 #Check if driver exists, else install
 if ($null -eq (Get-PrinterDriver -Name $Printerdrivername | Where-Object Manufacturer -eq $PrinterDriverManufacturer)) {
    Write-Output "SLNX preferred driver does not exist. Installing..."
    pnputil.exe /a $SLNXDriverinstallpath
    Add-PrinterDriver -Name $Printerdrivername
 }  else {
    Write-Output "SLNX preferred driver exists"
    
 }

#Remove SLNX printer if found
Remove-Printer -Name $PrinterName -ErrorAction SilentlyContinue
#Add printer and restart SLNX
Add-Printer -Name $PrinterName -DriverName $Printerdrivername -PortName $SLNXPort
Restart-Service -DisplayName $SLNXService #-ErrorAction SilentlyContinue
