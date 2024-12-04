Write-Host "Instalando Programas..." -ForegroundColor Yellow
$DiskPath = "$env:USERPROFILE\Downloads\Disk.exe"
$AnydeskPath = "$env:USERPROFILE\Downloads\Any.exe"
$WinrarPath = "$env:USERPROFILE\Downloads\Winrar.exe"
$Winrar32 = "$env:USERPROFILE\Downloads\Winrar32.exe"
$ChromePath = "$env:USERPROFILE\Downloads\Chrome.exe"
$DidiPath = "$env:USERPROFILE\Downloads\DiDi.exe"


#Solo hacer el curl al POS


$conexion = Test-Connection "8.8.8.8" -Count 2 -Quiet
$osInfo = Get-ComputerInfo 2>$null
$osArquitecture = $osInfo.OsArchitecture 2>$null
if ($conexion) {
    try {
        if ($osArquitecture -match "64 bits") {
            #Winrar
            Invoke-WebRequest -Uri "https://www.rarlab.com/rar/winrar-x64-621.exe" -OutFile $WinrarPath
            Start-Process -FilePath $WinrarPath -Verb runAs -Wait
            
            #DiDi
            Invoke-WebRequest -Uri "https://img0.didiglobal.com/static/soda_static/b/pc/client/release/DIDI_Setup_1.3.29.exe" -OutFile $DidiPath
            Start-Process -FilePath $DidiPath -Verb runAs -Wait
            
        } elseif ($osArquitecture -match "32 bits") {
            Write-host "Programa no disponible para x86"
        } else {
            Write-Host "Arquitectura no encontrada" -ForegroundColor Red 
        }

        #Chrome
        Invoke-WebRequest -Uri "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B4DB93B8C-2B3B-EF93-A509-EA4B86377CC6%7D%26lang%3Des-419%26browser%3D3%26usagestats%3D1%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-statsdef_1%26installdataindex%3Dempty/update2/installers/ChromeSetup.exe" -OutFile $ChromePath
        Start-Process -FilePath $ChromePath -Verb runAs -Wait
            
        #CristalDisk
        Invoke-WebRequest -Uri "https://psychz.dl.sourceforge.net/project/crystaldiskinfo/9.3.2/CrystalDiskInfo9_3_2.exe?viasf=1" -OutFile $DiskPath
        Start-Process -FilePath $DiskPath -Verb runAs -Wait
    
        #Anydesk
        Invoke-WebRequest -Uri "https://download.anydesk.com/AnyDesk.exe" -OutFile $AnydeskPath
        Start-Process -FilePath $AnydeskPath -Verb runAs -Wait
        
    } catch {
        Write-Host "Error al ejecutar el instalador." -ForegroundColor Red
        Write-Error -Message $_.Exception.Message
    }
} else {
    Write-Error "No hay conexion a internet." -ForegroundColor Red
}  

Read-Host -Prompt "Presiona enter para continuar"
