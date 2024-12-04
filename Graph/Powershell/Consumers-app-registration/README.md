# Consumers App Registration Script

This PowerShell script maps the consumers of an application registration in Microsoft Graph.

## Prerequisites

- PowerShell 5.1 or later
- Microsoft Graph PowerShell SDK

## Installation

1. Install the Microsoft Graph PowerShell SDK if you haven't already:

    ```powershell
    Install-Module Microsoft.Graph -Scope CurrentUser
    ```

## Usage

1. Open a PowerShell terminal.
2. Navigate to the directory containing the 

consumers-app-registration.ps1

 script.
3. Run the script with the required `TargetAppId` parameter:

    ```powershell
    .\consumers-app-registration.ps1 -TargetAppId <YourAppId>
    ```

    Replace `<YourAppId>` with the client ID of the app registration you are interested in.

## Parameters

- `TargetAppId` (Mandatory): The client ID of the app registration you are interested in.

## Example

```powershell
.\consumers-app-registration.ps1 -TargetAppId "12345678-90ab-cdef-1234-567890abcdef"
```

## Output

The script will output the display name and app ID of the target app registration, followed by the display names and app IDs of the filtered app registrations that use the target app.

## License

This project is licensed under the MIT License - see the 

LICENSE

 file for details.