### SET FOLDER TO WATCH + FILES TO WATCH + SUBFOLDERS YES/NO
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = "\\freenas\Y-Drive\HLPIT\"
    $watcher.Filter = "*.*"
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true  

### LOAD JSON EXTENSION FILE 
    $jsonFile = "G:\School Classes\2017\Summer\projectFiles\extensionFlatFile1.json"
    $jsonString = Get-Content -Raw -Path $jsonFile
    $json = $jsonString | ConvertFrom-Json 

### SEND ADMINISTRATOR EMAIL ###
$senderEmail = "databasemail@hlpengineering.com"
$senderPassword = "hlpengineering117"
$receiverEmail = "jmurphy@hlpengineering.com"
$smtpServer = "smtp.gmail.com"
$smtpSendPort = 587
function Send-ToEmail($extension, $path){
    $emailMessage = New-Object Net.Mail.MailMessage
    $emailMessage.From = $senderEmail
    $emailMessage.To.Add($receiverEmail)
    $emailMessage.Subject = "Suspicious File Detected"
    $emailMessage.Body = "A suspicious file was detected located at $path"

    $smtpClient = New-Object Net.Mail.SmtpClient($smtpServer,$smtpSendPort)
    $smtpClient.EnableSsl = $true
    $smtpClient.Credentials = New-Object System.Net.NetworkCredential($senderEmail,$senderPassword)
    $smtpClient.Send($emailMessage)
    Write-Host "Message Sent"
}

### DISABLE SAMBA SERVER ON FREENAS ###
$freenasRoot = "root"
$rootPassword = "t@rg3t11"
$freenasName = "192.168.5.5"#FQDN or IP address of host
function Disable-FreeNAS-Samba(){
    New-SshSession -ComputerName $freenasName -Username $freenasRoot -Password $rootPassword
    Invoke-SshCommand -ComputerName $freenasName -Command "service samba_server stop"
    Remove-SshSession -ComputerName $freenasName
    Write-Host "Samba has been stopped"
}
### DEFINE ACTIONS AFTER AN EVENT IS DETECTED ###
$logFile = "C:\cBlocker\log.txt"
    $action = { $path = $Event.SourceEventArgs.FullPath
                $fileName = Split-Path $path -Leaf
                $changeType = $Event.SourceEventArgs.ChangeType
                $user = $env:USERNAME
                $logline = "$(Get-Date), $changeType, $path, $user, $computer"
                Add-content $logFile -value $logline
                Write-Host "The file '$fileName' was '$changeType' by '$user'"
                foreach($obj in $json.filters)
                {
                    if("$fileName" -like "$obj")
                    {
                        Disable-FreeNAS-Samba
                        Send-ToEmail($obj,$path)

                    }
                }
                Write-Host "Action Complete"             
              }    
              
### DECIDE WHICH EVENTS SHOULD BE WATCHED 
    Register-ObjectEvent $watcher "Created" -Action $action 
    Register-ObjectEvent $watcher "Changed" -Action $action
    Register-ObjectEvent $watcher "Deleted" -Action $action
    Register-ObjectEvent $watcher "Renamed" -Action $action
    while($true){Start-Sleep 5}