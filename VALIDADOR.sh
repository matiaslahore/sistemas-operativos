#!/bin/bash

#valida que el archivo seleccionado de la carpeta ACEPTADOS
#no haya sido procesado anteriormente.
function validarProcesado {
	f=${1##*/};
	if [ -f $PATH_PROCESADOS/$f ]; then
		echo "El archivo $1 ya ha sido procesado";
		validarDuplicado $f;	
		if [ $? = 0 ]; then
			mv $PATH_ACEPTADOS/$f $PATH_RECHAZADOS;
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
	echo "el argumento $1 es válido";
else 
	echo "El argumento $1 NO es válido"; 
fi;
}

function validarNroDoc {
echo "el argumento a validar es $1";
if [[ $1 =~ [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$ ]]; then
	echo "el nro de cuenta: $1 es válido";
	validarExistenciaNroCuenta $1;
else 
	echo "El nro de cuenta: $1 NO es válido"; 
fi;
}

function validarExistenciaNroCuenta {
echo "el argumento a validar es $1";
nroCuenta=`grep $1 $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\2/'`
echo "el nro de cuenta encontrado es: $nroCuenta";
if [ $nroCuenta == "" ]; then 
	echo "la cuenta NO fue encontrada"; 
fi;
}

function validarFechas {
echo "estoy validando fechas";
#valido "Fecha Desde"
diaDsd=`echo $1 | sed 's|\(.*\)/\(.*\)/\(.*\)|\1|'`;
if ! [[ $diaDsd =~ ^[0-2][0-9]$|^[0-3][0-1]$ ]]; then
	echo "el diaDsd $diaDsd NOO es válido"; 
	return 1;
fi;
mesDsd=`echo $1 | sed 's|\(.*\)/\(.*\)/\(.*\)|\2|'`;
if ! [[ $mesDsd =~ ^[0][0-9]$|^[1][0-2]$ ]]; then
	echo "el mesDsd $mesDsd NOO es válido";
	return 1;
fi;
anioDsd=`echo $1 | sed 's|\(.*\)/\(.*\)/\(.*\)|\3|'`;
if ! [[ $anioDsd =~ ^[0-9][0-9][0-9][0-9]$ ]]; then
	echo "el añoDsd $anioDsd NOO es válido";
	return 1;
fi;

#valido "Fecha Hasta"
diaHsta=`echo $2 | sed 's|\(.*\)/\(.*\)/\(.*\)|\1|'`;
if ! [[ $diaHsta =~ ^[0-2][0-9]$|^[0-3][0-1]$ ]]; then
	echo "el diaH $diaHsta NOO es válido"; 
	return 1;
fi;
mesHsta=`echo $2 | sed 's|\(.*\)/\(.*\)/\(.*\)|\2|'`;

if ! [[ $mesHsta =~ ^[0][0-9]$|^[1][0-2]$ ]]; then
	echo "el mesH $mesHsta NOO es válido";
	return 1;
fi;
anioHsta=`echo $2 | sed 's|\(.*\)/\(.*\)/\(.*\)|\3|'`;
anioHsta=`echo $anioHsta | sed 's/.$//g'` 
if ! [[ $anioHsta =~ ^[0-9][0-9][0-9][0-9]$ ]]; then
	echo "año inválido: $anioHsta aaaa";	
	return 1;
fi;
echo "$diaDsd vs $diaHsta";
echo "$mesDsd vs $mesHsta";
echo "$anioDsd vs $anioHsta";

#valido diferencia entre fecha desde y fecha hasta
if [[ $anioDsd -gt $anioHsta ]]; then
	echo "el año desde $anioDsd es mayor que el año hasta $anioHsta";	
	return 2;	
fi;
if [ $anioDsd -eq $anioHsta ] && [ $mesDsd -gt $mesHsta ]; then
	echo "el mes desde es mayor que el mes hasta";
	return 2;
fi;
if [ $anioDsd -eq $anioHsta ] && [ $mesDsd -eq $mesHsta ] && [ $diaDsd -ge $diaHsta ]; then
	echo "el dia desde es mayor que el dia hasta";
	return 2;
fi;

echo "fechas válidas";
}

function validarNombre {
if [ $1 = "" ]; then 
	echo "el nombre no fué informado";
	return 1;
fi;
}

function validarDocumento {
if [ $1 = "" ]; then 
	echo "el documento no fue informado";
	return 1;
fi;
}

###################################################
# FIN VALIDACIONES DE REGISTRO
###################################################

# function generarRegistroOK {}



PATH_ACEPTADOS="/home/maciel/Documentos/SISOP/TP/aceptados";
PATH_PROCESADOS="/home/maciel/Documentos/SISOP/TP/aceptados/procesados";
PATH_RECHAZADOS="/home/maciel/Documentos/SISOP/TP/rechazados";
PATH_DUPLICADOS="/home/maciel/Documentos/SISOP/TP/duplicados";
PATH_VALIDADOS="/home/maciel/Documentos/SISOP/TP/validados";
PATH_RECHAZADOS="/home/maciel/Documentos/SISOP/TP/rechazados";
PATH_CUMAE="/home/maciel/Documentos/SISOP/TP/mandodatostpmaestrosyalgunasnovedades/cumae";
PATH_BAMAE="/home/maciel/Documentos/SISOP/TP/mandodatostpmaestrosyalgunasnovedades/bamae";

NUMERO_ARCH=0;
NUMERO_SESSION=5;

ENTIDAD_BANCARIA=015;

for i in $(ls -F $PATH_ACEPTADOS | grep -v '/$');
do  	
	echo $i;
	validarProcesado $i;
	if [ "$?" == 0 ]; then
		continue;
	fi;
	while read linea
		do echo "la línea es: $linea";
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

	validarNroDoc $cuenta;

	validarNombre $doc;
	validarDocumento $doc;

	validarNroTarjeta $nroTarj1
	validarNroTarjeta $nroTarj2
	validarNroTarjeta $nroTarj3
	validarNroTarjeta $nroTarj4

	validarFechas $fechaDsd $fechaHsta;
	if ! [ $? = 0 ]; then 	
	MSJ_ERR="Fecha inválida":
	echo $MSJ_ERR;
	fi;

	echo $PATH_VALIDADOS"/Plasticos_aceptados_$NUMERO_SESSION.txt";
	
	#reg=$cuenta\;$doc\;$nombre\;$nroTarj1\;$nroTarj2\;$nroTarj3\;$nroTarj4\;$fechaDsd\;$fechaHsta;
	
	estadoCuenta=`grep $cuenta $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\8/'`
	documentoCuenta=`grep $cuenta $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\3/'`
	denominacionCuenta=`grep $cuenta $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\4/'`
	fechaAlta=`grep $cuenta $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\5/'`
	categoria=`grep $cuenta $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\6/'`
	limite=`grep $cuenta $PATH_CUMAE | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\7/'`
	
	alias=`grep $ENTIDAD_BANCARIA $PATH_BAMAE | sed 's/\(.*\);\(.*\);\(.*\)/\2/'`
	
	#estadoCuenta=`echo $anioHsta | sed 's/.$//g'`;
	
	echo $estadoCuenta;
	echo $documentoCuenta;
	echo $denominacionCuenta;
	echo $fechaAlta;
	echo $categoria;
	echo $limite;
	echo $ENTIDAD_BANCARIA;
	echo $alias;
	
	PATH_TARJETAS="/home/maciel/Documentos/SISOP/TP/mandodatostpmaestrosyalgunasnovedades/tx_tarjetas";
	estado=`grep "1411677996" $PATH_TARJETAS | grep "Entregada" | sed 's/.*;//' | sed 's/.$//g'`;
	estado=`echo $estado | sed 's/.*\ //'`;
	echo $estado;
	
	regOK=$i\;$cuenta\;$estadoCuenta\;	
	

	if ! [ -f $PATH_VALIDADOS"/Plasticos_aceptados_$NUMERO_SESSION.txt" ];then
		echo $regOK > $PATH_VALIDADOS"/Plasticos_aceptados_$NUMERO_SESSION.txt";
	else	
		echo $regOK >> $PATH_VALIDADOS"/Plasticos_aceptados_$NUMERO_SESSION.txt";
	fi;

	done < $PATH_ACEPTADOS/$i;
	
	
done;
