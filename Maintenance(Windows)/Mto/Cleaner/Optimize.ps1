Clear-Host
$BasePathOP = (Get-Location).Path
#Activar modo rendimiento
Start-Process "SystemPropertiesPerformance.exe"

#Desactiva el widget de Intereses y clima
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"
Set-ItemProperty -Path $regPath -Name "ShellFeedsTaskbarViewMode" -Value 2
Stop-Process -Name explorer -Force
Start-Process explorer


$registryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"  
)
foreach ($path in $registryPaths) {
    $apps = Get-ItemProperty -Path $path
    $apps.PSObject.Properties | ForEach-Object {
    $appName = $_.Name
    if ($appName -ne "PSPath" -and $appName -ne "PSParentPath" -and $appName -ne "PSChildName" -and $appName -ne "PSDrive" -and $appName -ne "PSProvider") {
        Remove-ItemProperty -Path $path -Name $appName -ErrorAction Ignore 
        Write-Host "Se ha deshabilitado: $appName desde $path"
        }
    }
}

#Activa los Threads:
$Threads = $env:NUMBER_OF_PROCESSORS
Start-Process -FilePath "bcdedit" -ArgumentList "/set {current} numproc $Threads" -Verb RunAs 

#Importa la configuracion para gpedit
Start-Process -FilePath "$BasePathOP\Policies\LGPO.exe" -ArgumentList "/g $BasePathOP\Policies\GpeditCofig" -NoNewWindow -Wait
if ($?) {
    Write-Host "Se han importado las politicas correctamente" -ForegroundColor Green
} else {
    Write-Host "No se han importado las politicas correctamente" -ForegroundColor Red -ErrorAction Continue
}

Read-Host -Prompt "Presiona Enter para Continuar"
