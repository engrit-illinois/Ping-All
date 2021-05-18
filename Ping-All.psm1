# Handy function to asynchronously ping all computers that match a wildcard name query
# Documentation home: https://github.com/engrit-illinois/Ping-All
# By mseng3
function Ping-All {
	param(
		[Parameter(Position=0,Mandatory=$true)]
		[string[]]$Computers,
		
		[string]$OUDN = "OU=Desktops,OU=Engineering,OU=Urbana,DC=ad,DC=uillinois,DC=edu",
		
		[int]$Count = 4,
		
		[int]$ThrottleLimit = 50,
		
		[switch]$Detailed
	)
	
	$comps = @()
	foreach($query in @($Computers)) {
		$thisQueryComps = (Get-ADComputer -Filter "name -like '$query'" -SearchBase $OUDN | Select Name).Name
		$comps += @($thisQueryComps)
	}
	
	if($comps) {
		
		$params = @{
			Count = $Count
			Quiet = $true
		}
		
		if($Detailed) {
			$params.Quiet = $false
		}
		
		# Powershell 7 has a simple -Parallel parameter for the ForEach-Object cmdlet
		if((Get-Host).Version.Major -ge 7) {
			$script = {
				$params = $using:params
				[PSCustomObject]@{
					TargetName = $_
					Success = (Test-Connection -TargetName $_ @params)
				}
			}
			$comps | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel $script
		}
		# Powershell 5.1 requires more code
		else {
			# Test-ConnectionAsync is a custom module by David Wyatt: https://gallery.technet.microsoft.com/scriptcenter/Multithreaded-PowerShell-0bc3f59b
			# You'll need to download and import it
					
			if(Get-Module -Name "Test-ConnectionAsync") {
				# Each line must be immediately sent to Format-Table (instead of saving to a variable first) to take advantage of the asynchronicity
				$comps | Test-ConnectionAsync @params | Format-Table -AutoSize
			}
			else {
				Write-Host "Test-ConnectionAsync module is not installed."
			}
		}
	}
	else {
		Write-Host "No matching AD computers found!"
	}
}