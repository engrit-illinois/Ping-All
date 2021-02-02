# Overview
Ping-All is a PowerShell module to allow you to ping multiple computers with a single command, asynchronously. This is useful when checking multiple similarly-named computers (e.g. computers located in the same lab) as a quick check to see what's online and responding to ping. The asynchronous nature of the command also makes this run quickly, not allowing unresponsive computers to hold up pinging other computers in the list.

# Setup and Requirements
`Test-ConnectionAsync.psm1` is a prerequisite to `Ping-All.psm1`. Both of these are also built as PowerShell modules, so they must be imported before use.

Open a PowerShell window and navigate to the location where these modules are stored, then run the following:
```
Import-Module .\Test-ConnectionAsync.psm1
Import-Module .\Ping-All.psm1
```

# Usage
`Ping-All [[-Query] <string>] [[-Count] <int>] [-Verbose]`

## Examples
### Example 1
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
ECEB-4022...   False
```

### Example 2
A more detailed command, where we ping the same computers in Example 1, but also do it twice and add the Verbose flag
```
Ping-All -Query "eceb-4022-*" -Count 2 -Verbose

Source        Destination     IPV4Address      IPV6Address                              Bytes    Time(ms)
------        -----------     -----------      -----------                              -----    --------
MRL-270-44    ECEB-4022-02    128.174.187.193                                           32       0
MRL-270-44    ECEB-4022-02    128.174.187.193                                           32       0
MRL-270-44    ECEB-4022-03    128.174.187.194                                           32       0
MRL-270-44    ECEB-4022-03    128.174.187.194                                           32       1
MRL-270-44    ECEB-4022-04    128.174.187.195                                           32       0
MRL-270-44    ECEB-4022-04    128.174.187.195                                           32       1
MRL-270-44    ECEB-4022-05    128.174.187.196                                           32       0
MRL-270-44    ECEB-4022-05    128.174.187.196                                           32       1
MRL-270-44    ECEB-4022-06    128.174.187.197                                           32       1
MRL-270-44    ECEB-4022-06    128.174.187.197                                           32       1
MRL-270-44    ECEB-4022-07    128.174.187.198                                           32       0
MRL-270-44    ECEB-4022-07    128.174.187.198                                           32       1
MRL-270-44    ECEB-4022-08    128.174.187.199                                           32       1
MRL-270-44    ECEB-4022-08    128.174.187.199                                           32       0
MRL-270-44    ECEB-4022-09    128.174.187.200                                           32       1
MRL-270-44    ECEB-4022-09    128.174.187.200                                           32       0
MRL-270-44    ECEB-4022-10    128.174.187.201                                           32       1
MRL-270-44    ECEB-4022-10    128.174.187.201                                           32       1
MRL-270-44    ECEB-4022-11    128.174.187.202                                           32       0
MRL-270-44    ECEB-4022-11    128.174.187.202                                           32       0
MRL-270-44    ECEB-4022-12    128.174.187.203                                           32       1
MRL-270-44    ECEB-4022-12    128.174.187.203                                           32       1
MRL-270-44    ECEB-4022-13    128.174.187.204                                           32       0
MRL-270-44    ECEB-4022-13    128.174.187.204                                           32       0
MRL-270-44    ECEB-4022-14    128.174.187.205                                           32       1
MRL-270-44    ECEB-4022-14    128.174.187.205                                           32       0
MRL-270-44    ECEB-4022-15    128.174.187.206                                           32       0
MRL-270-44    ECEB-4022-15    128.174.187.206                                           32       0
MRL-270-44    ECEB-4022-16    128.174.187.207                                           32       2
MRL-270-44    ECEB-4022-16    128.174.187.207                                           32       1
MRL-270-44    ECEB-4022-01    128.174.187.192                                           32
MRL-270-44    ECEB-4022-01    128.174.187.192                                           32
MRL-270-44    ECEB-4022-DS01  130.126.29.84                                             32
MRL-270-44    ECEB-4022-DS01  130.126.29.84                                             32
```

# Notes
- By mseng3. See my other projects here: https://github.com/mmseng/code-compendium.
- Test-ConnectionAsync by David Wyatt: https://gallery.technet.microsoft.com/scriptcenter/Multithreaded-PowerShell-0bc3f59b
