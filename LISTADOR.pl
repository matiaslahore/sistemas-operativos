#!/usr/bin/perl

use Time::Local;
use strict;

########################################################
######################### MAIN #########################
########################################################
if (@ARGV) {
	#MODO MANUAL

	#BUSCO SI HAY UN LISTADOR EJECUTANDOSE
	my @otrosListadores = grep(/^LISTADOR.pl/, `ps -af | awk '{ print \$9 }' `);

	if (@otrosListadores >= 2) {
		print "ERROR, Ya existe otro LISTADOR ejecutando!\n";
		print "Debe frenar el DEMONIO o esperar para poder ejecutar el LISTADOR manualmente\n";
	} else {
		if(&validarComandos(\@ARGV)) {
			&listadorManual(\@ARGV);
		}
	}

} else {
	#MODO AUTOMATICO
	&listadorAutomatico();
}

########################################################
###################### SUBRUTINAS ######################
########################################################
sub validarComandos {
	if( ($ARGV[0] =~ "^-i=") and ($ARGV[1] =~ "^-l=") ){
		if( &validarInput($ARGV[0]) and &validarListado($ARGV[1]) ) {
			if (!$ARGV[2]) {
				return 1;
			} elsif( $ARGV[2] =~ "^-f=" ) {
				if(&validarFiltro($ARGV[2])) {
					return 1;
				}
			}
		}
	}

	if( ($ARGV[0] eq "-h") or ($ARGV[0] eq "-help") ) {
		&imprimirAyuda();
	} else {
		print "COMANDO INVALIDO\n";
	}

	return 0;
}

sub validarInput {
	my @input = split(";", substr($_[0],3));

	if( ($input[0] eq "PLASTICOS_EMITIDOS") or ($input[0] eq "PLASTICOS_DISTRIBUCION") ) {
		return 1; #TODOS LOS ARCHIVOS
	}

	opendir(DIR, $ENV{"ACEPTADOS"}."/");
	my @filesValidados = grep(/^PLASTICOS_/, readdir(DIR));
	closedir(DIR);

	#opendir(DIR, "./REPORTES/");
	opendir(DIR, $ENV{"REPORTES"}."/");
	my @filesReportes = grep(/^PLASTICOS_/, readdir(DIR));
	closedir(DIR);

	foreach my $elem (@input) {
		if ($elem =~ "_EMITIDOS") {
			if (!(grep $_ eq $elem, @filesValidados)) {
				return 0;
			}
		} else {
			if (!(grep $_ eq $elem, @filesReportes)) {
				return 0;
			}
		}
	}

	return 1;
}

sub validarListado {
	my @vec = split("=", substr($_[0],3));
	my @listados = ("cuentas", "tarjetas", "condDistr", "cuentaP", "tarjetaP");

	if (grep $_ eq $vec[0], @listados) {
		return 1;
	}

	return 0;
}

sub validarFiltro {
	my @vec = split(";", substr($_[0],3));
	my @filtros = ("entidad", "fuente", "condDistr", "docCuenta", "docTarjeta");

	foreach (@vec) {
		my @aux = split("=", $_);
		
		if (grep $_ eq $aux[0], @filtros) {
			return 1;
		}
	};

	return 0;
}

sub validarSubComandos {
	my $comandos = $_[0];

	if($comandos->[0] =~ "^-l=") {
		if( &validarListado($comandos->[0]) ) { # and &validarFiltro($comandos->[1]) ) {
			if($comandos->[1] and ($comandos->[1] =~ "^-f=")) {
				if(!&validarFiltro($comandos->[1])) {
					#$comandos[2] = substr($ARGV[2],3);
					return 0;
				}
			}
			return 1;
		}
	} elsif ($comandos->[0] =~ "^-f=") {
		if(&validarFiltro($comandos->[0])) {
			#$comandos[2] = substr($ARGV[2],3);
			return 1;
		}
	}

	if( ($comandos->[0] eq "-h") or ($comandos->[0] eq "-help") ) {
		&imprimirSubAyuda();
	} else {
		print "COMANDO INVALIDO\n";
	}
	
	return 0;
}

