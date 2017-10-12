#Script auxiliar para mover archivos, teniendo en cuenta el caso en el que ya exista un archivo con el mismo nombre en la carpeta destino
#Recibe cinco parámetros

origen=$1 #Incluye el nombre del archivo
destino=$2 #No incluye el nombre del archivo
nombre_archivo=$3
alternativa=$4 #Ruta alternativa a donde copiar si ya existe el archivo en el destino

sin_extension=${nombre_archivo%.*}
extension=${nombre_archivo##*.}

#Obtengo el codigo a agregar a los archivos repetidos para no perderlos
codigo=1
if [ ! -f "$EJECUTABLES""hash.txt" ]; then
	echo "$codigo" > "$EJECUTABLES""hash.txt"
else
	codigo=$(cat "$EJECUTABLES""hash.txt")
fi


if [ ! -f "$destino""$nombre_archivo" ]; then #Si no existe el archivo, lo muevo a la carpeta destino
	mv "$origen" "$destino""$nombre_archivo"
else
	mkdir -p "$alternativa" #Si no existe, creo el directorio de duplicados
	mv "$origen" "$alternativa""$sin_extension""-""$codigo"".""$extension"
	let codigo+=1 #Actualizo el valor para que no se repitan dos archivos
	echo "$codigo" > "$EJECUTABLES""hash.txt"
fi