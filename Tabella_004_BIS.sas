/****************************************************/
/*													*/
/*				tabella arcipelago 4 bis ADT		*/
/****************************************************/
/****************************************************/
LIBNAME FAR_2016 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2016';
LIBNAME FAR_2017 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2017';
LIBNAME FAR_2018 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2018';

%MACRO SET_ADT_FAR;
proc sql;
	create table adt as
		select *
			from DWHODD.ODD_FAR_UNI_A4_DEF
				where (anno=&anno and fase =&fase AND flg_archivio ne 'C');
quit;

DATA adt;
	SET adt;
	DATARIC_STRUTTURA_TEMP=INPUT(DATA_INGRESSO,DDMMYY8.);
	DATARIC_UDO_TEMP=INPUT(DATA_INGRESSO_UDO,DDMMYY8.);
	DATADIM_UDO_TEMP=INPUT(DATA_DIMISSIONE,DDMMYY8.);
	DATA_CONTRIBUTO_IN_TEMP=INPUT(DATA_CONTRIBUTO_IN,DDMMYY8.);
	DATA_CONTRIBUTO_FI_TEMP=INPUT(DATA_CONTRIBUTO_FI,DDMMYY8.);
	FORMAT DATARIC_STRUTTURA_TEMP DATARIC_UDO_TEMP 
		DATADIM_UDO_TEMP DATA_CONTRIBUTO_IN_TEMP DATA_CONTRIBUTO_FI_TEMP DATE9.;
RUN;

DATA adt;
	SET adt;
	DROP DATA_INGRESSO DATA_INGRESSO_UDO DATA_DIMISSIONE DATA_CONTRIBUTO_IN DATA_CONTRIBUTO_FI;
	RENAME PRG_REC=PRG_REC_A4
		ANNO=ANNO_A4
		COD_ENTE=ULSS
		ID_ASSISTITO=ID_EPISODIO
		COD_STRUT_EROG_UDO=COD_UDO
		COD_STRUT_EROG_STS=COD_STS
		COD_STRUT_EROG_MRA=COD_MRA
		COD_ASL_IMPEGNATIVA=ULSS_IMPEGNATIVA
		COD_PROVENIENZA=PROVENIENZA
		DATARIC_STRUTTURA_TEMP=DATARIC_STRUTTURA
		DATARIC_UDO_TEMP=DATARIC_UDO
		DATADIM_UDO_TEMP=DATADIM_UDO
		DATA_CONTRIBUTO_IN_TEMP=DATA_CONTRIBUTO_IN
		DATA_CONTRIBUTO_FI_TEMP=DATA_CONTRIBUTO_FI
		FASE=FASE_A4;
	FORMAT PROVENIENZA $PROVENIENZA.;
	FORMAT COD_RICHIESTA_INSERIMENTO $INIZIATIVA_INSERIMENTO. 
		VAL_RICHIESTA_INSERIMENTO $si_no_attesa. TITOLO_INGRESSO $titolo_ingresso. 
		cod_quota_rilievo $quota. cod_soggetto_pagante $sogg_pagante. 
		cod_tipo_dimissione $dimissione.;
run;

DATA adt;
	SET adt;
	VALORE_QUOTA_RILIEVO_num 		= input (VALORE_QUOTA_RILIEVO, best6.);
	TOTALE_QUOTA_GIORNALIERA_num 	= input (TOTALE_QUOTA_GIORNALIERA, best6.);
	COMPONENTE_SANITARIA_QUOTA_num	= input (COMPONENTE_SANITARIA_QUOTA, best6.);
run;

data adt;
	set adt;
	drop VALORE_QUOTA_RILIEVO TOTALE_QUOTA_GIORNALIERA COMPONENTE_SANITARIA_QUOTA;
run;
%MEND;

%MACRO SET_UDO;
/*CONTROLLARE CHE SIA AGGIORNATO IL FILE. 
EVENTUALMENTE FAR GIRARE anagrafica_udo che genera il file corretto*/
data udo;
	set FAR_&ANNO..ANAGRAFICA_UDO_POSTI_&ANNO.;
run;

