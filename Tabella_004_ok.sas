/****************************************************/
/*													*/
/*				tabella arcipelago 4 ADT			*/
/****************************************************/
/****************************************************/
LIBNAME FAR_2016 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2016';
LIBNAME FAR_2017 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2017';
LIBNAME FAR_2018 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2018';
LIBNAME ARCIPE '/sasprd/staging/staging_san1/S1_ORPSS/config/Arcipelago';



%MACRO SET_ANAGRAFICA_FAR;
proc sql;
	create table ANA as
		select *
			from DWHODD.ODD_FAR_UNI_A1_DEF
				where (anno=&anno and fase =&fase AND flg_archivio ne 'C');
quit;

data ana_&anno.;
	set ana;
	DATANASC_TEMP=input(DATA_NASCITA,ddmmyy8.);
	DATA_CAMBIO_RES_TEMP=input(DATA_CAMBIO_RES,ddmmyy8.);
	format DATANASC_TEMP DATA_CAMBIO_RES_TEMP date9.;
run;

data ana_&anno.;
	SET ana_&anno.;
	drop DATA_NASCITA DATA_CAMBIO_RES;
	ULSS_A1=INPUT(COD_ENTE,BEST3.);
	ULSS_UDO_A1=INPUT(SUBSTR(COD_ASL_EROGATRICE,4,3),BEST3.);
	RENAME 
		ANNO= ANNO_A1
		PRG_REC=PRG_REC_A1
/*		COD_ENTE=ULSS_A1*/
		ID_ASSISTITO=ID_EPISODIO
		CITTADINANZA=CITTAD
		TITOLO_STUDIO=ISTRUZIONE
		COD_REG_RES=REG_RES
		COD_ASL_RES=USL_RES
		COD_COMUNE_RES_IN=ISTRES_IN 
		COD_COMUNE_RES_OUT=ISTRES_OUT
		COD_ASL_EROGATRICE=ULSS_UDO 
		FLG_CHK_CODICE_FISCALE=FLG_CHK_CF
		FLG_CHK_CODICE_SSN=FLG_CHK_CODSAN
		FLG_CHK_COGNOME_E_NOME=FLG_CHK_CNOME 
		FLG_CHK_DATI_ANAG_CONGRUENTI=FLG_CHK_DATI_ANAG
		DATANASC_TEMP=DATANASC
		DATA_CAMBIO_RES_TEMP=DATA_CAMBIO_RES
		FASE=FASE_A1;
	run; 

data ana_&anno.;
	SET ana_&anno.;
	format 
		SESSO $SEX.
		ISTRUZIONE $istruzione.
		STATO_CIVILE $STA_CIV. 
		flg_tipo_utente $utente.
		tipo_id_utente $id_utente. 
		istres_in istres_out $6.;
run;

%MEND;

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
		COD_ENTE=ULSS_A4
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
	FORMAT PROVENIENZA $PROVENIENZA_far.;
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

data udo; set udo; rename fase=fase_a7 ulss=ulss_a7; run;
%MEND; 

%macro tabella_004;
proc sort data=adt;
	by cod_udo;
run;

proc sort data=udo;
	by cod_udo;
run;

DATA au;
	MERGE adt (IN=A) UDO (IN=B);
	BY cod_udo;

	IF A ;
RUN;