sub listadorManual {
	my $vecComandos = $_[0];

	#my @input = split(";", substr($vecComandos->[0],3));
	my @input = &definirInput(substr($vecComandos->[0],3));
	my ($impresor, @listador) = &definirListador(substr($vecComandos->[1],3));
	my @filtro = &definirFiltro(substr($vecComandos->[2],3));

	#El nombre de cada listado generado en opción manual debe ser único, no deben sobreescribirse los listados. Todos se graban en el directorio de reportes
	my $output = &nuevoNombreListado();
	my @inputCpy = @input; #salva N listados para un mismo input

	&procesarInput(\@input, $output, \@listador, $impresor, \@filtro);

	my $lectura;

	while() {
		print "\nLISTADOR -> ";
		$lectura = <STDIN>;
		chomp($lectura);
		$lectura =~ s/"//g;
		my @arrayComandos = split(" ",$lectura);

		if ($lectura eq "exit") {
			last;
		}

		if(validarSubComandos(\@arrayComandos)) {
			if($lectura =~ "-l") {
				@input = @inputCpy;
				$output = &nuevoNombreListado();
				($impresor, @listador) = &definirListador(substr($arrayComandos[0],3));
				@filtro = &definirFiltro(substr($arrayComandos[1],3));
			} else {
				@input = ($output);
				@filtro = &definirFiltro(substr($arrayComandos[0],3));
			}

			&procesarInput(\@input, $output, \@listador, $impresor, \@filtro);
		}

	}
}

sub definirInput {
	my @vec = split(";", $_[0]);

	if ( $_[0] eq "PLASTICOS_EMITIDOS" ) {
		opendir(DIR, $ENV{"ACEPTADOS"}."/");
		@vec = grep(/^PLASTICOS_EMITIDOS_/, readdir(DIR));
		closedir(DIR);
	} else {
		if ($_[0] eq "PLASTICOS_DISTRIBUCION") {
			opendir(DIR, $ENV{"REPORTES"}."/");
			@vec = grep(/^PLASTICOS_DISTRIBUCION_/, readdir(DIR));
			closedir(DIR);
		}
	}

	foreach my $elem (@vec){
		if ($elem =~ "^PLASTICOS_EMITIDOS") {
			$elem = $ENV{"ACEPTADOS"}."/".$elem;
		} else {
			$elem = $ENV{"REPORTES"}."/".$elem;
		}
	}

	return @vec;
}

sub definirListador {
	my @vec = split("=", $_[0]);

	my %listados = (
		"cuentas" => sub {
			my %definirPreFiltro = (
				"ACTIVAS" => sub {
					my @estados = ("ACTIVA");
					return @estados;
				},
				"BCJ" => sub {
					my @estados = ("BAJA", "CTX", "JUD");
					return @estados;
				},
				"*" => sub {
					my @estados = ("ACTIVA", "BAJA", "CTX", "JUD");
					return @estados;
				},
			);

			if($definirPreFiltro{$_[0]}) {
				my @estado = $definirPreFiltro{$_[0]}->();
				return (\&listarCuentas, \@estado, \&imprimirCuentas);
			} else {
				print "LISTADO INCORRECTO\n";
				return 0;
			}
		},
		"tarjetas" => sub {
			return (\&listarTarjetas, $_[0], \&imprimirTarjetas);
		},
		"condDistr" => sub {
			return (\&listarCondicionDeDistribucion, $_[0],\&imprimirGeneral);
		},
		"cuentaP" => sub {
			return (\&listarSituacionCuenta, $_[0], \&imprimirCuentas);
		},
		"tarjetaP" => sub {
			return (\&listarSituacionTarjeta, $_[0], \&imprimirTarjetas);
		},
	);

	my $impresor;
	if ($listados{$vec[0]}) {
		($vec[0], $vec[1], $impresor) = $listados{$vec[0]}->($vec[1]);
	} else {
		print "LISTADO INCORRECTO\n";
		return 0;
	}

	return ($impresor, @vec);
}

