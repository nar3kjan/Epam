Param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $FilePath
)

$re  = '(?<=^[a-z]{1})\S*\s'
$txt = (Get-Culture).TextInfo
$csv = Import-Csv -Path $filePath
$map = $csv | Group-Object { $_.name -replace $re } -AsHashTable -AsString

$csv | ForEach-Object {
    $_.name = $txt.ToTitleCase($_.name)
    $userName = $_.name -replace $re
    # if there is only one user with the same constructed user name
    if($map[$userName].Count -eq 1) {
        # use their Name and Last Name only
        $_.email = $userName.ToLower() + "@abc.com"
        return $_
    }

    # else, use also their Location_Id
    $_.email = $userName.ToLower() + $_.location_id + "@abc.com"
    $_
} | Export-Csv -UseQuotes AsNeeded ./accounts_new.csv