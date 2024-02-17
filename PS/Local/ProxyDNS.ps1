$NetInterface = Get-NetAdapter -Physical | Where-Object Status -eq 'up'
$MainInterface = $NetInterface.Name
$DNSList = @{
    USA1 = '204.106.240.53'
    USA2 = '108.179.34.214'
}

function Set-ProxyDNS ($DNS) {
    Set-DnsClientServerAddress -InterfaceAlias $MainInterface -ServerAddresses ($DNS, "8.8.8.8")
}

function Reset-ProxyDNS {
    Set-DnsClientServerAddress -InterfaceAlias $MainInterface -ResetServerAddresses
}

function Select-Server {
    $SelectedServer = Read-Host "Select Server`n1. US1`n2. US2`nSelection"
    return $SelectedServer
}

function Set-Server ($SelectedServer) {
    if ($SelectedServer -eq "1") {
        Set-ProxyDNS $DNSList.USA1
    } else {
        Set-ProxyDNS $DNSList.USA2
    }
}

function Start-Or-Stop-Proxy {
    do {
        $choice = Read-Host "Do you want to start or stop the proxy?`n1. Start`n2. Stop`nSelection"

        switch ($choice) {
            1 {
                $SelectedServer = Select-Server
                Set-Server $SelectedServer
                Write-Host "Proxy started with selected server."
            }
            2 {
                Reset-ProxyDNS
                Write-Host "Proxy stopped. DNS reset to default."
            }
            default {
                Write-Host "Invalid selection. Please choose 1 or 2."
            }
        }
    } while ($choice -ne 2)
}

# Call the function to start or stop the proxy
Start-Or-Stop-Proxy
