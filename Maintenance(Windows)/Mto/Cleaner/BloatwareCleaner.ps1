#Elimina las aplicaciones preinstaladas
Clear-Host
Write-Host "Desinstalando aplicaciones preinstaladas..."

$WhiteList = @(
    '*WindowsCalculator*',
    '*Microsoft.net*',
    '*WindowsTerminal*',
    '*WindowsNotepad*',
    '*Paint*'
)
$Packages = Get-AppxPackage

ForEach($Dependency in $WhiteList){
    (Get-AppxPackage  -Name "$Dependency").dependencies | ForEach-Object{
        $NewAdd = "*" + $_.Name + "*"
        if($_.name -ne $null -and $WhiteList -notcontains $NewAdd){
            $WhiteList += $NewAdd
       }
    }
}

ForEach($App in $Packages){
    $Matched = $false
    Foreach($Item in $WhiteList){
        If($App -like $Item){
            $Matched = $true
            break
        }
    }
    
    if($matched -eq $false -and $app.NonRemovable -eq $false){
        Get-AppxPackage -AllUsers -Name $App.Name -PackageTypeFilter Bundle  | Remove-AppxPackage -AllUsers
   }
}
Get-AppxPackage -allusers Microsoft.WindowsStore | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"} 2>$null
Write-Host "Se han eliminado todas las aplicaciones preinstaladas." -ForegroundColor Green
Read-Host -Prompt "Presiona Enter para Continuar"