DATA udo;
	SET udo;
	FORMAT TIPO_UDO $TIPOUDO. 
	COD_ATTO_ACCR $COD_ATTO.
	COD_ATTO_AUTO $COD_ATTO.
	;
run;

data udo; set udo; rename fase=fase_a7; run;
%MEND; 


%macro tabella_004;
proc sort data=adt;
	by cod_udo;
run;

proc sort data=udo;
	by cod_udo;
run;

DATA au;/**/
	MERGE adt (IN=A) UDO (IN=B);
	BY cod_udo;

	IF A ;
RUN;

data au;
	set au;

	if ULSS_UDO='101' THEN
		ULSS_UDO_NEW=501;

	if ULSS_UDO='102' THEN
		ULSS_UDO_NEW=501;

	*;
	if ULSS_UDO='109' THEN
		ULSS_UDO_NEW=502;

	if ULSS_UDO='107' THEN
		ULSS_UDO_NEW=502;

	if ULSS_UDO='108' THEN
		ULSS_UDO_NEW=502;

	*;
	if ULSS_UDO='112' THEN
		ULSS_UDO_NEW=503;

	if ULSS_UDO='113' THEN
		ULSS_UDO_NEW=503;

	if ULSS_UDO='114' THEN
		ULSS_UDO_NEW=503;

	*;
	if ULSS_UDO='110' THEN
		ULSS_UDO_NEW=504;

	*;
	if ULSS_UDO='118' THEN
		ULSS_UDO_NEW=505;

	if ULSS_UDO='119' THEN
		ULSS_UDO_NEW=505;

	*;
	if ULSS_UDO='115' THEN
		ULSS_UDO_NEW=506;

	if ULSS_UDO='116' THEN
		ULSS_UDO_NEW=506;

	if ULSS_UDO='117' THEN
		ULSS_UDO_NEW=506;

	*;
	if ULSS_UDO='103' THEN
		ULSS_UDO_NEW=507;

	if ULSS_UDO='104' THEN
		ULSS_UDO_NEW=507;

	*;
	if ULSS_UDO='106' THEN
		ULSS_UDO_NEW=508;

	if ULSS_UDO='105' THEN
		ULSS_UDO_NEW=508;

	*;
	if ULSS_UDO='120' THEN
		ULSS_UDO_NEW=509;

	if ULSS_UDO='121' THEN
		ULSS_UDO_NEW=509;

	if ULSS_UDO='122' THEN
		ULSS_UDO_NEW=509;
RUN;

DATA AU;
	SET AU;
	DUMMY=SUBSTR(ULSS_IMPEGNATIVA,1,3);
RUN;

DATA AU;
	SET AU;

	IF DUMMY='050' THEN
		ULSS_IMPEGNATIVA_OLD=SUBSTR(ULSS_IMPEGNATIVA, 4,3);
RUN;