data au;
	set au;

	if ULSS_UDO='101' THEN ULSS_UDO_NEW=501;
	if ULSS_UDO='102' THEN ULSS_UDO_NEW=501;
	if ULSS_UDO='109' THEN ULSS_UDO_NEW=502;
	if ULSS_UDO='107' THEN ULSS_UDO_NEW=502;
	if ULSS_UDO='108' THEN ULSS_UDO_NEW=502;
	if ULSS_UDO='112' THEN ULSS_UDO_NEW=503;
	if ULSS_UDO='113' THEN ULSS_UDO_NEW=503;
	if ULSS_UDO='114' THEN ULSS_UDO_NEW=503;
	if ULSS_UDO='110' THEN ULSS_UDO_NEW=504;
	if ULSS_UDO='118' THEN ULSS_UDO_NEW=505;
	if ULSS_UDO='119' THEN ULSS_UDO_NEW=505;
	if ULSS_UDO='115' THEN ULSS_UDO_NEW=506;
	if ULSS_UDO='116' THEN ULSS_UDO_NEW=506;
	if ULSS_UDO='117' THEN ULSS_UDO_NEW=506;
	if ULSS_UDO='103' THEN ULSS_UDO_NEW=507;
	if ULSS_UDO='104' THEN ULSS_UDO_NEW=507;
	if ULSS_UDO='106' THEN ULSS_UDO_NEW=508;
	if ULSS_UDO='105' THEN ULSS_UDO_NEW=508;
	if ULSS_UDO='120' THEN ULSS_UDO_NEW=509;
	if ULSS_UDO='121' THEN ULSS_UDO_NEW=509;
	if ULSS_UDO='122' THEN ULSS_UDO_NEW=509;
	if ulss_udo='501' THEN ulss_udo_new=501;
	if ulss_udo='502' THEN ulss_udo_new=502;
	if ulss_udo='503' THEN ulss_udo_new=503;
	if ulss_udo='504' THEN ulss_udo_new=504;
	if ulss_udo='505' THEN ulss_udo_new=505;
	if ulss_udo='506' THEN ulss_udo_new=506;
	if ulss_udo='507' THEN ulss_udo_new=507;
	if ulss_udo='508' THEN ulss_udo_new=508;
	if ulss_udo='509' THEN ulss_udo_new=509;
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

	if ULSS_IMPEGNATIVA_OLD='101' THEN ULSS_IMPEGNATIVA_NEW=501;
	if ULSS_IMPEGNATIVA_OLD='102' THEN ULSS_IMPEGNATIVA_NEW=501;
	if ULSS_IMPEGNATIVA_OLD='109' THEN ULSS_IMPEGNATIVA_NEW=502;
	if ULSS_IMPEGNATIVA_OLD='107' THEN ULSS_IMPEGNATIVA_NEW=502;
	if ULSS_IMPEGNATIVA_OLD='108' THEN ULSS_IMPEGNATIVA_NEW=502;
	if ULSS_IMPEGNATIVA_OLD='112' THEN ULSS_IMPEGNATIVA_NEW=503;
	if ULSS_IMPEGNATIVA_OLD='113' THEN ULSS_IMPEGNATIVA_NEW=503;
	if ULSS_IMPEGNATIVA_OLD='114' THEN ULSS_IMPEGNATIVA_NEW=503;
	if ULSS_IMPEGNATIVA_OLD='110' THEN ULSS_IMPEGNATIVA_NEW=504;
	if ULSS_IMPEGNATIVA_OLD='118' THEN ULSS_IMPEGNATIVA_NEW=505;
	if ULSS_IMPEGNATIVA_OLD='119' THEN ULSS_IMPEGNATIVA_NEW=505;
	if ULSS_IMPEGNATIVA_OLD='115' THEN ULSS_IMPEGNATIVA_NEW=506;
	if ULSS_IMPEGNATIVA_OLD='116' THEN ULSS_IMPEGNATIVA_NEW=506;
	if ULSS_IMPEGNATIVA_OLD='117' THEN ULSS_IMPEGNATIVA_NEW=506;
	if ULSS_IMPEGNATIVA_OLD='103' THEN ULSS_IMPEGNATIVA_NEW=507;
	if ULSS_IMPEGNATIVA_OLD='104' THEN ULSS_IMPEGNATIVA_NEW=507;
	if ULSS_IMPEGNATIVA_OLD='106' THEN ULSS_IMPEGNATIVA_NEW=508;
 	if ULSS_IMPEGNATIVA_OLD='105' THEN ULSS_IMPEGNATIVA_NEW=508;
	if ULSS_IMPEGNATIVA_OLD='120' THEN ULSS_IMPEGNATIVA_NEW=509;
	if ULSS_IMPEGNATIVA_OLD='121' THEN ULSS_IMPEGNATIVA_NEW=509;
	if ULSS_IMPEGNATIVA_OLD='122' THEN ULSS_IMPEGNATIVA_NEW=509;
	if ULSS_IMPEGNATIVA_OLD='501' THEN ULSS_IMPEGNATIVA_NEW=501;
	if ULSS_IMPEGNATIVA_OLD='502' THEN ULSS_IMPEGNATIVA_NEW=502;
	if ULSS_IMPEGNATIVA_OLD='503' THEN ULSS_IMPEGNATIVA_NEW=503;
	if ULSS_IMPEGNATIVA_OLD='504' THEN ULSS_IMPEGNATIVA_NEW=504;
	if ULSS_IMPEGNATIVA_OLD='505' THEN ULSS_IMPEGNATIVA_NEW=505;
	if ULSS_IMPEGNATIVA_OLD='506' THEN ULSS_IMPEGNATIVA_NEW=506;
	if ULSS_IMPEGNATIVA_OLD='507' THEN ULSS_IMPEGNATIVA_NEW=507;
	if ULSS_IMPEGNATIVA_OLD='508' THEN ULSS_IMPEGNATIVA_NEW=508;
	if ULSS_IMPEGNATIVA_OLD='509' THEN ULSS_IMPEGNATIVA_NEW=509;
