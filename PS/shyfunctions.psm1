# All my custom scripts because im lazy as fuck

# lazy ping or traceroute
# function run {
#     param (
#         [Parameter(Mandatory=$true, ParameterSetName="Ping")]
#         [Alias("p")]
#         [string]$AddressPing,

#         [Parameter(Mandatory=$true, ParameterSetName="Traceroute")]
#         [Alias("t")]
#         [string]$AddressTraceroute,

#         [Parameter(Mandatory=$true, ParameterSetName="Detailed")]
#         [Alias("d")]
#         [string]$AddressDetailed,

#         [Parameter(ParameterSetName="Detailed")]
#         [int]$Port
#     )

#     switch ($PSCmdlet.ParameterSetName) {
#         "Ping" {
#             Write-Host "Starting continuous ping to $AddressPing..."
#             Test-Connection -ComputerName $AddressPing -Continuous
#         }
#         "Traceroute" {
#             Write-Host "Running traceroute to $AddressTraceroute..."
#             Test-NetConnection -ComputerName $AddressTraceroute -TraceRoute
#         }
#         "Detailed" {
#             if ($Port) {
#                 Write-Host "Running detailed network test to $AddressDetailed on port $Port..."
#                 Test-NetConnection -ComputerName $AddressDetailed -Port $Port -InformationLevel Detailed
#             } else {
#                 Write-Host "Running detailed network test to $AddressDetailed..."
#                 Test-NetConnection -ComputerName $AddressDetailed -InformationLevel Detailed
#             }
#         }
#     }
# }

# # lazy SMTP test
# function smtp () {
#     $SMTPServer = Read-Host "SERVER"
#     $Source = Read-Host "FROM"
#     $Destination = Read-Host "TO"
#     $Port = Read-Host "PORT"

#     Send-MailMessage -SMTPServer $SMTPServer -Port $Port -To $Destination -From $Source -Subject "This is a test email" -Body "Hi, this is a test email sent to test SMTP server - KL" -WarningAction Ignore
# }

# # lazy exchange shell disconnect
# function exchd () {
#     Disconnect-ExchangeOnline
# }

# # lazy whois query for domain 
# function who ($whois) {
#     Start-Process chrome.exe "https://www.whois.com/whois/$whois"
# }

# # even lazier way to kill terminal
# function ex () {
#     exit
# }

# # fucking lazy ass launch admin console in ps ninja style
# function admin ($email) {
#     Write-Host "Logging in as: $email"
#     $site = Read-Host "launch"

#     $launch = switch ($site) {
#         "1" { exch($email) }
#         "2" { azure($email) }
#         default { exch($email) }
#     }
# }

# OLD CODE ABOVE

function run {
    param (
        [Parameter(Mandatory=$true, ParameterSetName="Ping")]
        [Alias("p")]
        [string]$AddressPing,

        [Parameter(Mandatory=$true, ParameterSetName="Traceroute")]
        [Alias("t")]
        [string]$AddressTraceroute,

        [Parameter(Mandatory=$true, ParameterSetName="Detailed")]
        [Alias("d")]
        [string]$AddressDetailed,

        [Parameter(ParameterSetName="Detailed")]
        [int]$Port,

        [Parameter(Mandatory=$true, ParameterSetName="SMTP")]
        [Alias("s")]
        [switch]$SMTPTest,

        [Parameter(Mandatory=$true, ParameterSetName="Whois")]
        [Alias("w")]
        [string]$DomainWhois,

        [Parameter(Mandatory=$true, ParameterSetName="ExchangeDisconnect")]
        [Alias("x")]
        [switch]$ExchangeDisconnect,

        [Parameter(Mandatory=$true, ParameterSetName="Admin")]
        [Alias("a")]
        [string]$AdminEmail
    )

    switch ($PSCmdlet.ParameterSetName) {
        "Ping" {
            Write-Host "Starting continuous ping to $AddressPing..."
            Test-Connection -ComputerName $AddressPing -Continuous
        }
        "Traceroute" {
            Write-Host "Running traceroute to $AddressTraceroute..."
            Test-NetConnection -ComputerName $AddressTraceroute -TraceRoute
        }
        "Detailed" {
            if ($Port) {
                Write-Host "Running detailed network test to $AddressDetailed on port $Port..."
                Test-NetConnection -ComputerName $AddressDetailed -Port $Port -InformationLevel Detailed
            } else {
                Write-Host "Running detailed network test to $AddressDetailed..."
                Test-NetConnection -ComputerName $AddressDetailed -InformationLevel Detailed
            }
        }
        "SMTP" {
            Write-Host "Starting SMTP test..."
            smtp
        }
        "Whois" {
            who $DomainWhois
        }
        "ExchangeDisconnect" {
            Write-Host "Disconnecting Exchange Online..."
            exchd
        }
        "Admin" {
            Write-Host "Launching admin console for $AdminEmail..."
            admin $AdminEmail
        }
    }
}