data au;
	set au;

	if ULSS_IMPEGNATIVA_OLD='101' THEN
		ULSS_IMPEGNATIVA_NEW=501;

	if ULSS_IMPEGNATIVA_OLD='102' THEN
		ULSS_IMPEGNATIVA_NEW=501;

	*;
	if ULSS_IMPEGNATIVA_OLD='109' THEN
		ULSS_IMPEGNATIVA_NEW=502;

	if ULSS_IMPEGNATIVA_OLD='107' THEN
		ULSS_IMPEGNATIVA_NEW=502;

	if ULSS_IMPEGNATIVA_OLD='108' THEN
		ULSS_IMPEGNATIVA_NEW=502;

	*;
	if ULSS_IMPEGNATIVA_OLD='112' THEN
		ULSS_IMPEGNATIVA_NEW=503;

	if ULSS_IMPEGNATIVA_OLD='113' THEN
		ULSS_IMPEGNATIVA_NEW=503;

	if ULSS_IMPEGNATIVA_OLD='114' THEN
		ULSS_IMPEGNATIVA_NEW=503;

	*;
	if ULSS_IMPEGNATIVA_OLD='110' THEN
		ULSS_IMPEGNATIVA_NEW=504;

	*;
	if ULSS_IMPEGNATIVA_OLD='118' THEN
		ULSS_IMPEGNATIVA_NEW=505;

	if ULSS_IMPEGNATIVA_OLD='119' THEN
		ULSS_IMPEGNATIVA_NEW=505;

	*;
	if ULSS_IMPEGNATIVA_OLD='115' THEN
		ULSS_IMPEGNATIVA_NEW=506;

	if ULSS_IMPEGNATIVA_OLD='116' THEN
		ULSS_IMPEGNATIVA_NEW=506;

	if ULSS_IMPEGNATIVA_OLD='117' THEN
		ULSS_IMPEGNATIVA_NEW=506;

	*;
	if ULSS_IMPEGNATIVA_OLD='103' THEN
		ULSS_IMPEGNATIVA_NEW=507;

	if ULSS_IMPEGNATIVA_OLD='104' THEN
		ULSS_IMPEGNATIVA_NEW=507;

	*;
	if ULSS_IMPEGNATIVA_OLD='106' THEN
		ULSS_IMPEGNATIVA_NEW=508;

	if ULSS_IMPEGNATIVA_OLD='105' THEN
		ULSS_IMPEGNATIVA_NEW=508;

	*;
	if ULSS_IMPEGNATIVA_OLD='120' THEN
		ULSS_IMPEGNATIVA_NEW=509;

	if ULSS_IMPEGNATIVA_OLD='121' THEN
		ULSS_IMPEGNATIVA_NEW=509;

	if ULSS_IMPEGNATIVA_OLD='122' THEN
		ULSS_IMPEGNATIVA_NEW=509;
RUN;

DATA AU;
	SET AU;
	ANNO_PRIMO_INGRESSO=YEAR(DATARIC_STRUTTURA);
	ANNO_INGRESSO_UDO=YEAR(DATARIC_UDO);
	ANNO_DIMISSIONE=YEAR(DATADIM_UDO);
RUN;

/*RICREO LE DATE PER IL CONTEGGIO DEI GIORNI LORDI DI PERMANENZA*/


DATA AU;
	SET AU; 

	IF ANNO_INGRESSO_UDO < &anno THEN
		DATARIC_UDO_NEW=mdy(01,01,&anno);

	IF ANNO_INGRESSO_UDO=&anno THEN
		DATARIC_UDO_NEW=DATARIC_UDO;

FORMAT DATARIC_UDO_NEW DATE9.;

run; 

data au; set au; 

	IF ANNO_DIMISSIONE=&anno THEN
		DATADIM_UDO_NEW=DATADIM_UDO; 

	IF (ANNO_DIMISSIONE=. and &fase in (1,3,5,7,8,10,12)) THEN DATADIM_UDO_NEW=mdy(&fase,31,&anno);
	IF (ANNO_DIMISSIONE=. and &fase in (4,6,9,11)) THEN DATADIM_UDO_NEW=mdy(&fase,30,&anno);
	IF (ANNO_DIMISSIONE=. and (mod(&anno,4)=0) and &fase = 2) THEN DATADIM_UDO_NEW=mdy(&fase,29,&anno);
	IF (ANNO_DIMISSIONE=. and (mod(&anno,4) ne 0) and &fase = 2) THEN DATADIM_UDO_NEW=mdy(&fase,28,&anno);

	IF ANNO_DIMISSIONE=(&anno+1) THEN
		DATADIM_UDO_NEW=mdy(12,31,&anno);

	format DATADIM_UDO_NEW date9.; 
RUN;


DATA AU;
	SET AU;
	GIORNI_LORDI_&anno = (DATADIM_UDO_NEW - DATARIC_UDO_NEW) +1;
RUN;

DATA AU;
	SET AU;
/*anno non bisesitle*/
	IF GIORNI_LORDI_&anno = 366 and (mod(&anno,4) ne 0) THEN
		GIORNI_LORDI_&anno = 365;
/*anno  bisesitle*/
		IF GIORNI_LORDI_&anno = 367 and (mod(&anno,4) eq 0) THEN
		GIORNI_LORDI_&anno = 366;
RUN;

