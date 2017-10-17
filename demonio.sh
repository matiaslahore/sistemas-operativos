#Valido que las variables de entorno hayan sido inicializadas
if [[ -z ${DIRABUS+x} || -z ${ACEPTADOS+x} || -z ${RECHAZADOS+x} || -z ${EJECUTABLES+x} || -z ${MAESTROS+x} || -z ${LOGS+x} ]]; then
	echo "Sistema sin inicializar"
	exit
fi

#Variabes utilizadas en la rutina
VALIDADOR="/validador.sh"
LOGER="/loger.sh"
MOVER="/mover.sh"
BAMAE="/bamae"
LOG_DEMONIO="/demonio.log"
ACEPTADOS_DUP="$ACEPTADOS""/dup/"
RECHAZADOS_DUP="$RECHAZADOS""/dup/"
CICLO=1
ENTIDADES=()
LIMITE_LOG=50
LIMITE_CICLOS=100
DORMIR=30

#Mensajes
M_NOV_ACEPTADA="Novedad aceptada: "
M_NOV_RECHAZADA="Novedad rechazada: "
M_ENT_INEXISTENTE="Entidad inexistente"
M_FECHA_INV="Fecha inválida"
M_FECHA_ADELANT="Fecha adelantada"
M_ARCH_VACIO="Archivo vacío"
M_ARCH_INVAL="Archivo inválido"
M_INFO="Informativo"
M_ERROR="Error"
M_VALIDADOR_INVOC="Validador invocado. PID: "
M_VALIDADOR_POST="Invocación del Validador pospuesta para el siguiente ciclo"
DEMONIO="DEMONIO"


#Guardo las entidades del archivo maestro en un array
while read -r linea
do
	entidad=$(echo $linea | sed 's/;.*//')
	ENTIDADES+=($entidad)
done < <(sed 1d "$MAESTROS""$BAMAE") #Salteo la primer linea de encabezado


while true
do
	novedades=()

	#Itero sobre cada archivo cuyo nombre cumple el patron buscado y hago validaciones
	while read novedad
	do
		mensaje_ciclos="Ciclo número "$CICLO

		#Validar existencia de entidad
		existe_entidad=false
		for entidad in "${ENTIDADES[@]}"
		do
			ent=${novedad##*/}; ent=${ent%%_*}
			if [ $ent -eq "${entidad}" ]; then
				existe_entidad=true
				break
			fi
		done

		if [ "$existe_entidad" == false ]; then
			mensaje="$mensaje_ciclos"", ""$M_NOV_RECHAZADA""$novedad"". ""$M_ENT_INEXISTENTE"
			bash "$EJECUTABLES""$LOGER" "$DEMONIO" "$M_ERROR" "$mensaje" "$LOGS""$LOG_DEMONIO"
			continue
		fi


		#Fecha invalida
		fecha_novedad=${novedad#*_}; fecha_novedad=${fecha_novedad%%.*}
		if [[ ! $fecha_novedad =~ [0-9]{4}[0-1][0-9][0-3][0-9] ]]; then
			mensaje="$mensaje_ciclos"", ""$M_NOV_RECHAZADA""$novedad"". ""$M_FECHA_INV"
			bash "$EJECUTABLES""$LOGER" "$DEMONIO" "$M_ERROR" "$mensaje" "$LOGS""$LOG_DEMONIO"
			continue
		fi


		#Fecha adelantada
		fecha_hoy=$(echo $(date +%F) | sed 's/-//g')
		if [[ "$fecha_novedad" -gt "$fecha_hoy" ]]; then
			mensaje="$mensaje_ciclos"", ""$M_NOV_RECHAZADA""$novedad"". ""$M_FECHA_ADELANT"
			bash "$EJECUTABLES""$LOGER" "$DEMONIO" "$M_ERROR" "$mensaje" "$LOGS""$LOG_DEMONIO"
			continue
		fi

		novedades+=("$novedad")

	done < <(find "$DIRABUS" -regextype sed -regex ".*/[0-9]\{3\}_[0-9]\{8\}\.txt" -type f) #Validaciones

	#Itero sobre las novedades cuyo nombre cumplieron con el patron y veo que hago con ellas
	for novedad in "${novedades[@]}"
	do

		#Valido que el archivo no este vacio
		if [ ! -s "$novedad" ]; then
			mensaje="$mensaje_ciclos"", ""$M_NOV_RECHAZADA""$novedad"". ""$M_ARCH_VACIO"
			bash "$EJECUTABLES""$LOGER" "$DEMONIO" "$M_ERROR" "$mensaje" "$LOGS""$LOG_DEMONIO"
			bash "$EJECUTABLES""$MOVER" "$novedad" "$RECHAZADOS" "$RECHAZADOS_DUP"
			continue
		fi


		#Valido que sea un archivo de texto
		mime_type=$(file -i "$novedad" | cut -d' ' -f2)
		if [ ! "$mime_type" == "text/plain;" ]; then
			mensaje="$mensaje_ciclos"", ""$M_NOV_RECHAZADA""$novedad"", ""$M_ARCH_INVAL"
			bash "$EJECUTABLES""$LOGER" "$DEMONIO" "$M_ERROR" "$mensaje" "$LOGS""$LOG_DEMONIO"
			bash "$EJECUTABLES""$MOVER" "$novedad" "$RECHAZADOS" "$RECHAZADOS_DUP"
			continue
		fi


		#Novedad aceptada
		mensaje="$mensaje_ciclos"", ""$M_NOV_ACEPTADA""$novedad"
		bash "$EJECUTABLES""$LOGER" "$DEMONIO" "$M_INFO" "$mensaje" "$LOGS""$LOG_DEMONIO"
		bash "$EJECUTABLES""$MOVER" "$novedad" "$ACEPTADOS" "$ACEPTADOS_DUP"

	done

	aceptados=$(find "$ACEPTADOS" -maxdepth 1 -type f | wc -l) #Cuento cuantas novedades aceptadas hay
	
	if [ ! $aceptados -eq 0 ]; then #Valido que haya archivos en el directorio de aceptados

		if [[ $(ps -ef | grep "$VALIDADOR") ]]; then #Valido que el validador no este corriendo
			bash "$EJECUTABLES""$VALIDADOR" &
			pid_validador=$!
			mensaje="$mensaje_ciclos"", ""$M_VALIDADOR_INVOC"$pid_validador
			bash "$EJECUTABLES""$LOGER" "$DEMONIO" "$M_INFO" "$mensaje" "$LOGS""$LOG_DEMONIO"
		
		else
			mensaje="$mensaje_ciclos"", ""$M_VALIDADOR_POST"
			bash "$EJECUTABLES""$LOGER" "$DEMONIO" "$M_INFO" "$mensaje" "$LOGS""$LOG_DEMONIO"
		fi
	fi


	let CICLO=CICLO+1

	if [ $CICLO -gt $LIMITE_CICLOS ]; then #Chequeo si hay que truncar el log
		tail -n $LIMITE_LOG "$LOGS""$LOG_DEMONIO" > "$LOGS""$LOG_DEMONIO".tmp
		mv -f "$LOGS""$LOG_DEMONIO".tmp "$LOGS""$LOG_DEMONIO"
	fi

	sleep $DORMIR
done