sub definirFiltro {
	my @vec;
	my @aux = split(";", $_[0]);

	foreach (@aux) {
		push @vec, split("=", $_);
	};

	my %filtro = (
		"entidad" => sub {
			my @condicion = split(",", $_[0]);
			
			if (@condicion == 1) {
				push @condicion, $condicion[0];
			}

			return (\&filtroPorEntidad,\@condicion);
		},
		"fuente" => sub {
			return (\&filtroPorFuente,$_[0]);
		},
		"condDistribucion" => sub {
			return (\&filtroPorCondicionDeDistribucion,$_[0]);
		},
		"docCuenta" => sub {
			return (\&filtroPorDocumentoCuenta,$_[0]);
		},
		"docTarjeta" => sub {
			return (\&filtroPorDocumentoTarjeta,$_[0]);
		},
	);

	for (my $i = 0; $i < @vec; $i=$i+2) { #FORMATO DEL VEC -> (filtro,condicion) -> (subrutina,parametro) 
		if ($filtro{$vec[$i]}) {
			($vec[$i], $vec[$i+1]) = $filtro{$vec[$i]}->($vec[$i+1]);
		} else {
			print "ERROR FILTRO\n";
			return 0;
		}
	}

	return (@vec);
}

sub procesarInput {
	my ($input, $output, $listador, $impresor ,$filtros) = @_;

	#ESTRUCTURAS
	#INPUT -> array de archivos a listar / N elementos
	#LISTADOR -> array que contiene (listador(subrutina), condicion a listar) / 2 elementos
	#IMPRESOR -> subrituna que imprime el registro del input x pantalla
	#FILTROS -> array con estructura (i,i+1)->(filtrador(subrutina),condicon a filtrar) / N elementos

	open (SAL,">aux.list") || die "ERROR: No puedo abrir el fichero de output\n";

	foreach my $elem (@$input) {
		open (ENT,"<$elem") || die "ERROR: No puedo abrir el fichero input\n";

		while (<ENT>) {
			#LISTAR ARCHIVO
			chomp($_);
			my @reg = split(";",$_);

			if ( ($listador->[0]->($listador->[1], \@reg)) and (&pasaFiltro($filtros, \@reg)) ) {
				$impresor->(@reg);
				
				my $cadena = join(";",@reg);
				print SAL $cadena . "\n";
			}
		}

		close (ENT);
	};

	close (SAL);

	rename "aux.list", "$output";
	#delete "aux.list";
}

sub pasaFiltro {
	my ($filtro, $reg) = @_;

	for (my $i = 0; $i < @$filtro; $i=$i+2) { #FORMATO DEL VEC -> (filtro,@condicion) -> (subrutina,parametro)
		if(!( $filtro->[$i]->( $filtro->[($i+1)], $reg ) )) {
			return 0;
		}
	}

	return 1;
}

sub listarCuentas {
	#titulo listado:
	my ($estadoCuenta, $regVec) = @_;

	#PRE-FILTRO
	return (grep $_ eq $regVec->[2], @$estadoCuenta);
}

