/**/
/************************************************/
/* 			Tabella 5 arcipelago 				*/
/*			Tracciato assenze					*/
/************************************************/


LIBNAME FAR_2016 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2016';
LIBNAME FAR_2017 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2017';
LIBNAME FAR_2018 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2018';

%MACRO SET_ANAGRAFICA_FAR;
proc sql;
	create table ANA as
		select *
			from DWHODD.ODD_FAR_UNI_A1_DEF
				where (anno=&anno and fase =&fase  and flg_err=0 AND flg_archivio ne 'C'
and flg_tipo_utente NE '7');
quit;

data ana;
	set ana;
	DATANASC_TEMP=input(DATA_NASCITA,ddmmyy8.);
	DATA_CAMBIO_RES_TEMP=input(DATA_CAMBIO_RES,ddmmyy8.);
	format DATANASC_TEMP DATA_CAMBIO_RES_TEMP date9.;
run;

data ana;
	SET ana;
	drop DATA_NASCITA DATA_CAMBIO_RES;
	ULSS_A1=INPUT(COD_ENTE,BEST3.);
	ULSS_UDO_A1=INPUT(SUBSTR(COD_ASL_EROGATRICE,4,3),BEST3.);
	RENAME 
		ANNO= ANNO_A1
		PRG_REC=PRG_REC_A1
		CODICE_SOGGETTO=CODICE_SOGGETTO_BIN
		COD_ENTE=ULSS
		ID_ASSISTITO=ID_EPISODIO
		DATA_NASCITA=DATANASC
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

data ana;
	SET ana;
	format 
		SESSO $SEX.
		ISTRUZIONE $istruzione.
		STATO_CIVILE $STA_CIV. 
		flg_tipo_utente $utente.
		tipo_id_utente $id_utente. 
		;
run;

data ana; set ana; 
drop ulss_udo; run; 

%MEND;


%MACRO SET_ADT_FAR;
proc sql;
	create table adt as
		select *
			from DWHODD.ODD_FAR_UNI_A4_DEF
				where (anno=&anno and fase =&fase  and flg_err=0 AND flg_archivio ne 'C');
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
%MEND; 


/* IMPORTO IL DB ASSENZE*/
/* importo assenze */

%macro set_assenze;
proc sql;
	create table assenze as
		select *
			from DWHODD.ODD_FAR_UNI_A5_DEF
				where ( flg_err=0  AND flg_archivio ne 'C' and anno=&anno and fase=&fase );
quit;


DATA ASSENZE;
	SET ASSENZE;
	DATA_IN_ASSENZA_TEMP2=INPUT(DATA_IN_ASSENZA_TEMP,DDMMYY8.);
	DATA_FI_ASSENZA_TEMP2=INPUT(DATA_FI_ASSENZA_TEMP,DDMMYY8.);
	FORMAT DATA_IN_ASSENZA_TEMP2 DATA_FI_ASSENZA_TEMP2 DATE9.;
RUN;

DATA ASSENZE;
	SET ASSENZE;
	DROP DATA_IN_ASSENZA_TEMP DATA_FI_ASSENZA_TEMP;
	RENAME PRG_REC=PRG_REC_A5
		COD_ENTE=ULSS
		ID_ASSISTITO=ID_EPISODIO
		COD_STRUT_EROG_UDO=COD_UDO
		DATA_IN_ASSENZA_TEMP2=DATA_IN_ASSENZA_TEMP
		DATA_FI_ASSENZA_TEMP2=DATA_FI_ASSENZA_TEMP
		FASE=FASE_A5;
	FORMAT COD_MOTIVAZIONE_ASSENZA $MOTIVO_ASSENZA.;
RUN;
data assenze;
	set assenze;
	ULSS_42=INPUT(ULSS,BEST12.);
run;
%mend; 

%macro tabella_005;

/* calcoli PER SOGGETTO*/

data assenze;
	set assenze;

	if (DATA_FI_ASSENZA_TEMP ne . and DATA_IN_ASSENZA_TEMP ne .) then
		giorni_assenza_lordi = (DATA_FI_ASSENZA_TEMP - DATA_IN_ASSENZA_TEMP)+1;
run;

