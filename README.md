######################## COMANDOS ######################## <br/>
############ MODO AUTOMATICO<br/>
Modo de uso: perl LISTADOR.pl<br/>
<br/>
############ MODO MANUAL<br/>
Ejemplo de uso:<br/>
~ perl LISTADOR.pl -i="PLASTICOS_EMITIDOS_1;PLASTICOS_EMITIDOS_2" -l="cuentas=ACTIVAS" -f="entidad=2,99;docCuenta=40355277"<br/>
<br/>
Modo de uso: perl LISTADOR.pl [-i]="[inputs]" [-l]="[listado]" [-f]="[filtros]"<br/>
	-i			~ Input:<br/>
 				· Un archivo especifico de plasticos_emitidos o de plasticos_distribucion<br/>
 				· Varios archivos específicos(de emitidos, de distribucion o de ambos)<br/>
 				· Todos los archivos de plasticos_emitidos (default)<br/>
					="PLASTICOS_EMITIDOS"<br/>
 				· Todos los archivos de plasticos_distribucion<br/>
					="PLASTICOS_DISTRIBUCION"<br/>
	-l			~ Opciones de listados:<br/>
	=cuentas		· Listados de cuentas:<br/>
					General <br/>
					=ACTIVAS 	Cuentas activas<br/>
					=BCJ	 	Cuentas dadas de baja, ctx, o jud<br/>
	=tarjetas		· Listados de tarjetas:<br/>
					General <br/>
					=denunciadas	Denunciadas<br/>
					=bloqueadas	Bloqueadas<br/>
					=vencidas 	Vencidas<br/>
	=condDistr		· Listado de condición de distribución<br/>
					-> para este listado solo se solicita filtro por condición de distribución<br/>
	=cuentaP		· Listado de la situación de una cuenta en particular<br/>
					-> para este listado solo se solicita filtro por documento cuenta<br/>
	=tarjetaP		· Listado de la situación de una tarjeta en particular<br/>
					-> para este listado solo se solicita filtro por documento tarjeta<br/>
	-f			~ Opciones de filtros<br/>
	=entidad		· Filtro por entidad<br/>
					= (una, rango de entidades, todas)<br/>
	=fuente			· Filtro por fuente<br/>
					= (una o todas)<br/>
	=condDistr		· Filtro por condición de distribución (default *)<br/>
					= sub-string<br/>
	=docCuenta		· Filtro por documento cuenta: (default *)<br/>
					= sub-string<br/>
	=docTarjeta		· Filtro por documento tarjeta: (default *)<br/>
					= sub-string<br/>
<br/>
	';'			-> SEPARADOR DE ARCHIVOS Y FILTROS<br/>
	','			-> SEPARADOR DE RANGOS<br/>
<br/>
*DURANTE LA EJECUCION DEL LISTADOR PERMITE:<br/>
	· VOLVER A LISTAR EL INPUT N VECES<br/>
	· APLICAR FILTROS N VECES AL LISTADO GENERADO<br/>