sub listarTarjetas {
	#titulo listado:
	my ($estadoTx, $regVec) = @_;

	#PRE-FILTRO -> ESTADO_TX => general / denunciadas / bloqueadas / vencidas.
	my %definirEstadoTx = (
		"denunciadas" => sub {
			my $regACmp = $_[0];
			#comparo el campo "DENUNCIADA?" -> es un flag
			return ($regACmp->[4] != 0);
		},
		"bloqueadas" => sub {
			my $regACmp = $_[0];
			#comparo el campo "BLOQUEADA?" -> es un flag
			return ($regACmp->[5] != 0);
		},
		"vencidas" => sub {
			my $regACmp = $_[0];
			#comparo el campo "fechaHasta" con fecha actual

			my @regFecha = split("/",$regACmp->[16]); #levanta formato DD/MM/YYYY
			$regFecha[2] += 2000;

			my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
			$year += 1900;
			my $timeAct = timelocal(0,0,0,$mday,$mon,$year);
			my $timeaCmp = timelocal(0,0,0,$regFecha[0],$regFecha[1]-1,$regFecha[2]);

			return ($timeaCmp <= $timeAct);
		},
		"*" => sub {
			return 1;
		},
	);

	#QUE PASA SI LE MANDO FRUTA AL DEFINIRESTADOTX?
	return ($definirEstadoTx{$estadoTx}->($regVec));

	#el campo es un "FLAG", si no es "0" cumple
	#vencida -> paso a numero la fecha, y cmp con la de hoy
	#return (grep $_ eq $regVec->[2], @$estadoTx);
}

sub listarCondicionDeDistribucion {
	#titulo listado:
	# *para este listado solo se solicita filtro por condición de distribución.
	#PRE-FILTRO es x condicion de distribucion o nada..
	my ($condDistribucion, $regVec) = @_;

	return &filtroPorCondicionDeDistribucion($condDistribucion, $regVec);
}

sub listarSituacionCuenta {
	#titulo listado:
	# *para este listado solo se solicita filtro por documento cuenta.
	#PRE-FILTRO es x docCuenta
	my ($docCuenta, $regVec) = @_;

	return &filtroPorDocumentoCuenta($docCuenta, $regVec);
}

sub listarSituacionTarjeta {
	#titulo listado:
	# *para este listado solo se solicita filtro por documento tarjeta.
	my ($docTx, $regVec) = @_;

	return &filtroPorDocumentoTarjeta($docTx, $regVec);
}

sub filtroPorEntidad {
	#filtro por entidad (una, rango de entidades, todas)
	#$_[0]; -> listado
	#$_[1]; -> (una, rango, todas) -> my (@list) = @_[1]; (PASO UNA LISTA)
	#return $_[0]; -> listadoFiltrado
	my ($filtroVec, $regVec) = @_;

	if($filtroVec->[0] eq "*") {
		return 1;
	}
	
	return ( ($regVec->[22] >= $filtroVec->[0]) and ($regVec->[22] <= $filtroVec->[1]) );
}

sub filtroPorFuente {
	#filtro por fuente (una o todas)
	#$_[0]; -> listado
	#$_[1]; -> (una o todas)
	#return $_[0]; -> listadoFiltrado
	my ($condFuente, $regVec) = @_;

	if($condFuente eq "*") {
		return 1;
	}
	
	return ($regVec->[0] eq $condFuente);
}

sub filtroPorCondicionDeDistribucion {
	#filtro por condición de distribución (default * ) (búsqueda por sub-string, ejemplo " BAJA" "NO DISTRIBUIR" "DENU")
	my ($condDistribucion, $regVec) = @_;

	# if (! $condDistribucion) {
	# 	return 1;
	# }

	return ($regVec->[6] =~ $condDistribucion); # =~ -> EXPRESIONES REGULARES
}

sub filtroPorDocumentoCuenta {
	#filtro por documento cuenta: (default * ) (búsqueda por sub-string Ejemplo: si el campo es:
	#CUIT:30707339158 y se busca 30707339158 debería encontrar el registro de plástico emitido de Martin Tivori)
	#$_[0]; -> listado
	# $_[1]; -> (busca x sub-string)
	#return $_[0]; -> listadoFiltrado

	my ($docCuenta, $regVec) = @_;

	return ($regVec->[17] =~ $docCuenta); # =~ -> EXPRESIONES REGULARES
}

