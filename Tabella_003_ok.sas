/********************************************
Tabella Arcipelago 003
Impegnative
***********************************************/

LIBNAME FAR_2016 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2016';
LIBNAME FAR_2017 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2017';
LIBNAME FAR_2018 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2018';

%include '/sasprd/staging/staging_san1/S1_ORPSS/config/MACRO_ORPSS/far_adt.sas' ;
%include '/sasprd/staging/staging_san1/S1_ORPSS/config/MACRO_ORPSS/far_anagrafica.sas' ;
%include '/sasprd/staging/staging_san1/S1_ORPSS/config/MACRO_ORPSS/far_udo_atti.sas' ;
%include '/sasprd/staging/staging_san1/S1_ORPSS/config/MACRO_ORPSS/far_impegnative.sas' ;

/*esecuzione delle macro*/
%let anno=2017; 	/*anno di interesse*/
%let fase=12; 		/*fase di interesse*/
%let trimestre=4; 	/* trimestre di interesse */

%SET_ANAGRAFICA_FAR(&anno,&fase);
%SET_ADT_FAR(&anno,&fase);
%SET_UDO;
%SET_IMPEGNATIVE_FAR(&anno,&fase); 



%MACRO TABELLA_003;
data impegnative;
	set imp;
	U1=substr(ulss_impegnativa, 4, 3);
	U=input(u1, best3.);
run;

data impegnative;
	set impegnative;
	if motivo_chiusura_impegnativa = '8' then motivo_chiusura_impegnativa = '9'; 
	if U=101 THEN ULSS_NEW=501;
	if U=102 THEN ULSS_NEW=501;
	if U=109 THEN ULSS_NEW=502;
	if U=107 THEN ULSS_NEW=502;
	if U=108 THEN ULSS_NEW=502;
	if U=112 THEN ULSS_NEW=503;
	if U=113 THEN	ULSS_NEW=503;
	if U=114 THEN	ULSS_NEW=503;
	if U=110 THEN	ULSS_NEW=504;
	if U=118 THEN	ULSS_NEW=505;
	if U=119 THEN	ULSS_NEW=505;
	if U=115 THEN	ULSS_NEW=506;
	if U=116 THEN	ULSS_NEW=506;
	if U=117 THEN	ULSS_NEW=506;
	if U=103 THEN	ULSS_NEW=507;
	if U=104 THEN ULSS_NEW=507;
	if U=106 THEN ULSS_NEW=508;
	if U=105 THEN ULSS_NEW=508;
	if U=120 THEN ULSS_NEW=509;
	if U=121 THEN ULSS_NEW=509;
	if U=122 THEN ULSS_NEW=509;
	if U=501 THEN ULSS_NEW=501;
	if U=502 THEN ULSS_NEW=502;
	if U=503 THEN ULSS_NEW=503;
	if U=504 THEN ULSS_NEW=504;
	if U=505 THEN ULSS_NEW=505;
	if U=506 THEN ULSS_NEW=506;
	if U=507 THEN ULSS_NEW=507;
	if U=508 THEN ULSS_NEW=508;
	if U=509 THEN ULSS_NEW=509;

RUN; 

data impegnative;
	set impegnative;
	rename u = ulss_old;
	ANNO_EMISSIONE_IMP = YEAR(DATA_IMPEGNATIVA);
	ANNO_CHIUSURA_IMP = YEAR(DATA_CHIUSURA_IMPEGNATIVA);
run;

data impegnative;
	set impegnative;
	if DATA_CHIUSURA_IMPEGNATIVA ne . then
		DIFFERENZA_GG=DATA_CHIUSURA_IMPEGNATIVA-DATA_IMPEGNATIVA;
RUN;

data impegnative;
	set impegnative;
	TRIMESTRE = &trimestre;
RUN;

DATA impegnative;
	set impegnative;

	if DIFFERENZA_GG <0 then
		DIFFERENZA_GG=.;
run;

/*attacco all'anagrafica*/
PROC SORT DATA=impegnative;
	BY CODICE_SOGGETTO_BIN;
RUN;/**/

PROC SORT DATA=ana_&anno.;
	BY CODICE_SOGGETTO_BIN;
RUN;

data I;
	MERGE impegnative(in=a) ana_&anno. (in=b);
	BY CODICE_SOGGETTO_BIN;
	if a;
