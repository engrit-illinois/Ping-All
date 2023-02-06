# Overview
Ping-All is a PowerShell module to allow you to ping multiple computers with a single command, asynchronously. This is useful when checking multiple similarly-named computers (e.g. computers located in the same lab) as a quick check to see what's online and responding to ping.  

This module is primarily targeted at PowerShell v7. Support for 5.1 is minimal and may be removed in the future.  

# Usage
1. Download `Ping-All.psm1` to the appropriate subdirectory of your PowerShell [modules directory](https://github.com/engrit-illinois/how-to-install-a-custom-powershell-module).
2. If using Powershell older than v7, then also download [Test-ConnectionAsync.psm1](https://www.powershellgallery.com/packages/TestConnectionAsync/1.0.0.1) to the appropriate subdirectory of your PowerShell [modules directory](https://github.com/engrit-illinois/how-to-install-a-custom-powershell-module).
    - Test-ConnectionAsync is by David Wyatt. Use the link above to download from the original source. A copy is kept in this repo in case it becomes unavailable.
3. Run it, e.g.: `Ping-All -Computers "mel-1001-*","mel-1009-01.ews.illinois.edu"`

# Examples

Ping multiple sequentially-named FQDNs:
```powershell
$lab = "ECEB-9999"
$nums = @(1..30)
$comps = $nums | ForEach-Object {
    $num = ([string]$_).PadLeft(2,"0")
    "$lab-$num"
}
Ping-All $comps
```

# Parameters

### -Computers \<string[]\>
Required string array of FQDNs, AD computer names, and/or wildcard AD computer name queries.  
Any strings including `*` will be treated as a wildcard query for AD computer names.  
Any string _not_ including `*` will be pinged as-given.  

### -AppendDomain \<string\>
Optional string.  
Specifies a domain/subdomain to append to all AD-queried names.  
AD names and FQDNs given explicitly are not appended to.  
e.g. `Ping-All -Computers "gelib-4c-*" -AppendDomain "ews.illinois.edu"  

### -OUDN \<string\>
Optional string.  
The distinguished name of the OU to limit the computer name search.  
Default is `OU=Desktops,OU=Engineering,OU=Urbana,DC=ad,DC=uillinois,DC=edu`.  

### -Count \<int\>
Optional integer.  
The number of times to ping machines.  
Machines which respond to at least one ping will be considered a success.  
Default is `4`.  

### -IpVersion \<int\>
Optional integer.  
The version IP protocol version to use.  
Valid values are `4` and `6`.  
Default is `4`.  
Only supported on Powershell 7+. Earlier versions ignore this parameter, due to the use of the custom `Test-ConnectionAsync` module. So behavior will be different in Powershell 5.1. I can't be bothered to account for this and make `Ping-All` behave the same for both Powershell versions, as I really only care about Powershell 7 compatibility at this point. If you really want to know how `Test-ConnectionAsync` will behave you can look at its code. Otherwise just use Powershell 7. From what I can tell `Test-ConnectionAsync` tests both IPv4 and IPv6 (if available).  

### -ThrottleLimit \<int\>
Optional integer.  
Only relevant when using Powershell 7+.  
The maximum number of async calls to make simultaneously.  
Default is `100`.  

### -PassThru
Optional switch.  
By default the module returns a formatted table of the results after pinging all of the computers.  
When `-PassThru` is specified, the raw, unformatted results are returned, and will likely be in `List` format.  

## Example
A simple request to ping all computers with names starting with a certain string of characters
```
> Ping-All dcl-l426-*

TargetName  IPv4_IP        IPv4_Status                              IPv4_Error IPv6_IP                             IPv6_Status                                                                                                      IPv6_Error
----------  -------        -----------                              ---------- -------                             -----------                                                                                                      ----------
DCL-L426-01 130.126.246.2  {Success, Success, Success, Success}     None       2620:0:e00:550f:aeba:f341:6b8f:a41f {Success, Success, Success, Success}                                                                             None
DCL-L426-02 130.126.246.3  {Success, Success, Success, Success}     None       2620:0:e00:550f:c00a:cb8a:4330:26cf {Success, Success, Success, Success}                                                                             None
DCL-L426-03 130.126.246.4  {Success, Success, Success, Success}     None       2620:0:e00:550f:6ded:2681:376c:2348 {Success, Success, Success, Success}                                                                             None
DCL-L426-04                {TimedOut, TimedOut, TimedOut, TimedOut} None                                           {DestinationHostUnreachable, DestinationHostUnreachable, DestinationHostUnreachable, DestinationHostUnreachable} None
DCL-L426-05                {TimedOut, TimedOut, TimedOut, TimedOut} None                                           {DestinationHostUnreachable, DestinationHostUnreachable, DestinationHostUnreachable, DestinationHostUnreachable} None
DCL-L426-06 130.126.246.7  {Success, Success, Success, Success}     None       2620:0:e00:550f:2575:8fb:35a7:39a4  {Success, Success, Success, Success}                                                                             None
DCL-L426-07 130.126.246.8  {Success, Success, Success, Success}     None       2620:0:e00:550f:7a16:74cc:2cdf:7b0e {Success, Success, Success, Success}                                                                             None
DCL-L426-08 130.126.246.9  {Success, Success, Success, Success}     None       2620:0:e00:550f:1a85:4472:8d5d:c92a {Success, Success, Success, Success}                                                                             None
DCL-L426-09 130.126.246.10 {Success, Success, Success, Success}     None       2620:0:e00:550f:f9a8:6fdc:f911:9528 {Success, Success, Success, Success}                                                                             None
DCL-L426-10 130.126.246.11 {Success, Success, Success, Success}     None       2620:0:e00:550f:7da2:7a9d:1ba4:567d {Success, Success, Success, Success}                                                                             None
DCL-L426-11 130.126.246.13 {Success, Success, Success, Success}     None       2620:0:e00:550f:37cb:8c56:b742:a8aa {Success, Success, Success, Success}                                                                             None
```

# Notes
- By mseng3. See my other projects here: https://github.com/mmseng/code-compendium.
- Test-ConnectionAsync by David Wyatt:
  - Originally at: https://gallery.technet.microsoft.com/scriptcenter/Multithreaded-PowerShell-0bc3f59b
  - More recently found at: https://www.powershellgallery.com/packages/TestConnectionAsync/1.0.0.1
- If using PowerShell versions older than 7, the computer name property of the returned object is named `ComputerName`. In version 7 or later is is named `TargetName`. This is just how the underlying `Test-Connection` cmdlet works in these versions.
