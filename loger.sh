#Script auxiliar para logear respetando w5
#Recibe cuatro parámetros

separador="-"
fecha=$(date '+%d/%m/%Y %H:%M:%S');
usuario=$(whoami)
rutina=$1 #El script que llama al log
tipo=$2 #Tipo de mensaje (Informativo, Error, Alerta)
mensaje=$3 #Mensaje de log
archivo=$4 #Archivo de log

echo "$fecha""$separador""$usuario""$separador""$rutina""$separador""$tipo""$separador""$mensaje" >> $archivo