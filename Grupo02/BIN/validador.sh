#!/bin/bash

#valida que el archivo seleccionado de la carpeta ACEPTADOS
#no haya sido procesado anteriormente.
function validarProcesado {
	if [ -f $PROCESADOS/$1 ]; then
		#$1 es el nombre de archivo completo (sin path)	

		bash "$EJECUTABLES""$MOVER" "$ACEPTADOS/$1" "$RECHAZADOS" "$DUPLICADOS"
		result=$?

		if [ $result = 0 ]; then #Cayo en rechazados
			MSJ_ERR="El archivo $1 ya ha sido procesado. Ha sido movido hacia la carpeta de rechazados"
		elif [[ $result = 1 || $result = 2 ]]; then #Cayo en duplicados
			MSJ_ERR="El archivo $1 será movido hacia la carpeta de duplicados"
		fi

		bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ALERTA" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR"
		return 0

	else
		return 1
	fi;
	
}

###################################################
# VALIDACIONES DE REGISTRO
###################################################

function validarNroTarjeta {
if [[ $1 =~ [0-9][0-9][0-9][0-9]$ ]]; then
	return 0;
else 
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. EL número de tarjeta es inválido"
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 1;
fi;
}

function validarNroCuenta {
echo $1;
if [[ $1 =~ [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$ ]]; then
	echo $1;
	validarExistenciaNroCuenta $1;
	resp=$?;
	echo $resp;
	return $resp;
else 
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. El número de cuenta es inválido";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 1;
fi;
}

function validarExistenciaNroCuenta {
nroCuenta=`grep $1 $MAESTROS$CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\2/'`;
if [ "$nroCuenta" = "" ]; then 
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La cuenta es inexistente";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 1;
fi;
}

function validarFechas {
#valido "Fecha Desde"
diaDsd=`echo $1 | sed 's|\(.*\)/\(.*\)/\(.*\)|\1|'`;
if ! [[ $diaDsd =~ ^[0-2][0-9]$|^[0-3][0-1]$ ]]; then
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La fecha Desde es inválida";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 1;
fi;
mesDsd=`echo $1 | sed 's|\(.*\)/\(.*\)/\(.*\)|\2|'`;
if ! [[ $mesDsd =~ ^[0][0-9]$|^[1][0-2]$ ]]; then
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La fecha Desde es inválida";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 1;
fi;
anioDsd=`echo $1 | sed 's|\(.*\)/\(.*\)/\(.*\)|\3|'`;
if ! [[ $anioDsd =~ ^[0-9][0-9][0-9][0-9]$ ]]; then
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La fecha Desde es inválida";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 1;
fi;

#valido "Fecha Hasta"
echo $2;
diaHsta=`echo $2 | sed 's|\(.*\)/\(.*\)/\(.*\)|\1|'`;
if ! [[ $diaHsta =~ ^[0-2][0-9]$|^[0-3][0-1]$ ]]; then
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La fecha Hasta es inválida";	
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 1;
fi;
mesHsta=`echo $2 | sed 's|\(.*\)/\(.*\)/\(.*\)|\2|'`;

if ! [[ $mesHsta =~ ^[0][0-9]$|^[1][0-2]$ ]]; then
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La fecha Hasta es inválida";	
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 1;
fi;
anioHsta=`echo $2 | sed 's|\(.*\)/\(.*\)/\(.*\)|\3|'`;
anioHsta=`echo $anioHsta | sed 's/.$//g'` 
if ! [[ $anioHsta =~ ^[0-9][0-9][0-9][0-9]$ ]]; then
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La fecha Hasta es inválida";	
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 1;
fi;
#valido diferencia entre fecha desde y fecha hasta
if [[ $anioDsd -gt $anioHsta ]]; then
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. Fechas inválidas";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 2;	
fi;
if [ $anioDsd -eq $anioHsta ] && [ $mesDsd -gt $mesHsta ]; then
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. Fechas inválidas";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 2;
fi;
if [ $anioDsd -eq $anioHsta ] && [ $mesDsd -eq $mesHsta ] && [ $diaDsd -ge $diaHsta ]; then
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. Fechas inválidas";	
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 2;
fi;

}

function validarNombre {
if [ "$1" = "" ]; then 
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. El nombre no fue informado";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 1;
fi;
}

function validarDocumento {
if [ "$1" = "" ]; then 
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. El documento no fue informado";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	return 1;
fi;
}

###################################################
# FIN VALIDACIONES DE REGISTRO
###################################################

function registrarRegNoValido {
	separador="-"
	rchivoInput=$1 #El script que llama al log
	mensaje=$2 
	registro=$3 
	archivoOutput=$4;
	echo "$archivoInput""$separador""$mensaje""$separador""$registro" >> $archivoOutput
}

function getNroValidador {

for i in $(ls -F $VALIDADOS | sed 's/.*\_//' | sed 's/\..*//');
do	
	if [ $i -gt $NUMERO_SESSION ]; then
		NUMERO_SESSION=$i;
	fi;	
	
done;
NUMERO_SESSION=$((NUMERO_SESSION + 1));
}

#recibe la dirección de una carpeta, si no existe la crea.
function crearDir {
if ! [ -d $1 ]; then 
	mkdir $1;
fi;	
}

#Valido que las variables de entorno hayan sido inicializadas
if [[ -z ${DIRABUS+x} || -z ${ACEPTADOS+x} || -z ${RECHAZADOS+x} || -z ${EJECUTABLES+x} || -z ${MAESTROS+x} || -z ${LOGS+x} || -z ${VALIDADOS+x} ]]; then
	echo "Sistema sin inicializar"
	exit
fi

PROCESADOS="$ACEPTADOS"/procesados
DUPLICADOS="$RECHAZADOS""/dup/"
CUMAE="/cumae"
BAMAE="/bamae"
TX_TARJETAS="/tx_tarjetas"
LOGER="/loger.sh"
LISTADOR="/listador.pl"
LOG_VALIDADOR="/validador.log"
MOVER="/mover.sh"
PLASTICOS_RECHAZADOS="/Plasticos_rechazados.txt"

NUMERO_SESSION=1;

MSJ_ERR="";

REG_OK_POR_ARCH=0;
REG_POR_ARCH=0;
uno=1;
LLAMAR_LISTADOR=0;

MSJ_ERR="El VALIDADOR del DEMONIO comienza."
bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";

#creo carpetas a usar
crearDir $DUPLICADOS;
crearDir $PROCESADOS;
crearDir $VALIDADOS;
crearDir $RECHAZADOS;
#obtengo el número a utilizar en nombre de archivo de validación
getNroValidador

for i in $(ls -F $ACEPTADOS | grep -v '/$');
do  	
	f=${i##*/};

	ENTIDAD_BANCARIA=`echo $f | sed 's/\_.*//'`;
	validarProcesado "$i";
	salida=$?
	if [ "$salida" == 0 ]; then
		continue;
	fi;
	
	MSJ_ERR="Se va a procesar el archivo ""$f";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	
	while read linea
		do 
		
		REG_POR_ARCH=$((REG_POR_ARCH + uno));

		cuenta=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\1/'`
#		cuenta=`echo $linea | sed 's/;.*//'`

		doc=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\2/'`
		nombre=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\3/'`
		nroTarj1=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\4/'`
		nroTarj2=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\5/'`
		nroTarj3=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\6/'`
		nroTarj4=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\7/'`
		fechaDsd=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\8/'`
		fechaHsta=`echo $linea | sed 's/.*;//'`

		validarNroCuenta $cuenta;
		if ! [ $? = 0 ]; then 
			registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$RECHAZADOS$PLASTICOS_RECHAZADOS";
	 		continue; fi;
		 validarNombre $nombre;
		if ! [ $? = 0 ]; then 
			registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$RECHAZADOS$PLASTICOS_RECHAZADOS";
			continue; fi;
		validarDocumento $doc;
		if ! [ $? = 0 ]; then 
			registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$RECHAZADOS$PLASTICOS_RECHAZADOS";
			continue; fi;
		validarNroTarjeta $nroTarj1
		if ! [ $? = 0 ]; then 
			registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$RECHAZADOS$PLASTICOS_RECHAZADOS";
			continue; fi;
		validarNroTarjeta $nroTarj2
		if ! [ $? = 0 ]; then 
			registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$RECHAZADOS$PLASTICOS_RECHAZADOS";
			continue; fi;
		validarNroTarjeta $nroTarj3
		if ! [ $? = 0 ]; then 
			registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$RECHAZADOS$PLASTICOS_RECHAZADOS";
			continue; fi;
		validarNroTarjeta $nroTarj4
		if ! [ $? = 0 ]; then 
			registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$RECHAZADOS$PLASTICOS_RECHAZADOS";
			continue; fi;

		validarFechas $fechaDsd $fechaHsta;
		if ! [ $? = 0 ]; then 
			registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$RECHAZADOS$PLASTICOS_RECHAZADOS";
			continue; fi;
			
		fechaHsta=`echo $fechaHsta | sed 's/.$//g'`	
			
		estadoCuenta=`grep $cuenta $MAESTROS$CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\8/'`
		documentoCuenta=`grep $cuenta $MAESTROS$CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\3/'`
		denominacionCuenta=`grep $cuenta $MAESTROS$CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\4/'`
		fechaAlta=`grep $cuenta $MAESTROS$CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\5/'`
		categoria=`grep $cuenta $MAESTROS$CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\6/'`
		limite=`grep $cuenta $MAESTROS$CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\7/'`
	
		alias=`grep $ENTIDAD_BANCARIA $MAESTROS$BAMAE | sed 's/\(.*\);\(.*\);\(.*\)/\2/'`
	
		estadoCuenta=`echo $estadoCuenta | sed 's/.$//g'`;
		
		cant=`fgrep -o $cuenta $MAESTROS$TX_TARJETAS | wc -l `
	
		if ! [ $cant -gt 1 ]; then
			tarjVieja="1";
			denunciada=`grep $cuenta $MAESTROS$TX_TARJETAS | grep "Entregada" | sed 's/.*;\([0-2]\);\([0-2]\);.*/\1/'`;
			denunciada=`echo $denunciada | sed 's/[0-2].*\ //'`;
			bloqueada=`grep $cuenta $MAESTROS$TX_TARJETAS | grep "Entregada" | sed 's/.*;\([0-2]\);\([0-2]\);.*/\2/'`;
			bloqueada=`echo $bloqueada | sed 's/[0-2].*\ //'`;
		else 	
			tarjVieja="0";
			denunciada=0;
			bloqueada=0;
		fi;
	
		regOK=$i\;$cuenta\;$estadoCuenta\;$tarjVieja\;$denunciada\;$bloqueada\;\ \;\ \;$doc\;$nombre\;$nroTarj1\;$nroTarj2\;$nroTarj3\;$nroTarj4\;$fechaDsd\;$fechaHsta\;$documentoCuenta\;$denominacionCuenta\;$fechaAlta\;$categoria\;$limite\;$ENTIDAD_BANCARIA\;$alias;	

		echo $regOK >> $VALIDADOS"/Plasticos_emitidos_$NUMERO_SESSION";
	
		REG_OK_POR_ARCH=$((REG_OK_POR_ARCH + uno));
	
		MSJ_ERR="Registro n°""$REG_POR_ARCH"": ACEPTADO.";
		bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	
	done < $ACEPTADOS/$i;
	
	#logeo cuantos registros se aceptaron/rechazaron en el archivo recientemente recorrido.
	MSJ_ERR="Se aceptaron ""$REG_OK_POR_ARCH"" registros del archivo ""$f";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	REG_RECH_POR_ARCH=$((REG_POR_ARCH - REG_OK_POR_ARCH));
	MSJ_ERR="Se rechazaron ""$REG_RECH_POR_ARCH"" registros del archivo ""$f";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	
	LLAMAR_LISTADOR=$((LLAMAR_LISTADOR + REG_OK_POR_ARCH));	
	
	REG_POR_ARCH=0;
	REG_OK_POR_ARCH=0;
	REG_RECH_POR_ARCH=0;

	mv $ACEPTADOS/$i $PROCESADOS/$i;
	
done;

MSJ_ERR="El VALIDADOR del DEMONIO terminó."
bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";


#Chequeo que haya información para llamar al listador
if [ $LLAMAR_LISTADOR -gt 0 ]; then
	#Chequeo que el listador no esté corriendo.
	proc_listador=`ps -ef | grep -c "$LISTADOR"`
	if [[ $proc_listador -eq 1 ]]; then #Valido que el validador no este corriendo
		MSJ_ERR="Se llamará al listador."
		bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
		perl "$EJECUTABLES""$LISTADOR";
	else 	
		MSJ_ERR="No se pudo llamar al listador porque ya está corriendo."
		bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
	fi;	
	
else 
	MSJ_ERR="No hay información para llamar al listador."
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""$LOG_VALIDADOR";
fi;