data au;
set au;
/*anno non bisesitle*/
if (mod(&anno,4) ne 0) and &fase=1 then denominatore = 31; 
if (mod(&anno,4) ne 0) and &fase=2 then denominatore = 31+28; 
if (mod(&anno,4) ne 0) and &fase=3 then denominatore = 31+28+31; 
if (mod(&anno,4) ne 0) and &fase=4 then denominatore = 31+28+31+30; 
if (mod(&anno,4) ne 0) and &fase=5 then denominatore = 31+28+31+30+31; 
if (mod(&anno,4) ne 0) and &fase=6 then denominatore = 31+28+31+30+31+30; 
if (mod(&anno,4) ne 0) and &fase=7 then denominatore = 31+28+31+30+31+30+31; 
if (mod(&anno,4) ne 0) and &fase=8 then denominatore = 31+28+31+30+31+30+31+31; 
if (mod(&anno,4) ne 0) and &fase=9 then denominatore = 31+28+31+30+31+30+31+31+30; 
if (mod(&anno,4) ne 0) and &fase=10 then denominatore = 31+28+31+30+31+30+31+31+30+31; 
if (mod(&anno,4) ne 0) and &fase=11 then denominatore = 31+28+31+30+31+30+31+31+30+31+30; 
if (mod(&anno,4) ne 0) and &fase=12 then denominatore = 31+28+31+30+31+30+31+31+30+31+30+31; 
/**/


/*anno bisesitle*/
if (mod(&anno,4) eq 0) and &fase=1 then denominatore = 31; 
if (mod(&anno,4) eq 0) and &fase=2 then denominatore = 31+29; 
if (mod(&anno,4) eq 0) and &fase=3 then denominatore = 31+29+31; 
if (mod(&anno,4) eq 0) and &fase=4 then denominatore = 31+29+31+30; 
if (mod(&anno,4) eq 0) and &fase=5 then denominatore = 31+29+31+30+31; 
if (mod(&anno,4) eq 0) and &fase=6 then denominatore = 31+29+31+30+31+30; 
if (mod(&anno,4) eq 0) and &fase=7 then denominatore = 31+29+31+30+31+30+31; 
if (mod(&anno,4) eq 0) and &fase=8 then denominatore = 31+29+31+30+31+30+31+31; 
if (mod(&anno,4) eq 0) and &fase=9 then denominatore = 31+29+31+30+31+30+31+31+30; 
if (mod(&anno,4) eq 0) and &fase=10 then denominatore = 31+29+31+30+31+30+31+31+30+31; 
if (mod(&anno,4) eq 0) and &fase=11 then denominatore = 31+29+31+30+31+30+31+31+30+31+30; 
if (mod(&anno,4) eq 0) and &fase=12 then denominatore = 31+29+31+30+31+30+31+31+30+31+30+31; 
*/
if (mod(&anno,4) eq 0) then denominatore = 366; 
run; 

/*tengo conto dei giorni feriali per la presenza in CD max 261*/
data au;
	set au;
	if  &fase=1 then denominatore_cd = 21.75;
if  &fase=2 then denominatore_cd = (21.75 * 2);
if  &fase=3 then denominatore_cd = (21.75 * 3);
if  &fase=4 then denominatore_cd = (21.75 * 4);
if  &fase=5 then denominatore_cd = (21.75 * 5);
if  &fase=6 then denominatore_cd = (21.75 * 6);
if  &fase=7 then denominatore_cd = (21.75 * 7);
if  &fase=8 then denominatore_cd = (21.75 * 8);
if  &fase=9 then denominatore_cd = (21.75 * 9);
if  &fase=10 then denominatore_cd = (21.75 * 10);
if  &fase=11 then denominatore_cd = (21.75 * 11);
if  &fase=12 then denominatore_cd = (21.75 * 12);

	if tipo_udo = '5' or tipo_udo =  '12' then
		GIORNI_LORDI_&anno = intck('weekday',DATARIC_UDO_NEW,DATADIM_UDO_NEW)+1;
run;

/*proc freq data=au; table gg_presenza_cd; run; */

