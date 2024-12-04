function Show-Menu {
    Clear-Host
    Write-Host "================= Impresoras y Drivers ============================" -ForegroundColor Green

    Write-Host "1. Informacion detallada"
    Write-Host "2. Eliminar todas las impresoras"
    Write-Host "3. Eliminar todos los drivers"
    Write-Host "4. Limpiar cola de impresion"
    Write-Host "5. Comprobar Puerto"
    Write-Host "6. Salir"
} 

function IsDefault($printerName) {
    try {
        $defaultPrinter = Get-WmiObject win32_printer | Where-Object { $_.Default -eq $True }
        if ($defaultPrinter.Name -eq $printerName) {
            return $True
        } else {
            return $False
        }
    }
    catch {
        Write-Error -Message $_.Exception.Message
        return $False
    }
}

while ($true) {
    Show-Menu
    $eleccion = Read-Host "Selecciona una opcion"
    switch ($eleccion) {
        "1" {
            Clear-Host
            Write-Host "Drivers instalados" -ForegroundColor Green
            Get-PrinterDriver | Format-table -Property Name, Manufacturer -AutoSize

            Write-Host "========================================"

            Write-Host "Impresoras Disponibles" -ForegroundColor Green
            
            $printers = Get-Printer 
            foreach ($printer in $printers) {
                Write-Host "Nombre de la impresora: " -NoNewline; Write-Host "$($printer.Name)" -ForegroundColor Cyan
                Write-Host "Modelo: " -NoNewline; Write-Host "$($printer.DriverName)" -ForegroundColor Cyan
                Write-Host "Estado: " -NoNewline; Write-Host "$($printer.PrinterStatus)" -ForegroundColor Cyan
                Write-Host "Puerto: " -NoNewline; Write-Host "$($printer.PortName)" -ForegroundColor Cyan
                $isDefault = IsDefault -printerName $printer.Name
                Write-Host "Predeterminada: " -NoNewline; Write-Host "$isDefault" -ForegroundColor Magenta
                Write-Host "Compartida: " -NoNewline; Write-Host "$($printer.Shared)" -ForegroundColor Cyan
                if ($null -ne $printer.PSObject.Properties["CommunicationStatus"]) {
                    Write-Host "Estado de comunicacion: " -NoNewline; Write-Host "$($printer.CommunicationStatus)" -ForegroundColor Cyan
                } else {
                    Write-Host "Estado de comunicacion: " -NoNewline; Write-Host "No disponible" -ForegroundColor Red
                }
                Write-Host "-------------------------------------"

            }
            Read-Host -Prompt "presiona enter para continuar" 
        }
        "2" {
            Clear-Host
            $printers = Get-Printer
            foreach ($printer in $printers) {
                Write-Host "Eliminando impresora: $($printer.Name)" -ForegroundColor Yellow
                try {
                    Remove-Printer -Name $printer.Name
                    Write-Host "Se ha eliminado correctamente la impresora $($printer.Name)" -ForegroundColor Green
                }
                catch {
                    Write-Error -Message $_.Exception.Message
                    Write-Host "No se ha eliminado la impresora: $($printer.Name)" -ForegroundColor Red
                }
            }
            Read-Host -Prompt "presiona enter para continuar" 

        }
        "3" {
            Clear-Host
            $drivers = Get-PrinterDriver
            foreach ($driver in $drivers) {
                Write-Host "Eliminando driver: $($driver.Name)" -ForegroundColor Yellow
                try {
                    Remove-PrinterDriver -Name $driver.Name
                    Write-Host "Se ha eliminado correctamente el driver $($driver.Name)" -ForegroundColor Green
                }
                catch {
                    Write-Error -Message $_.Exception.Message
                    Write-Host "No se ha eliminado el driver: $($driver.Name)" -ForegroundColor Red
                }
            }
            Read-Host -Prompt "presiona enter para continuar" 

        }
        "4" {
            Clear-Host 
            $printers = Get-Printer
            foreach ($printer in $printers) {
                $printjobs = Get-PrintJob -PrinterObject $printer
                foreach ($printjob in $printjobs) {
                    Remove-PrintJob -InputObject $printjob
                }
            }
            Write-Host "Se ha eliminado todas las colas de impresion" -ForegroundColor Green
            Read-Host -Prompt "presiona enter para continuar" 
        }
        "5" {
            #Monitorea los puertos en busca de impresoras obteniendo el puerto, ubicacion, servicio y estatus
            Clear-Host
            Write-Host "Monitoreando los puertos para detectar impresoras..." -ForegroundColor Yellow
            Write-Host "`n"

            $KnownDevices = Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' } | Select-Object -Property InstanceId,FriendlyName,Status,Service
            $NewDevices = @()
            do {
                $ActualDevices = Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' } | Select-Object -Property InstanceId,FriendlyName,Status,Service
                foreach ($device in $ActualDevices) {
                    if (-not ($KnownDevices.InstanceId -contains $device.InstanceId)) {

                        Write-Host "Nuevo dispositivo detectado:" -ForegroundColor Green
                        Write-Host "`n"

                        Write-Host "Puerto: " -NoNewline; Write-Host "$($device.InstanceId)" -ForegroundColor Cyan
                        Write-Host "Nombre: " -NoNewline; Write-Host "$($device.FriendlyName)" -ForegroundColor Cyan
                        Write-Host "Status: " -NoNewline
                        if ($device.Status -eq "OK") {
                            Write-Host "$($device.Status)" -ForegroundColor Green
                        } else {
                            Write-Host "$($device.Status)" -ForegroundColor Red
                        }
                        Write-Host "Servicio: " -NoNewline; Write-Host "$($device.Service)" -ForegroundColor Magenta

                        Write-Host "-------------------------------------"
                        $NewDevices += $device.InstanceId
                        $KnownDevices += $device
                    }
                }
                if ($NewDevices.Count -gt 0) {
                    break
                }
                Start-Sleep -Seconds 1
            } while ($true)
            Read-Host -Prompt "presiona enter para continuar" 
        }
        "6" {
            Write-Host "Finalizando..."
            Stop-Process $PID      
        }
        default {
            Write-Host "Opcion no valida, intenta de nuevo." -ForegroundColor Red
        }
    }
}
