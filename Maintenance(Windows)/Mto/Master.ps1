# Paths
$BasePath = (Get-Location).Path
$BlockPath = "$BasePath\Block"
$CleanerPath = "$BasePath\Cleaner"
$InstallationPath = "$BasePath\Installation"

#Primero cambia los scopes a unrestricted 
$scopes = @("CurrentUser", "LocalMachine")

foreach ($scope in $scopes) {
    Write-Host "Estableciendo politica de ejecucion en Unrestricted para el ambito: $scope"
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope $scope -Force
}

Read-Host -Prompt "presiona enter para continuar"

function Show-Master {
    Clear-Host
    Write-Host "================= Configuracion Individual ============================"

    Write-Host "1. Preparar sistema"
    Write-Host "2. Aplicar Bloqueos"
    Write-Host "3. Aplicar optimizacion"
    Write-Host "4. Aplicar Limpieza"
    Write-Host "5. Instalar programas"

    Write-Host "================= Configuracion Completa ============================"

    Write-Host "6. Aplicar todo"
    Write-Host "7. Salir"
} 

while ($true) {
    Show-Master
    $eleccion = Read-Host "Selecciona una opcion"
    switch ($eleccion) {
        "1" {
            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$InstallationPath\GetStart.ps1`"" -Verb runAs -Wait 
        }
        "2" {
            $itemsB = Get-ChildItem $BlockPath
            foreach ($item in $itemsB ) {
                $scriptPath = $item.FullName
                Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb runAs -Wait
            }
        }
        "3" {
            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$CleanerPath\optimize.ps1`""  -Verb runAs -Wait
        }
        "4" {
            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$CleanerPath\WindowsCleaner.ps1`""  -Verb runAs -Wait
            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$CleanerPath\BloatwareCleaner.ps1`""  -Verb runAs -Wait
        }
        "5" {
            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$InstallationPath\Installer.ps1`"" -Verb runAs -Wait
        }
        "6" {
            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$InstallationPath\GetStart.ps1`""  -Verb runAs -Wait
            
            #bloqueos
            $itemsB = Get-ChildItem $BlockPath
            foreach ($item in $itemsB ) {
                $scriptPath = $item.FullName
                Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb runAs -Wait
            }
            
            #cleaner
            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$CleanerPath\WindowsCleaner.ps1`"" -Verb runAs -Wait
            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$CleanerPath\Optimize.ps1`"" -Verb runAs -Wait
            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$CleanerPath\BloatwareCleaner.ps1`""  -Verb runAs -Wait
            
            while ($respuesta -notmatch "[s|n]"){
                $respuesta = Read-Host "Deseas actualizar el sistema? (s/n)"
                $respuesta = $respuesta.ToLower()
                if ($respuesta -eq "s") {
                    Write-Host "Buscando actualizaciones espera..." -ForegroundColor Yellow
                    Install-Module -Name PSWindowsUpdate -Scope AllUsers -Force
                    Import-Module PSWindowsUpdate 
                    $updates = Get-WindowsUpdate
                    if ($updates) {
                        Install-WindowsUpdate -AcceptAll -AutoReboot
                        Write-Host "Se han instalado las actualizaciones." -ForegroundColor Green
                        #Si no se reinicia automaticamente
                        Restart-Computer -Force
                    } else{
                        Write-Host "No hay actualizaciones disponibles." -ForegroundColor Green
                    }
                } elseif ($respuesta -eq "n"){
                    Write-Host "Configuracion completada." -ForegroundColor Green
                    break
                }            
            }
        }
        "7" {
            Write-Host "Saliendo..."
            #Regresa los scopes a Restricted
            $scopes = @("CurrentUser", "LocalMachine")
            foreach ($scope in $scopes) {
                Write-Host "Estableciendo politica de ejecucion en Restricted para el ambito: $scope"
                Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope $scope -Force
            }
            Read-Host -Prompt "Presione Enter para finalizar"
            Stop-Process $PID
        }
        default {
            Write-Host "Opcion no valida, intenta de nuevo." -ForegroundColor Red
        }
    }
}