DATA AU;
	SET AU;
	if (tipo_udo = '5' or tipo_udo = '12') then do;
		UT_EQ_LORDO	= GIORNI_LORDI_&anno / denominatore_cd; end;
	else do;
		UT_EQ_LORDO	= GIORNI_LORDI_&anno / denominatore; end; 

	VAL_SAN_LORDO 				= GIORNI_LORDI_&anno * VALORE_QUOTA_RILIEVO_num;
	VAL_EC_SOCIALE_LORDO 		= GIORNI_LORDI_&anno * TOTALE_QUOTA_GIORNALIERA_num;
	VAL_EC_ALBERGHIERO_LORDO 	= GIORNI_LORDI_&anno * COMPONENTE_SANITARIA_QUOTA_num;

RUN;


proc summary data=au nway;
	class cod_udo;
	var UT_EQ_LORDO;
	output out=UT_EQ_UDO (drop = _type_ _freq_) sum(UT_EQ_LORDO)=SOMMA_UT_EQ_LORDI_PER_UDO;
run;


PROC SORT DATA=AU; BY COD_UDO; RUN;
PROC SORT DATA=UT_EQ_UDO; BY COD_UDO; RUN; 

DATA AU_S;
	MERGE AU (IN=A) UT_EQ_UDO (IN=B);
	by cod_udo;

	IF A;
RUN;

/**/

data au;
	set au;
	rename GIORNI_LORDI_&anno = GIORNI_LORDI;
RUN;

DATA tabella_004;
	SET AU;
	KEEP
		CODICE_SOGGETTO_BIN
		ID_EPISODIO
		ULSS_UDO
		ULSS_UDO_NEW
		ULSS_IMPEGNATIVA_OLD
		ULSS_IMPEGNATIVA_NEW
		ANNO_A4
		ANNO_PRIMO_INGRESSO
		ANNO_INGRESSO_UDO
		COD_UDO
		COD_TIPO_UDO
/*		DENOMINAZIONE_UDO*/
		REG_ENTE_GES
/*		DENOM_ENTE_GES*/
/*		REG_PROVV_CDS
/*		DENOM_APPART_CDS*/
		PROVENIENZA
		COD_RICHIESTA_INSERIMENTO
		VAL_RICHIESTA_INSERIMENTO
		TITOLO_INGRESSO
		COD_QUOTA_RILIEVO
		VALORE_QUOTA_RILIEVO_num
		TOTALE_QUOTA_GIORNALIERA_num
		COMPONENTE_SANITARIA_QUOTA_num
		COD_SOGGETTO_PAGANTE
		ANNO_DIMISSIONE
		COD_TIPO_DIMISSIONE
		GIORNI_LORDI
		VAL_SAN_LORDO 
		VAL_EC_SOCIALE_LORDO 
		VAL_EC_ALBERGHIERO_LORDO 
		UT_EQ_LORDO	
	;
RUN;

DATA tabella_004;
	SET tabella_004;
	TRIMESTRE = &trimestre;
RUN;

DATA tabella_004;
	retain
		CODICE_SOGGETTO_BIN
		ID_EPISODIO
		ULSS_UDO
		ULSS_UDO_NEW
		ULSS_IMPEGNATIVA_OLD
		ULSS_IMPEGNATIVA_NEW
		ANNO_A4
		TRIMESTRE
		ANNO_PRIMO_INGRESSO
		ANNO_INGRESSO_UDO
		COD_UDO
		COD_TIPO_UDO
/*		DENOMINAZIONE_UDO */
		REG_ENTE_GES
/*		DENOM_ENTE_GES */
/*		REG_PROVV_CDS
/*		DENOM_APPART_CDS */
		PROVENIENZA
		COD_RICHIESTA_INSERIMENTO
		VAL_RICHIESTA_INSERIMENTO
		TITOLO_INGRESSO
		COD_QUOTA_RILIEVO
		VALORE_QUOTA_RILIEVO_num
		TOTALE_QUOTA_GIORNALIERA_num
		COMPONENTE_SANITARIA_QUOTA_num
		COD_SOGGETTO_PAGANTE
		ANNO_DIMISSIONE
		COD_TIPO_DIMISSIONE
		GIORNI_LORDI
		VAL_SAN_LORDO 
		VAL_EC_SOCIALE_LORDO 
		VAL_EC_ALBERGHIERO_LORDO 
		UT_EQ_LORDO	
		;
	SET tabella_004;
