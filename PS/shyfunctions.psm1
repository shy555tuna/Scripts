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
            Write-Host "Opening Whois lookup for $DomainWhois..."
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
    Write-Host "`nFetching WHOIS information for: $domain`n" -ForegroundColor Cyan

    # Check if whois command is available
    if (Get-Command whois -ErrorAction SilentlyContinue) {
        $whoisOutput = whois $domain
        if ($whoisOutput) {
            Write-Host "`nWHOIS Information:`n" -ForegroundColor Green
            $whoisOutput -split "`r?`n" | ForEach-Object { Write-Host $_ }
        } else {
            Write-Host "No WHOIS information found for $domain." -ForegroundColor Yellow
        }
    } else {
        Write-Host "`nThe 'whois' command is not installed. Attempting nslookup...`n" -ForegroundColor Yellow
        $nslookupOutput = nslookup $domain
        $nslookupOutput -split "`r?`n" | ForEach-Object { Write-Host $_ }
    }

    # Optional: Use API fallback for richer data
    try {
        Write-Host "`nFetching WHOIS details from API..." -ForegroundColor Cyan
        $whoisInfo = Invoke-RestMethod -Uri "https://rdap.org/domain/$domain" -ErrorAction Stop

        if ($whoisInfo) {
            Write-Host "`nDomain Information:`n" -ForegroundColor Green
            Write-Host "Domain Name: $($whoisInfo.handle)"
            Write-Host "Status: $($whoisInfo.status -join ', ')"
            Write-Host "Created: $($whoisInfo.events | Where-Object {$_.eventAction -eq 'registration'} | Select-Object -ExpandProperty eventDate)"
            Write-Host "Expires: $($whoisInfo.events | Where-Object {$_.eventAction -eq 'expiration'} | Select-Object -ExpandProperty eventDate)"
            
            Write-Host "`nName Servers:`n" -ForegroundColor Magenta
            $whoisInfo.nameservers | ForEach-Object { Write-Host " - $_.ldhName" }

            Write-Host "`nRegistrar Information:`n" -ForegroundColor Blue
            Write-Host "Registrar: $($whoisInfo.entities[0].vcardArray[1][3][3])"
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
