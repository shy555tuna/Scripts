# PowerShell Utility Script

## Overview
This PowerShell script provides a set of functions for network diagnostics, email testing, administrative logins, and system management. The `run` function integrates multiple utilities into a single command-line interface, making it efficient for IT operations.

## Features
- **Network Diagnostics:** Ping, Traceroute, and detailed network tests.
- **SMTP Testing:** Send test emails to verify mail server connectivity.
- **Whois Lookup:** Quickly open domain WHOIS information in a web browser.
- **Exchange Management:** Disconnect from Exchange Online.
- **Admin Console Launcher:** Simplified login to Exchange and Azure environments.

## Usage
Run the script in PowerShell and use the following commands:

### Network Testing
| Description                | Command                    |
|----------------------------|----------------------------|
| Ping a host                | `run -p google.com`       |
| Traceroute to a host       | `run -t google.com`       |
| Detailed network test      | `run -d example.com -Port 443` |

### Email & Domain Tools
| Description                 | Command                    |
|-----------------------------|----------------------------|
| Run an SMTP test            | `run -s`                   |
| Check WHOIS info            | `run -w example.com`       |

### Admin & System Management
| Description                 | Command                    |
|-----------------------------|----------------------------|
| Disconnect Exchange Online  | `run -x`                   |
| Launch Admin Console        | `run -a "admin@example.com"` |

## Function Descriptions
### `run` (Main Function)
Handles various tasks based on parameters provided.

### `smtp`
Prompts for server details and sends a test email.

### `who`
Opens the WHOIS lookup page for a specified domain.

### `exchd`
Disconnects from Exchange Online.

### `admin`
Allows selection of login to Exchange or Azure.

## Setup Instructions
1. Copy the script into a PowerShell file (e.g., `script.ps1`).
2. Open PowerShell and navigate to the script directory.
3. Run `Set-ExecutionPolicy Unrestricted -Scope Process` to allow execution.
4. Execute commands as needed.

## Notes
- Requires administrator privileges for some functions.
- Ensure PowerShell 5.1+ is installed for compatibility.

## License
This script is provided "as is" without warranty. Use at your own risk.