data assenze;
	set assenze;

	/*giorni_assenza_quotasan rappresenta il conteggio dei giorni pesato 
	per quanto la ULSS ha pagato per letti caldi non usati, 
	cioè vale 0.75 se l'assenza è più lunga di 2 giorni e l'assenza è 
	trascorsa in ospedale o in struttura intermedia*/
	if giorni_assenza_lordi<=2 then
		giorni_assenza_quotasan = giorni_assenza_lordi;

	if giorni_assenza_lordi >= 3 and (COD_MOTIVAZIONE_ASSENZA='1' or COD_MOTIVAZIONE_ASSENZA='2') then
		giorni_assenza_quotasan = ((giorni_assenza_lordi-2) * 0.75) + 2;

	if giorni_assenza_lordi >= 3 and (COD_MOTIVAZIONE_ASSENZA='3') then
		giorni_assenza_quotasan = 2;
run;

data assenze;
	set assenze;

	if ulss_42=101 THEN
		ULSS_NEW=501;

	if ulss_42=102 THEN
		ULSS_NEW=501;

	*;
	if ulss_42=109 THEN
		ULSS_NEW=502;

	if ulss_42=107 THEN
		ULSS_NEW=502;

	if ulss_42=108 THEN
		ULSS_NEW=502;

	if ulss_42=112 THEN
		ULSS_NEW=503;

	if ulss_42=113 THEN
		ULSS_NEW=503;

	if ulss_42=114 THEN
		ULSS_NEW=503;

	if ulss_42=110 THEN
		ULSS_NEW=504;

	if ulss_42=118 THEN
		ULSS_NEW=505;

	if ulss_42=119 THEN
		ULSS_NEW=505;

	if ulss_42=115 THEN
		ULSS_NEW=506;

	if ulss_42=116 THEN
		ULSS_NEW=506;

	if ulss_42=117 THEN
		ULSS_NEW=506;

	if ulss_42=103 THEN
		ULSS_NEW=507;

	if ulss_42=104 THEN
		ULSS_NEW=507;

	if ulss_42=106 THEN
		ULSS_NEW=508;

	if ulss_42=105 THEN
		ULSS_NEW=508;

	if ulss_42=120 THEN
		ULSS_NEW=509;

	if ulss_42=121 THEN
		ULSS_NEW=509;

	if ulss_42=122 THEN
		ULSS_NEW=509;
run;


/*ulss che ha emesso impegnativa 
attacco per chiave=(ID_EPISODIO, NUM_PRATICA, COD_UDO)*/

/*link con adt */


proc sort data=adt;
	by cod_udo;
run;

proc sort data=udo;
	by cod_udo;
run;

DATA adt_udo;
	MERGE adt (IN=A) UDO (IN=B);
	BY cod_udo;
	IF A and b;
RUN;

data adt_udo;
	set adt_udo;
	chiave=cats(CODICE_SOGGETTO_BIN,NUM_PRATICA,COD_UDO);
RUN;

DATA ASSENZE;
	SET ASSENZE;
	chiave=cats(CODICE_SOGGETTO_BIN,NUM_PRATICA,COD_UDO);
RUN;

proc sort data=ASSENZE;
	by chiave;
run;

proc sort data=adt_udo;
	by chiave;
run;

DATA ASSENZE_adt_udo;
	MERGE ASSENZE (IN=A) adt_udo (IN=B);
	BY chiave;
	IF A AND B;
RUN;

DATA ASSENZE_ADT_UDO;
	SET ASSENZE_ADT_UDO;
	ULSS_IMPEGNATIVA_OK=SUBSTR(ULSS_IMPEGNATIVA, 4, 3);
RUN;

