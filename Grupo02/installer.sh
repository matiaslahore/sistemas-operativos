#!/usr/bin/env bash
actualPosition=`pwd`
GRUPO=~/Grupo02;
CONFDIR=dirconf;
CONFIGFILE="$GRUPO/$CONFDIR/config.conf";
#MOVER="$GRUPO/afrai/BIN/mover.sh"
#GRALOG="$GRUPO/afrai/BIN/gralog.sh

verifyFile () {
    if [ -f "$1" ];then
        return 0;
    else
        return 1;
	fi
}

verifyInstallation(){
	echo "\nIniciando instalación...\n"
    verifyFile $CONFIGFILE
    result=$?
    if [ $result = 0 ];then
        echo "Estamos verificando si la instalacion esta completa...";
		verifyFullInstall;
    else
        echo "Card validator no está instalado en su computadora\n";
        verifyPerl;
    fi
}
  
verifyFullInstall(){

	BINDIR=$(grep '^BINDIR' $CONFIGFILE | cut -d '=' -f 2);
	MAEDIR=$(grep '^MAEDIR' $CONFIGFILE | cut -d '=' -f 2);
	ACEPTDIR=$(grep '^ACEPDIR' $CONFIGFILE | cut -d '=' -f 2);
	VALIDDIR=$(grep '^VALIDDIR' $CONFIGFILE | cut -d '=' -f 2);
	RECHDIR=$(grep '^RECHDIR' $CONFIGFILE | cut -d '=' -f 2);
	REPODIR=$(grep '^REPODIR' $CONFIGFILE | cut -d '=' -f 2);
	LOGDIR=$(grep '^LOGDIR' $CONFIGFILE | cut -d '=' -f 2);


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
	for p in ${dirToInstall[*]}
	do
		mkdir $p;
	done

	whereAMI=`pwd`
	
	for p in ${binToInstall[*]}
	do
		cp $whereAMI/BIN/$p $BINDIR  
	done

	for p in ${maeToInstall[*]}
	do
		cp $whereAMI/MAE/$p $MAEDIR  
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
	echo "Verificando instalación de Perl...\n";
	perlVersionCommand=`perl -v`;
	version=$(echo "$perlVersionCommand" | grep " perl [0-9]" | sed "s-.*\(perl\) \([0-9]*\).*-\2-");
	if [ $version -ge 5 ];then
		echo "Perl version: $perlVersionCommand \n"
		echo "Estamos listos para instalar el sistema, presione una tecla para continuar"
		read x
		clear
		fullInstall;
	else
		echo "Para ejecutar el validador de tarjetas es necesario contar con Perl 5 o superior"
		echo "Instale Perl y vuelva e inténtelo nuevamente"
		echo "\nLa instalacion ha sido interrumpida\n"
		end;
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
	echo "Bienvenido a la instalacion del validador de tarjetas.\n"
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

verifyDir () {
	local filePath=$1
	if [ -d "$filePath" ];then
		echo "Directorio ya existe"
		return 1
	else
		return 0
	fi
}

makeDirs() {
	foldersName=("ejecutables" "archivos maestros" "tarjetas aceptadas" "tarjetas rechazadas" "tarjetas validadas" "reportes" "logs");
	defaultFolders=("$GRUPO/bin" "$GRUPO/maestros" "$GRUPO/aceptados" "$GRUPO/rechazados" "$GRUPO/validados" "$GRUPO/reportes" "$GRUPO/logs");
	binFolder=("mover.sh" "gralog.sh" "funcionesComunes.sh" "detener.sh" "arrancar.sh" "afraumbr.sh" "afrareci.sh" "afralist.pl" "afrainic.sh")
	maeFolder=("umbral.tab" "tllama.tab" "CdP.mae" "CdC.mae" "CdA.mae" "agentes.mae")

	p=0;
	for defaultDir in ${defaultFolders[*]}
	do
		Message="Defina el directorio de ${foldersName[$p]} ($defaultDir):"
		echo "$Message"
		read INPUT
   		if [ ! INPUT ]; then
			dirToInstall[$p]=$defaultDir;
		else
			verifyDir $INPUT
			answer=$?
			if [ ! $answer ]; then
				dirToInstall[$p]=$INPUT;
			fi
		fi
		p=$((p + 1 ))
 	done
    echo "asd";
	mostrarDefiniciones
}

mostrarDefiniciones() {
	clear;
	echo "El sistema va a instalarse en los siguientes directorios";
	for defaultDir in ${dirToInstall[*]}
	do
		Message="Directorio de $foldersName[$p] ($defaultDir):" 
		echo "$Message\n"		
		let p=p+1;
 	done
	echo "¿Desea continuar? (S/N)";
	read answer
	if [ ${answer^^} = "S" ];then
		BINDIR=$dirToInstall[0];
		MAEDIR=$dirToInstall[1];
		completeInstallation;
	else
		end;
	fi
}

writeConfig () {
	WHEN=`date +%T-%d-%m-%Y`
	WHO=${USER}

	#GRUPO
	echo "ejecutables-$GRUPO=$WHO=$WHEN" >> $CONFIGFILE
	#MAEDIR
	echo "maestros-$GRUPO/$MAEDIR=$WHO=$WHEN" >> $CONFIGFILE
	#ACEPDIR
	echo "aceptados-$GRUPO/$ACEPTDIR=$WHO=$WHEN" >> $CONFIGFILE
	#RECHDIR
	echo "rechazados=$GRUPO/$RECHDIR=$WHO=$WHEN" >> $CONFIGFILE
	#VALIDDIR
	echo "validados-$GRUPO/$VALIDDIR=$WHO=$WHEN" >> $CONFIGFILE
	#REPODIR
	echo "reportes=$GRUPO/$REPODIR=$WHO=$WHEN" >> $CONFIGFILE
	#LOGDIR
	echo "logs-$GRUPO/$LOGDIR=$WHO=$WHEN" >> $CONFIGFILE
}

end(){
    writeConfig;
	echo "fin";
}

verifyInstallation;