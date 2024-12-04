$Optimize = {
    # Aplica optimización general
    Start-Process "SystemPropertiesPerformance.exe"
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
            }
        }
    }
    $Threads = $env:NUMBER_OF_PROCESSORS
    Start-Process -FilePath "bcdedit" -ArgumentList "/set {current} numproc $Threads" -Verb RunAs
}

$RemoveApps = {
    #Desinstala aplicaciones preinstaladas
    $WhiteList = @(
        '*WindowsCalculator*',
        '*Microsoft.net*',
        '*WindowsTerminal*',
        '*WindowsNotepad*',
        '*WindowsStore*',
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
    return "BloatwareRemove completo"
}

$Cleaner = {
    # Limpieza general de archivos,temps,dumps y cache
    Clear-RecycleBin -Force -Confirm:$false 2>$null

    #Limpieza de temporales 
    function Clear-TempFiles {
        param (
            [string]$Path
        )
        $TempItems = Get-ChildItem $Path 2>$null
        foreach ($item in $TempItems) {
            $item | Remove-Item -Force -Recurse  2>$null
        }
    }
    Clear-TempFiles -Path "$env:TEMP"
    Clear-TempFiles -Path "$env:LOCALAPPDATA\Temp"


    #Dumps
    $PathVolcados = "$env:LOCALAPPDATA\CrashDumps"
    $volcadoitems = Get-ChildItem  $PathVolcados 2>$null
    foreach ($itemsVolcados in $volcadoitems){
        $itemsVolcados | Remove-Item -Force -Recurse  2>$null
    }

    #Registros de Seguimiento de windows
    function Clear-Logs {
        param (
            [string]$path
        )
        $LogsItems = Get-ChildItem $Path
        foreach ($item in $LogsItems) {
            $item | Remove-Item -Force -Recurse  2>$null
        }
    }
    Clear-Logs -Path "$env:ProgramData\USOShared\Logs\User"
    Clear-Logs -Path "$env:SystemRoot\Logs\WindowsUpdate"


    #Cache Windows
    $CacheStorage = "$env:LOCALAPPDATA\Packages\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy\LocalState\EBWebView\Default\Service Worker\CacheStorage"
    $ScriptCache = "$env:LOCALAPPDATA\Packages\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy\LocalState\EBWebView\Default\Service Worker\ScriptCache"
    function Clear-Cache {
        param (
            [string]$path
        )
        $CacheItems =  Get-ChildItem $path 2>$null
        foreach ($item in $CacheItems) {
            $item | Remove-Item -Force -Recurse  2>$null
        }
    }
    Clear-Cache -Path $CacheStorage
    Clear-Cache -Path $ScriptCache

    #Widgets de Windows
    $CodeCache = "$env:LOCALAPPDATA\Packages\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy\LocalState\EBWebView\Default\Code Cache"
    $widgetItem = Get-ChildItem  $CodeCache  2>$null
    foreach ($itemsWidgets in $widgetItem){
        $itemsWidgets | Remove-Item -Force -Recurse  2>$null
    }

    #Logs de errores
    $ReportesCrash = "C:\ProgramData\Microsoft\Windows\WER\ReportArchive"
    $ReportesQueue = "C:\ProgramData\Microsoft\Windows\WER\ReportQueue"
    function Clear-Report {
        param (
            [string]$path    
        )
        $ReportItems =  Get-ChildItem $path  2>$null
        foreach ($item in $ReportItems) {
            $item | Remove-Item -Force -Recurse 
        }
    }
    Clear-Report -Path $ReportesCrash
    Clear-Report -Path $ReportesQueue

    return "Cleaner Completo"
}

#Array de scriptblocks
$scripts = @($Optimize, $RemoveApps, $Cleaner)

#Aqui inicializa los jobs en paralelo en segundo plano como un proceso individual 
$jobs = @()
foreach ($script in $scripts) {
    $jobs += Start-Job -ScriptBlock $script
}

Wait-Job -Job $jobs

# Aqui obtiene el resultado de los jobs
foreach ($job in $jobs) {
    $resultado = Receive-Job -Job $job
    Write-Host $resultado
}

Remove-Job -Job $jobs
