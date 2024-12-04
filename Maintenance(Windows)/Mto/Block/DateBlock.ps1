Clear-Host
function set-privileges {
    param (
        [string[]]$contenido,
        [string]$filePath
    )
    
    $resultado = @()
    foreach ($linea in $contenido) {
        if ($linea -match "SeTimeZonePrivilege" -or $linea -match "SeSystemtimePrivilege") {
            $partes = $linea -split ","
            if ($partes.Count -gt 2) {
                $nuevaLinea = "$($partes[0]),$($partes[1])"
                $resultado += $nuevaLinea
            } else {
                $resultado += $linea
            }
        } else {
            $resultado += $linea
        }
    }
    Set-Content -Path $filePath -Value $resultado
    return $filePath  
}

$Secpath = "$env:TEMP\secpol.cfg"
if (-not (Test-Path $Secpath)) {
    # Crea el archivo cfg 
    secedit /export /cfg $Secpath | Out-Null
} 
$contenido = Get-Content $Secpath

# Procesa el archivo y guarda los cambios
$aplicadoPath = set-privileges -contenido $contenido -filePath $Secpath

secedit /configure /db c:\windows\security\local.sdb /cfg $aplicadoPath /areas USER_RIGHTS
Write-Host "Se han editado las politicas correctamente" -ForegroundColor Green
Read-Host -Prompt "Presione Enter para continuar"