sub filtroPorDocumentoTarjeta {
	#filtro por documento tarjeta: (default * ) (búsqueda por sub-string Ejemplo: si el campo es: du:
	#40123456 y se busca 40123456 debería encontrar el registro de plástico emitido de Martin Tivori)
	#$_[0]; -> listado
	#$_[1]; -> (busca x sub-string)
	#return $_[0]; -> listadoFiltrado
	my ($docTx, $regVec) = @_;

	return ($regVec->[9] =~ $docTx); # =~ -> EXPRESIONES REGULARES
}

sub imprimirCuentas {
	#Fuente/Nro de Cuenta/Estado de la cuenta/Tarjeta vieja?/Denunciada?/Bloqueada?/Condición de Distribución/
	#	Fecha de cambio de la condición de distribución/Proceso/Documento Tarjeta/Denominación en la Tarjeta/
	#	t1/t2/t3/t4/Fecha desde/Fecha hasta/Documento cuenta/Denominación de la Cuenta/Fecha de Alta/Categoría/
	#	Limite/Entidad Bancaria/Alias
	
	my @regVec = @_;
	my @aux = ($regVec[22]." - ".$regVec[23] , $regVec[1], $regVec[17], $regVec[18], $regVec[19], $regVec[20], $regVec[21], $regVec[2]);

	#Entidad Bancaria/Nro. de Cuenta/Documento cuenta/Denominación de la Cuenta/Fecha de Alta/
	#	Categoría/Limite/Estado de la cuenta
	print join("\t",@aux) . "\n";
}

sub imprimirTarjetas {
	#Fuente/Nro de Cuenta/Estado de la cuenta/Tarjeta vieja?/Denunciada?/Bloqueada?/Condición de Distribución/
	#	Fecha de cambio de la condición de distribución/Proceso/Documento Tarjeta/Denominación en la Tarjeta/
	#	t1/t2/t3/t4/Fecha desde/Fecha hasta/Documento cuenta/Denominación de la Cuenta/Fecha de Alta/Categoría/
	#	Limite/Entidad Bancaria/Alias
	
	my @regVec = @_;
	my @aux = ($regVec[22]." - ".$regVec[23], $regVec[1], $regVec[9], $regVec[10], $regVec[11]."-".$regVec[12]."-".$regVec[13]."-".$regVec[14], $regVec[15]." - ".$regVec[16], $regVec[4], $regVec[5], $regVec[6], $regVec[7]);

	#Entidad Bancaria-Alias/Nro. de Cuenta/Documento Tarjeta/Denominación en la Tarjeta/
	#	T1-T2-T3-T4/Fecha desde - Fecha hasta/Denunciada?/Bloqueada?/Condición  de Distribución/
	#	Fecha de cambio de la condición de distribución
	print join("\t",@aux) . "\n";
}

sub imprimirGeneral {
	my @regVec = @_; #recibo registro

	#Fuente/Nro de Cuenta/Estado de la cuenta/Tarjeta vieja?/Denunciada?/Bloqueada?/Condición de Distribución/
	#	Fecha de cambio de la condición de distribución/Proceso/Documento Tarjeta/Denominación en la Tarjeta/
	#	t1/t2/t3/t4/Fecha desde/Fecha hasta/Documento cuenta/Denominación de la Cuenta/Fecha de Alta/Categoría/
	#	Limite/Entidad Bancaria/Alias

	# ·Si muestra Nro de Tarjeta hacerlo con el siguiente formato:
	# 	Nro de Tarjeta (t1-t2-t3-t4)
	$regVec[11] = $regVec[11] . "-" . $regVec[12] . "-" . $regVec[13] . "-" . $regVec[14];

	# ·Si muestra fechas, hacerlo con el siguiente formato:
	# 	Fecha desde - Fecha hasta
	$regVec[15] = $regVec[15] . " - " . $regVec[16];

	# ·Si muestra Fuentes, hacerlo con el siguiente formato:
	# 	Fuente - Alias
	$regVec[22] = $regVec[22] . " - " . $regVec[23];

	splice(@regVec, 12, 3);
	splice(@regVec, 13, 1);
	splice(@regVec, 19, 1);

	print join("\t",@regVec) . "\n";
}

