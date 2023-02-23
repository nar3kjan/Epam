param (
    [parameter(Mandatory = $true, Position = 0)]
    [Net.IPAddress]
    $ip_address_1,
     
    [parameter(Mandatory = $true, Position = 1)]
    [Net.IPAddress]
    $ip_address_2,
     
    [parameter(Mandatory = $true, Position = 2)]
    [alias("SubnetMask")]
    [Net.IPAddress]
    $network_mask
)
     
if (($ip_address_1.address -band $network_mask.address) -eq ($ip_address_2.address -band $network_mask.address)) { Write-Output "Yes" } else { Write-Output "No" }