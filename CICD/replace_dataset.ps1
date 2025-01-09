param($source_path, $input_dataset)

function ReplaceInPlace {
    param (
        [string]$filePath,
        [string]$from,
        [string]$to
    )

    (Get-Content $filePath) | Foreach-Object {$_ -replace [Regex]::Escape($from), $to}  | Set-Content $filePath  
}

$allfiles = Get-ChildItem -Path $source_path -Recurse


Write-Host $allfiles

$jsonFiles = Get-ChildItem -Path "$source_path" -Filter *.json -Recurse
""
"Replace input prameters in JSON files:"
$con = Get-Content -Path $input_dataset | ConvertFrom-Json
$jsonFiles | ForEach-Object {
    $file = $_.FullName
    Write-Host $_.FullName

    if($con -eq $null) {
        Throw('Please, provide valid json file with configurations')
    }
    for($i=0; $i -le $con.length-1; $i++) {
        $site = $con[$i]

  
        if($site.data_sources -eq $null){
            Throw('Please, provide data_sources object list to change')
        }
        for ($n= 0; $n -le $site.data_sources.Count -1; $n++){
            $list = $site.data_sources[$n]

            if ($list.id_from -eq $null -or $list.id_to -eq $null) {
                Throw("Please, provide data source id to change for object list[$($n)]: id_from and id_to")
            }
            ReplaceInPlace $file $list.id_from $list.id_to
        }
    }
}