sub listadorAutomatico {
	#AGARRAR EL ULTIMO PLASTICOS EMITIDOS
	#ES X NUMERO SEC -> EL ULTIMO ES EL MAS NUEVO

	my $input = &ultimoArchivoEmitidos();
	my $output = &nuevoArchivoDistribucion();

	&actualizarDistribucion($input, $output);

	print"Se genero: $output; con: $input\n";
}

sub actualizarDistribucion {
	my ($input,$output) = @_;

	open (ENT,"<$input") || die " ERROR: No puedo abrir el fichero de entrada \n :$input\n";
	open (SAL,">$output") || die "ERROR: No puedo abrir el fichero de salida \n :$output\n";

	while (<ENT>) {
		chomp($_); #con chomp elimino el fin de linea, $_ contiene el último registro leido de un fichero.
		my @reg = split(";",$_); #split() divide una cadena, @reg defino un vector

		#AUTOMATICO
		#MODIFICAR CAMPO "Condición de Distribución" , "Fecha de cambio de la condición de distribución" y "Proceso"
		# vector -> 6, 7 y 8

		# FECHA DE CAMBIO DE LA CONDICION DE DISTRIBUCION
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$year += 1900;
		$mon++;
		$reg[7] = "$mday/$mon/$year";
		
		#PROCESO
		$reg[8] = "LISTADOR";

		#DEFAULT
		my $str = "DISTRIBUCION ESTANDAR";

		#POSIBLE CASE CHETO
		#SI ESTADO DE CUENTA:
		# = BAJA, $str = "NO DISTRIBUIR, La cuenta esta dada de BAJA"
		# = CTX, $str = "NO DISTRIBUIR, La cuenta es CONTENCIOSA"
		# = JUD, $str = "NO DISTRIBUIR, La cuenta es JUDICIAL"
		my %estadoDeCuentas = ( #defino Hashes(listas asociativas)
			"BAJA" => sub {
				return "NO DISTRIBUIR, La cuenta esta dada de BAJA";
			},
			"CTX" => sub {
				return "NO DISTRIBUIR, La cuenta es CONTENCIOSA";
			},
			"JUD" => sub {
				return "NO DISTRIBUIR, La cuenta es JUDICIAL";
			},
		);

		if ($estadoDeCuentas{$reg[2]}) {
			$str = $estadoDeCuentas{$reg[2]}->();
		} else {
			#SI EL FLAG BLOQUEADA: 
			# = 1, $str = "RETENER, La tarjeta fue BLOQUEADA"
			if($reg[5] == 1) {
				$str = "RETENER, La tarjeta fue BLOQUEADA";
			} else {
				#SI LA FECHA HASTA
				# >= HOY, $str = "NO DISTRIBUIR, tarjeta VENCIDA"
				# >= (HOY-10 dias), $str = "NO DISTRIBUIR, VENTANA de distribucion insuficiente"

				my @regFecha = split("/",$reg[16]); #levanta formato DD/MM/YYYY
				$regFecha[2] += 2000;

				my $timeAct = timelocal(0,0,0,$mday,$mon-1,$year);
				my $timeDiezDias = timegm(0,0,0,11,0,1970);
				my $timeMasDiezDias = $timeAct + $timeDiezDias;

				my $timeaCmp = timelocal(0,0,0,$regFecha[0],$regFecha[1]-1,$regFecha[2]);

				# $ltime = localtime($timeMasDiezDias);
				# print "HOY+10 ES " . "$timeMasDiezDias => $ltime\n";
				# $ltimeCmp = localtime($timeaCmp);
				# print "TIME CMP: " . "$timeaCmp => $ltimeCmp\n";

				if($timeaCmp <= $timeMasDiezDias) {
					$str = "NO DISTRIBUIR, VENTANA de distribucion insuficiente";
					
					if($timeaCmp <= $timeAct){
						$str = "NO DISTRIBUIR, tarjeta VENCIDA";
					}
				} else {
					#SI FLAG DENUNCIADA
					# = 1, $str = "DISTRIBUCION URGENTE"
					if($reg[4] == 1) {
						$str = "DISTRIBUCION URGENTE";
					}
				}
			}
		}

		#CONDICION DE DISTRIBUCION
		$reg[6] = $str;
		# print $reg[6] . ";" . $reg[7] . ";" . $reg[8] . "\n";

		my $cadena = join(";",@reg);
		print SAL $cadena . "\n";
	}

	close (SAL);
	close (ENT);
}

