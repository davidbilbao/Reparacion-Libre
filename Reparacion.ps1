 function Borrar-Particion {
    $disco = Read-Host "Ingrese el numero del disco"
    $particion = Read-Host "Ingrese el número de la partición a borrar"

    $diskpartScript = @"
    select disk $disco
    select partition $particion
    delete partition
"@

    $diskpartScript | diskpart

    Write-Host "Partición borrada exitosamente."
}
function infor{
	# Obtener información del sistema
	systeminfo

	# Obtener información de la CPU
	Get-WmiObject Win32_Processor | Select-Object Caption, DeviceID

	# Obtener información de las memorias
	Get-WmiObject Win32_PhysicalMemory

	# Obtener información de las unidades de disco
	Get-WmiObject Win32_DiskDrive

	# Obtener información de la placa base
	Get-WmiObject Win32_BaseBoard

	# Obtener información del sistema operativo
	(Get-WmiObject Win32_OperatingSystem).Caption, (Get-WmiObject Win32_OperatingSystem).Version
}
function crear-part{
	diskpart
	Get-Disk | Format-Table -Property Number, FriendlyName

	$disco = Read-Host "Ingrese el número del disco que desea particionar"
	Invoke-Expression "select disk $disco"
	Invoke-Expression "list partition"

	$particion = Read-Host "Ingrese el tipo de partición que desea (primary, extended, logical)"
	$crear = Read-Host "Ingrese el tamaño de la partición que desea (en MB)"
	Invoke-Expression "create partition $particion size=$crear"
	Invoke-Expression "list partition"

	$num = Read-Host "Ingrese el número de la partición a la que desea asignar un nombre"
	Invoke-Expression "select partition $num"
	$nom = Read-Host "Ingrese el nombre para la partición"
	Invoke-Expression "format fs=NTFS label='$nom' quick"

	$let = Read-Host "Ingrese la letra de unidad que desea asignar a la partición"
	Invoke-Expression "assign letter=$let"
}
function Formatear-Particion {
    $disco = Read-Host "Ingrese el número del disco"
    
    $diskpartScript = @"
    select disk $disco
    clean
    create partition primary
    select partition 1
    active
    format fs=NTFS
    assign
"@

    $diskpartScript | diskpart

    Write-Host "Partición formateada exitosamente."
}

function Realizar-Diagnostico {
    Clear-Host
    Write-Host "Realizando diagnóstico y reparación del sistema..."

    # Ejecutar comandos de diagnostico y reparacion
    sfc /scannow
    DISM /Online /Cleanup-Image /CheckHealth
    DISM /Online /Cleanup-Image /ScanHealth
    DISM /Online /Cleanup-Image /RestoreHealth

    Write-Host "diagnostico completado"
}
function Desfragmentar-Disco {
    Write-Host "Advertencia: Esto es solo para discos duros mecanicos"
    $choice = Read-Host "¿Desea continuar? Ingrese '1' para si, '2' para no"

    if ($choice -eq "1") {
        $dis = Read-Host "Ingrese la letra del disco que desea desfragmentar"
        defrag $dis /O
    }
}
function Show-Menu {
    Clear-Host
    Write-Host "------------- Menú -------------"
    Write-Host "1. Diagnóstico y reparación del sistema"
    Write-Host "2. Escaneo y reparación de disco"
    Write-Host "3. Opciones de inicio"
    Write-Host "4. Hacer un respaldo"
    Write-Host "5. Actualizar programas"
    Write-Host "6. Todas las características del sistema"
    Write-Host "7. Crear particiones"
    Write-Host "8. Reparar Windows Update"
    Write-Host "9. Restaurar el sistema"
    Write-Host "10. Borrar archivos basura"
    Write-Host "11. Instalar programa"
    Write-Host "12. Borrar particiones"
    Write-Host "13. Formatear particiones"
    Write-Host "14. Información del hardware de la computadora"
    Write-Host "15. Información de los drivers instalados en la computadora"
    Write-Host "16. Desfragmentación del disco"
    Write-Host "17. Optimizar sistema"
    Write-Host "18. Salir"
}

do {
    Show-Menu
    $choice = Read-Host "Elige una opción"
    switch ($choice) {
        "1" { # Diagnosticco y reparacion del sistema
			Clear-Host
            Realizar-Diagnostico
			
        }
        "2" { # Escaneo y reparación de disco
            Clear-Host
			
			$disco = Read-Host "Ingrese el nombre del disco"
			Invoke-Expression "chkdsk $disco /f /r"

        }
        "3" { # Opciones de inicio
            Clear-Host
            msconfig
        }
        "4" { # Hacer un respaldo
            Clear-Host
			diskpart
			Get-Volume

			$respaldo = Read-Host "Ingrese la letra del respaldo"
			wbadmin start backup -backuptarget:$respaldo -include:C: -allCritical
        }
        "5" { # Actualizar programas
            Clear-Host
			winget upgrade
			winget upgrade --all
        }
        "6" { # Todas las características del sistema
            Clear-Host
			Get-WmiObject Win32_PnPSignedDriver
			systeminfo
        }
        "7" { # Crear particiones
            Clear-Host
			crear-part
        }
        "8" { # Reparar Windows Update
            Clear-Host

        }
        "9" { # Restaurar el sistema
		    Clear-Host
            rstrui
        }
        "10" { # Borrar archivos basura
			Clear-Host
			Start-Process "cleanmgr"
			Remove-Item -Path $env:TEMP\* -Force -Recurse
        }
        "11" { # Instalar programa
            Clear-Host
			$programa = Read-Host "Ingrese el nombre del programa que desea instalar"
			Start-Process "winget" -ArgumentList "install $programa" -Wait
        }
        "12" { # Borrar particiones
			Clear-Host
            Borrar-Particion
        }
        "13" { # Formatear particiones
		
            Clear-Host
			Formatear-Particion
        }
        "14" { # Información del hardware de la computadora
            Clear-Host
			infor

        }
        "15" { # Información de los drivers instalados en la computadora
            Clear-Host
			# Obtener información de los drivers
			Get-WmiObject Win32_PnPSignedDriver | Select-Object Manufacturer, DeviceName, DriverVersion

			# Ejecutar DirectX Diagnostic Tool (dxdiag)
			Start-Process "dxdiag"
        }
        "16" { # Desfragmentación del disco
            Clear-Host
            Desfragmentar-Disco
        }
        "17" { # Optimizar sistema
            Clear-Host
			# Abrir Propiedades del Sistema
			Start-Process "control" -ArgumentList "sysdm.cpl"

			# Abrir Editor del Registro
			Start-Process "regedit"

			# Abrir Liberador de Espacio en Disco
			Start-Process "cleanmgr"
        }
        "18" { # Salir
            break
        }
        default {
            Write-Host "Opción inválida. Por favor, elige una opción válida."
        }
    }
    Pause
} while ($choice -ne "18")

