#!/bin/bash

###############################################################################################################
# El propósito de este script es asegurar que esten dadas todas las condiciones para la ejecucion del sistema #
# Debe proveer los siguientes escenarios: 																	  #
# - El sistema nunca fue inicializado																		  #
# - El sistema ya fue inicializado exitosamente																  #
# - El sistema no puede ser inicializado																	  #
###############################################################################################################

export GRUPO="$HOME"/Grupo02
export CONFDIR="$GRUPO"/dirconf
CONFARCH="$CONFDIR"/config.conf

#chmod +w $LOGS/preparar.log
chmod +x loger.sh

LOGER=loger.sh
SCRIPT="preparar.sh"

#####################################################################
# Verificar que las variables no estan inicializadas				#
# si lo están es porque el sistema ya fue inicializado exitosamente	#
#####################################################################

continuar_proceso="false"
variables=( "$EJECUTABLES" "$MAESTROS" "$ACEPTADOS" ) #"$RECHAZADOS" "$VALIDADOS" "$REPORTES" "$LOGS" )
size=${#variables[@]}

for (( i=0;i<$size;i++ )); do

	var=${variables[${i}]}
	if [ "" = "$var" ]; then
		# Si al menos una variable de ambiente se encuentra vacia debere setear el ambiente
		continuar_proceso="true"
	fi
	
done

if [ $continuar_proceso = "false" ]; then
	echo "Ambiente ya inicializado, si quiere reiniciar termine su sesión e ingrese nuevamente"
	sleep 3
	./$LOGER "$SCRIPT" "Alerta" "Ambiente ya inicializado" "$LOGS"/preparar.log
	exit 
fi

####################################
# Setear las variables de ambiente #
####################################

echo "Seteando variables de ambiente..."

LOGS=$(grep "logs" "$CONFARCH")
LOGS=$(echo $LOGS| cut -d'-' -f2)
export LOGS
./$LOGER "$SCRIPT" "Informativo" "Se exporto la variable LOGS" "$LOGS"/preparar.log

EJECUTABLES=$(grep "ejecutables" "$CONFARCH")
EJECUTABLES=$(echo $EJECUTABLES| cut -d'-' -f2)
export EJECUTABLES
./$LOGER "$SCRIPT" "Informativo" "Se exporto la variable EJECUTABLES" "$LOGS"/preparar.log

MAESTROS=$(grep "maestros" "$CONFARCH")
MAESTROS=$(echo $MAESTROS| cut -d'-' -f2)
export MAESTROS
./$LOGER "$SCRIPT" "Informativo" "Se exporto la variable MAESTROS" "$LOGS"/preparar.log

ACEPTADOS=$(grep "aceptados" "$CONFARCH")
ACEPTADOS=$(echo $ACEPTADOS| cut -d'-' -f2)
export ACEPTADOS
./$LOGER "$SCRIPT" "Informativo" "Se exporto la variable ACEPTADOS" "$LOGS"/preparar.log

RECHAZADOS=$(grep "rechazados" "$CONFARCH")
RECHAZADOS=$(echo $RECHAZADOS| cut -d'-' -f2)
export RECHAZADOS
./$LOGER "$SCRIPT" "Informativo" "Se exporto la variable RECHAZADOS" "$LOGS"/preparar.log

VALIDADOS=$(grep "validados" "$CONFARCH")
VALIDADOS=$(echo $VALIDADOS| cut -d'-' -f2)
export VALIDADOS
./$LOGER "$SCRIPT" "Informativo" "Se exporto la variable VALIDADOS" "$LOGS"/preparar.log

REPORTES=$(grep "reportes" "$CONFARCH")
REPORTES=$(echo $REPORTES| cut -d'-' -f2)
export REPORTES
./$LOGER "$SCRIPT" "Informativo" "Se exporto la variable REPORTES" "$LOGS"/preparar.log

./$LOGER "$SCRIPT" "Informativo" "Las variables fueron seteadas exitosamente" "$LOGS"/preparar.log


##############################################
# Verificar que la instalacion este completa #
##############################################

for LINEA in $(cat "$CONFARCH"); do

	path=$(echo $LINEA | cut -d'-' -f2 )

	if [ -d $path ]; then
		./$LOGER "$SCRIPT" "Informativo" "El directorio $path existe" "$LOGS"/preparar.log
	else
		./$LOGER "$SCRIPT" "Error" "No se encontro el directorio $path, es necesario ejecutar el instalador instalador.sh" "$LOGS"/preparar.log
		echo "No se encontro el directorio $path, es necesario ejecutar el instalador instalador.sh"
		sleep 5
		exit 
	fi

done

./$LOGER "$SCRIPT" "Informativo" "La instalacion esta completa" "$LOGS"/preparar.log

############################################################
# Verificar que los archivos tengan los permisos adecuados #
############################################################

count=1
for LINEA in $(cat "$CONFARCH"); do

	path=$(echo $LINEA | cut -d'-' -f2)

	if [ $count -eq 1 ]; then
		for NOMBRE in $( ls "$path" ); do
			if [ -x $NOMBRE ]; then
				./$LOGER "$SCRIPT" "Informativo" "El archivo $NOMBRE tiene permisos de ejecucion" "$LOGS"/preparar.log
			else
				./$LOGER "$SCRIPT" "Alerta" "El archivo $NOMBRE no tiene permisos de ejecucion, seteando permisos..." "$LOGS"/preparar.log
				chmod +x "$path"/"$NOMBRE"
				./$LOGER "$SCRIPT" "Informativo" "Permisos de ejecuccion listos" "$LOGS"/preparar.log
			fi
		done
	else
		for NOMBRE in $( ls "$path" ); do
			if [ -r $NOMBRE ]; then
				./$LOGER "$SCRIPT" "Informativo" "El archivo $NOMBRE tiene permisos de lectura" "$LOGS"/preparar.log
			else
				./$LOGER "$SCRIPT" "Alerta" "El archivo $NOMBRE no tiene permisos de lectura, seteando permisos..." "$LOGS"/preparar.log
				chmod +r "$path"/"$NOMBRE"
				./$LOGER "$SCRIPT" "Informativo" "Permisos de escritura listos" "$LOGS"/preparar.log
			fi
		done	
	fi
	
	if [ $count -eq 2 ]; then
		break
	fi
	count=$[$count+1]

done


############################################################
# Solicitar al usuario que eliga el LINEA de busqueda #
############################################################

read -p "Ingrese la ruta en el cual quiere buscar el archivo de input: " DIRABUS

while ! [ -d $DIRABUS ]; do
	echo "La ruta ingresada no es valida. Por favor ingrese una ruta valida."
	read -p "" DIRABUS
done

export DIRABUS

./$LOGER "$SCRIPT" "Informativo" "Se exporto la variable DIRABUS exitosamente" "$LOGS"/preparar.log

#############################
# Invocar al script demonio #
#############################

chmod +x demonio.sh
chmod +x stop.sh

./demonio.sh &

PROCESO=$(ps | grep demonio)

IDPROCESO=$(echo $PROCESO| cut -d' ' -f 1)

echo "Se ha invocado al demonio, su ID de proceso es: $IDPROCESO"

./$LOGER "$SCRIPT" "Informativo" "Se ejecuto el script demonio.sh, su ID es $IDPROCESO" "$LOGS"/preparar.log


echo "Para finalizar el demonio escriba: ./stop.sh"


