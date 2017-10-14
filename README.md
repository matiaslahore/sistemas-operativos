######################## COMANDOS ########################
############ MODO AUTOMATICO
Modo de uso: perl LISTADOR.pl

############ MODO MANUAL
Ejemplo de uso:
~ perl LISTADOR.pl -i="PLASTICOS_EMITIDOS_1;PLASTICOS_EMITIDOS_2" -l="cuentas=ACTIVAS" -f="entidad=2,99;docCuenta=40355277"

Modo de uso: perl LISTADOR.pl [-i]="[inputs]" [-l]="[listado]" [-f]="[filtros]"
	-i			~ Input:
 				· Un archivo especifico de plasticos_emitidos o de plasticos_distribucion
 				· Varios archivos específicos(de emitidos, de distribucion o de ambos)
 				· Todos los archivos de plasticos_emitidos (default)
					="PLASTICOS_EMITIDOS"
 				· Todos los archivos de plasticos_distribucion
					="PLASTICOS_DISTRIBUCION"
	-l			~ Opciones de listados:
	=cuentas		· Listados de cuentas:
					General 
					=ACTIVAS 	Cuentas activas
					=BCJ	 	Cuentas dadas de baja, ctx, o jud
	=tarjetas		· Listados de tarjetas:
					General 
					=denunciadas	Denunciadas
					=bloqueadas	Bloqueadas
					=vencidas 	Vencidas
	=condDistr		· Listado de condición de distribución
					-> para este listado solo se solicita filtro por condición de distribución
	=cuentaP		· Listado de la situación de una cuenta en particular
					-> para este listado solo se solicita filtro por documento cuenta
	=tarjetaP		· Listado de la situación de una tarjeta en particular
					-> para este listado solo se solicita filtro por documento tarjeta
	-f			~ Opciones de filtros
	=entidad		· Filtro por entidad
					= (una, rango de entidades, todas)
	=fuente			· Filtro por fuente
					= (una o todas)
	=condDistr		· Filtro por condición de distribución (default *)
					= sub-string
	=docCuenta		· Filtro por documento cuenta: (default *)
					= sub-string
	=docTarjeta		· Filtro por documento tarjeta: (default *)
					= sub-string

	';'			-> SEPARADOR DE ARCHIVOS Y FILTROS
	','			-> SEPARADOR DE RANGOS

*DURANTE LA EJECUCION DEL LISTADOR PERMITE:
	· VOLVER A LISTAR EL INPUT N VECES
	· APLICAR FILTROS N VECES AL LISTADO GENERADO


