# Overview
Ping-All is a PowerShell module to allow you to ping multiple computers with a single command, asynchronously. This is useful when checking multiple similarly-named computers (e.g. computers located in the same lab) as a quick check to see what's online and responding to ping. The asynchronous nature of the command also makes this run quickly, not allowing unresponsive computers to hold up pinging other computers in the list.

# Usage
1. Download `Ping-All.psm1` to `$HOME\Documents\WindowsPowerShell\Modules\Ping-All\Ping-All.psm1`.
2. If using Powershell older than v7, then also download [Test-ConnectionAsync.psm1](https://www.powershellgallery.com/packages/TestConnectionAsync/1.0.0.1) to `$HOME\Documents\WindowsPowerShell\Modules\Test-ConnectionAsync\Test-ConnectionAsync.psm1`.
    - Test-ConnectionAsync is by David Wyatt. Use the link above to download from the original source. A copy is kept in this repo in case it becomes unavailable.
3. Run it, e.g.: `Ping-All -Computers "mel-1001-*","mel-1009-01"`

# Parameters

### -Computers
Required string array of computer names or wildcard computer name queries.  

### -OUDN
Optional string.  
The distinguished name of the OU to limit the computer name search.  
Default is `OU=Desktops,OU=Engineering,OU=Urbana,DC=ad,DC=uillinois,DC=edu`.  

### -Count
Optional integer.  
The number of times to ping machines.  
Machines which respond to at least one ping will be considered a success.  
Default is `4`.  

### -ThrottleLimit
Optional integer.  
Only relevant when using Powershell 7 or greater.  
The maximum number of async calls to make simultaneously.  
Default is `100`.  

### -Format
Optional switch.  
The default behavior is to allow the parallelized pipeline to return the results as they are received. This populates the table returned in real time, which may be desirable, but which will likely cause the results to be returned out of alphanumeric order, and names later in the list may be truncated, if they are longer than the first name returned.  
Specifying `-Format` causes all of the output to be captured, sorted by the computer name, and the table columns auto-sized (to avoid the truncation issue). The downside of this is that it must wait for all results to be received before doing this, so the "real-time" nature is somewhat diminished. As a result you won't get any results until all pings are complete, which may take a while if some of the machines don't respond.  

## Example
A simple request to ping all computers with names starting with a certain string of characters
```
Ping-All "eceb-4022-*"

ComputerName Success
------------ -------
ECEB-4022-01    True
ECEB-4022-02    True
ECEB-4022-03    True
ECEB-4022-04    True
ECEB-4022-05    True
ECEB-4022-06    True
ECEB-4022-07    True
ECEB-4022-08    True
ECEB-4022-09    True
ECEB-4022-10    True
ECEB-4022-11    True
ECEB-4022-12    True
ECEB-4022-13    True
ECEB-4022-14    True
ECEB-4022-15    True
ECEB-4022-16    True
ECEB-4022-17   False
```

# Notes
- By mseng3. See my other projects here: https://github.com/mmseng/code-compendium.
- Test-ConnectionAsync by David Wyatt:
  - Originally at: https://gallery.technet.microsoft.com/scriptcenter/Multithreaded-PowerShell-0bc3f59b
  - More recently found at: https://www.powershellgallery.com/packages/TestConnectionAsync/1.0.0.1
- If using PowerShell versions older than 7, the computer name property of the returned object is named `ComputerName`. In version 7 or later is is named `TargetName`. This is just how the underlying `Test-Connection` cmdlet works in these versions.