RUN;

DATA tabella_004;
	SET tabella_004;
	format 
		PROVENIENZA $PROVENIENZA_far.
		COD_RICHIESTA_INSERIMENTO $iniziativa.;
RUN;

/*
proc summary data=tabella_004 nway;
	class cod_udo;
	var UT_EQ_LORDO;
	output out=pippo (drop = _type_ _freq_) sum(UT_EQ_LORDO)=SOMMA_UT_EQ_LORDI_PER_UDO;
run;
*/
%mend; 

%macro tab_004_bis;
/*
ulss vecchia 
ulss nuova
somma val san 
somma val sociale
somma val alberghiero
utenti eq lordi con idr res 
utenti eq lordi senza idr res 
teste res 
teste semires
utenti eq lordi con idr semires
utenti eq lordi senza idr semires
*/

/*somma quote*/
proc summary data=tabella_004 nway;
	class ulss_impegnativa_new ulss_impegnativa_old anno_a4;
	var val_san_lordo val_ec_sociale_lordo val_ec_alberghiero_lordo;
	output out = t4_quote_&anno. (drop = _type_ _freq_)
	sum(val_san_lordo) 			  = somma_val_san_lordo
	sum(val_ec_sociale_lordo)	  = somma_val_sociale_lordo_IDR
	sum(val_ec_alberghiero_lordo) = somma_val_albergh_lordo_IDR
;
run; 

/*conto soggetti in struttura residenziale*/
proc sql; 
create table t4_utenti_res_&anno. 
as select ulss_impegnativa_old , ulss_impegnativa_new , 
count (distinct CODICE_SOGGETTO_BIN) as conta_teste_res
from au 
where (tipo_udo not in ('5', '12') and ulss_impegnativa_old ne '')
group by  ulss_impegnativa_old , ulss_impegnativa_new; run; 

/*conto soggetti in struttura semiresidenziale*/
proc sql; 
create table t4_utenti_semires_&anno. 
as select ulss_impegnativa_old , ulss_impegnativa_new , 
count (distinct CODICE_SOGGETTO_BIN) as conta_teste_semires
from au 
where (tipo_udo in ('5', '12') and ulss_impegnativa_old ne '')
group by  ulss_impegnativa_old , ulss_impegnativa_new; run; 

/*conteggio utenti equivalenti lordi con IDR RESIDENZIALI */
proc summary data=au nway;
	class ulss_impegnativa_new ulss_impegnativa_old ;
	var ut_eq_lordo;
	output out = t4_ut_eq_idr_res_&anno. (drop = _type_ _freq_)
	sum(ut_eq_lordo) 			  = somma_ut_eq_res_idr
;
where titolo_ingresso='1' and tipo_udo not in ('5', '12') ;
run; 

/*conteggio utenti equivalenti lordi con IDR semiRESIDENZIALI */
proc summary data=au nway;
	class ulss_impegnativa_new ulss_impegnativa_old ;
	var ut_eq_lordo;
	output out = t4_ut_eq_idr_semir_&anno. (drop = _type_ _freq_)
	sum(ut_eq_lordo) 			  = somma_ut_eq_semires_idr
;
where titolo_ingresso='1' and tipo_udo  in ('5', '12') ;
run; 

/*conteggio utenti equivalenti lordi senza IDR RESIDENZIALI */
proc summary data=au nway;
	class ulss_impegnativa_new ulss_impegnativa_old ;
	var ut_eq_lordo;
	output out = t4_ut_eq_no_idr_res_&anno. (drop = _type_ _freq_)
	sum(ut_eq_lordo) 			  = somma_ut_eq_res_no_idr
;
where titolo_ingresso ne '1' and tipo_udo not in ('5', '12') ;
run; 