RUN;

DATA AU;
	SET AU;
	ANNO_PRIMO_INGRESSO=YEAR(DATARIC_STRUTTURA);
	ANNO_INGRESSO_UDO=YEAR(DATARIC_UDO);
	ANNO_DIMISSIONE=YEAR(DATADIM_UDO);
RUN;

/*mi creo una tabella che mi serve poi per cambiare l'ulss che ha emesso 
l'impegnativa*/

data aui; set au; 
run; 

proc sort data=aui; by codice_soggetto_bin  dataric_udo; run; 
data aui;
set aui;
by codice_soggetto_bin;
if first.codice_soggetto_bin then contapic=1; else contapic+1; 
run; 

/*proc freq data=aui; table contapic; run;

/*tengo solo la prima pic per valutare la ulss_impegnativa che paga*/
data aui; set aui; where contapic=1; run; 


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

/*calcolo i giorni di presenza per soggetti non in CD */
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
/*if (mod(&anno,4) ne 0) then denominatore = 365; */

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
*/if (mod(&anno,4) eq 0) then denominatore = 366; 
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
/* tasso di occupazione
DATA AU_S;
	SET AU_S;
	TASSO_OCCUPAZIONE = (SOMMA_UT_EQ_LORDI_PER_UDO/SOMMA_POSTI_AUTO);
RUN;
/**/
/**/

data au;
	set au;
	rename GIORNI_LORDI_&anno = GIORNI_LORDI;
RUN;

/*++++++++++++++++++++++++++++++++++++*/
	/*disabili anziani fad inizio*/
/*++++++++++++++++++++++++++++++++++++*/
/*		data pippo; set au;
		run; 

		data pippo; set pippo; chiave =cats(id_episodio, codice_soggetto_bin, ulss_a4);
		run; 
		data ana_2017; ste ana_2017; chiave = cats(id_episodio, codice_soggetto_bin, cod_ente); run; 

		proc sort data=pippo; by chiave; run;
		proc sort data=ana_2017; by chiave; run; 

		data p1; merge pippo (in=a) ana_2017 (in=b) ; by chiave; if a ; run; 
		/*guardo i soggetti presenti in FAD in strutture I II livello
		data ciao; set p1; WHERE (dataric_udo  = '01Jun2017'd) ;run;
		

		proc print data=p1; var codice_soggetto_bin 
		dataric_udo dataric_struttura cod_udo istres_in istres_out;   
		WHERE (dataric_udo  = '01Jun2017'd) ;run;
/*++++++++++++++++++++++++++++++++++++*/
	/*disabili anziani fad fine*/
/*++++++++++++++++++++++++++++++++++++*/

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
		REG_ENTE_GES
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
		REG_ENTE_GES
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
		PROVENIENZA $PROVENIENZA_far.;
RUN;

/*sistemo i codici ulss vecchi e nuovi */

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
		REG_ENTE_GES
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


%mend; 



/*ulss udo prendi da filemaker (fare tabella di appoggio)
ulss impegnativa old prendi da file dei comuni (ulss del comune di residenza fare join con anagrafica
*/