sub nuevoNombreListado {
	opendir(DIR, $ENV{"REPORTES"}."/");
	my @files = grep(/^LISTADO_/, readdir(DIR));

	if(!@files) {
		return ($ENV{"REPORTES"}."/LISTADO_1");
	}

	my @numeros;
	foreach (@files) {
		push @numeros, substr($_ , 8);
	}

	my @numerosSort = sort {$a <=> $b} @numeros;
	my $numero = $numerosSort[@numerosSort-1] + 1; 
	closedir(DIR);

	return ($ENV{"REPORTES"}."/LISTADO_".$numero);
}

sub ultimoArchivoEmitidos {
	opendir(DIR, $ENV{"ACEPTADOS"}."/");
	my @files = grep(/^PLASTICOS_EMITIDOS_/, readdir(DIR));
	@files = sort @files;
	my $numero = substr($files[@files-1], 19);
	closedir(DIR);

	return ($ENV{"ACEPTADOS"}."/PLASTICOS_EMITIDOS_$numero");
}

sub nuevoArchivoDistribucion {
	opendir(DIR, $ENV{"REPORTES"}."/");
	my @files = grep(/^PLASTICOS_DISTRIBUCION_/, readdir(DIR));

	if(!@files) {
		return ($ENV{"REPORTES"}."/PLASTICOS_DISTRIBUCION_1");
	}

	my @numeros;
	foreach (@files) {
		push @numeros, substr($_ , 23);
	}

	my @numerosSort = sort {$a <=> $b} @numeros;
	my $numero = $numerosSort[@numerosSort-1] + 1;
	closedir(DIR);

	return ($ENV{"REPORTES"}."/PLASTICOS_DISTRIBUCION_$numero");
}