DATA ASSENZE_ADT_UDO;
	SET ASSENZE_ADT_UDO;

	if ULSS_IMPEGNATIVA_OK='101' THEN
		ULSS_IMPEGNATIVA_NEW=501;

	if ULSS_IMPEGNATIVA_OK='102' THEN
		ULSS_IMPEGNATIVA_NEW=501;

	if ULSS_IMPEGNATIVA_OK='109' THEN
		ULSS_IMPEGNATIVA_NEW=502;

	if ULSS_IMPEGNATIVA_OK='107' THEN
		ULSS_IMPEGNATIVA_NEW=502;

	if ULSS_IMPEGNATIVA_OK='108' THEN
		ULSS_IMPEGNATIVA_NEW=502;

	if ULSS_IMPEGNATIVA_OK='112' THEN
		ULSS_IMPEGNATIVA_NEW=503;

	if ULSS_IMPEGNATIVA_OK='113' THEN
		ULSS_IMPEGNATIVA_NEW=503;

	if ULSS_IMPEGNATIVA_OK='114' THEN
		ULSS_IMPEGNATIVA_NEW=503;

	if ULSS_IMPEGNATIVA_OK='110' THEN
		ULSS_IMPEGNATIVA_NEW=504;

	if ULSS_IMPEGNATIVA_OK='118' THEN
		ULSS_IMPEGNATIVA_NEW=505;

	if ULSS_IMPEGNATIVA_OK='119' THEN
		ULSS_IMPEGNATIVA_NEW=505;

	if ULSS_IMPEGNATIVA_OK='115' THEN
		ULSS_IMPEGNATIVA_NEW=506;

	if ULSS_IMPEGNATIVA_OK='116' THEN
		ULSS_IMPEGNATIVA_NEW=506;

	if ULSS_IMPEGNATIVA_OK='117' THEN
		ULSS_IMPEGNATIVA_NEW=506;

	if ULSS_IMPEGNATIVA_OK='103' THEN
		ULSS_IMPEGNATIVA_NEW=507;

	if ULSS_IMPEGNATIVA_OK='104' THEN
		ULSS_IMPEGNATIVA_NEW=507;

	if ULSS_IMPEGNATIVA_OK='106' THEN
		ULSS_IMPEGNATIVA_NEW=508;

	if ULSS_IMPEGNATIVA_OK='105' THEN
		ULSS_IMPEGNATIVA_NEW=508;

	if ULSS_IMPEGNATIVA_OK='120' THEN
		ULSS_IMPEGNATIVA_NEW=509;

	if ULSS_IMPEGNATIVA_OK='121' THEN
		ULSS_IMPEGNATIVA_NEW=509;

	if ULSS_IMPEGNATIVA_OK='122' THEN
		ULSS_IMPEGNATIVA_NEW=509;
run;

/**/
/*ATTACCO CON ANAGRAFICA*/


DATA ASSENZE_ADT_UDO;
	SET ASSENZE_ADT_UDO;
	K0=CATS(ID_EPISODIO,CODICE_SOGGETTO_BIN);
RUN;

DATA ana;
	SET ana;
	K0=CATS(ID_EPISODIO,CODICE_SOGGETTO_BIN);
RUN;

proc sort data=ASSENZE_adt_udo;
	by K0;
run;

proc sort data=ana;
	by K0;
run;

DATA ASS_ADT_UDO_ANA;/**/
	MERGE ASSENZE_adt_udo (IN=A) ana (IN=B);
	BY K0;

	IF A;
RUN;

data ASS_ADT_UDO_ANA;
	set ASS_ADT_UDO_ANA;

	if ULSS_UDO='101' THEN
		ULSS_UDO_NEW=501;

	if ULSS_UDO='102' THEN
		ULSS_UDO_NEW=501;

	if ULSS_UDO='109' THEN
		ULSS_UDO_NEW=502;

	if ULSS_UDO='107' THEN
		ULSS_UDO_NEW=502;

	if ULSS_UDO='108' THEN
		ULSS_UDO_NEW=502;

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
run;

data ASS_ADT_UDO_ANA;
	set ASS_ADT_UDO_ANA;

	IF ( &fase in (1,3,5,7,8,10,12)  and cod_tipo_dimissione ne '5'	)	THEN eta=int((mdy(&fase,31,&anno)-DATANASC)/365.25);
	IF ( &fase in (4,6,9,11) and cod_tipo_dimissione ne '5'	) 				THEN eta=int((mdy(&fase,30,&anno)-DATANASC)/365.25);
	IF ( (mod(&anno,4)=0) and &fase = 2 and cod_tipo_dimissione ne '5'	)	THEN eta=int((mdy(&fase,29,&anno)-DATANASC)/365.25);
	IF ( (mod(&anno,4) ne 0) and &fase = 2 and cod_tipo_dimissione ne '5'	) THEN eta=int((mdy(&fase,28,&anno)-DATANASC)/365.25);

	if (cod_tipo_dimissione eq '5' and datadim_udo ne .) then
		eta=int((datadim_udo-datanasc)/365);

run;

data ASS_ADT_UDO_ANA;
	set ASS_ADT_UDO_ANA;

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



DATA ARCIPELAGO5;
	SET ASS_ADT_UDO_ANA;
	KEEP
		CODICE_SOGGETTO_BIN
		ID_EPISODIO
		ANNO
		giorni_assenza_quotasan
		giorni_assenza_lordi 
		COD_MOTIVAZIONE_ASSENZA
		DATARIC_STRUTTURA
		DATARIC_UDO
		COD_UDO
		REG_ENTE_GES
		ULSS_UDO
		ULSS_UDO_NEW
		ULSS_IMPEGNATIVA_OK
		ULSS_IMPEGNATIVA_NEW
		CLETA
		SESSO
		FLG_TIPO_UTENTE
	;
