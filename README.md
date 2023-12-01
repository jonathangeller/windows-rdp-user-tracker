# User Activity Tracking Script

This PowerShell script is designed to track user activity on a Windows 10 / 11 system, specifically focusing on login and logoff/disconnect times during Remote Desktop sessions. It calculates the total active duration for each user per day and captures the first login and last logoff/disconnect times and outputs the result into a daily csv file.

## Installation

To use this script, you should have administrative access to the Windows 10 system where you want to track user activity.

1. **Download the Script**: 
   - Download the `UserActivityTracking.ps1` script from this repository.
   - Place the script in a suitable directory, for example, `C:\Scripts\`.

2. **Prerequisites**: 
   - Ensure PowerShell is installed on your system. This script is compatible with PowerShell 5.1 and later versions.

## Usage

To run the script manually:

1. Open PowerShell as an administrator.
2. Navigate to the directory where the script is located. 
   - Example: `cd C:\Scripts\`
3. Execute the script:
   - Example: `.\UserActivityTracking.ps1`

The script will generate a CSV file with user activity data for the current day. The CSV file includes each user's total active duration, first login time, and last logoff/disconnect time.

### Output Example

The script outputs a CSV file named `output-YYYY-MM-DD.csv`, where `YYYY-MM-DD` is the date of the report. The CSV file contains columns for:

- `Date`: The date of the activity.
- `User`: The username of the user.
- `Duration`: The total active duration in HH:MM:SS format.
- `FirstLogin`: The time of the first login on that day.
- `LastLogoff`: The time of the last logoff or disconnect on that day.

Example CSV output:
```CSV
"Date","User","Duration","FirstLogin","LastLogoff"
"2023-12-01","user1","01:47:58","2023-12-01 1:59:18 PM","2023-12-01 5:38:40 PM"
"2023-12-01","user2","02:45:25","2023-12-01 11:08:21 AM","2023-12-01 1:53:45 PM"
```

### Parameters

The script accepts an optional date parameter in the `YYYY-MM-DD` format. If provided, the script generates the user activity report for the specified date. If not provided, it defaults to the current date.

Example usage with a date parameter:

```powershell
.\UserActivityTracking.ps1 2023-12-01
```

> **Disclaimer:**  
> Each time the script is run, it overwrites any previously generated files for the same date. Ensure to backup or rename files if you need to retain data for multiple runs on the same day.
> 
### Additional Instructions

Before running the script, ensure you have the necessary permissions and your system's execution policy allows running PowerShell scripts.

If you encounter an error related to script execution policies (such as "cannot be loaded because running scripts is disabled on this system"), you may need to change the execution policy. 

#### Changing the Execution Policy

1. **Open PowerShell as an Administrator**:
   - Right-click on the Start button and select "Windows PowerShell (Admin)".

2. **Check the Current Execution Policy**:
   - Run the following command to see your current policy:
     ```powershell
     Get-ExecutionPolicy
     ```

3. **Set the Execution Policy to Allow the Script**:
   - To temporarily allow the execution of PowerShell scripts, you can set the policy to `Unrestricted` or `RemoteSigned`. For example:
     ```powershell
     Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
     ```
   - This will allow the execution of scripts that are either locally created or signed by a trusted publisher.

4. **Revert Back to the Original Policy** (optional but recommended):
   - After running the script, you can revert to your original policy for security reasons:
     ```powershell
     Set-ExecutionPolicy -ExecutionPolicy [YourOriginalPolicy] -Scope CurrentUser
     ```
   - Replace `[YourOriginalPolicy]` with the policy noted in step 2.

> **Note:**    
> Changing the execution policy might affect your system's security. Always ensure that the scripts you are running are from a trusted source.

## Auto Scheduling

For automated daily tracking, you can schedule this script to run every night using Windows Task Scheduler.

1. **Open Task Scheduler**:
   - Search for "Task Scheduler" in the Start menu and open it.

2. **Create a New Task**:
   - In Task Scheduler, go to `Action > Create Task`.
   - Name the task (e.g., "Daily User Activity Report").

3. **Set the Trigger**:
   - Go to the `Triggers` tab and click `New`.
   - Set the task to begin `On a schedule`, and choose `Daily`.
   - Set the start time to when you want the script to run (e.g., 11:00 PM).

4. **Set the Action**:
   - Go to the `Actions` tab and click `New`.
   - Set `Action` to `Start a program`.
   - In `Program/script`, enter `powershell.exe`.
   - In `Add arguments`, enter `-File "C:\Scripts\UserActivityTracking.ps1"`.
   - In `Start in`, enter the folder where your script is located (e.g., `C:\Scripts\`).

5. **Configure Other Settings**:
   - Under the `Conditions` and `Settings` tabs, configure as per your requirements.

6. **Save the Task**: 
   - Click `OK` to save and enable the task.

The script will now run automatically at the scheduled time each day, providing a CSV file with the day's user activity.

## Contributions

Contributions to this script are welcome. Please fork the repository and submit a pull request with your enhancements.

## Support

For support or to report issues, please file an issue on the GitHub repository.

## License

This project is open source and available under the [MIT License](LICENSE).

---

MIT License

Copyright (c) 2023 Jonathan B Geller

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

