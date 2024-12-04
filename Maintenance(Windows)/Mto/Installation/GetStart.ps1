Clear-Host

$BsP = (Get-Location).Path
$avgPath = "$env:USERPROFILE\Downloads\avg.exe"
$PowerShellMajor = $Psversiontable.PSVersion.Major


#Cambia la zona horaria
Write-Host "Verificando la zona horaria..." -ForegroundColor Yellow
$osTimeZone = (Get-TimeZone).Id
if ($osTimeZone -ne "Central America Standard Time") {
    Set-TimeZone -Id "Central America Standard Time" -ErrorAction Continue
    if ($?) {
         Write-Host "Se ha cambiado la zona horaria a Central America Standard Time" -ForegroundColor Green
    } else {
        Write-Error "No se ha podido cambiar la zona horaria." 
    }
} else {
    Write-Host "La zona ya es america central, continuando..." -ForegroundColor Green
}


#Instala el gpedit y secpol
$gpeditPath = "$env:SystemRoot\System32\gpedit.msc"
if (Test-Path -Path $gpeditPath) {
    Write-Host "EL gpedit y secpol ya esta instalado." -ForegroundColor Green
} else {
    Write-Host "El gpedit no esta instalado. Instalando" -ForegroundColor Yellow
    Start-Process -FilePath "$BsP\Installation\secpolEnabler.bat" -Wait
}

#instala avg para actualizar drivers
$osInfo = Get-ComputerInfo 2>$null
$osArquitecture = $osInfo.OsArchitecture 2>$null
$conexion = Test-Connection "8.8.8.8" -Count 2 -Quiet 2>$null
if ($osArquitecture -match "64 bits") {
    if ($conexion) {
        try {
            Invoke-WebRequest -Uri "https://bits.avcdn.net/productfamily_DRIVER_UPDATER/insttype_PRO/platform_WIN_AVG/installertype_ONLINE/build_RELEASE/trialid_mmm_dua_ppc_007_001_m/cookie_mmm_duw_003_999_a8h" -OutFile $avgPath 
            if (Test-Path $avgPath) {
                Start-Process -FilePath $avgPath -Verb runAs -Wait
            } else {
                Write-Host "El archivo avg.exe no se descargo correctamente." -ForegroundColor Red
            }
        }
        catch {
            Write-Host "No se ha podido instalar avgDriver." -ForegroundColor Red
            Write-Error -Message $_.Exception.Message
        }
    } else {
        Write-Host "No hay conexion a internet" -ForegroundColor Red
    }
}elseif($osArquitecture -match "32 bits"){
    Write-Host "Avg driver no es compatible con sistemas de 32 bits"
}

#Instala driver de touch Wincor
$GalaxyPath = "$env:USERPROFILE\Downloads\Galaxy.zip"
$unzipGalaxy = "$env:USERPROFILE\Downloads\Galaxy"
$Setup = "$env:USERPROFILE\Downloads\Galaxy\eGalaxTouch_5.14.0.24318-Release-240118-SingleTouchDev\setup.exe"
$Modelo = (Get-ComputerInfo).Csmodel 2>$null
if ($Modelo -match "BETTLE /FUSION 15 GM45" -and $osArquitecture -match "64 bits" -and $PowerShellMajor -ceq 5) {
    try {
        Invoke-WebRequest -Uri "https://www.eeti.com/touch_dsriver/Win10/20240320/eGalaxTouch_5.14.0.24318-Release-240118-SingleTouchDev.zip" -OutFile $GalaxyPath
        if (Test-Path $GalaxyPath) {
            Expand-Archive -Path $GalaxyPath -DestinationPath $unzipGalaxy
            if (Test-Path $Setup) {
                Start-Process -FilePath $Setup -Verb runAs -Wait
            }else {
                Write-Host "No se ha encontrado el setup.exe" -ForegroundColor Red
            }
        } else {
            Write-Host "El archivo galaxy.zip no se descargo correctamente." -ForegroundColor Red
        }
    }
    catch {
        Write-Error -Exception
        Write-Host "El modelo no es el mismo" -ForegroundColor Red
    }
}

#Crea un usuario para Punto de Venta
Write-Host "Creando usuario para Punto de Venta..." -ForegroundColor Yellow
$PVusuario = "PV"
New-LocalUser -Name $PVusuario  -Description "usuario para punto de venta" -NoPassword
Add-LocalGroupMember -Group "Usuarios" -Member $PVusuario
Enable-LocalUser -Name $PVusuario
Set-LocalUser -Name $PVusuario -PasswordNeverExpires $True
Write-Host "Usuario $PVusuario creado correctamente."

#Verificacion de clave OEM en sistema
while ($respuesta -notmatch "[s|n]"){
    $respuesta = Read-Host "Deseas verificar la existencia de una clave OEM? (s/n)"
    $respuesta = $respuesta.ToLower()
    if ($respuesta -eq "s") {
        # Obtener la clave OEM
        $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
       if($key){
           Write-host "Clave OEM encontrada: $key"
           slmgr /ipk $key
           slmgr /ato
       } else{
           Write-host "No se encontró ninguna clave OEM en el sistema"
       }
    }elseif ($respuesta -eq "n") {
        Write-Host "Instalacion finalizada." -ForegroundColor Green
        break
    }else {
        Write-Error "Respuesta incorrecta. Responde 's' o 'n'."
    }
}
Write-Host "Se ha completado el script inicial correctamente" -ForegroundColor Green
Read-Host -Prompt "Presiona enter para continuar"
