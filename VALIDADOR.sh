#!/bin/bash

#valida que el archivo seleccionado de la carpeta ACEPTADOS
#no haya sido procesado anteriormente.
function validarProcesado {
	f=${1##*/};
	if [ -f $PATH_PROCESADOS/$f ]; then
		echo "El archivo $1 ya ha sido procesado";
		validarDuplicado "$f";	
		if [ $? = 0 ]; then
			mv $PATH_ACEPTADOS/$f $PATH_RECHAZADOS;
			MSJ_ERR="El archivo $1 ya ha sido procesado. Ha sido movido hacia la carpeta de rechazados";
			bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ALERTA" "$MSJ_ERR" "$LOGS""validador.log";
			echo "El archivo $f se movió a la carpeta de rechazados";
			return 0;
		fi;
	else 
		echo "El archivo $f se va a procesar";
		return 1; 
	fi; 
	
}

#Si entra acá es porque el archivo de la carpeta ACEPTADOS ya fue procesado
#y verifica que no esté en la carpeta de RECHAZADOS; si no está, lo mueve allí; y si ya está
#en RECHAZADOS, lo mueve a la carpeta de DUPLICADOS cambiandole el nombre al archivo para no perderlo.
function validarDuplicado {
	if [ -f $PATH_RECHAZADOS/$1 ]; then
		echo "El archivo $1 está duplicado";
		f=`echo $1 | sed 's/\..*//'`;
		ext=".txt";
		echo "el archivo se va a llamar $f$NUMERO_ARCH$ext";
		uno=1;
		mv $PATH_ACEPTADOS/$1 $PATH_ACEPTADOS/$f$NUMERO_ARCH$ext;
		mv $PATH_ACEPTADOS/$f$NUMERO_ARCH$ext $PATH_DUPLICADOS;
		MSJ_ERR="El archivo $1 será movido hacia la carpeta de duplicados con el nombre de $f$NUMERO_ARCH$ext";
		bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ALERTA" "$MSJ_ERR" "$LOGS""validador.log";
		echo "El archivo $f$NUMERO_ARCH$ext se movió a la carpeta de duplicados";
		let NUMERO_ARCH=$NUMERO_ARCH+$uno;
		echo "el numero arch es: $NUMERO_ARCH";
		return 2;
	fi; 
	return 0;
}

###################################################
# VALIDACIONES DE REGISTRO
###################################################

function validarNroTarjeta {
echo "el argumento a vaidar es $1";
if [[ $1 =~ [0-9][0-9][0-9][0-9]$ ]]; then
	echo "el argumento ""$1"" es válido";
	return 0;
else 
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. EL número de tarjeta es inválido"
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	echo "El argumento ""$1"" NO es válido"; 
	return 1;
fi;
}

function validarNroCuenta {
echo "el argumento a validar es $1";
if [[ $1 =~ [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$ ]]; then
	echo "el nro de cuenta: $1 es válido";
	validarExistenciaNroCuenta $1;
	return $?;
else 
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. El número de documento es inválido";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	echo "El nro de cuenta: $1 NO es válido"; 
	return 1;
fi;
}

function validarExistenciaNroCuenta {
echo "el argumento a validar es $1";
nroCuenta=`grep $1 $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\2/'`
echo "el nro de cuenta encontrado es: $nroCuenta";
if [ "$nroCuenta" = "" ]; then 
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La cuenta es inexistente";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	echo "la cuenta NO fue encontrada"; 
	return 1;
fi;
}

function validarFechas {
echo "estoy validando fechas";
#valido "Fecha Desde"
diaDsd=`echo $1 | sed 's|\(.*\)/\(.*\)/\(.*\)|\1|'`;
if ! [[ $diaDsd =~ ^[0-2][0-9]$|^[0-3][0-1]$ ]]; then
	echo "el diaDsd $diaDsd NOO es válido"; 
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La fecha Desde es inválida";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	return 1;
fi;
mesDsd=`echo $1 | sed 's|\(.*\)/\(.*\)/\(.*\)|\2|'`;
if ! [[ $mesDsd =~ ^[0][0-9]$|^[1][0-2]$ ]]; then
	echo "el mesDsd $mesDsd NOO es válido";
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La fecha Desde es inválida";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	return 1;
fi;
anioDsd=`echo $1 | sed 's|\(.*\)/\(.*\)/\(.*\)|\3|'`;
if ! [[ $anioDsd =~ ^[0-9][0-9][0-9][0-9]$ ]]; then
	echo "el añoDsd $anioDsd NOO es válido";
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La fecha Desde es inválida";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	return 1;
fi;

#valido "Fecha Hasta"
diaHsta=`echo $2 | sed 's|\(.*\)/\(.*\)/\(.*\)|\1|'`;
if ! [[ $diaHsta =~ ^[0-2][0-9]$|^[0-3][0-1]$ ]]; then
	echo "el diaH $diaHsta NOO es válido"; 
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La fecha Hasta es inválida";	
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	return 1;
fi;
mesHsta=`echo $2 | sed 's|\(.*\)/\(.*\)/\(.*\)|\2|'`;

if ! [[ $mesHsta =~ ^[0][0-9]$|^[1][0-2]$ ]]; then
	echo "el mesH $mesHsta NOO es válido";
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La fecha Hasta es inválida";	
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	return 1;
fi;
anioHsta=`echo $2 | sed 's|\(.*\)/\(.*\)/\(.*\)|\3|'`;
anioHsta=`echo $anioHsta | sed 's/.$//g'` 
if ! [[ $anioHsta =~ ^[0-9][0-9][0-9][0-9]$ ]]; then
	echo "año inválido: $anioHsta aaaa";
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. La fecha Hasta es inválida";	
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	return 1;
fi;
echo "$diaDsd vs $diaHsta";
echo "$mesDsd vs $mesHsta";
echo "$anioDsd vs $anioHsta";

#valido diferencia entre fecha desde y fecha hasta
if [[ $anioDsd -gt $anioHsta ]]; then
	echo "el año desde $anioDsd es mayor que el año hasta $anioHsta";
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. Fechas inválidas";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	return 2;	
fi;
if [ $anioDsd -eq $anioHsta ] && [ $mesDsd -gt $mesHsta ]; then
	echo "el mes desde es mayor que el mes hasta";
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. Fechas inválidas";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	return 2;
fi;
if [ $anioDsd -eq $anioHsta ] && [ $mesDsd -eq $mesHsta ] && [ $diaDsd -ge $diaHsta ]; then
	echo "el dia desde es mayor que el dia hasta";
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. Fechas inválidas";	
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	return 2;
fi;

echo "fechas válidas";
}

function validarNombre {
if [ "$1" = "" ]; then 
	echo "el nombre no fué informado";
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. El nombre no fue informado";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	return 1;
fi;
}

function validarDocumento {
if [ "$1" = "" ]; then 
	echo "el documento no fue informado";
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ERROR. El documento no fue informado";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";
	return 1;
fi;
}

###################################################
# FIN VALIDACIONES DE REGISTRO
###################################################

function registrarRegNoValido {
separador="-"
archivoInput=$1 #El script que llama al log
mensaje=$2 
registro=$3 
archivoOutput=$4;
echo "El archivo de output es: $archivoOutput";
#archivoOutput=$4 
echo " El registro rechazado es $archivoInput""$separador""$mensaje""$separador""$registro"" a ingresar en ""$archivoOutput";
echo "$archivoInput""$separador""$mensaje""$separador""$registro" >> $archivoOutput
}

function getNroValidador {

for i in $(ls -F $PATH_VALIDADOS | sed 's/.*\_//' | sed 's/\..*//');
do	
	echo $i;
	if [ $i -gt $NUMERO_SESSION ]; then
		NUMERO_SESSION=$i;
	fi;	
	
done;
echo "El ultimo número es: $NUMERO_SESSION";
NUMERO_SESSION=$((NUMERO_SESSION + 1));
echo "El archivo validador será el nro°$NUMERO_SESSION";
}

PATH_ACEPTADOS="/home/maciel/Documentos/SISOP/TP/aceptados";
PATH_PROCESADOS="/home/maciel/Documentos/SISOP/TP/aceptados/procesados";
PATH_RECHAZADOS="/home/maciel/Documentos/SISOP/TP/rechazados";
PATH_DUPLICADOS="/home/maciel/Documentos/SISOP/TP/duplicados";
PATH_VALIDADOS="/home/maciel/Documentos/SISOP/TP/validados";
PATH_RECHAZADOS="/home/maciel/Documentos/SISOP/TP/rechazados";
PATH_CUMAE="/home/maciel/Documentos/SISOP/TP/mandodatostpmaestrosyalgunasnovedades/cumae";
PATH_BAMAE="/home/maciel/Documentos/SISOP/TP/mandodatostpmaestrosyalgunasnovedades/bamae";
PATH_TARJETAS="/home/maciel/Documentos/SISOP/TP/mandodatostpmaestrosyalgunasnovedades/tx_tarjetas";
LOGER="loger.sh";
LISTADOR="listador.sh";
LOGS="/home/maciel/Documentos/SISOP/TP/logs/";
LOGS_VALIDADOR="validador.log";
EJECUTABLES="/home/maciel/Documentos/SISOP/TP/ejecutables/";
PATH_REG_RECHAZADOS="/home/maciel/Documentos/SISOP/TP/rechazados/Plasticos_rechazados.txt";

NUMERO_ARCH=3;
NUMERO_SESSION=1;

MSJ_ERR="";

REG_OK_POR_ARCH=0;
REG_POR_ARCH=0;
uno=1;
LLAMAR_LISTADOR=0;

MSJ_ERR="El VALIDADOR del DEMONIO comienza."
bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";

getNroValidador

for i in $(ls -F $PATH_ACEPTADOS | grep -v '/$');
do  	
	echo $i;
	f=${i##*/};
	ENTIDAD_BANCARIA=`echo $f | sed 's/\_.*//'`;
	echo "La entidad bancaria es: $ENTIDAD_BANCARIA";
	validarProcesado "$i";
	if [ "$?" == 0 ]; then
		continue;
	fi;
	
	MSJ_ERR="Se va a procesar el archivo ""$f";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMACIÓN" "$MSJ_ERR" "$LOGS""validador.log";
	echo "voy a procesar";
	
	while read linea
		do echo "la línea es: $linea";
		
		REG_POR_ARCH=$((REG_POR_ARCH + uno));
		
	cuenta=`echo $linea | sed 's/;.*//'`

	doc=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\2/'`
	nombre=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\3/'`
	nroTarj1=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\4/'`
	nroTarj2=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\5/'`
	nroTarj3=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\6/'`
	nroTarj4=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\7/'`
	fechaDsd=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\8/'`
	fechaHsta=`echo $linea | sed 's/.*;//'`
	echo "El alrgumento 1 es: $cuenta";
	echo "El alrgumento 2 es: $doc";
	echo "El alrgumento 3 es: $nombre";
	echo "El alrgumento 4 es: $nroTarj1";
	echo "El alrgumento 5 es: $nroTarj2";
	echo "El alrgumento 6 es: $nroTarj3";
	echo "El alrgumento 7 es: $nroTarj4";
	echo "El alrgumento 8 es: $fechaDsd";
	echo "El alrgumento 9 es: $fechaHsta";
	
	echo "El arch de reg rechazados es $PATH_REG_RECHAZADOS";

	validarNroCuenta $cuenta;
	if ! [ $? = 0 ]; then 
		registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$PATH_REG_RECHAZADOS";
		continue; fi;
	validarNombre $nombre;
	if ! [ $? = 0 ]; then 
		registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$PATH_REG_RECHAZADOS";
		continue; fi;
	validarDocumento $doc;
	if ! [ $? = 0 ]; then 
		registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$PATH_REG_RECHAZADOS";
		continue; fi;
	validarNroTarjeta $nroTarj1
	if ! [ $? = 0 ]; then 
		registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$PATH_REG_RECHAZADOS";
		continue; fi;
	validarNroTarjeta $nroTarj2
	if ! [ $? = 0 ]; then 
		registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$PATH_REG_RECHAZADOS";
		continue; fi;
	validarNroTarjeta $nroTarj3
	if ! [ $? = 0 ]; then 
		registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$PATH_REG_RECHAZADOS";
		continue; fi;
	validarNroTarjeta $nroTarj4
	if ! [ $? = 0 ]; then 
		registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$PATH_REG_RECHAZADOS";
		continue; fi;

	validarFechas $fechaDsd $fechaHsta;
	if ! [ $? = 0 ]; then 
		registrarRegNoValido "$f" "$MSJ_ERR" "$linea" "$PATH_REG_RECHAZADOS";
		continue; fi;

	echo $PATH_VALIDADOS"/Plasticos_aceptados_$NUMERO_SESSION.txt";
	
	estadoCuenta=`grep $cuenta $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\8/'`
	documentoCuenta=`grep $cuenta $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\3/'`
	denominacionCuenta=`grep $cuenta $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\4/'`
	fechaAlta=`grep $cuenta $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\5/'`
	categoria=`grep $cuenta $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\6/'`
	limite=`grep $cuenta $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\7/'`
	
	alias=`grep $ENTIDAD_BANCARIA $PATH_BAMAE | sed 's/\(.*\);\(.*\);\(.*\)/\2/'`
	
	estadoCuenta=`echo $anioHsta | sed 's/.$//g'`;
	
	echo $estadoCuenta;
	echo $documentoCuenta;
	echo $denominacionCuenta;
	echo $fechaAlta;
	echo $categoria;
	echo $limite;
	echo $ENTIDAD_BANCARIA;
	echo $alias;
	
	cant=`fgrep -o $cuenta $PATH_TARJETAS | wc -l `
	
	echo "La cantidad de tarjetas anteriores es $cant";
	
	if ! [ $cant -gt 1 ]; then
		tarjVieja="SI";
	
		denunciada=`grep $cuenta $PATH_TARJETAS | grep "Entregada" | sed 's/.*;\([0-2]\);\([0-2]\);.*/\1/'`;
		echo $denunciada;
		denunciada=`echo $denunciada | sed 's/[0-2].*\ //'`;
		echo $denunciada;
	
		bloqueada=`grep $cuenta $PATH_TARJETAS | grep "Entregada" | sed 's/.*;\([0-2]\);\([0-2]\);.*/\2/'`;
		echo $bloqueada;
		bloqueada=`echo $bloqueada | sed 's/[0-2].*\ //'`;
		echo $bloqueada;
	else 	
		tarjVieja="NO";
		denunciada=0;
		bloqueada=0;
	fi;
	
	regOK=$i\;$cuenta\;$estadoCuenta\;$tarjVieja\;$denunciada\;$bloqueada\;\ \;\ \;$doc\;$nombre\;$nroTarj1\;$nroTarj2\;$nroTarj3\;$nroTarj4\;$fechaDsd\;$fechaHsta\;$documentoCuenta\;$denominacionCuenta\;$fechaAlta\;$categoria\;$limite\;$ENTIDAD_BANCARIA\;$alias;	

	echo $regOK >> $PATH_VALIDADOS"/Plasticos_aceptados_$NUMERO_SESSION.txt";
	
	REG_OK_POR_ARCH=$((REG_OK_POR_ARCH + uno));
	
	MSJ_ERR="Registro n°""$REG_POR_ARCH"": ACEPTADO.";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""validador.log";
	
	done < $PATH_ACEPTADOS/$i;
	
	#logeo cuantos registros se aceptaron/rechazaron en el archivo recientemente recorrido.
	MSJ_ERR="Se aceptaron ""$REG_POR_ARCH"" registros del archivo ""$f";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""validador.log";
	REG_RECH_POR_ARCH=$((REG_POR_ARCH - REG_OK_POR_ARCH));
	MSJ_ERR="Se rechazaron ""$REG_RECH_POR_ARCH"" registros del archivo ""$f";
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""validador.log";
	
	LLAMAR_LISTADOR=$((LLAMAR_LISTADOR + REG_OK_POR_ARCH));	
	
	REG_POR_ARCH=0;
	REG_OK_POR_ARCH=0;
	REG_RECH_POR_ARCH=0;
	
done;

MSJ_ERR="El VALIDADOR del DEMONIO terminó."
bash "$EJECUTABLES""$LOGER" "VALIDADOR" "ERROR" "$MSJ_ERR" "$LOGS""validador.log";

if [ $LLAMAR_LISTADOR -gt 0 ]; then
	MSJ_ERR="Se llamará al listador."
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""validador.log";
	bash "$EJECUTABLES""$LISTADOR";
else 
	MSJ_ERR="No hay información para llamar al listador."
	bash "$EJECUTABLES""$LOGER" "VALIDADOR" "INFORMATIVO" "$MSJ_ERR" "$LOGS""validador.log";
fi;	


