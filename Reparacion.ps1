Add-Type -AssemblyName PresentationFramework

function Show-Menu {
	do{
    $options = @(
        "Diagnóstico y reparación del sistema",
        "Escaneo y reparación de disco",
        "Opciones de inicio",
        "Hacer un respaldo",
        "Actualizar programas",
        "Todas las características del sistema",
        "Crear particiones",
        "Reparar Windows Update",
        "Restaurar el sistema",
        "Borrar archivos basura",
        "Instalar programa",
        "Borrar particiones",
        "Formatear particiones",
        "Información del hardware de la computadora",
        "Información de los drivers instalados",
        "Desfragmentación del disco",
        "Optimizar sistema",
        "Salir"
    )

    $choice = $options | Out-GridView -Title "Menú" -PassThru

    switch ($choice) {
        "Diagnóstico y reparación del sistema" { 
		Clear-Host
		Realizar-Diagnostico 
		}
        "Escaneo y reparación de disco" { 
		Clear-Host
		Escaneo-Reparacion-Disco 
		}
        "Opciones de inicio"{
			Clear-Host
			msconfig
			}
        "Hacer un respaldo"{
			Clear-Host
			respaldo
			}
         "Actualizar programas"{
			 Clear-Host
            winget upgrade
			winget upgrade --all
          }
          "Todas las características del sistema"{
			  Clear-Host
			  infor
		  }
			"Crear particiones"{
				Clear-Host
				crear-part
			}
			"Reparar Windows Update"{
				Clear-Host
				# Detener los servicios wuauserv y bits
				Stop-Service -Name wuauserv, bits -Force

				# Iniciar los servicios wuauserv y bits	
				Start-Service -Name wuauserv, bits
			}
			"Restaurar el sistema"{
				Clear-Host
				rstrui
			}
			"Borrar archivos basura"{
				Clear-Host
				Start-Process "cleanmgr"
				Remove-Item -Path $env:TEMP\* -Force -Recurse
			}
			 "Instalar programa"{
				Clear-Host
				$programa = Read-Host "Ingrese el nombre del programa que desea instalar"
				Start-Process "winget" -ArgumentList "install $programa" -Wait
			}
			"Borrar particiones"{
				Clear-Host
				Borrar-Particion
			}
			"Formatear particiones"{ 
		
            Clear-Host
			Formatear-Particion
			}
			"Información del hardware de la computadora"{
				Clear-Host
				infor
			}
			"Información de los drivers instalados"{
				Clear-Host
				dri
			}
			 "Desfragmentación del disco"{
				Clear-Host
				des
			}
        "Salir" {
				Clear-Host	
				Write-Host "Saliendo..." 
				}
		"Optimizar sistema"{
				Clear-Host	
				# Abrir Propiedades del Sistema
				Start-Process "control" -ArgumentList "sysdm.cpl"

				# Abrir Editor del Registro
				Start-Process "regedit"

				# Abrir Liberador de Espacio en Disco
				Start-Process "cleanmgr"
			}
    }
	}while($choice -ne "Salir")
}
function des{
	
	$options = @(
        "Si"
		"No"
    )
	

    "Si"{
        $dis = Read-Host "Ingrese la letra del disco que desea desfragmentar"
        defrag $dis /O
	}
	"No"{
		Clear-Host
	}
    
}
function dri{
		# Obtener información de los drivers
		Get-WmiObject Win32_PnPSignedDriver | Select-Object Manufacturer, DeviceName, DriverVersion

		# Ejecutar DirectX Diagnostic Tool (dxdiag)
		Start-Process "dxdiag"
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
   
    Write-Host "Realizando diagnóstico y reparación del sistema..."


    # Ejecutar comandos de diagnostico y reparacion
    sfc /scannow
    DISM /Online /Cleanup-Image /CheckHealth
    DISM /Online /Cleanup-Image /ScanHealth
    DISM /Online /Cleanup-Image /RestoreHealth


}
function Borrar-Particion {
    $disco = Read-Host "Ingrese el nombre del disco"
	Invoke-Expression "list partition"
    $particion = Read-Host "Ingrese el número de la partición a borrar"

    $diskpartScript = @"
    select disk $disco
    select partition $particion
    delete partition
"@

    $diskpartScript | diskpart

    Write-Host "Partición borrada exitosamente."
}
function Escaneo-Reparacion-Disco {
    $disco = Read-Host "Ingrese el nombre del disco"
	Invoke-Expression "chkdsk $disco /f /r"
    Write-Host "Realizando escaneo y reparación de disco..."
}
function respaldo{
            diskpart
			Get-Volume

			$respaldo = Read-Host "Ingrese la letra del respaldo"
			wbadmin start backup -backuptarget:$respaldo -include:C: -allCritical
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
# Ejecutar el menú
Show-Menu
