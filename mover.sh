function getCodigoDuplicado {
	CODIGO_DUP=0
	for i in $(ls -F "$1" | grep "$2" | sed 's/.*\-//g' | sed 's/\..*//');
	do
		if [[ ! $i == *"_"* ]]; then #Es el primer archivo, no tiene codigo agregado aun
			if [ $i -gt $CODIGO_DUP ]; then
				CODIGO_DUP=$i;
			fi
		fi
	done;
	CODIGO_DUP=$((CODIGO_DUP + 1));
	return $CODIGO_DUP
}

#Script auxiliar para mover archivos, teniendo en cuenta el caso en el que ya exista un archivo con el mismo nombre en la carpeta destino
#Recibe cinco parámetros

origen=$1 #Incluye el nombre del archivo
destino=$2 #No incluye el nombre del archivo
alternativa=$3 #Ruta alternativa a donde copiar si ya existe el archivo en el destino

nombre_archivo=${origen##*/}
sin_extension=${nombre_archivo%.*}
extension=${nombre_archivo##*.}

if [ ! -f "$destino"/"$nombre_archivo" ]; then #Si no existe el archivo, lo muevo a la carpeta destino
	mv "$origen" "$destino"/"$nombre_archivo"
else
	mkdir -p "$alternativa" #Si no existe, creo el directorio de duplicados
	#Obtengo el codigo a agregar a los archivos repetidos para no perderlos
	if [ -f "$alternativa"/"$nombre_archivo" ]; then
		getCodigoDuplicado "$alternativa" "$sin_extension"
		codigo=$?
		mv "$origen" "$alternativa"/"$sin_extension""-""$codigo"".""$extension"
	else
		mv "$origen" "$alternativa"/"$nombre_archivo"
	fi
fi