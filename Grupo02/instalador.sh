#!/usr/bin/env bash
actualPosition=`pwd`
GRUPO=~/Grupo02;
CONFDIR=dirconf;
CONFIGFILE="$GRUPO/$CONFDIR/config.conf";
USERVALUES="$actualPosition/uservalues.tmp";
LOGER=BIN/loger.sh
SCRIPT="Instalador"
LOGFILE=installer.log

verifyFile () {

    if [ -f "$1" ];then
        return 1;
    else
        return 0;
	fi
}

verifyDir () {

	local filePath=$1
	if [ -d "$filePath" ];then
		return 1
	else
		return 0
	fi
}

install(){

	echo "Iniciando instalación..."
    verifyFile $CONFIGFILE
    result=$?
    if [  "$result" -eq "1" ];then
        ./$LOGER "$SCRIPT" "INF" "Se ejecuto la instalacion, se esta verificando que el sistema este completo" $LOGFILE
		verifyFullInstall;
    else
        ./$LOGER "$SCRIPT" "INF" "Se ejecuto la instalacion, no hay sistema instalado" $LOGFILE
        initInstallation;
    fi
}

initInstallation(){

    echo "****************************************************";
    echo "Card validator no está instalado en su computadora";
    echo "****************************************************";

    verifyPerl;
    perlInstaled=$?
    if [ "$perlInstaled" -eq "1" ];then
        echo "Perl version: `perl -v`"
        echo "****************************************************";
        ./$LOGER "$SCRIPT" "INF" "Perl esta correctamente instalado en el sistema" $LOGFILE

        echo "Estamos listos para instalar el sistema, presione una tecla para continuar"
        read x
        uploadUserValues;
        clear
        fullInstall;
    else
        ./$LOGER "$SCRIPT" "ERR" "Fallo la instalacion, la version 5 de Perl no esta instalada en el sistema" $LOGFILE

        echo "Para ejecutar el validador de tarjetas es necesario contar con Perl 5 o superior"
        echo "Instale Perl y vuelva e inténtelo nuevamente"
        echo "La instalacion ha sido interrumpida"
    fi
}

uploadUserValues(){

    verifyFile $USERVALUES
    result=$?
    if [  "$result" -eq "1" ];then
        p=0;
        while IFS='' read -r line || [[ -n "$line" ]]; do
            defaultFolders[$p]=$line
            ((++p));
        done < "$USERVALUES"

        ./$LOGER "$SCRIPT" "INF" "Se cargaron los nombres de las carpetas elegidas anteriormente por el usuario" $LOGFILE
    else
        defaultFolders=("$GRUPO/bin" "$GRUPO/maestros" "$GRUPO/aceptados" "$GRUPO/rechazados" "$GRUPO/validados" "$GRUPO/reportes" "$GRUPO/logs");
    fi
}
  