RUN;

DATA ARCIPELAGO5;
	SET ARCIPELAGO5;
	ANNO_PRIMO_INGRESSO =	YEAR(DATARIC_STRUTTURA);
	ANNO_INGRESSO_UDO	=	YEAR(DATARIC_UDO);
	TRIMESTRE 			= 	&trimestre;
RUN;

DATA ARCIPELAGO5;
	SET ARCIPELAGO5;
	DROP DATARIC_STRUTTURA
		DATARIC_UDO
	;
RUN;

DATA ARCIPELAGO5;
	RETAIN
		CODICE_SOGGETTO_BIN
		ID_EPISODIO
		ANNO
		giorni_assenza_quotasan
		giorni_assenza_lordi 
		COD_MOTIVAZIONE_ASSENZA
		TRIMESTRE
		ANNO_PRIMO_INGRESSO
		ANNO_INGRESSO_UDO
		COD_UDO
		REG_ENTE_GES
		ULSS_UDO
		ULSS_UDO_NEW
		ULSS_IMPEGNATIVA_OK
		ULSS_IMPEGNATIVA_NEW
		CLETA
		SESSO
		FLG_TIPO_UTENTE
	;
	SET ARCIPELAGO5;
RUN;
%mend;

/*esecuzione delle macro*/
%let anno=2018; 	/*anno di interesse*/
%let fase=7; 		/*fase di interesse*/
%let trimestre=3; 	/* trimestre di interesse */

%SET_ADT_FAR;
%set_udo;
%set_assenze;
%SET_ANAGRAFICA_FAR;
%TABELLA_005;

/*PER ACCODAMENTO DI PIù ANNI*/
DATA TMP_2016; SET ARCIPELAGO5; RUN; /*ANNO 2016*/

DATA TMP_2017; SET ARCIPELAGO5; RUN; /*ANNO 2017*/

DATA TMP_2018; SET ARCIPELAGO5; RUN; /*ANNO 2018*/

DATA TMP1_2018; SET ARCIPELAGO5; RUN; /*ANNO 2018*/

DATA ARCIPELAGO_005; SET TMP_2016 TMP_2017 TMP_2018 TMP1_2018; RUN; 

data arcipelago_005; set arcipelago_005;
if ulss_udo_new eq . and ulss_udo = '501' then ulss_udo_new = 501;
if ulss_udo_new eq . and ulss_udo = '502' then ulss_udo_new = 502;
if ulss_udo_new eq . and ulss_udo = '503' then ulss_udo_new = 503;
if ulss_udo_new eq . and ulss_udo = '504' then ulss_udo_new = 504;
if ulss_udo_new eq . and ulss_udo = '505' then ulss_udo_new = 505;
if ulss_udo_new eq . and ulss_udo = '506' then ulss_udo_new = 506;
if ulss_udo_new eq . and ulss_udo = '507' then ulss_udo_new = 507;
if ulss_udo_new eq . and ulss_udo = '508' then ulss_udo_new = 508;
if ulss_udo_new eq . and ulss_udo = '509' then ulss_udo_new = 509;
if ulss_impegnativa_new eq . and ulss_impegnativa_ok = 501 then ulss_impegnativa_new = 501;
if ulss_impegnativa_new eq . and ulss_impegnativa_ok = 502 then ulss_impegnativa_new = 502;
if ulss_impegnativa_new eq . and ulss_impegnativa_ok = 503 then ulss_impegnativa_new = 503;
if ulss_impegnativa_new eq . and ulss_impegnativa_ok = 504 then ulss_impegnativa_new = 504;
if ulss_impegnativa_new eq . and ulss_impegnativa_ok = 505 then ulss_impegnativa_new = 505;
if ulss_impegnativa_new eq . and ulss_impegnativa_ok = 506 then ulss_impegnativa_new = 506;
if ulss_impegnativa_new eq . and ulss_impegnativa_ok = 507 then ulss_impegnativa_new = 507;
if ulss_impegnativa_new eq . and ulss_impegnativa_ok = 508 then ulss_impegnativa_new = 508;
if ulss_impegnativa_new eq . and ulss_impegnativa_ok = 509 then ulss_impegnativa_new = 509;
if giorni_assenza_quotasan eq . then giorni_assenza_quotasan = 0;
if giorni_assenza_lordi eq . then giorni_assenza_lordi =0;
run; 

/*eof*/