%macro comuni;
data c; set ARCIPE.comuni ; run; 

proc sort data=c; by cod_comune_esteso descending data_in_val; run;
data c; 
set c; 
by cod_comune_esteso; 
if first.cod_comune_esteso then conta1=1; else conta1+1; 
run; 

data c1; set c; where conta1=1; run; 

data c1; set c1;
cod_comune_str=put(cod_comune_esteso, 5.);
istres_in=cats('0', cod_comune_str);run;
run; 

data comuni_per_merge; set c1; keep istres_in cod_azienda; run; 

data comuni_per_merge; set comuni_per_merge; format istres_in $6.; run; 

proc sql;
alter table comuni_per_merge
  modify istres_in char(6) format=$6.;
quit;

data comuni_per_merge; set comuni_per_merge; rename cod_azienda=ULSS_UDO_comuni; run; 
%mend; 

/*esecuzione delle macro*/
%let anno=2018; 	/*anno di interesse*/
%let fase=4; 		/*fase di interesse*/
%let trimestre=2; 	/* trimestre di interesse */

%SET_ANAGRAFICA_FAR;
%SET_ADT_FAR;
%set_udo; 
%TABELLA_004;

/*PER ACCODAMENTO DI PIù ANNI*/

DATA TMP_2016; SET tabella_004; RUN; /*ANNO 2016*/

/*
proc freq data=tmp_2016; table ulss_impegnativa_new * ulss_impegnativa_old /norow nofreq nopercent; run; 
proc freq data=tmp_2016; table ulss_udo_new * ulss_udo /norow nofreq nopercent; run; 

proc freq data=tmp_2017; table ulss_impegnativa_new * ulss_impegnativa_old /norow nofreq nopercent; run; 
proc freq data=tmp_2017; table ulss_udo_new * ulss_udo /norow nofreq nopercent; run; 

/*
dal 2017 in poi le ulss old non esistono più
*/
/*anno= 2017 : */
DATA TMP_2017; SET tabella_004; RUN; /*ANNO 2017*/
DATA TMP_2018; SET tabella_004; RUN; /*ANNO 2018*/



/*possono esserci delle sovrastime sugli ut eq cd in corso dell'anno, quindi li casto a 1*/
data tmp_2018; set tmp_2018; if ut_eq_lordo > 1 then ut_eq_lordo =1; run; 
data tmp_2017; set tmp_2017; if ut_eq_lordo > 1 then ut_eq_lordo =1; run; 
data tmp_2016; set tmp_2016; if ut_eq_lordo > 1 then ut_eq_lordo =1; run; 

data f; set tmp_2016 tmp_2017 tmp_2018; run; 

/*proc print data=f; var cod_udo ulss_udo ulss_udo_new ; where ulss_udo_new=.; run; */

data f; set f; 
if cod_udo='007412' then ulss_udo='109';
if cod_udo='007412' then ulss_udo_new=502;
if cod_udo='011238' then ulss_udo='109';
if cod_udo='011238' then ulss_udo_new=502;

if cod_udo='010695' then ulss_udo='999';
if cod_udo='010695' then ulss_udo_new=999;
if cod_udo='011101' then ulss_udo='999';
if cod_udo='011101' then ulss_udo_new=999;
if cod_udo='011285' then ulss_udo='999';
if cod_udo='011285' then ulss_udo_new=999;

run;

data f; set f; 
if ulss_udo='000' or ulss_udo='999' then ulss_udo='999';
if ulss_udo='000' or ulss_udo='999' then ulss_udo_new=999;
run; 

/*
proc freq data=f; table ulss_udo ulss_udo_new cod_udo;run; 

proc freq data=f; table ulss_impegnativa_new ulss_impegnativa_old; where anno_a4=2017; run;  

/*data fimp_17 ; set f ; where anno_a4=2017; run; */
data fimp_17; set f; run; 
/*attacco con comuni e con anagrafica (istres_in)*/


proc sort data=ana_2016 (keep =  codice_soggetto_bin  istres_in) nodupkey out=a16;
	by codice_soggetto_bin;