verifyFullInstall(){

    echo "****************************************************";
    echo "Estamos verificando si la instalacion esta completa...";
    echo "****************************************************";

	BINDIR=$(grep '^ejecutables' $CONFIGFILE | cut -d '-' -f 2);
	MAEDIR=$(grep '^maestros' $CONFIGFILE | cut -d '-' -f 2);
	ACEPTDIR=$(grep '^aceptados' $CONFIGFILE | cut -d '-' -f 2);
	RECHDIR=$(grep '^rechazados' $CONFIGFILE | cut -d '-' -f 2);
	VALIDDIR=$(grep '^validados' $CONFIGFILE | cut -d '-' -f 2);
	REPODIR=$(grep '^reportes' $CONFIGFILE | cut -d '-' -f 2);
	LOGDIR=$(grep '^logs' $CONFIGFILE | cut -d '-' -f 2);

	folders=("$BINDIR" "$MAEDIR" "$ACEPTDIR" "$VALIDDIR" "$RECHDIR" "$REPODIR" "$LOGDIR");

	# if directory dont exist, its attached to dirToInstall array if the user want to install
	p=0;
	for Dir in ${folders[*]}
	do
   		if [ ! -d $Dir ]; then  
			dirToInstall[$p]=$Dir;		
			((++p));
		fi
 	done

 	#if binary dont exist, its attached to binToInstall array if the user want to install
	p=0;
	filepath="$actualPosition/BIN/*";
	for binFile in $filepath; do
	    scriptName=$(basename $binFile);
		if [ ! -f "$BINDIR/$scriptName" ];then
			binToInstall[$p]=$scriptName;
			((++p));
		fi
	done

	#if mae dont exist, its attached to maeToInstall array if the user want to install
	p=0;
	filepath="$actualPosition/MAE/*";
	for maeFile in $filepath; do
	    maeName=$(basename $maeFile);
		if [ ! -f "$MAEDIR/$maeName" ];then
			maeToInstall[$p]=$maeName;
			((++p));
		fi
	done	

	state=incomplete
	#verify if its complete
	if [ ${#dirToInstall[@]} -eq 0 -a ${#binToInstall[@]} -eq 0 -a ${#maeToInstall[@]} -eq 0 ];then
		state=completed
	fi
	
	repairInstall $state;
}

repairInstall (){

	state=$1
	showInstalationState $state;

	if [ $state != "completed" ];then
		# listar componentes faltantes
		echo "Componentes faltantes:";	
		showComponentsToInstall;
		echo "¿Desea completar la instalación? (S/N)"
		read answer
		if [ ${answer^^} == "S" ] 
		then
			echo "Instalando faltantes..."			
			completeInstallation;	
			clear;
			state=completed;
			showInstalationState $state;
		fi
	fi
	echo "Proceso de Instalación Finalizado"
	end;
}

completeInstallation () {

    ./$LOGER "$SCRIPT" "INF" "Se estan por crear todas las carpetas necesarias en los directorios elegido por el usuario" $LOGFILE
	for p in ${dirToInstall[*]}
	do
		IFS='/' read -r -a array <<< "$p";
        unset array[0];
        array=( "${array[@]}" );
        ant="/"
        for element in "${array[@]}"
        do
            dirToCreate=$ant$element
            verifyDir $dirToCreate
            answer=$?
            if [  "$answer" -eq "0" ]; then
                mkdir $dirToCreate;
            fi
            ant="$dirToCreate/";
        done
	done
    ./$LOGER "$SCRIPT" "INF" "Se crearon todas las carpetas necesarias" $LOGFILE

    ./$LOGER "$SCRIPT" "INF" "Se estan por mover todos los ejecutables a la carpeta de ejecutables" $LOGFILE
    for binFile in "$actualPosition/BIN/*"; do
		cp $binFile $BINDIR/
    done
    ./$LOGER "$SCRIPT" "INF" "Se movieron todos los ejecutables con exito" $LOGFILE

    ./$LOGER "$SCRIPT" "INF" "Se estan por mover todos los archivos maestros a la carpeta de maestros" $LOGFILE
    for maeFile in "$actualPosition/MAE/*"; do
		cp $maeFile $MAEDIR/
    done
}

showComponentsToInstall(){

    if [ ${#dirToInstall[@]} -gt 0 ];then
        echo "****************************************************";
        echo "Directorios a instalar:"
        for p in ${dirToInstall[*]}
        do
            echo $p;
        done
    fi

    if [ ${#binToInstall[@]} -gt 0 ];then
        echo "****************************************************";
        echo "Ejecutables a instalar:"
        for p in ${binToInstall[*]}
        do
            echo $BINDIR/$p;
        done
    fi

    if [ ${#maeToInstall[@]} -gt 0 ];then
        echo "****************************************************"
        echo "Archivos a instalar:"
        for p in ${maeToInstall[*]}
        do
            echo $MAEDIR/$p;
        done
    fi
}

verifyPerl(){

	echo "Verificando instalación de Perl...";
	perlVersionCommand=`perl -v`;
	version=$(echo "$perlVersionCommand" | grep " perl [0-9]" | sed "s-.*\(perl\) \([0-9]*\).*-\2-");
	if [ $version -ge 5 ];then
	    return 1;
	else
		return 0;
	fi
}

showInstalationState(){

	echo "Carpeta de Ejecutables: ${BINDIR}"
	echo "Carpeta de Configuración: "/${CONFDIR}""
	echo "Archivos de Maestros: ${MAEDIR}"
	echo "Archivos de tarjetas aceptadas: ${ACEPTDIR}"
	echo "Archivos de tarjetas validadas: ${VALIDDIR}"
	echo "Archivos de Log: ${LOGDIR}"
	echo "Archivos de tarjetas rechazadas: ${RECHDIR}"
    echo "****************************************************";
	echo "Estado de la instalación: $1"
    echo "****************************************************";

    ./$LOGER "$SCRIPT" "INF" "Estado de la instalacion: $1" $LOGFILE
}

fullInstall(){

    ./$LOGER "$SCRIPT" "INF" "Instalador preparado para la instalacion completa" $LOGFILE
	echo "Bienvenido a la instalacion del validador de tarjetas."
	echo "¿Desea instalar el validador?(S/N)"
	read answer
	if [ ${answer^^} = "S" ];then
		while [ ${answer^^} = "S" ]
		do
            ./$LOGER "$SCRIPT" "INF" "El usuario ha aceptado instalar el sistema" $LOGFILE
			makeDirs
			answer=$?
		done
	else
		echo "Instalacion cancelada";
        ./$LOGER "$SCRIPT" "WARN" "El usuario ha cancelado la instalacion del sistema" $LOGFILE
		clear
	fi
}

makeDirs() {

	foldersName=("ejecutables" "archivos maestros" "tarjetas aceptadas" "tarjetas rechazadas" "tarjetas validadas" "reportes" "logs");

    declare -A dirToInstall
	p=0;
	for defaultDir in ${defaultFolders[*]}
	do
        ./$LOGER "$SCRIPT" "INF" "El usuario tiene por defecto $defaultDir para la carpeta de ${foldersName[$p]}" $LOGFILE
		Message="Defina el directorio de ${foldersName[$p]} ($defaultDir):"
		echo "$Message"
		read input
   		if [  "$input"  == "" ]; then
            ./$LOGER "$SCRIPT" "INF" "El usuario seleccion la carpeta por defecto de ${foldersName[$p]} que por defecto era la ruta $defaultDir" $LOGFILE
			dirToInstall[$p]=$defaultDir;
		else
			verifyDir $input
			answer=$?
			if [ !$answer ]; then
			    while [ "$input"  == "$GRUPO/dirconf" ]
                do
                    echo "La carpeta $GRUPO/dirconf esta reservada para el sistema, por favor elija otra";
                    Message="Defina el directorio de ${foldersName[$p]} ($defaultDir):"
                    echo "$Message"
                    read input
                done
                if [  "$input"  == "" ]; then
                    ./$LOGER "$SCRIPT" "INF" "El usuario seleccion la carpeta por defecto de ${foldersName[$p]} que por defecto era la ruta $defaultDir" $LOGFILE
                    dirToInstall[$p]=$defaultDir;
                else
                    dirToInstall[$p]=$input;
                    ./$LOGER "$SCRIPT" "INF" "El usuario seleccion para la carpeta de ${foldersName[$p]} la ruta $input" $LOGFILE
                fi
			fi
		fi
		((++p))
 	done

	mostrarDefiniciones
}

mostrarDefiniciones() {

    BINDIR=${dirToInstall[0]};
    MAEDIR=${dirToInstall[1]};
    ACEPTDIR=${dirToInstall[2]};
    RECHDIR=${dirToInstall[3]};
    VALIDDIR=${dirToInstall[4]};
    REPODIR=${dirToInstall[5]};
    LOGDIR=${dirToInstall[6]};
    writeUserValue;

	clear;
	Message1="El sistema va a instalarse en los siguientes directorios";
	echo $Message1;
    ./$LOGER "$SCRIPT" "INF" "$Message1" $LOGFILE

	p=0;
	for defaultDir in ${dirToInstall[*]}
	do
		Message="Directorio de ${foldersName[$p]} ($defaultDir):"
		echo "$Message"
		((++p))
        ./$LOGER "$SCRIPT" "INF" "$Message" $LOGFILE
 	done
	echo "¿Desea continuar? (S/N)";
	read answer
	if [ ${answer^^} = "S" ];then
		completeInstallation;
		end;
	else
	    echo "La instalacion a sido interrumpida"
        ./$LOGER "$SCRIPT" "INF" "La instalacion ha sido interrumpida por el usuario" $LOGFILE
	fi

}

writeConfig () {

	WHEN=`date +%T-%d-%m-%Y`
	WHO=${USER}

    verifyDir $GRUPO
    answer=$?
    if [  "$answer" -eq "1" ];then
        verifyDir $GRUPO/dirconf
        answer=$?
        if [  "$answer" -eq "0" ];then
            mkdir $GRUPO/dirconf
        fi
    fi

    verifyFile $CONFIGFILE
    result=$?
    if [  "$result" -eq "1" ];then
        touch $CONFIGFILE;
    fi

	echo "ejecutables-$BINDIR-$WHO-$WHEN" >> $CONFIGFILE
	echo "maestros-$MAEDIR-$WHO-$WHEN" >> $CONFIGFILE
	echo "aceptados-$ACEPTDIR-$WHO-$WHEN" >> $CONFIGFILE
	echo "rechazados-$RECHDIR-$WHO-$WHEN" >> $CONFIGFILE
	echo "validados-$VALIDDIR-$WHO-$WHEN" >> $CONFIGFILE
	echo "reportes-$REPODIR-$WHO-$WHEN" >> $CONFIGFILE
	echo "logs-$LOGDIR-$WHO-$WHEN" >> $CONFIGFILE

    ./$LOGER "$SCRIPT" "INF" "Se genero un archivo .conf donde se guardan las rutas de las carpetas elegidas por el usuario" $LOGFILE
}

writeUserValue () {

    verifyFile $USERVALUES
    result=$?
    if [  "$result" -eq "1" ];then
        rm $USERVALUES;
    fi

    touch $USERVALUES;

	echo "$BINDIR" >> $USERVALUES
	echo "$MAEDIR" >> $USERVALUES
	echo "$ACEPTDIR" >> $USERVALUES
	echo "$RECHDIR" >> $USERVALUES
	echo "$VALIDDIR" >> $USERVALUES
	echo "$REPODIR" >> $USERVALUES
	echo "$LOGDIR" >> $USERVALUES

    ./$LOGER "$SCRIPT" "INF" "Se guardaron todos los valores de las carpetas elegidas por el usuario en un archivo temporal" $LOGFILE
}

end(){

    writeConfig;

    verifyFile $USERVALUES
    result=$?
    if [  "$result" -eq "1" ];then
        rm $USERVALUES;
    fi

    echo "La instalación finalizo con exito!";

    ./$LOGER "$SCRIPT" "INF" "La instalación finalizo con exito!" $LOGFILE

    verifyFile "$GRUPO/dirconf/$LOGFILE"
    result=$?
    if [  "$result" -eq "0" ];then
        touch "$GRUPO/dirconf/$LOGFILE";
        ./$LOGER "$SCRIPT" "INF" "Se creo un archivo nuevo de logeo en: $GRUPO/dirconf/$LOGFILE" $LOGFILE
    fi

    ./$LOGER "$SCRIPT" "INF" "Se movio el archivo temporal de logeo a: $GRUPO/dirconf/$LOGFILE" $LOGFILE

    cat "$LOGFILE" >> "$GRUPO/dirconf/$LOGFILE"
    rm $LOGFILE;
}

main(){

    verifyFile $LOGFILE
    result=$?
    if [  "$result" -eq "0" ];then
        touch $LOGFILE;
    fi

    chmod +x $LOGER

    if [  "$1" -eq "-r" ];then
        ./$LOGER "$SCRIPT" "INF" "Se ejecuto la reparacion de la instalacion manualmente" $LOGFILE
        verifyFullInstall;
    else
        install;
    fi
}

main;