RUN;

data I;
set I;
	IF MOTIVO_CHIUSURA_IMPEGNATIVA='05' 		THEN DO; 
eta=(int(DATA_CHIUSURA_IMPEGNATIVA-DATANASC)/365.25);
END; 
ELSE DO;
	IF ( &fase in (1,3,5,7,8,10,12) ) 		THEN eta=int((mdy(&fase,31,&anno)-DATANASC)/365.25);
	IF ( &fase in (4,6,9,11) ) 				THEN eta=int((mdy(&fase,30,&anno)-DATANASC)/365.25);
	IF ( (mod(&anno,4)=0) and &fase = 2)	THEN eta=int((mdy(&fase,29,&anno)-DATANASC)/365.25);
	IF ( (mod(&anno,4) ne 0) and &fase = 2) THEN eta=int((mdy(&fase,28,&anno)-DATANASC)/365.25);
END; 
run;

data I;
	set I;

	if eta=. then
		cleta=.;

	if 0<=eta<=64 then
		cleta=1;

	if 65<=eta<=74 then
		cleta=2;

	if 75<=eta<=84 then
		cleta=3;

	if eta>=85 then
		cleta=4;
	format cleta fascia_eta.;
RUN;

data arcipelago3;
	set I;
	keep 
		CODICE_SOGGETTO_BIN
		ULSS_OLD
		ULSS_NEW
		ANNO_A3
		TRIMESTRE
		ANNO_EMISSIONE_IMP
		DURATA_IMPEGNATIVA
		EMISSIONE_IMPEGNATIVA
		SPESA_FUORI_REGIONE
		TIPO_TRATTAMENTO
		IMPEGNATIVA_EX_DGR_1322
		DIFFERENZA_GG
		ANNO_CHIUSURA_IMP
		MOTIVO_CHIUSURA_IMPEGNATIVA
		FLG_TIPO_UTENTE
		CLETA
		SESSO;
run;

/* CANCELLO l'utente con impegnativa chiusa nel 2012*/
data arcipelago3; set arcipelago3; 
if anno_chiusura_imp=2012 then delete; /*48749*/
run; 

data arcipelago3;
	retain
		CODICE_SOGGETTO_BIN
		ULSS_OLD
		ULSS_NEW
		ANNO_A3
		TRIMESTRE
		ANNO_EMISSIONE_IMP
		DURATA_IMPEGNATIVA
		EMISSIONE_IMPEGNATIVA
		SPESA_FUORI_REGIONE
		TIPO_TRATTAMENTO
		IMPEGNATIVA_EX_DGR_1322
		DIFFERENZA_GG
		ANNO_CHIUSURA_IMP
		MOTIVO_CHIUSURA_IMPEGNATIVA
		FLG_TIPO_UTENTE
		CLETA
		SESSO;
	set arcipelago3;
run;
%MEND; 

%TABELLA_003;

/*ACCODAMENTO */

/*PER ACCODAMENTO DI PIù ANNI*/
DATA TMP_&anno.; SET ARCIPELAGO3; RUN; 

DATA ARCIPELAGO_003; SET TMP_2016 TMP_2017 TMP_2018; RUN; 

data arcipelago_003; set arcipelago_003;
if ulss_old=501 and ulss_new = .  then ulss_new = 501;
if ulss_old=502 and ulss_new = .  then ulss_new = 502;
if ulss_old=503 and ulss_new = .  then ulss_new = 503;
if ulss_old=504 and ulss_new = .  then ulss_new = 504;
if ulss_old=505 and ulss_new = .  then ulss_new = 505;
if ulss_old=506 and ulss_new = .  then ulss_new = 506;
if ulss_old=507 and ulss_new = .  then ulss_new = 507;
if ulss_old=508 and ulss_new = .  then ulss_new = 508;
if ulss_old=509 and ulss_new = .  then ulss_new = 509;
run; 
 
/*non possono esserci impegnative chiuse in anni troppo indietro... (sono poche)*/
data arcipelago_003; set arcipelago_003; 
if (anno_a3=2017 and anno_chiusura_imp <2017 ) then anno_chiusura_imp = .  ; run; 

/*proc freq data=arcipelago_003; table anno_a3 * anno_chiusura_imp; run;
EOF*/ 
