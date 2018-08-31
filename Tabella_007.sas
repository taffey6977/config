/*TABELLA ARCIPELAGO 7 - CENTRI DIURNI
/* Tracciato 4.3 
*/

LIBNAME FAR_2016 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2016';
LIBNAME FAR_2017 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2017';
LIBNAME FAR_2018 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2017';

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

%macro import_rilevazioni;
proc sql;
	create table RILEVAZIONI as
		select *
			from DWHODD.ODD_FAR_UNI_A6_DEF
				where (anno=&anno and fase =&fase  and flg_err=0 AND flg_archivio ne 'C');
quit;
data RILEVAZIONI;
	SET RILEVAZIONI;
	RENAME PRG_REC=PRG_REC_A6
		COD_ENTE=ULSS
		ID_ASSISTITO=ID_EPISODIO
		COD_STRUT_EROG_UDO=COD_UDO
		FASE=FASE_A6;
	FORMAT COD_MOTIV_ASSENZA $MOTIVO_ASSENZA.;
	format COD_LESIONI $LESIONI. FLG_CATETERE $SI_NO.;
	format COD_CONTENZIONE $CONTENZIONE.;
RUN;

DATA RILEVAZIONI;
	SET RILEVAZIONI;
	GG_ASSENZA_TEMP_num=input(GG_ASSENZA_TEMP, best3.);
	NUM_EVENTI_ASSENZA_num=input(NUM_EVENTI_ASSENZA, best2.);
	NUM_CADUTE_LIEVI_num=input(NUM_CADUTE_LIEVI, best3.);
	NUM_CADUTE_MODERATE_num=input(NUM_CADUTE_MODERATE, best3.);
	NUM_CADUTE_GRAVI_num=input(NUM_CADUTE_GRAVI, best3.);
	NUM_INF_URINARIE_num=input(NUM_INF_URINARIE, best3.);
	NUM_INF_NON_URINARIE_num=input(NUM_INF_NON_URINARIE, best3.);
	GG_PRESENZA_num=input(GG_PRESENZA, best3.);
	HH_PRESENZA_num=input(HH_PRESENZA, best4.);
run;

data rilevazioni; set rilevazioni; if gg_assenza_temp_num>366 then gg_assenza_temp_num=366; run; 

data rilevazioni; set rilevazioni;
drop
GG_ASSENZA_TEMP
NUM_EVENTI_ASSENZA
NUM_CADUTE_LIEVI
NUM_CADUTE_MODERATE
NUM_CADUTE_GRAVI
NUM_INF_URINARIE
NUM_INF_NON_URINARIE
GG_PRESENZA
HH_PRESENZA
; 
rename 
GG_ASSENZA_TEMP_num	=	GG_ASSENZA_TEMP
NUM_EVENTI_ASSENZA_num	=	NUM_EVENTI_ASSENZA
NUM_CADUTE_LIEVI_num	=	NUM_CADUTE_LIEVI
NUM_CADUTE_MODERATE_num	=	NUM_CADUTE_MODERATE
NUM_CADUTE_GRAVI_num	=	NUM_CADUTE_GRAVI
NUM_INF_URINARIE_num	=	NUM_INF_URINARIE
NUM_INF_NON_URINARIE_num	=	NUM_INF_NON_URINARIE
GG_PRESENZA_num	=	GG_PRESENZA
HH_PRESENZA_num	=	HH_PRESENZA
;

run;
%mend;

%macro tabella_007;
DATA RILEVAZIONI;
	SET RILEVAZIONI;
	ANNO_RIFERIMENTO = SUBSTR(ANNO_RILEVAZIONE, 1, 4);
	MESE_RIFERIMENTO = SUBSTR(ANNO_RILEVAZIONE, 5, 2);
RUN;

DATA RILEVAZIONI;
	SET RILEVAZIONI;
	ANNO_RIF = INPUT(ANNO_RIFERIMENTO, BEST4.);
	MESE_RIF = INPUT(MESE_RIFERIMENTO, BEST2.);
	DROP ANNO_RIFERIMENTO MESE_RIFERIMENTO;
RUN;

/*attacco 7.1*/


data udo;
	set udo;
	RENAME 	ANNO=ANNO_A7 ulss=ulss_a7;
run;

proc sort data=RILEVAZIONI;
	by cod_udo;
run;

proc sort data=udo;
	by cod_udo;
run;

DATA RIL_UDO;/**/
	MERGE RILEVAZIONI (IN=A) UDO (IN=B);
	BY cod_udo;

	IF A ;
RUN;

data RIL_UDO;
	set RIL_UDO;

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

DATA RIL_UDO;
	SET RIL_UDO;
	rename 
		num_cadute_lievi =CADUTE_LIEVI 		
		NUM_CADUTE_MODERATE = CADUTE_MODERATE 
		NUM_CADUTE_GRAVI = CADUTE_GRAVI 
		NUM_INF_URINARIE = INFEZIONI_URINARIE	
		NUM_INF_NON_URINARIE = INFEZIONI_NONURIN;
RUN;

DATA CD;
	SET RIL_UDO;
	WHERE TIPO_UDO='5';
RUN;

DATA ARCIPELAGO7;
	SET CD;
	KEEP
		CODICE_SOGGETTO_BIN
		ID_EPISODIO
		ULSS_UDO
		ULSS_UDO_NEW
		ANNO_RIF
		MESE_RIF
		COD_UDO
		REG_ENTE_GES
		GG_PRESENZA
		HH_PRESENZA;
RUN;

DATA ARCIPELAGO7;
	RETAIN
		CODICE_SOGGETTO_BIN
		ID_EPISODIO
		ULSS_UDO
		ULSS_UDO_NEW
		ANNO_RIF
		MESE_RIF
		COD_UDO
		REG_ENTE_GES
		GG_PRESENZA
		HH_PRESENZA;
	SET ARCIPELAGO7;
RUN;

%mend; 
/**/
%let anno=2018; /*anno di interesse*/
%let fase=7;  /*fase di interesse*/

/*esecuzione delle macro*/
%SET_UDO;
%import_rilevazioni;
%tabella_007;

/*PER ACCODAMENTO DI PIù ANNI*/
DATA TMP_2016; SET ARCIPELAGO7; RUN; /*ANNO 2016*/

DATA TMP_2017; SET ARCIPELAGO7; RUN; /*ANNO 2017*/

DATA TMP_2018; SET ARCIPELAGO7; RUN; /*ANNO 2018*/
DATA TMP1_2018; SET ARCIPELAGO7; RUN; /*ANNO 2018*/

DATA ARCIPELAGO_007; SET TMP_2016 TMP_2017 TMP_2018 TMP1_2018; RUN; 

data arcipelago_007; set arcipelago_007;
if ulss_udo_new eq . and ulss_udo = '501' then ulss_udo_new = 501;
if ulss_udo_new eq . and ulss_udo = '502' then ulss_udo_new = 502;
if ulss_udo_new eq . and ulss_udo = '503' then ulss_udo_new = 503;
if ulss_udo_new eq . and ulss_udo = '504' then ulss_udo_new = 504;
if ulss_udo_new eq . and ulss_udo = '505' then ulss_udo_new = 505;
if ulss_udo_new eq . and ulss_udo = '506' then ulss_udo_new = 506;
if ulss_udo_new eq . and ulss_udo = '507' then ulss_udo_new = 507;
if ulss_udo_new eq . and ulss_udo = '508' then ulss_udo_new = 508;
if ulss_udo_new eq . and ulss_udo = '509' then ulss_udo_new = 509;
if ulss_udo_new eq . and ulss_udo = '000' then ulss_udo_new = 999;
run; 
