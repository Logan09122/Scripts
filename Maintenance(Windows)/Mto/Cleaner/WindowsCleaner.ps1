Clear-Host
# Limpieza de la papelera
$txtPath = "$env:USERPROFILE\Downloads\FileDeleted.txt"
$Shell = New-Object -ComObject Shell.Application
$RecycleBin = $Shell.Namespace(0x0a)
$RecycleBinItems = $RecycleBin.Items()

if ($RecycleBinItems.Count -eq 0) {
    Write-Host "La papelera esta vacia"
} else {
    Clear-Content -Path $txtPath 2>$null
    $Resultados = @()

    foreach ($item in $RecycleBinItems) {
        $itemName = $item.Name
        $itemPath = $item.Path
        $itemType = $item.Type
        $itemTime = $item.ModifyDate

        $Resultado = @{
            Nombre = $itemName
            Path = $itemPath
            Tipo = $itemType
            Modificacion = $itemTime
        }
        
        $Resultados += $Resultado
    }

    # Escribe los resultados en el archivo
    $Resultados | Sort-Object -Property Modificacion -Descending | Format-Table | Out-File -FilePath $txtPath

    Clear-RecycleBin -Force -Confirm:$false 2>$null
    Write-Host "Archivos eliminados en $txtPath..." -ForegroundColor Green
}


function Clear-TempFiles {
    param (
        [string]$Path
    )
    $TempItems = Get-ChildItem $Path 2>$null
    if ($TempItems.Count -eq 0) {
        Write-Host "No hay archivos temporales"
    } else {
        foreach ($item in $TempItems) {
            $item | Remove-Item -Force -Recurse  2>$null
        }
    }
}
Clear-TempFiles -Path "$env:TEMP"
Clear-TempFiles -Path "$env:LOCALAPPDATA\Temp"

#volcados de memoria
$PathVolcados = "$env:LOCALAPPDATA\CrashDumps"
$volcadoitems = Get-ChildItem  $PathVolcados 2>$null
if ($volcadoitems.Count -eq 0 ) {
    Write-Host "No hay archivos volcados"
} else {
    foreach ($itemsVolcados in $volcadoitems){
        $itemsVolcados | Remove-Item -Force -Recurse  2>$null
    }
}

#Registros de Seguimiento de windows
function Clear-Logs {
    param (
        [string]$path
    )
    $LogsItems = Get-ChildItem $Path
    if ($LogsItems.Count -eq 0) {
        Write-Host "No hay archivos"
    } else {
        foreach ($item in $LogsItems) {
            $item | Remove-Item -Force -Recurse  2>$null
        }
    }
}
Clear-Logs -Path "$env:ProgramData\USOShared\Logs\User"
Clear-Logs -Path "$env:SystemRoot\Logs\WindowsUpdate"

#Reportes de errores
$ReportesCrash = "C:\ProgramData\Microsoft\Windows\WER\ReportArchive"
$ReportesQueue = "C:\ProgramData\Microsoft\Windows\WER\ReportQueue"
function Clear-Report {
    param (
        [string]$path    
    )
    $ReportItems =  Get-ChildItem $path  2>$null
    if ($ReportItems.Count -eq 0) {
        Write-Host "No hay archivos temporales"
    } else {
        foreach ($item in $ReportItems) {
            $item | Remove-Item -Force -Recurse 
        }
    }
}
Clear-Report -Path $ReportesCrash
Clear-Report -Path $ReportesQueue

#Widgets de Windows
$CodeCache = "$env:LOCALAPPDATA\Packages\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy\LocalState\EBWebView\Default\Code Cache"
$widgetItem = Get-ChildItem  $CodeCache  2>$null
if ($widgetItem.Count -eq 0 ) {
    Write-Host "No hay Widgets"
} else {
    foreach ($itemsWidgets in $widgetItem){
        $itemsWidgets | Remove-Item -Force -Recurse  2>$null
    }
}

#Cache Windows
$CacheStorage = "$env:LOCALAPPDATA\Packages\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy\LocalState\EBWebView\Default\Service Worker\CacheStorage"
$ScriptCache = "$env:LOCALAPPDATA\Packages\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy\LocalState\EBWebView\Default\Service Worker\ScriptCache"

function Clear-Cache {
    param (
        [string]$path
    )
    $CacheItems =  Get-ChildItem $path 2>$null
    if ($CacheItems.Count -eq 0) {
        Write-Host "No hay cache para eliminar"
    } else {
        foreach ($item in $CacheItems) {
            $item | Remove-Item -Force -Recurse  2>$null
        }
    }
}
Clear-Cache -Path $CacheStorage
Clear-Cache -Path $ScriptCache

#Cache web de windows
$Content = "$env:USERPROFILE\AppData\LocalLow\Microsoft\CryptnetUrlCache\Content"
$MetaData = "$env:USERPROFILE\AppData\LocalLow\Microsoft\CryptnetUrlCache\MetaData"

function Clear-WinCache {
    param (
        [string]$path
    )
    $ContentItems =  Get-ChildItem $path  2>$null
    if ($ContentItems.Count -eq 0) {
        Write-Host "No hay archivos para eliminar"
    } else {
        foreach ($item in $ContentItems) {
            $item | Remove-Item -Force -Recurse  2>$null
        }
    }
}
Clear-WinCache -path $Content
Clear-WinCache -path $MetaData

#Paths
$paths = @{
    "CacheFirefox" = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\t40ovod4.default-release\cache2\entries"
    "CoockiesFirefox" = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\t40ovod4.default-release\cookies.sqlite"
    "HistorialFirefox" = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\t40ovod4.default-release\thumbnails"
    "CacheChrome" = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
    "CoockiesChrome" = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies"
    "HistorialChrome" = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History"
    "CacheEdge" = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
    "HistorialEdge" = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History"
    "CoockiesEdge" = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cookies"
}

#Detiene cualquiera de los 3 navegadores para su limpieza
$Procesos = Get-Process
foreach ($proceso in $Procesos) {
    if ($proceso.ProcessName -match "firefox" -or $proceso.ProcessName -match "edge" -or $proceso.ProcessName -match "chrome") {
        Stop-Process -Id $proceso.Id -Force 2>$null
    }
}
Clear-DnsClientCache


function Clear-Browser {
    param (
        [hashtable]$paths
    )

    foreach ($key in $paths.Keys) {
        $path = $paths[$key]
        if (Test-Path $path -ErrorAction SilentlyContinue) {
            Remove-Item -Path $path -Recurse -Force 2>$null
            if ($?) {
                Write-Host "Se ha limpiado la cache de navegador: $key" -ForegroundColor Green
            } else {
                Write-Host "No se ha podido limpiar la cache de navegador: $key" -ForegroundColor Red
            }
        }
    }
}

Clear-Browser -paths $paths
Write-Host "Se ha completado toda la limpieza." -ForegroundColor Green
Read-Host -Prompt "Presiona enter para continuar"
