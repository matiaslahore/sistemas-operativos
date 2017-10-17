********************************************************************************************
#FIUBA - Sistemas Operativos ( 75.08 ) - Segundo Cuatrimestre 2017
   GRUPO N° 2
        
    Bazzana, Matias 
    Itchart, Maciel 
    Casal, Joaquin
    Sosa, Santiago 
    Lahore, Matias 

********************************************************************************************
   Descarga del paquete
********************************************************************************************
       Usted podra descargar el paquete directemente: https://drive.google.com/open?id=0B5NllDEIfHpOUkx3X01sb25nbWM

********************************************************************************************
   Requisitos de instalación
********************************************************************************************
       Contar con Perl versión 5 o superior.
       Contar con un espacio mínimo superior al especificado para almacenar los datos de las tarjetas.
		
*********************************************************************************************
   Instalación
*********************************************************************************************

	1- Ubicarse en el directorio donde se descargo el archivo 

	2- Descomprimir el archivo Grupo02.tar.gz. con la opcion Click Derecho-->Extraer Aqui.

	3. Luego de esto, se habrá creado la carpeta grupo02 en el directorio donde esta parado 

	4. Para instalar el programa, se deberá ir a la ruta de esta carpeta base mediante la consola y 
	    ejecutar el instalador:

		$ cd {ruta a donde se genero la carpeta grupo02}
		$ cd Grupo02
		$ cd Grupo02
		$ ./installer.sh
	
	5. Luego de haber seguido los pasos de instalación, se podrá ver que se crearon sub carpetas 
	    en /home/{user}/grupo02. Donde {user} es el nombre del usuario. Adentro de la carpeta de 
	    ejecutables encontrara todos los ejecutables que seran las herramientas del programa.
	    
    6. Si se quiere reparar la instalacion, usted puede llamar al instalador y este automaticamente 
        listara los errores y le pedira la confirmacion de la reparación.
        Sino tambien puede llamar al instalador con el paramentro "-r" para repararla manualmente.
        (./installer.sh -r).
		
*********************************************************************************************
Ejecución
*********************************************************************************************

    1. Dirigirse luego a la carpeta definida para los ejecutables (por defecto /bin):
	   
	   	$ cd bin

    2. Luego inicializar el programa mediante el siguiente comando:

		$ ./preparar.sh

    3. Ahora el programa comenzo a ejecutarse automaticamente. Si decide ejecutarlo manualmente 
        puede hacerlo mediante el siguiente comando:
 		$ ./start.sh

    4. Si el usuario quiere detener la ejecucion de este demonio, deberá escribir:

		$ ./stop.sh

************************************************************************************************************************************************
Listado de informacion de los plasticos de las tarjetas	
************************************************************************************************************************************************

    Luego de haber procesado los archivos, se pueden generar consultas e informes usando el comando:
    
        perl LISTADOR.pl
        
    
    MODO MANUAL
    
    Ejemplo de uso:
    ~ perl LISTADOR.pl -i="Plasticos_emitidos_1;Plasticos_emitidos_2" -l="cuentas=ACTIVAS" -f="entidad=2,99;docCuenta=40355277"
    
    Modo de uso: perl LISTADOR.pl [-i]="[inputs]" [-l]="[listado]" [-f]="[filtros]"
    -i	~ Input:
    · Un archivo especifico de lasticos_emitidos o de plasticos_distribucion
    · Varios archivos específicos(de emitidos, de distribucion o de ambos)
    · Todos los archivos de plasticos_emitidos (default)
    ="Plasticos_emitidos"
    · Todos los archivos de plasticos_distribucion
    ="Plasticos_distribucion"
    -l	~ Opciones de listados:
    =cuentas	· Listados de cuentas:
    General 
    =ACTIVAS Cuentas activas
    =BCJ	Cuentas dadas de baja, ctx, o jud
    =tarjetas	· Listados de tarjetas:
    General 
    =denunciadas	Denunciadas
    =bloqueadas	Bloqueadas
    =vencidas Vencidas
    =condDistr	· Listado de condición de distribución
    -> para este listado solo se solicita filtro por condición de distribución
    =cuentaP	· Listado de la situación de una cuenta en particular
    -> para este listado solo se solicita filtro por documento cuenta
    =tarjetaP	· Listado de la situación de una tarjeta en particular
    -> para este listado solo se solicita filtro por documento tarjeta
    -f	~ Opciones de filtros
    =entidad	· Filtro por entidad
    = (una, rango de entidades, todas)
    =fuente	· Filtro por fuente
    = (una o todas)
    =condDistr	· Filtro por condición de distribución (default *)
    = sub-string
    =docCuenta	· Filtro por documento cuenta: (default *)
    = sub-string
    =docTarjeta	· Filtro por documento tarjeta: (default *)
    = sub-string
    
    ';'	-> SEPARADOR DE ARCHIVOS Y FILTROS
    ','	-> SEPARADOR DE RANGOS
    
    *DURANTE LA EJECUCION DEL LISTADOR PERMITE:
    · VOLVER A LISTAR EL INPUT N VECES
    · APLICAR FILTROS N VECES AL LISTADO GENERADO
