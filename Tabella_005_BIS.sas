/**/
/************************************************/
/* 			Tabella 5 BIS arcipelago 				*/
/*			Tracciato assenze per UDO					*/
/************************************************/


LIBNAME FAR_2016 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2016';
LIBNAME FAR_2017 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2017';
LIBNAME FAR_2018 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2018';


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


%macro tabella_005_bis;
/******************************/

/*	tabella ARCIPELAGO 5BIS 
CALCOLI PER UDO				
**********************************/

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

	if ulss_42=109 THEN
		ULSS_NEW=502;

	if ulss_42=107 THEN
		ULSS_NEW=502;

	if ulss_42=108 THEN
		ULSS_NEW=502;

	*;
	if ulss_42=112 THEN
		ULSS_NEW=503;

	if ulss_42=113 THEN
		ULSS_NEW=503;

	if ulss_42=114 THEN
		ULSS_NEW=503;

	*;
	if ulss_42=110 THEN
		ULSS_NEW=504;

	*;
	if ulss_42=118 THEN
		ULSS_NEW=505;

	if ulss_42=119 THEN
		ULSS_NEW=505;

	*;
	if ulss_42=115 THEN
		ULSS_NEW=506;

	if ulss_42=116 THEN
		ULSS_NEW=506;

	if ulss_42=117 THEN
		ULSS_NEW=506;

	*;
	if ulss_42=103 THEN
		ULSS_NEW=507;

	if ulss_42=104 THEN
		ULSS_NEW=507;

	*;
	if ulss_42=106 THEN
		ULSS_NEW=508;

	if ulss_42=105 THEN
		ULSS_NEW=508;

	*;
	if ulss_42=120 THEN
		ULSS_NEW=509;

	if ulss_42=121 THEN
		ULSS_NEW=509;

	if ulss_42=122 THEN
		ULSS_NEW=509;
run;

/*SOMMO I GIORNI DI ASSENZA PER LA COD_UDO E COD_MOTIVAZIONE_ASSENZA*/
PROC SQL;
	create table DURATA_ASSENZE2
		as SELECT DISTINCT  COD_UDO, COD_MOTIVAZIONE_ASSENZA,
			SUM(giorni_assenza_quotasan) AS SUM_giorni_assenza_quotasan ,
			SUM(giorni_assenza_lordi) AS SUM_giorni_assenza_lordi
		FROM ASSENZE GROUP BY COD_UDO, COD_MOTIVAZIONE_ASSENZA;
QUIT;

PROC SORT DATA=DURATA_ASSENZE2;
	BY COD_UDO;
RUN;

data udo;
	set udo;
	RENAME 	ANNO=ANNO_A7;
run;

proc sort data=DURATA_ASSENZE2;
	by cod_udo;
run;

proc sort data=udo;
	by cod_udo;
run;

DATA ass_udo ;/**/
	MERGE DURATA_ASSENZE2 (IN=A) UDO (IN=B);
	BY cod_udo;

	IF A;
RUN;

data ass_udo;
	set ass_udo;
	where anno_a7 ne .;
run; /**/



data ass_udo;
	set ass_udo;

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
run;

data ass_udo;
	set ass_udo;
	ANNO=&anno;
	TRIMESTRE=&trimestre;
RUN;

DATA ARCIPELAGO5_BIS;
	SET ASS_UDO;
	KEEP
		ULSS_UDO
		ULSS_UDO_NEW
		ANNO
		COD_UDO
		REG_ENTE_GES
		SUM_giorni_assenza_quotasan
		SUM_giorni_assenza_lordi
		COD_MOTIVAZIONE_ASSENZA
		TRIMESTRE
	;
RUN;

DATA ARCIPELAGO5_BIS;
	RETAIN
		ULSS_UDO
		ULSS_UDO_NEW
		ANNO
		COD_UDO
		REG_ENTE_GES
		SUM_giorni_assenza_quotasan
		SUM_giorni_assenza_lordi
		COD_MOTIVAZIONE_ASSENZA
		TRIMESTRE
	;
	SET ARCIPELAGO5_BIS;
RUN;
%mend; 



/*esecuzione delle macro*/
%let anno=2018; 	/*anno di interesse*/
%let fase=7; 		/*fase di interesse*/
%let trimestre=3; 	/* trimestre di interesse */

%set_udo;
%set_assenze;
%TABELLA_005_BIS;

/*PER ACCODAMENTO DI PIù ANNI*/
DATA TMP_2016; SET ARCIPELAGO5_BIS; RUN; /*ANNO 2016*/

DATA TMP_2017; SET ARCIPELAGO5_BIS; RUN; /*ANNO 2017*/

DATA TMP_2018; SET ARCIPELAGO5_BIS; RUN; /*ANNO 2018*/
DATA TMP1_2018; SET ARCIPELAGO5_BIS; RUN; /*ANNO 2018*/

DATA ARCIPELAGO_005_BIS; SET TMP_2016 TMP_2017 TMP_2018 TMP1_2018; RUN; 

data arcipelago_005_bis; 
set arcipelago_005_bis;
if ulss_udo_new eq . and ulss_udo = '501' then ulss_udo_new = 501;
if ulss_udo_new eq . and ulss_udo = '502' then ulss_udo_new = 502;
if ulss_udo_new eq . and ulss_udo = '503' then ulss_udo_new = 503;
if ulss_udo_new eq . and ulss_udo = '504' then ulss_udo_new = 504;
if ulss_udo_new eq . and ulss_udo = '505' then ulss_udo_new = 505;
if ulss_udo_new eq . and ulss_udo = '506' then ulss_udo_new = 506;
if ulss_udo_new eq . and ulss_udo = '507' then ulss_udo_new = 507;
if ulss_udo_new eq . and ulss_udo = '508' then ulss_udo_new = 508;
if ulss_udo_new eq . and ulss_udo = '509' then ulss_udo_new = 509;
if ulss_udo_new eq . and ulss_udo = '999' then ulss_udo_new = 999;
run; 

/*eof*/
