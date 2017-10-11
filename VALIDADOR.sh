#!/bin/bash

function validarDuplicado {
	f=${1##*/};
	if [ -f $PATH_PROCESADOS/$f ]; then
		echo "El archivo $2 está duplicado";
		mv $PATH_ACEPTADOS/$f $PATH_RECHAZADOS;
		echo "El archivo $f se movió a la carpeta de rechazados";
		return 0;
	else 
		echo "El archivo $f se va a procesar";
		return 1; 
	fi; 
	
}

PATH_ACEPTADOS="/home/maciel/Documentos/SISOP/TP/aceptados";
PATH_PROCESADOS="/home/maciel/Documentos/SISOP/TP/aceptados/procesados";
PATH_RECHAZADOS="/home/maciel/Documentos/SISOP/TP/rechazados";
PATH_CUMAE="/home/maciel/Documentos/SISOP/TP/mandodatostpmaestrosyalgunasnovedades/cumae";

for i in $(ls -F $PATH_ACEPTADOS | grep -v '/$');
do  	
	echo $i;
	validarDuplicado $i;
	if [ "$?" == 0 ]; then
		continue;
	fi;
	while read linea
		do echo "la línea es: $linea";
	arg1=`echo $linea | sed 's/;.*//'`

	arg2=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\2/'`
	arg3=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\3/'`
	arg4=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\4/'`
	arg5=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\5/'`
	arg6=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\6/'`
	arg7=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\7/'`
	arg8=`echo $linea | sed 's/\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\8/'`
	arg9=`echo $linea | sed 's/.*;//'`
	echo "El alrgumento 1 es: $arg1";
	echo "El alrgumento 2 es: $arg2";
	echo "El alrgumento 3 es: $arg3";
	echo "El alrgumento 4 es: $arg4";
	echo "El alrgumento 5 es: $arg5";
	echo "El alrgumento 6 es: $arg6";
	echo "El alrgumento 7 es: $arg7";
	echo "El alrgumento 8 es: $arg8";
	echo "El alrgumento 9 es: $arg9";
	done < $PATH_ACEPTADOS/$i;
done;