run;
proc sort data=ana_2017 (keep =  codice_soggetto_bin  istres_in) nodupkey out=a17;
	by codice_soggetto_bin;
run;
proc sort data=ana_2018 (keep =  codice_soggetto_bin  istres_in) nodupkey out=a18;
	by codice_soggetto_bin;
run;
data asd; set a16 a17 a18; run; 

proc sort data=asd  nodupkey out=asdas;
	by codice_soggetto_bin;
run;


proc sort data=asdas; by codice_soggetto_bin;run; 

proc sort data=fimp_17 ; by codice_soggetto_bin; run; 



data ff17; merge fimp_17 (in=a) asdas (in=b) ; by codice_soggetto_bin ; if a ; run;
 
proc freq data=ff17; table istres_in; run;  
data ff17; set ff17; if istres_in=. or istres_in=' ' then istres_in='999999'; run; 
%comuni; 

proc sort data=comuni_per_merge;
	by istres_in;
run;

proc sort data=ff17;
	by istres_in;
run;

data g17;
	merge ff17 (in=a) comuni_per_merge (in=b);
	by istres_in;

	if a;
run;

data g17; 
set g17;
ulss_udo_comuni_txt=put(ulss_udo_comuni, 3.); 
run; 

data g17; 
set g17;
drop ulss_udo_comuni; 
run; 

data g17; 
set g17;
if 
ulss_impegnativa_old = '501' or 
ulss_impegnativa_old = '502' or 
ulss_impegnativa_old = '503' or 
ulss_impegnativa_old = '504' or 
ulss_impegnativa_old = '505' or 
ulss_impegnativa_old = '506' or 
ulss_impegnativa_old = '507' or 
ulss_impegnativa_old = '508' or 
ulss_impegnativa_old = '509' or 
ulss_impegnativa_old = . then do; /**metto anche quelle a missing con l'ulss udo comuni; */
ulss_impegnativa_old = ulss_udo_comuni_txt; 
end; 
run; 

/*proc freq data=g17; table ulss_impegnativa_old ulss_udo ulss_udo_new ulss_impegnativa_new ulss_impegnativa_old; run; 
*/
data g17; set g17;
	if ULSS_IMPEGNATIVA_OLD='101' THEN ULSS_IMPEGNATIVA_NEW=501;
	if ULSS_IMPEGNATIVA_OLD='102' THEN ULSS_IMPEGNATIVA_NEW=501;
	if ULSS_IMPEGNATIVA_OLD='109' THEN ULSS_IMPEGNATIVA_NEW=502;
	if ULSS_IMPEGNATIVA_OLD='107' THEN ULSS_IMPEGNATIVA_NEW=502;
	if ULSS_IMPEGNATIVA_OLD='108' THEN ULSS_IMPEGNATIVA_NEW=502;
	if ULSS_IMPEGNATIVA_OLD='112' THEN ULSS_IMPEGNATIVA_NEW=503;
	if ULSS_IMPEGNATIVA_OLD='113' THEN ULSS_IMPEGNATIVA_NEW=503;
	if ULSS_IMPEGNATIVA_OLD='114' THEN ULSS_IMPEGNATIVA_NEW=503;
	if ULSS_IMPEGNATIVA_OLD='110' THEN ULSS_IMPEGNATIVA_NEW=504;
	if ULSS_IMPEGNATIVA_OLD='118' THEN ULSS_IMPEGNATIVA_NEW=505;
	if ULSS_IMPEGNATIVA_OLD='119' THEN ULSS_IMPEGNATIVA_NEW=505;
	if ULSS_IMPEGNATIVA_OLD='115' THEN ULSS_IMPEGNATIVA_NEW=506;
	if ULSS_IMPEGNATIVA_OLD='116' THEN ULSS_IMPEGNATIVA_NEW=506;
	if ULSS_IMPEGNATIVA_OLD='117' THEN ULSS_IMPEGNATIVA_NEW=506;
	if ULSS_IMPEGNATIVA_OLD='103' THEN ULSS_IMPEGNATIVA_NEW=507;
	if ULSS_IMPEGNATIVA_OLD='104' THEN ULSS_IMPEGNATIVA_NEW=507;
	if ULSS_IMPEGNATIVA_OLD='106' THEN ULSS_IMPEGNATIVA_NEW=508;
 	if ULSS_IMPEGNATIVA_OLD='105' THEN ULSS_IMPEGNATIVA_NEW=508;
	if ULSS_IMPEGNATIVA_OLD='120' THEN ULSS_IMPEGNATIVA_NEW=509;
	if ULSS_IMPEGNATIVA_OLD='121' THEN ULSS_IMPEGNATIVA_NEW=509;
	if ULSS_IMPEGNATIVA_OLD='122' THEN ULSS_IMPEGNATIVA_NEW=509;
	if ULSS_IMPEGNATIVA_OLD='501' THEN ULSS_IMPEGNATIVA_NEW=501;
	if ULSS_IMPEGNATIVA_OLD='502' THEN ULSS_IMPEGNATIVA_NEW=502;
	if ULSS_IMPEGNATIVA_OLD='503' THEN ULSS_IMPEGNATIVA_NEW=503;
	if ULSS_IMPEGNATIVA_OLD='504' THEN ULSS_IMPEGNATIVA_NEW=504;
	if ULSS_IMPEGNATIVA_OLD='505' THEN ULSS_IMPEGNATIVA_NEW=505;
	if ULSS_IMPEGNATIVA_OLD='506' THEN ULSS_IMPEGNATIVA_NEW=506;
	if ULSS_IMPEGNATIVA_OLD='507' THEN ULSS_IMPEGNATIVA_NEW=507;
	if ULSS_IMPEGNATIVA_OLD='508' THEN ULSS_IMPEGNATIVA_NEW=508;
	if ULSS_IMPEGNATIVA_OLD='509' THEN ULSS_IMPEGNATIVA_NEW=509;
	if ULSS_IMPEGNATIVA_OLD=.	  THEN ULSS_IMPEGNATIVA_NEW=999;
