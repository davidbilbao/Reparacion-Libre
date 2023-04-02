@echo off
color a 
title Reparacion y diagnostico
mode 120, 120
:inicio

echo                              Menu											 

echo.1.Diagnostico  , analisis y reparacion del sistema													 
echo.2.Escaneo y reparacion de disco 							 
echo.3.Opciones de inicio						 
echo.4.Hacer un backud															 
echo.5.Actualizar programas y drivers
echo.6.Todas las caracteristicas del sistema
echo.7.Crear particiones
echo.8.Reparar Windows Update
echo.9.Restaurar el sistema


echo.10.Borrar archivos basura

echo.11.Instalar programa
echo.12.Salir

set /p menu=opcion=

case "$menu" in
	  1) op1 ;
		cls
		sfc /scannow
		DISM /Online /Cleanup-Image /CheckHealth
		DISM /Online /Cleanup-Image /ScanHealth
		DISM /Online /Cleanup-Image /RestoreHealth
		pause>nul
		goto inicio
			;
  2) op2 ; 
		cls
		echo El nombre del disco
		set /p disco=Disco= 
		chkdsk "%disco%": /f /r
		pause>nul
		goto inicio
  
  ;
  3) op3 ;
		cls 
		msconfig 

		goto inicio
  ;
  4) op4 ;
		  cls
		diskpart
		list volume
		echo Escoge donde quiere realizar el backud
		set /p respaldo=Respaldo=
		wbadmin start backup - backuptarget:"%respaldo%": -incluide:C: -allCritical
		pause>nul
		goto inicio
  ;
  5) op5 ;
		cls
		winget upgrade--all
		pause>nul
		goto inicio
  ;
  6) op6 ;
		cls
		driverquery
		systeminfo
		pause>nul
		goto inicio
  
  ;
  7) op7 ;
		cls
		diskpart
		list disk
		echo Escoge el disco que quiere particionar
		set /p disco=Disco=
		select disk "%disco%"
		list partition
		echo escriba que tipo de particion quiere
		set /p particion=Particion=
		echo escriba el tamaño de la aprticion
		set /p crear=Crear=
		ceate partition "%particion%" size="%crear%"
		list partition
		echo numero de la particion
		set /p num=Num=
		seletition partition "%num%"
		echo escriba nombre 
		set /p nom=Nom
		format fs=NTFS label="%nom%" quick
		echo escriba la letra que quiere asignar
		set /p let=Let
		assign letter="%let%"
		pause>nul
		goto inicio
  ;
  8) op8 ;
		 cls
		net stop wuaserv
		net stop bits
		net start wuauserv
		net start bits
		pause>nul
		goto inicio
  
  ;
  9) op9 ;
		cls
		rstrui.exe
		pause>nul
		goto inicio
  ;
  10) op10 ;
		cls
		cd..
		cd..
		cd Users
		dir
		echo Escriba su usuario
		set /p direccion=Dirrecion=
		cd "%dirrecion%"
		cd AppData
		cd Roaming
		del *
		cd..
		cd..
		cd..
		cd..
		cd Windows
		cd Prefetch
		del *
		pause>nul
		goto inicio
  ;
  11) op11 ;
		cls
		echo El nombre del programa que vas a instalar
		set /p programa=Programa= 
		winget install "%programa%"
		  ;
  12) salir ;
		exit
		pause>nul
  ;
  *) echo "Opcion invalida" ;
  pause>nul
  goto inicio ;
esac
