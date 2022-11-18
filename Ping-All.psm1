# Handy function to asynchronously ping all computers that match a wildcard name query
# Documentation home: https://github.com/engrit-illinois/Ping-All
# By mseng3
function Ping-All {
	param(
		[Parameter(Position=0,Mandatory=$true)]
		[string[]]$Computers,
		
		[string]$OUDN = "OU=Desktops,OU=Engineering,OU=Urbana,DC=ad,DC=uillinois,DC=edu",
		
		[int]$Count = 4,
		
		[int]$ThrottleLimit = 100,
		
		[switch]$Format
	)
	
	function log($msg) {
		Write-Host $msg
	}
	
	function Get-Comps {
		$comps = @()
		foreach($query in @($Computers)) {
			$thisQueryComps = (Get-ADComputer -Filter "name -like '$query'" -SearchBase $OUDN | Select Name).Name
			$comps += @($thisQueryComps)
		}
		$comps
	}
	
	function Get-Results($comps) {			
		$params = @{
			Count = $Count
		}
		
		# Powershell 7 has a simple -Parallel parameter for the ForEach-Object cmdlet
		if((Get-Host).Version.Major -ge 7) {
			$script = {
				$params = $using:params
				
				try {
					$result = Test-Connection -TargetName $_ @params -ErrorAction "Stop"
					$status = $result | Select -ExpandProperty "Status" 
					$ip = $result | Select -ExpandProperty "Address" | Select -ExpandProperty "IPAddressToString" | Select -First 1
					$err = "None"
				}
				catch {
					$err = $_.Exception.Message
				}
				
				[PSCustomObject]@{
					TargetName = $_
					Status = $status
					Ip = $ip
					Error = $err
				}
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
			if($Format) {
				$results = Get-Results $comps
				if($results) {
					Format-Results $results
				}
				else {
					log "No results were returned!"
				}
			}
			else {
				Get-Results $comps
			}
		}
		else {
			log "No matching AD computers found!"
		}
	}
	
	Do-Stuff
}