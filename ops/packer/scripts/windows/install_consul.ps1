write-output "Installing and configuring Consul"

write-output "Creating directories"
foreach ($dir in @('log', 'data')) {
  New-Item -Path "C:\opt\consul\$dir" -ItemType Directory -Force
}

New-Item -Path "C:\opt\nssm" -ItemType Directory -Force

write-output "Setting download filepaths"
$nssmUrl = "http://nssm.cc/release/nssm-2.24.zip"
$consulUrl = "https://dl.bintray.com/mitchellh/consul/0.5.2_windows_386.zip"
$uiUrl = "https://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip"

$nssmFilePath = "$($env:TEMP)\nssm.zip"
$consulFilePath = "$($env:TEMP)\consul.zip"
$uiFilePath = "$($env:TEMP)\consulwebui.zip"

write-output "Downloading nssm"
(New-Object System.Net.WebClient).DownloadFile($nssmUrl, $nssmFilePath)
write-output "Downloading Consul"
(New-Object System.Net.WebClient).DownloadFile($consulUrl, $consulFilePath)
write-output "Downloading Consul Web UI"
(New-Object System.Net.WebClient).DownloadFile($uiUrl, $uiFilePath)

write-output "Setting shell namespaces"
$shell = New-Object -ComObject Shell.Application

$nssmZip = $shell.NameSpace($nssmFilePath)
$consulZip = $shell.NameSpace($consulFilePath)
$uiZip = $shell.NameSpace($uiFilePath)

$nssmDestination = $shell.NameSpace("C:\opt\nssm")
$consulDestination = $shell.NameSpace("C:\opt\consul")
$uiDestination = $shell.NameSpace("C:\opt\consul")

$copyFlags = 0x00
$copyFlags += 0x04 # Hide progress dialogs
$copyFlags += 0x10 # Overwrite existing files

write-output "Unzipping files"
$nssmDestination.CopyHere($nssmZip.Items(), $copyFlags)
$consulDestination.CopyHere($consulZip.Items(), $copyFlags)
$uiDestination.CopyHere($uiZip.Items(), $copyFlags)

write-output "Moving files"
Move-Item -Path "C:\opt\nssm\nssm-2.24\win32\nssm.exe" "C:\opt" -Force
Move-Item -Path "C:\opt\consul\dist" "C:\opt\consul\ui" -Force

write-output "Cleanup filepaths"
Remove-Item -Force -Path $consulFilePath
Remove-Item -Force -Path $uiFilePath
Remove-Item -Force -Path $nssmFilePath

write-output "Creating Consul service"
C:\opt\nssm.exe install consul "C:\opt\consul\consul.exe" agent -config-dir "C:\etc\consul.d"

write-output "Setting Consul options"
C:\opt\nssm.exe set consul AppEnvironmentExtra "GOMAXPROCS=%NUMBER_OF_PROCESSORS%"
C:\opt\nssm.exe set consul AppRotateFiles 1
C:\opt\nssm.exe set consul AppRotateOnline 1
C:\opt\nssm.exe set consul AppRotateBytes 10485760
C:\opt\nssm.exe set consul AppStdout C:\opt\consul\log\consul.log
C:\opt\nssm.exe set consul AppStderr C:\opt\consul\log\consul.log

write-output "Stopping Consul service"
Stop-Service consul -EA silentlycontinue
Set-Service consul -StartupType Manual

write-output "Disable negative DNS response caching"
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters -Name MaxNegativeCacheTtl -Value 0 -Type DWord

# Allow Consul Serf traffic through the firewall
write-output "Set firewalls"
netsh advfirewall firewall add rule name="Consul Serf LAN TCP" dir=in action=allow protocol=TCP localport=8301
netsh advfirewall firewall add rule name="Consul Serf LAN UDP" dir=in action=allow protocol=UDP localport=8301
