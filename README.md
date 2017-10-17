********************************************************************************************
#FIUBA - Sistemas Operativos ( 75.08 ) - Segundo Cuatrimestre 2017
   GRUPO N° 2
        
    , 
    , 
    , 
    , 
    Lahore, Matias 

********************************************************************************************
   Descarga del paquete
********************************************************************************************
       Usted podra descargar el paquete directemente: http:// Grupo02.tgz.gz

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
		$ cd grupo02
		$ cd installer
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

    3. Ahora el programa comenzo a ejecutarse automaticamente. Si decide ejecutarlo manualmente puede hacerlo mediante el siguiente comando:
	   
 		$ ./start.sh

    4. Si el usuario quiere detener la ejecucion de este demonio, deberá escribir:

		$ ./stop.sh

************************************************************************************************************************************************
Listado de informacion de los plasticos de las tarjetas	
************************************************************************************************************************************************

    Luego de haber procesado los archivos, se pueden generar consultas e informes usando el comando:
    
        listador.pl 