#!/bin/bash

######################################################################
# Al ser invocado este script se da por terminado el proceso demonio #
######################################################################

PROCESO=$(ps | grep demonio)
echo $PROCESO

IDPROCESO=$(echo $PROCESO| cut -d' ' -f 1)

echo cerrando proceso ...
kill $IDPROCESO
echo proceso finalizado.

./loger.sh "stop.sh" "Informativo" "Se detuvo la ejecuccion del demonio" "$CONFDIR/stop.log"