# Lazy SMTP test
function smtp {
    $SMTPServer = Read-Host "SERVER"
    $Source = Read-Host "FROM"
    $Destination = Read-Host "TO"
    $Port = Read-Host "PORT"

    Send-MailMessage -SMTPServer $SMTPServer -Port $Port -To $Destination -From $Source -Subject "This is a test email" -Body "Hi, this is a test email sent to test SMTP server - KL" -WarningAction Ignore
}

# Lazy Exchange shell disconnect
function exchd {
    Disconnect-ExchangeOnline
}

# Lazy Whois query for domain
function who ($domain) {
    Write-Host "`nFetching WHOIS information for: $domain" -ForegroundColor Cyan

    try {
        Write-Host "`nFetching WHOIS details from API..." -ForegroundColor Cyan
        $whoisInfo = Invoke-RestMethod -Uri "https://rdap.org/domain/$domain" -ErrorAction Stop

        if ($whoisInfo) {
            Write-Host "`nDomain Information:" -ForegroundColor Green
            Write-Host "Domain Name: $($whoisInfo.handle)"
            Write-Host "Status: $($whoisInfo.status -join ', ')"
            Write-Host "Created: $($whoisInfo.events | Where-Object {$_.eventAction -eq 'registration'} | Select-Object -ExpandProperty eventDate -ErrorAction SilentlyContinue)"
            Write-Host "Expires: $($whoisInfo.events | Where-Object {$_.eventAction -eq 'expiration'} | Select-Object -ExpandProperty eventDate -ErrorAction SilentlyContinue)"
            
            # Extract and properly format name servers
            if ($whoisInfo.nameservers) {
                Write-Host "`nName Servers:`n" -ForegroundColor Magenta
                $whoisInfo.nameservers | ForEach-Object { Write-Host " - $($_.ldhName)" }
            } else {
                Write-Host "No Name Servers found." -ForegroundColor Yellow
            }

            # Extract and display registrar information correctly
            $registrar = $null
            if ($whoisInfo.entities) {
                foreach ($entity in $whoisInfo.entities) {
                    if ($entity.vcardArray -and $entity.vcardArray.Count -gt 1) {
                        $registrarEntry = $entity.vcardArray[1] | Where-Object { $_[0] -eq 'fn' }
                        if ($registrarEntry) {
                            $registrar = $registrarEntry[3]
                            break
                        }
                    }
                }
            }

            if ($registrar) {
                Write-Host "`nRegistrar Information:`n" -ForegroundColor Blue
                Write-Host "Registrar: $registrar`n"
            } else {
                Write-Host "Registrar information not available." -ForegroundColor Yellow
            }
        } else {
            Write-Host "No additional WHOIS data found via API." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "API lookup failed. WHOIS details may be incomplete." -ForegroundColor Red
    }
}


# Even lazier way to kill terminal
function ex {
    exit
}

# Lazy admin login
function admin ($email) {
    Write-Host "Logging in as: $email"
    $site = Read-Host "launch"

    switch ($site) {
        "1" { Connect-ExchangeOnline -UserPrincipalName $email }
        "2" { Connect-AzureAD -UserPrincipalName $email }
        default { exch($email) }
    }
}
