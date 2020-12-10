# Handy function to asynchronously ping all computers that match a wildcard name query
# Documentation home: https://github.com/engrit-illinois/Ping-All
# By mseng3
function global:Ping-All {
	param(
		[string]$Query,
		[int]$Count = 4,
		[switch]$Verbose
	)
	
	# Sorting likely won't have an actual effect because the pings are asynchrounous and responses are output as soon as they're received
	$comps = (Get-ADComputer -Filter { Name -like $query }).Name | Sort
	
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