# Handy function to asynchronously ping all computers that match a wildcard name query
# Documentation home: https://github.com/engrit-illinois/Ping-All
# By mseng3
function global:Ping-All {
	param(
		[Parameter(Position=0,Mandatory=$true)]
		[string]$Computers,
		
		[string]$OUDN = "OU=Desktops,OU=Engineering,OU=Urbana,DC=ad,DC=uillinois,DC=edu",
		
		[int]$Count = 4,
		
		[switch]$Verbose
	)
	
	$comps = @()
	foreach($query in @($Computers)) {
		$thisQueryComps = (Get-ADComputer -Filter "name -like '$query'" -SearchBase $OUDN | Select Name).Name
		$comp += @($thisQueryComps)
	}
	
	# Test-ConnectionAsync is a custom module by David Wyatt: https://gallery.technet.microsoft.com/scriptcenter/Multithreaded-PowerShell-0bc3f59b
	# You'll need to download it and customize the path below
	#Import-Module -Name ".\Test-ConnectionAsync.psm1" -Force
	
	if(Get-Module -Name "Test-ConnectionAsync") {
		# Each line must be immediately sent to Format-Table (instead of saving to a variable first) to take advantage of the asynchronicity
		if($Verbose) {
			$comps | Test-ConnectionAsync -Count $count | Format-Table
		}
		else {
			$comps | Test-ConnectionAsync -Count $count -Quiet | Format-Table
		}
	}
	else {
		Write-Host "Test-ConnectionAsync module is not installed."
	}
}