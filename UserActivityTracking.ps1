<#
    UserActivityTracking.ps1

    Description:
    A PowerShell script to track user activity on a Windows 10 / 11 system,
    focusing on login and logout times during Remote Desktop sessions.

    License:
    This script is released under the MIT License. See the LICENSE file in the
    repository root for full license text.

    Disclaimer:
    This script is provided "as is", without warranty of any kind. Use at
    your own risk. The author is not responsible for any damages or issues
    that arise from using this script.

#>

param (
    [string]$dateParam = (Get-Date).ToString("yyyy-MM-dd")
)

# Convert the date parameter to a DateTime object
$targetDate = [DateTime]::ParseExact($dateParam, "yyyy-MM-dd", $null)

# Define the CSV file path with the specified or current date
$csvFilePath = "C:\path\to\output-$dateParam.csv"

# Define the start and end times for the target date
$startTime = $targetDate.Date
$currentTime = Get-Date
$endTime = $targetDate.Date.AddDays(1) # End of the target date

# Function to safely get events and handle cases where no events are found
function SafeGet-WinEvent {
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$FilterHashtable,
        [int]$MaxEvents = 1000
    )

    try {
        $events = Get-WinEvent -FilterHashtable $FilterHashtable -MaxEvents $MaxEvents -ErrorAction Stop
    } catch {
        $events = @() # Return an empty array if no events are found
    }

    return $events
}

# Get logon, logoff, disconnect, and reconnect events for the target date, using the safe function
$logonEvents = SafeGet-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational';ID=21;StartTime=$startTime;EndTime=$endTime}
$logoffAndDisconnectEvents = SafeGet-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational';ID=23,24,25,40;StartTime=$startTime;EndTime=$endTime}

# Convert events to custom objects with necessary properties
function ConvertTo-CustomObject {
    param ($Event)

    $user = 'Unknown'
    if ($Event.Message -match 'User:\s+([^\r\n]+)') {
        $user = $matches[1].Split('\')[-1]
    }

    @{
        TimeCreated = $Event.TimeCreated
        SessionID = $Event.Properties[1].Value
        User = $user.Trim()
        Date = $Event.TimeCreated.Date
    }
}

$logonObjects = $logonEvents | ForEach-Object { ConvertTo-CustomObject -Event $_ }
$logoffObjects = $logoffAndDisconnectEvents | ForEach-Object { ConvertTo-CustomObject -Event $_ }

# Initialize a hashtable to accumulate session durations and track first and last event times
$userActivityPerDay = @{}

foreach ($logon in $logonObjects) {
    $key = "$($logon.Date.ToString('yyyy-MM-dd'))-$($logon.User)"

    # Initialize user's daily record if it doesn't exist
    if (!$userActivityPerDay.ContainsKey($key)) {
        $userActivityPerDay[$key] = @{
            TotalDuration = 0
            FirstLogin = $logon.TimeCreated
            LastLogoff = $null
        }
    }

    # Update the first login time if the current logon is earlier
    if ($logon.TimeCreated -lt $userActivityPerDay[$key].FirstLogin) {
        $userActivityPerDay[$key].FirstLogin = $logon.TimeCreated
    }

    # Find the corresponding logoff or disconnect event
    $logoff = $logoffObjects | Where-Object { $_.SessionID -eq $logon.SessionID -and $_.TimeCreated -gt $logon.TimeCreated -and $_.TimeCreated -lt $currentTime } | Sort-Object TimeCreated | Select-Object -First 1

    if ($logoff) {
        # Calculate the session duration
        $durationSeconds = ($logoff.TimeCreated - $logon.TimeCreated).TotalSeconds
        $userActivityPerDay[$key].TotalDuration += $durationSeconds

        # Update the last logoff time if the current logoff is later
        if (-not $userActivityPerDay[$key].LastLogoff -or $logoff.TimeCreated -gt $userActivityPerDay[$key].LastLogoff) {
            $userActivityPerDay[$key].LastLogoff = $logoff.TimeCreated
        }
    } elseif (-not $userActivityPerDay[$key].LastLogoff) {
        # If there's no logoff event yet, and this is the latest login, update the last logoff to the current time
        $userActivityPerDay[$key].LastLogoff = $currentTime
    }
}

# Helper function to convert seconds to HH:MM:SS format
function ConvertTo-HHMMSS {
    param ([int]$TotalSeconds)

    $hours = [math]::Floor($TotalSeconds / 3600)
    $minutes = [math]::Floor(($TotalSeconds % 3600) / 60)
    $seconds = $TotalSeconds % 60

    return "{0:00}:{1:00}:{2:00}" -f $hours, $minutes, $seconds
}

# Convert the hashtable to a CSV-friendly format
$sessionData = foreach ($key in $userActivityPerDay.Keys) {
    $splitKey = $key -split '-'
    $date = $splitKey[0..2] -join '-'
    $user = $splitKey[3]
    $activity = $userActivityPerDay[$key]

    [PSCustomObject]@{
        Date = $date
        User = $user
        Duration = ConvertTo-HHMMSS -TotalSeconds $activity.TotalDuration
        FirstLogin = $activity.FirstLogin
        LastLogoff = $activity.LastLogoff
    }
}

# Export the session data to a CSV file
$sessionData | Export-Csv -Path $csvFilePath -NoTypeInformation