/*conteggio utenti equivalenti lordi senza IDR semiRESIDENZIALI (non ci sono)*/
proc summary data=au nway;
	class ulss_impegnativa_new ulss_impegnativa_old ;
	var ut_eq_lordo;
	output out = t4_ut_eq_no_idr_semir_&anno. (drop = _type_ _freq_)
	sum(ut_eq_lordo) 			  = somma_ut_eq_semires_noidr
;
where titolo_ingresso ne '1' and tipo_udo  in ('5', '12') ;
run; 

proc sort data= t4_quote_&anno.; by ulss_impegnativa_old; run; 
proc sort data= t4_utenti_res_&anno. ; by ulss_impegnativa_old; run;
proc sort data= t4_utenti_semires_&anno. ; by ulss_impegnativa_old; run;  
proc sort data= t4_ut_eq_idr_res_&anno.  ; by ulss_impegnativa_old; run;  
proc sort data= t4_ut_eq_idr_semir_&anno. ; by ulss_impegnativa_old; run;  
proc sort data= t4_ut_eq_no_idr_res_&anno.  ; by ulss_impegnativa_old; run;  
/*
in teoria non dovrebbero esserci 
proc sort data= t4_ut_eq_no_idr_semires_&anno.  ; by ulss_impegnativa_old; run;  
*/


data t_004_&anno. ;  merge 
t4_quote_&anno. (in=a)
t4_utenti_res_&anno. (in=b)
t4_utenti_semires_&anno. (in=c)
t4_ut_eq_idr_res_&anno. (in=d)
t4_ut_eq_idr_semir_&anno. (in=e)
t4_ut_eq_no_idr_res_&anno. (in=f); 
by ulss_impegnativa_old; if a; run; 

data t_004_&anno.; set  t_004_&anno.;
tot_quota_sociale = somma_val_sociale_lordo_IDR + somma_val_albergh_lordo_IDR; run; 


%mend; 


/*esecuzione delle macro*/
%let anno=2018; 	/*anno di interesse*/
%let fase=7; 		/*fase di interesse*/
%let trimestre=3; 	/* trimestre di interesse */

%SET_ADT_FAR;
%set_udo; 
%TABELLA_004;
%tab_004_bis; /*verificare le somme per no idr semires*/

/*PER ACCODAMENTO DI PIù ANNI*/
DATA TMP_2016; SET t_004_&anno.; RUN; /*ANNO 2016*/

DATA TMP_2017; SET t_004_&anno.; RUN; /*ANNO 2017*/

DATA TMP_2018; SET t_004_&anno.; RUN; /*ANNO 2018*/
DATA TMP1_2018; SET t_004_&anno.; RUN; /*ANNO 2018*/

DATA ARCIPELAGO_004_bis; SET TMP_2016 TMP_2017 TMP_2018 TMP1_2018; RUN; 

data arcipelago_004_bis; set arcipelago_004_bis;
if ULSS_IMPEGNATIVA_NEW = . 		then ULSS_IMPEGNATIVA_NEW = 0;
if ULSS_IMPEGNATIVA_OLD = . 		then ULSS_IMPEGNATIVA_OLD = 0;
if ANNO_A4 = . 						then ANNO_A4 = 0;
if somma_val_san_lordo = . 			then somma_val_san_lordo = 0;
if somma_val_sociale_lordo_IDR = . 	then somma_val_sociale_lordo_IDR = 0;
if somma_val_albergh_lordo_IDR = . 	then somma_val_albergh_lordo_IDR = 0;
if conta_teste_res = . 				then conta_teste_res = 0;
if conta_teste_semires = . 			then conta_teste_semires = 0;
if somma_ut_eq_res_idr = . 			then somma_ut_eq_res_idr = 0;
if somma_ut_eq_semires_idr = . 		then somma_ut_eq_semires_idr = 0;
if somma_ut_eq_res_no_idr = . 		then somma_ut_eq_res_no_idr = 0;
if tot_quota_sociale = . 			then tot_quota_sociale = 0;
run; 

data arcipelago_004_bis; set arcipelago_004_bis;
format somma_ut_eq_res_idr somma_ut_eq_semires_idr somma_ut_eq_res_no_idr $best6.; run; 

/*eof*/