RUN;
data g17; set g17;
	if ULSS_IMPEGNATIVA_OLD='  .'	  THEN ULSS_IMPEGNATIVA_NEW=999;
	run; 


data g17; set g17;
if ulss_impegnativa_new = 999 then ulss_impegnativa_old='999'; run; 

/*
proc print data=g17; var ulss_impegnativa_new ulss_impegnativa_old ulss_udo_comuni_txt istres_in; where 
ulss_udo='102'; run; 
*/

data g17; set g17 ; drop ulss_udo_comuni_txt; run; 
data tab_004_finale ; set g17; run;  
/*proc freq data=tab_004_finale; table ulss_udo_new; run; */


data tab_004_finale; set tab_004_finale; 
if cod_udo='007412' then ulss_udo='109';
if cod_udo='007412' then ulss_udo_new=502;
if cod_udo='011238' then ulss_udo='109';
if cod_udo='011238' then ulss_udo_new=502;
if cod_udo='010695' then ulss_udo='999';
if cod_udo='010695' then ulss_udo_new=999;
if cod_udo='011101' then ulss_udo='999';
if cod_udo='011101' then ulss_udo_new=999;
if cod_udo='011285' then ulss_udo='999';
if cod_udo='011285' then ulss_udo_new=999;

if valore_quota_rilievo_num=0.01 then valore_quota_rilievo_num=0; 
run;

data tab_004_finale; set tab_004_finale; 
if TOTALE_QUOTA_GIORNALIERA_num=. then  TOTALE_QUOTA_GIORNALIERA_num=0;
if TOTALE_QUOTA_GIORNALIERA_num=0.01 then  TOTALE_QUOTA_GIORNALIERA_num=0;
if COMPONENTE_SANITARIA_QUOTA_num=. then COMPONENTE_SANITARIA_QUOTA_num=0;
if COMPONENTE_SANITARIA_QUOTA_num=0.01 then COMPONENTE_SANITARIA_QUOTA_num=0;
run;

data tab_004_finale; set tab_004_finale; drop istres_in; run; 

/*proc freq data=tab_004_finale; table cod_udo ulss_udo ulss_udo_new ulss_impegnativa_new ulss_impegnativa_old; run; */

/*eof*/
