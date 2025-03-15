# Handy function to asynchronously ping all computers that match a wildcard name query
# Documentation home: https://github.com/engrit-illinois/Ping-All
# By mseng3
function Ping-All {
	param(
		[Parameter(Position=0,Mandatory=$true)]
		[string[]]$Computers,
		
		[string]$AppendDomain,
		
		[switch]$AppendEwsDomain,
		[string]$EwsDomain = "ews.illinois.edu",
		
		[switch]$AppendCbtfDomain,
		[string]$CbtfDomain = "cbtf.illinois.edu",
		
		[string]$SearchBase,
		
		[int]$Count = 4,
		
		[int]$TimeoutSeconds,
		
		[ValidateScript({($_ -eq "4") -or ($_ -eq "6") -or ($_ -eq "Both")})]
		[string]$IpVersion = "Both",
		
		[switch]$PassThru,
		[switch]$Quiet,
		
		[int]$ThrottleLimit = 100
	)
	
	function log($msg) {
		if(-not $Quiet) {
			Write-Host $msg
		}
	}
	
	function Get-Comps {
		log "Building final list of names to ping..."
		$comps = @()
		$Computers | ForEach-Object {
			if($_ -like "*``**") {
				log "    Searching for AD computers matching `"$_`"..."
				$params = @{
					Filter = "name -like '$_'"
				}
				if($SearchBase) { $params.SearchBase = $SearchBase }
				$thisQueryComps = Get-ADComputer @params | Select -ExpandProperty "Name"
				if(-not $thisQueryComps) {
					log "        No matching AD computers found!"
				}
				else {
					if($AppendDomain) {
						$thisQueryComps = $thisQueryComps | ForEach-Object {
							"$($_).$($AppendDomain)"
						}
					}
					elseif($AppendEwsDomain) {
						$thisQueryComps = $thisQueryComps | ForEach-Object {
							"$($_).$($EwsDomain)"
						}
					}
					elseif($AppendCbtfDomain) {
						$thisQueryComps = $thisQueryComps | ForEach-Object {
							"$($_).$($CbtfDomain)"
						}
					}
					else {
					}
					$comps += @($thisQueryComps)
				}
			}
			else {
				$comps += $_
			}
		}
		
		if($comps) {
			$joinString = "`",`""
			$compsString = $comps -join $joinString
			log "    Computers: `"$compsString`"." -L 1
		}
		else { log "    Final list is empty!" -L 1 }
		
		$comps
	}
	
	function Get-Results($comps) {
		log "Pinging computers..."
		
		$params = @{
			Count = $Count
			ErrorAction = "Stop"
		}
		if($TimeoutSeconds) { $params.TimeoutSeconds = $TimeoutSeconds }
		
		# Powershell 7 has a simple -Parallel parameter for the ForEach-Object cmdlet
		if((Get-Host).Version.Major -ge 7) {
			$script = {
				function addm($property, $value, $object) {
					$object | Add-Member -NotePropertyName $property -NotePropertyValue $value
					$object
				}
				
				$params = $using:params
				$IpVersion = $using:IpVersion
				
				$results = [PSCustomObject]@{
					TargetName = $_
				}
				
				if(($IpVersion -eq "4") -or ($IpVersion -eq "Both")) {
					$err4 = "None"
					try {
						$result4 = Test-Connection -TargetName $_ -IPv4 @params
					}					
					catch {
						$err4 = $_.Exception.Message
					}
					$status4 = $result4 | Select -ExpandProperty "Status" 
					$ip4 = $result4 | Select -ExpandProperty "Address" | Select -ExpandProperty "IPAddressToString" | Select -First 1
					$result = addm "IPv4_IP" $ip4 $results
					$result = addm "IPv4_Status" $status4 $results
					$result = addm "IPv4_Error" $err4 $results
				}
				
				if(($IpVersion -eq "6") -or ($IpVersion -eq "Both")) {
					$err6 = "None"
					try {
						$result6 = Test-Connection -TargetName $_ -IPv6 @params
					}
					catch {
						$err6 = $_.Exception.Message
					}
					$status6 = $result6 | Select -ExpandProperty "Status" 
					$ip6 = $result6 | Select -ExpandProperty "Address" | Select -ExpandProperty "IPAddressToString" | Select -First 1
					$result = addm "IPv6_IP" $ip6 $results
					$result = addm "IPv6_Status" $status6 $results
					$result = addm "IPv6_Error" $err6 $results
				}
				
				$results
			}
			
			$comps | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel $script
		}
		# Powershell 5.1 requires more code
		else {
			# Test-ConnectionAsync is a custom module by David Wyatt: https://gallery.technet.microsoft.com/scriptcenter/Multithreaded-PowerShell-0bc3f59b
			# You'll need to download and import it
					
			if(Get-Module -Name "Test-ConnectionAsync") {
				$comps | Test-ConnectionAsync -Quiet @params
			}
			else {
				log "Test-ConnectionAsync module is not installed."
			}
		}
	}
	
	function Format-Results($results) {
		# Note: The Test-Connection cmdlet in v5.1 (used by Test-ConnectionAsync in this case) returns a "ComputerName" property, while later versions return a "TargetName" property.
		if((Get-Host).Version.Major -ge 7) {
			$results = $results | Sort TargetName
		}
		else {
			$results = $results | Sort ComputerName
		}		
		$results | Format-Table -AutoSize
	}
	
	function Do-Stuff {
		$comps = Get-Comps
		if($comps) {
			$results = Get-Results $comps
			if($PassThru) {
				$results
			}
			else {
				if(-not $Quiet) {
					Format-Results $results
				}
			}
		}
	}
	
	Do-Stuff
}