########################################################
######################### HELP #########################
########################################################
sub imprimirAyuda {
	print "\n";
	print "######################## HELP ########################\n";
	print "############ MODO MANUAL\n";
	print "EJEMPLO:\n";
	print "~ perl LISTADOR.pl -i=\"PLASTICOS_EMITIDOS_1;PLASTICOS_EMITIDOS_2\" -l=\"cuentas=ACTIVAS\" -f=\"entidad=2,99;docCuenta=40355277\"\n";
	print "Modo de uso: LISTADOR.pl [-i]=\"[inputs]\" [-l]=\"[listado]\" [-f]=\"[filtros]\"\n";
	print "	-i			~ Input:\n";
	print " 					· Un archivo especifico de plasticos_emitidos o de plasticos_distribucion\n";
	print " 					· Varios archivos específicos(de emitidos, de distribucion o de ambos)\n";
	print " 					· Todos los archivos de plasticos_emitidos (default)\n";
	print " 					· Todos los archivos de plasticos_distribucion\n\n";
	print "	-l			~ Opciones de listados:\n";
	print "	=cuentas		· Listados de cuentas:\n";
	print "					General \n";
	print "					=ACTIVAS 	Cuentas activas\n";
	print "					=BCJ	 	Cuentas dadas de baja, ctx, o jud\n";
	print "	=tarjetas		· Listados de tarjetas:\n";
	print "					General \n";
	print "					=denunciadas	Denunciadas\n";
	print "					=bloqueadas	Bloqueadas\n";
	print "					=vencidas 	Vencidas\n";
	print "	=condDistr		· Listado de condición de distribución\n";
	print "					-> para este listado solo se solicita filtro por condición de distribución\n";
	print "	=cuentaP		· Listado de la situación de una cuenta en particular\n";
	print "					-> para este listado solo se solicita filtro por documento cuenta\n";
	print "	=tarjetaP		· Listado de la situación de una tarjeta en particular\n";
	print "					-> para este listado solo se solicita filtro por documento tarjeta\n\n";
	print "	-f			~ Opciones de filtros\n";
	print "	=entidad		· Filtro por entidad\n";
	print "					= (una, rango de entidades, todas)\n";
	print "	=fuente			· Filtro por fuente\n";
	print "					= (una o todas)\n";
	print "	=condDistr		· Filtro por condición de distribución (default *)\n";
	print "					= sub-string\n";
	print "	=docCuenta		· Filtro por documento cuenta: (default *)\n";
	print "					= sub-string\n";
	print "	=docTarjeta		· Filtro por documento tarjeta: (default *)\n";
	print "					= sub-string\n\n";
	print "	';'			-> SEPARADOR DE ARCHIVOS Y FILTROS\n";
	print "	','			-> SEPARADOR DE RANGOS\n\n";
}

sub imprimirSubAyuda {
	print "\n";
	print "######################## HELP ########################\n";
	print "############ LISTADOR\n";
	print "#	Se puede: APLICAR N FILTROS AL LISTADO O GENERAR UN NUEVO LISTADO SOBRE EL INPUT ANTERIOR\n";
	print "Modo de uso:	[-l]=\"[listado]\" [-f]=\"[filtros]\"\n";
	print "		[-f]=\"[filtros]\"\n";
	print "	-l			~ Opciones de listados:\n";
	print "	=cuentas		· Listados de cuentas:\n";
	print "					General \n";
	print "					=ACTIVAS 	Cuentas activas\n";
	print "					=BCJ	 	Cuentas dadas de baja, ctx, o jud\n";
	print "	=tarjetas		· Listados de tarjetas:\n";
	print "					General \n";
	print "					=denunciadas	Denunciadas\n";
	print "					=bloqueadas	Bloqueadas\n";
	print "					=vencidas 	Vencidas\n";
	print "	=condDistr		· Listado de condición de distribución\n";
	print "					-> para este listado solo se solicita filtro por condición de distribución\n";
	print "	=cuentaP		· Listado de la situación de una cuenta en particular\n";
	print "					-> para este listado solo se solicita filtro por documento cuenta\n";
	print "	=tarjetaP		· Listado de la situación de una tarjeta en particular\n";
	print "					-> para este listado solo se solicita filtro por documento tarjeta\n\n";
	print "	-f			~ Opciones de filtros\n";
	print "	=entidad		· Filtro por entidad\n";
	print "					= (una, rango de entidades, todas)\n";
	print "	=fuente			· Filtro por fuente\n";
	print "					= (una o todas)\n";
	print "	=condDistr		· Filtro por condición de distribución (default *)\n";
	print "					= sub-string\n";
	print "	=docCuenta		· Filtro por documento cuenta: (default *)\n";
	print "					= sub-string\n";
	print "	=docTarjeta		· Filtro por documento tarjeta: (default *)\n";
	print "					= sub-string\n\n";
	print "	';'			-> SEPARADOR DE FILTROS\n";
	print "	','			-> SEPARADOR DE RANGOS\n\n";
	print "	exit			-> FINALIZAR EJECUCION\n\n";
}