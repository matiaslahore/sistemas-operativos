#!/usr/bin/env bash
actualPosition=`pwd`
GRUPO=~/Grupo02;
CONFDIR=dirconf;
CONFIGFILE="$GRUPO/$CONFDIR/config.conf";
USERVALUES="$actualPosition/BIN/uservalues.temp";

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

verifyInstallation(){

	echo "Iniciando instalación..."
    verifyFile $CONFIGFILE
    result=$?
    if [  "$result" -eq "1" ];then
        echo "****************************************************";
        echo "Estamos verificando si la instalacion esta completa...";
        echo "****************************************************";
		verifyFullInstall;
    else
        echo "****************************************************";
        echo "Card validator no está instalado en su computadora";
        echo "****************************************************";
        initInstallation;
    fi
}

initInstallation(){

    verifyPerl;
    perlInstaled=$?
    if [ "$perlInstaled" -eq "1" ];then
        echo "Perl version: `perl -v`"
        echo "****************************************************";
        echo "Estamos listos para instalar el sistema, presione una tecla para continuar"
        read x
        uploadUserValues;
        clear
        fullInstall;
    else
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
    else
        defaultFolders=("$GRUPO/bin" "$GRUPO/maestros" "$GRUPO/aceptados" "$GRUPO/rechazados" "$GRUPO/validados" "$GRUPO/reportes" "$GRUPO/logs");
    fi
}
  
verifyFullInstall(){

	BINDIR=$(grep '^ejecutables' $CONFIGFILE | cut -d '-' -f 2);
	MAEDIR=$(grep '^maestros' $CONFIGFILE | cut -d '-' -f 2);
	ACEPTDIR=$(grep '^aceptados' $CONFIGFILE | cut -d '-' -f 2);
	RECHDIR=$(grep '^rechazados' $CONFIGFILE | cut -d '-' -f 2);
	VALIDDIR=$(grep '^validados' $CONFIGFILE | cut -d '-' -f 2);
	REPODIR=$(grep '^reportes' $CONFIGFILE | cut -d '-' -f 2);
	LOGDIR=$(grep '^logs' $CONFIGFILE | cut -d '-' -f 2);


	folders=("$BINDIR" "$MAEDIR" "$ACEPTDIR" "$VALIDDIR" "$RECHDIR" "$REPODIR" "$LOGDIR");
	binFolder=("mover.sh" "gralog.sh" "funcionesComunes.sh" "detener.sh" "arrancar.sh" "afraumbr.sh" "afrareci.sh" "afralist.pl" "afrainic.sh");
	maeFolder=("umbral.tab" "tllama.tab" "CdP.mae" "CdC.mae" "CdA.mae" "agentes.mae");

	# if directory dont exist, its attached to dirToInstall array if the user want to install
	p=0;
	for Dir in ${folders[*]}
	do
   		if [ ! -d $Dir ]; then  
			dirToInstall[$p]=$Dir;		
			let p=p+1;
		fi
 	done

 	#if binary dont exist, its attached to binToInstall array if the user want to install 
	p=0;
	for binFile in ${binFolder[*]}
	do
		if [ ! -f "$BINDIR/$binFile" ];then 
			binToInstall[$p]=$binFile;
			let p=p+1;
		fi
	done	

	#if binary dont exist, its attached to maeToInstall array if the user want to install
	p=0;
	for maeFile in ${maeFolder[*]}
	do
		if [ ! -f "$MAEDIR/$maeFile" ];then 
			maeToInstall[$p]=$maeFile;
			let p=p+1;
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
		else
			end;
		fi
	fi
	echo "Proceso de Instalación Finalizado"
	end;
}

completeInstallation () {

    BINDIR=${dirToInstall[0]};
    MAEDIR=${dirToInstall[1]};
    ACEPTDIR=${dirToInstall[2]};
    RECHDIR=${dirToInstall[3]};
    VALIDDIR=${dirToInstall[4]};
    REPODIR=${dirToInstall[5]};
    LOGDIR=${dirToInstall[6]};
    writeUserValue;

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
                mkdir $dirToCreate
            fi
            ant="$dirToCreate/";
        done
	done

	whereAMI=`pwd`

	for p in ${binFolder[*]}
	do
		cp $whereAMI/BIN/$p $BINDIR/
	done

	for p in ${maeToInstall[*]}
	do
		cp $whereAMI/MAE/$p $MAEDIR/
	done
}

showComponentsToInstall(){
	echo "Directorios a instalar:\n"
	for p in ${dirToInstall[*]}
	do
		echo $p;
	done

	echo "Ejecutables a instalar:\n"
	for p in ${binToInstall[*]}
	do
		echo $BINDIR/$p;
	done	

	echo "Archivos a instalar:\n"
	for p in ${maeToInstall[*]}
	do
		echo $MAEDIR/$p;
	done
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
	echo "Carpeta de Configuración: ${CONFDIR}"
	echo "Archivos de Maestros: ${MAEDIR}"
	echo "Archivos de tarjetas aceptadas: ${ACEPTDIR}"
	echo "Archivos de tarjetas validadas: ${VALIDDIR}"
	echo "Archivos de Log: ${LOGDIR}"
	echo "Archivos de tarjetas rechazadas: ${RECHDIR}"
	echo "\nEstado de la instalación: $1"
}

fullInstall(){
	echo "Bienvenido a la instalacion del validador de tarjetas."
	echo "¿Desea instalar el validador?(S/N)"
	read answer
	if [ ${answer^^} = "S" ];then
		while [ ${answer^^} = "S" ]
		do
			makeDirs
			answer=$?
		done
	else
		echo "\nInstalacion cancelada\n";
		fin;
		clear
	fi
}

makeDirs() {
	foldersName=("ejecutables" "archivos maestros" "tarjetas aceptadas" "tarjetas rechazadas" "tarjetas validadas" "reportes" "logs");
	binFolder=("mover.sh")
#	binFolder=("mover.sh" "gralog.sh" "funcionesComunes.sh" "detener.sh" "arrancar.sh")
	maeFolder=("umbral.tab" "tllama.tab" "CdP.mae" "CdC.mae" "CdA.mae" "agentes.mae")

    declare -A dirToInstall
	p=0;
	for defaultDir in ${defaultFolders[*]}
	do
		Message="Defina el directorio de ${foldersName[$p]} ($defaultDir):"
		echo "$Message"
		read input
   		if [  "$input"  == "" ]; then
			dirToInstall[$p]=$defaultDir;
		else
			verifyDir $input
			answer=$?
			if [ !$answer ]; then
				dirToInstall[$p]=$input;
			fi
		fi
		((++p))
 	done

	mostrarDefiniciones
}

mostrarDefiniciones() {
	clear;
	echo "El sistema va a instalarse en los siguientes directorios";

	p=0;
	for defaultDir in ${dirToInstall[*]}
	do
		Message="Directorio de ${foldersName[$p]} ($defaultDir):"
		echo "$Message"
		((++p))
 	done
	echo "¿Desea continuar? (S/N)";
	read answer
	if [ ${answer^^} = "S" ];then
		completeInstallation;
	fi
    end;
}

writeConfig () {
	WHEN=`date +%T-%d-%m-%Y`
	WHO=${USER}

    verifyDir $GRUPO
    answer=$?
    if [  "$answer" -eq "1" ];then
        mkdir $GRUPO/dirconf
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
}

writeUserValue () {

    verifyFile $USERVALUES
    result=$?
    if [  "$result" -eq "0" ];then
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
}

end(){
    writeConfig;
    rm $USERVALUES;
	echo "fin";
}

verifyInstallation;