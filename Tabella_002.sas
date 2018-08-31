/********************************************/
/* 	Programma per creare 					*/
/*	la tabella Arcipelago 002				*/
/* 	per l'upload su Arcipelago (dashboard)	*/
*********************************************/;

LIBNAME FAR_2016 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2016';
LIBNAME FAR_2017 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2017';
LIBNAME FAR_2018 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2018';

LIBNAME ARCIPE '/sasprd/staging/staging_san1/S1_ORPSS/config/Arcipelago';

/*sistemare dataset comuni */

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

data comuni_per_merge; set comuni_per_merge; rename cod_azienda=ulss_a1_comuni; run; 
%mend; 


%MACRO SET_ANAGRAFICA_FAR;
proc sql;
	create table ANA as
		select *
			from DWHODD.ODD_FAR_UNI_A1_DEF
				where (anno=&anno and fase =&fase  and flg_err=0 AND flg_archivio ne 'C');
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
EVENTUALMENTE FAR GIRARE FAR_2017/anagrafica_udo che genera il file corretto*/
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

%MACRO SET_VALUTAZIONI_FAR;
proc sql;
	create table valutazioni as
		select *
			from DWHODD.ODD_FAR_UNI_A2_DEF
				where (anno=&anno and fase =&fase and  flg_err=0  AND flg_archivio ne 'C' );
quit;

/*proc freq data=valutazioni; table cod_ente; run; */

DATA valutazioni;
	SET valutazioni;
	DATA_VALUTAZIONE_TEMP=input(DATA_VALUTAZIONE,ddmmyy8.);
	DATA_DOMANDA_TEMP=input(DATA_DOMANDA,ddmmyy8.);
	DATA_VERIFICA_TEMP=input(DATA_VERIFICA,ddmmyy8.);
	DIABETE=SUBSTR(TRATTAMENTI_SPECIALISTICI,1,1);
	SCOMPENSO=SUBSTR(TRATTAMENTI_SPECIALISTICI,2,1);
	CIRROSI=SUBSTR(TRATTAMENTI_SPECIALISTICI,3,1);
	TRACHEOSTOMIA=SUBSTR(TRATTAMENTI_SPECIALISTICI,4,1);
	OSSIGENO=SUBSTR(TRATTAMENTI_SPECIALISTICI,5,1);
	SONDINO=SUBSTR(TRATTAMENTI_SPECIALISTICI,6,1);
	CATETERE_VENOSO=SUBSTR(TRATTAMENTI_SPECIALISTICI,7,1);
	CATETERE_VESCICALE=SUBSTR(TRATTAMENTI_SPECIALISTICI,8,1);
	ANO_ARTIF=SUBSTR(TRATTAMENTI_SPECIALISTICI,9,1);
	NEFROSTOMIA=SUBSTR(TRATTAMENTI_SPECIALISTICI,10,1);
	ULCERE=SUBSTR(TRATTAMENTI_SPECIALISTICI,11,1);
	VENTILAZ=SUBSTR(TRATTAMENTI_SPECIALISTICI,12,1);
	DIALISI=SUBSTR(TRATTAMENTI_SPECIALISTICI,13,1);
	DOLORE=SUBSTR(TRATTAMENTI_SPECIALISTICI,14,1);
	APPARECCHIATURE=SUBSTR(TRATTAMENTI_SPECIALISTICI,15,1);
	NEOPLASIA=SUBSTR(TRATTAMENTI_SPECIALISTICI,16,1);
	DA_DEFINIRE1=SUBSTR(TRATTAMENTI_SPECIALISTICI,17,1);
	DA_DEFINIRE2=SUBSTR(TRATTAMENTI_SPECIALISTICI,18,1);
	DA_DEFINIRE3=SUBSTR(TRATTAMENTI_SPECIALISTICI,19,1);
	DA_DEFINIRE4=SUBSTR(TRATTAMENTI_SPECIALISTICI,20,1);
	MEDICO_DISTRETTO=SUBSTR(FIGURE_PROF_VAL,1,1);
	MMG=SUBSTR(FIGURE_PROF_VAL,2,1);
	PLS=SUBSTR(FIGURE_PROF_VAL,3,1);
	MEDICO_SPECIALISTA=SUBSTR(FIGURE_PROF_VAL,4,1);
	MEDICO_ESPERTO=SUBSTR(FIGURE_PROF_VAL,5,1);
	PSICOLOGO=SUBSTR(FIGURE_PROF_VAL,6,1);
	INFERMIERE=SUBSTR(FIGURE_PROF_VAL,7,1);
	FISIOTERA_LOGOPEDISTA=SUBSTR(FIGURE_PROF_VAL,8,1);
	ASS_SOC_ULS=SUBSTR(FIGURE_PROF_VAL,9,1);
	ASS_SOC_COMUNE=SUBSTR(FIGURE_PROF_VAL,10,1);
	ASS_SOC_ALTRO=SUBSTR(FIGURE_PROF_VAL,11,1);
	EDUCATORE_PROF=SUBSTR(FIGURE_PROF_VAL,12,1);
	TERAPISTA=SUBSTR(FIGURE_PROF_VAL,13,1);
	VOLONTARIATO=SUBSTR(FIGURE_PROF_VAL,14,1);
	OSS=SUBSTR(FIGURE_PROF_VAL,15,1);
	PERSONALE_AMMVO=SUBSTR(FIGURE_PROF_VAL,16,1);
	FAMILIARE=SUBSTR(FIGURE_PROF_VAL,17,1);
	ALTRO=SUBSTR(FIGURE_PROF_VAL,18,1);
	format DATA_VALUTAZIONE_TEMP DATA_DOMANDA_TEMP DATA_VERIFICA_TEMP date9.;
run;

DATA valutazioni;
	SET valutazioni;
	drop data_valutazione data_domanda data_verifica TRATTAMENTI_SPECIALISTICI FIGURE_PROF_VAL;
	RENAME PRG_REC=PRG_REC_A2
		COD_ENTE=ULSS_A2
		ID_ASSISTITO=ID_EPISODIO
		PATOLOGIA_PREVALENTE=DIAGICPC1 
		PATOLOGIA_CONCOMITANTE=DIAGICPC2 
		PATOLOGIA_CONCOMITANTE_II=DIAGICPC3
		TRATT_DEMENZE=TRATTAMENTO_DEMENZE
		DATA_VALUTAZIONE_TEMP=DATA_VALUTAZIONE
		DATA_DOMANDA_TEMP=DATA_DOMANDA
		DATA_VERIFICA_TEMP=DATA_VERIFICA
		FASE=FASE_A2
		ANNO=ANNO_A2;
	format tipo_valutazione $valutazione. area_disturbi_comp $disturbi_comp. 
		supporto_rete_sociale $rete_sociale. profilo_autonomia $profilo_auto. mod_finanziamento $finanziamento.
		alternative_istit $alternative_ist. iniziativa_domanda_val $iniziativa. 
		progetto_ass_principale progetto_ass_secondario $progetto_ass. referente_org $referente.
		invalidita $si_no. indennita $si_no_attesa.;
	FORMAT tratt_demenze $no_si.;
	FORMAT MEDICO_DISTRETTO MMG PLS MEDICO_SPECIALISTA MEDICO_ESPERTO PSICOLOGO
		INFERMIERE FISIOTERA_LOGOPEDISTA ASS_SOC_ULS ASS_SOC_COMUNE ASS_SOC_ALTRO EDUCATORE_PROF
		TERAPISTA VOLONTARIATO OSS PERSONALE_AMMVO FAMILIARE ALTRO $assente.;
RUN;

*tengo solo le valutazioni all'ammissione;
data VALUTAZIONI;
	set VALUTAZIONI;
	where TIPO_VALUTAZIONE='1';
run;

data VALUTAZIONI;
	set VALUTAZIONI;
	CHIAVE_V = CATS(ULSS_A2, CODICE_SOGGETTO_BIN, ID_VALUTAZIONE);
run;

data VALUTAZIONI;
	set VALUTAZIONI;

	if ULSS_A2='101' THEN ULSS_NEW=501;
	if ULSS_A2='102' THEN ULSS_NEW=501;
	if ULSS_A2='109' THEN ULSS_NEW=502;
	if ULSS_A2='107' THEN ULSS_NEW=502;
	if ULSS_A2='108' THEN ULSS_NEW=502;
	if ULSS_A2='112' THEN ULSS_NEW=503;
	if ULSS_A2='113' THEN ULSS_NEW=503;
	if ULSS_A2='114' THEN ULSS_NEW=503;
	if ULSS_A2='110' THEN ULSS_NEW=504;
	if ULSS_A2='118' THEN ULSS_NEW=505;
	if ULSS_A2='119' THEN ULSS_NEW=505;
	if ULSS_A2='115' THEN ULSS_NEW=506;
	if ULSS_A2='116' THEN ULSS_NEW=506;
	if ULSS_A2='117' THEN ULSS_NEW=506;
	if ULSS_A2='103' THEN ULSS_NEW=507;
	if ULSS_A2='104' THEN ULSS_NEW=507;
	if ULSS_A2='106' THEN ULSS_NEW=508;
	if ULSS_A2='105' THEN ULSS_NEW=508;
	if ULSS_A2='120' THEN ULSS_NEW=509;
	if ULSS_A2='121' THEN ULSS_NEW=509;
	if ULSS_A2='122' THEN ULSS_NEW=509;
	if ULSS_A2='501' THEN ULSS_NEW=501;
	if ULSS_A2='502' THEN ULSS_NEW=502;
	if ULSS_A2='503' THEN ULSS_NEW=503;
	if ULSS_A2='504' THEN ULSS_NEW=504;
	if ULSS_A2='505' THEN ULSS_NEW=505;
	if ULSS_A2='506' THEN ULSS_NEW=506;
	if ULSS_A2='507' THEN ULSS_NEW=507;
	if ULSS_A2='508' THEN ULSS_NEW=508;
	if ULSS_A2='509' THEN ULSS_NEW=509;

	ANNO_VAL=YEAR(DATA_VALUTAZIONE);
	area_funzionale_num=input(area_funzionale, best2.);
	area_mobilita_num=input(area_mobilita, best2.);
	area_cognitiva_num=input(area_cognitiva, best2.);
	area_disturbi_comp_num=input(area_disturbi_comp, best1.);
run;

/*correggo il punteggio svama con lo zero davanti che manca*/
data VALUTAZIONI;
	set VALUTAZIONI;
	if length(punteggio_svama)=5 then punteggio_svama1=cats('0',punteggio_svama);
	else punteggio_svama1=punteggio_svama; run; 

data VALUTAZIONI;
	set VALUTAZIONI;
	parte_intera_svama=substr(punteggio_svama1, 1, 3);
	parte_decimale_svama=substr(punteggio_svama1, 5, 2);
	i=input(parte_intera_svama, best3.);
	d=input(parte_decimale_svama, best2.);
	punteggio_svama_num=i+((d)/100);
run;

data VALUTAZIONI;
	set VALUTAZIONI;

	if punteggio_svama_num>100 then
		punteggio_svama_num=.;
run;

data VALUTAZIONI;
	set VALUTAZIONI;

	/*pcog**/
	if 0 <= area_cognitiva_num <=3 then
		pcog=1;

	if 4 <= area_cognitiva_num <=8 then
		pcog=2;

	if 9 <= area_cognitiva_num <=10 then
		pcog=3;

	/*pmob*/
	if 0 <= area_mobilita_num <=14 then
		PMOB=1;

	if 15 <= area_mobilita_num <=29 then
		PMOB=2;

	if 30 <= area_mobilita_num <=40 then
		PMOB=3;

	/*padl*/
	if 0 <= area_funzionale_num <=14 then
		padl=1;

	if 15 <= area_funzionale_num <=49 then
		padl=2;

	if 50 <= area_funzionale_num <=60 then
		padl=3;
run;

data VALUTAZIONI;
	set VALUTAZIONI;
	SVAMA_RIS_DEC_VPIA_num=input(SVAMA_RIS_DEC_VPIA, best2.);
	SVAMA_ASS_INF_VIP_num=input(SVAMA_ASS_INF_VIP, best2.);
	SVAMA_POT_RES_VPOT_num=input(SVAMA_POT_RES_VPOT, best2.);
	NECESSITA_ASS_SAN_VSAN_num=input(SVAMA_POT_RES_VPOT, best2.);
run;

data VALUTAZIONI;
	set VALUTAZIONI;
	GIORNI = DATA_VALUTAZIONE - DATA_DOMANDA;
RUN;

data VALUTAZIONI;
	set VALUTAZIONI;

	IF GIORNI <0 THEN
		GIORNI_ATTESA=0;

	if GIORNI >365 THEN
		GIORNI_ATTESA=365;

	if 0 < giorni < 365 then
		GIORNI_ATTESA=GIORNI;
RUN;

data valutazioni;
	set valutazioni;
	RENAME  DIABETE= TS1DIABETE;
	RENAME  SCOMPENSO= TS2SCOMPENSO;
	RENAME  CIRROSI= TS3CIRROSI;
	RENAME  TRACHEOSTOMIA= TS4TRACHEOSTOMIA;
	RENAME  OSSIGENO= TS5OSSIGENO;
	RENAME  SONDINO= TS6SONDINO;
	RENAME  CATETERE_VENOSO= TS7CATETERE_VENOSO;
	RENAME  CATETERE_VESCICALE= TS8CATETERE_VESCICALE;
	RENAME  ANO_ARTIF= TS9ANO_ARTIF;
	RENAME  NEFROSTOMIA= TS10NEFROSTOMIA;
	RENAME  ULCERE= TS11ULCERE;
	RENAME  VENTILAZ= TS12VENTILAZ;
	RENAME  DIALISI= TS13DIALISI;
	RENAME  DOLORE= TS14DOLORE;
	RENAME  APPARECCHIATURE= TS15APPARECCHIATURE;
	RENAME  NEOPLASIA= TS16NEOPLASIA;
run;

/*duplicati*/
PROC SORT NODUPKEY DATA=VALUTAZIONI OUT=NO_DUPL_V4;
	BY CHIAVE_V;
RUN; 

/*attacco all'anagrafica per aggiungere eta e sesso*/
data NO_DUPL_V4;
	set NO_DUPL_V4;
	key	= cats(ULSS_a2, CODICE_SOGGETTO_BIN, ID_EPISODIO);
run;

/*CALCOLO DIRETTAMENTE L'ETA' all'ultimo giorno del mese (&fase) e &anno */
data ana;
	set ana;
	key = cats(ULSS, CODICE_SOGGETTO_BIN, ID_EPISODIO);
	IF ( &fase in (1,3,5,7,8,10,12) ) 		THEN eta=int((mdy(&fase,31,&anno)-DATANASC)/365.25);
	IF ( &fase in (4,6,9,11) ) 				THEN eta=int((mdy(&fase,30,&anno)-DATANASC)/365.25);
	IF ( (mod(&anno,4)=0) and &fase = 2)	THEN eta=int((mdy(&fase,29,&anno)-DATANASC)/365.25);
	IF ( (mod(&anno,4) ne 0) and &fase = 2) THEN eta=int((mdy(&fase,28,&anno)-DATANASC)/365.25);

run;

PROC SORT DATA=NO_DUPL_V4;
	BY KEY;
RUN;

PROC SORT DATA=ana;
	BY KEY;
RUN;

data V5;
	MERGE NO_DUPL_V4(in=a) ana (in=b);
	BY KEY;
	if a;
RUN;

/* calcolo MPI*/

DATA v5;
	set V5;
	R_age_M= (ETA*0.00331);
	R_age_Y= (ETA*0.01351);
	R_VIP_M= (SVAMA_ASS_INF_VIP_num*0.02741);
	R_VIP_Y= (SVAMA_ASS_INF_VIP_num*0.02771);
	R_VCOG_M= (area_cognitiva_num*0.01772);
	R_VCOG_Y= (area_cognitiva_num*0.00799);
	R_VPIA_M= (SVAMA_RIS_DEC_VPIA_num*0.02104);
	R_VPIA_Y= (SVAMA_RIS_DEC_VPIA_num*0.02858);
	R_VADL_M= (area_funzionale_num*0.01098);
	R_VADL_Y= (area_funzionale_num*0.00662);
	R_VMOB_M= (area_mobilita_num*0.02617);
	R_VMOB_Y= (area_mobilita_num*0.01645);
run;

DATA V5;
	set V5;
	SOC = SUBSTR (SUPPORTO_RETE_SOCIALE,1,1);
RUN;

DATA V5;
	set V5;

	IF soc= '1' then
		R_VSOC_M= (40*0.0007367);

	IF soc= '2' then
		R_VSOC_M= (120*0.0007367);

	IF soc= '3' then
		R_VSOC_M= (200*0.0007367);

	IF soc= '1' then
		R_VSOC_y= (40*0.0000994);

	IF soc= '2' then
		R_VSOC_y= (120*0.0000994);

	IF soc= '3' then
		R_VSOC_y= (200*0.0000994);
run;

DATA V5;
	set V5;

	if SESSO='1' then
		R_sesso_M=0.31464;
	else R_sesso_M=0;

	if SESSO='1' then
		R_sesso_Y=0.3413;
	else R_sesso_Y=0;
run;

DATA V5;
	set V5;

	if (DIAGICPC1='D75' or 
		DIAGICPC1='D74' or 
		DIAGICPC1='D76' or
		DIAGICPC1='D77' or
		DIAGICPC1='B72' or
		DIAGICPC1='B73' or
		DIAGICPC1='B74' or
		DIAGICPC1='X76' or
		DIAGICPC1='X77' or	
		DIAGICPC1='U75' or
		DIAGICPC1='U76' or
		DIAGICPC1='U79' or
		DIAGICPC1='Y77' or
		DIAGICPC1='Y78' or	
		DIAGICPC1='T71' or
		DIAGICPC1='S77' or
		DIAGICPC1='S80' or
		DIAGICPC1='R84' or
		DIAGICPC1='R85' or
		DIAGICPC1='N74' or	
		DIAGICPC1='N75' or
		DIAGICPC1='H75' or
		DIAGICPC1='F74') then
		MAPRICA=1;

	if DIAGICPC1='L75' then
		MAPRICA=2;

	if DIAGICPC1='K75' or 
		DIAGICPC1='K76' or 
		DIAGICPC1='K78' or
		DIAGICPC1='K79' or
		DIAGICPC1='K87' or
		DIAGICPC1='K92' or
		DIAGICPC1='K99' or
		DIAGICPC1='K86' or
		DIAGICPC1='K77' or	
		DIAGICPC1='K84' or
		DIAGICPC1='K91' or
		DIAGICPC1='K74' then
		MAPRICA=4;

	if DIAGICPC1='P71' or 
		DIAGICPC1='P20' or 
		DIAGICPC1='P76' or
		DIAGICPC1='P72' or
		DIAGICPC1='P99' or
		DIAGICPC1='P73' or
		DIAGICPC1='P98' or
		DIAGICPC1='N86' or
		DIAGICPC1='N87' or	
		DIAGICPC1='N88' or
		DIAGICPC1='N99' then
		MAPRICA=6;

	if DIAGICPC1='R95' or 
		DIAGICPC1='R91' or 
		DIAGICPC1='R96' or
		DIAGICPC1='R81' or
		DIAGICPC1='K82' then
		MAPRICA=5;

	if DIAGICPC1='A00' then
		MAPRICA=7;

	/*if DIAGICPC1='A07' then
	  MAPRICA=8;*/
	if DIAGICPC1='K89' or DIAGICPC1='K90' then
		MAPRICA=3;

	if DIAGICPC1='P70' then
		MAPRICA=0;
RUN;

/*? missing settato a 8*/
DATA V5;
	set V5;

	if (DIAGICPC1 NE 'D75' AND 
		DIAGICPC1 NE 'D74' AND 
		DIAGICPC1 NE 'D76' AND
		DIAGICPC1 NE 'D77' AND
		DIAGICPC1 NE 'B72' AND
		DIAGICPC1 NE 'B73' AND
		DIAGICPC1 NE 'B74' AND
		DIAGICPC1 NE 'X76' AND
		DIAGICPC1 NE 'X77' AND	
		DIAGICPC1 NE 'U75' AND
		DIAGICPC1 NE 'U76' AND
		DIAGICPC1 NE 'U79' AND
		DIAGICPC1 NE 'Y77' AND
		DIAGICPC1 NE 'Y78' AND	
		DIAGICPC1 NE 'T71' AND
		DIAGICPC1 NE 'S77' AND
		DIAGICPC1 NE 'S80' AND
		DIAGICPC1 NE 'R84' AND
		DIAGICPC1 NE 'R85' AND
		DIAGICPC1 NE 'N74' AND	
		DIAGICPC1 NE 'N75' AND
		DIAGICPC1 NE 'H75' AND
		DIAGICPC1 NE 'F74' AND
		DIAGICPC1 NE 'L75' AND  
		DIAGICPC1 NE 'K75' AND 
		DIAGICPC1 NE 'K76' AND 
		DIAGICPC1 NE 'K78' AND
		DIAGICPC1 NE 'K79' AND
		DIAGICPC1 NE 'K87' AND
		DIAGICPC1 NE 'K92' AND
		DIAGICPC1 NE 'K99' AND
		DIAGICPC1 NE 'K86' AND
		DIAGICPC1 NE 'K77' AND	
		DIAGICPC1 NE 'K84' AND
		DIAGICPC1 NE 'K91' AND
		DIAGICPC1 NE 'K74' AND 
		DIAGICPC1 NE 'P71' AND 
		DIAGICPC1 NE 'P20' AND 
		DIAGICPC1 NE 'P76' AND
		DIAGICPC1 NE 'P72' AND
		DIAGICPC1 NE 'P99' AND
		DIAGICPC1 NE 'P73' AND
		DIAGICPC1 NE 'P98' AND
		DIAGICPC1 NE 'N86' AND
		DIAGICPC1 NE 'N87' AND	
		DIAGICPC1 NE 'N88' AND
		DIAGICPC1 NE 'N99' AND
		DIAGICPC1 NE 'R95' AND 
		DIAGICPC1 NE 'R91' AND 
		DIAGICPC1 NE 'R96' AND
		DIAGICPC1 NE 'R81' AND
		DIAGICPC1 NE 'K82' AND
		DIAGICPC1 NE 'A00' AND 
		DIAGICPC1 NE 'K89' AND
		DIAGICPC1 NE 'K90' AND
		DIAGICPC1 NE 'P70') THEN
		MAPRICA=8;
RUN;

DATA V5;
	set V5;

	if MAPRICA=0 then
		MAPRICA_M=0;

	if MAPRICA=1 then
		MAPRICA_M=2.22093;

	if MAPRICA=2 then
		MAPRICA_M= -0.65872;

	if MAPRICA=3 then
		MAPRICA_M=0.20318;

	if MAPRICA=4 then
		MAPRICA_M=0.38855;

	if MAPRICA=5 then
		MAPRICA_M=0.39394;

	if MAPRICA=6 then
		MAPRICA_M= -0.14409;

	if MAPRICA=7 then
		MAPRICA_M=0.43482;

	if MAPRICA=8 then
		MAPRICA_M=0.699910;

	if MAPRICA=0 then
		MAPRICA_Y=0;

	if MAPRICA=1 then
		MAPRICA_Y=1.99569;

	if MAPRICA=2 then
		MAPRICA_Y=-0.54763;

	if MAPRICA=3 then
		MAPRICA_Y=0.0099;

	if MAPRICA=4 then
		MAPRICA_Y=0.30945;

	if MAPRICA=5 then
		MAPRICA_Y=0.2596;

	if MAPRICA=6 then
		MAPRICA_Y=-0.10899;

	if MAPRICA=7 then
		MAPRICA_Y=0.21911;

	if MAPRICA=8 then
		MAPRICA_Y=0.34769;
run;

/*CALCOLO INDICE MPI-SVAMA*/
DATA V5;
	set V5;
	R_M = R_age_M+R_sesso_M+MAPRICA_M+R_VIP_M+R_VCOG_M+R_VPIA_M+R_VADL_M+R_VMOB_M+R_VSOC_M;

	/*MPI-SVAMA AT 1 MONTH*/
	MPI_SVAMA_M = (R_M+0.274)/6.564;
	R_Y = R_age_Y+R_sesso_Y+MAPRICA_Y+R_VIP_Y+R_VCOG_Y+R_VPIA_Y+R_VADL_Y+R_VMOB_Y+R_VSOC_Y;

	/*MPI-SVAMA AT 1 YEAR*/
	MPI_SVAMA_Y = (R_Y-0.673)/5.476;
RUN;


data udo;
	set udo;
	RENAME 	ANNO=ANNO_A7;
run;

proc sort data=adt;
	by cod_udo;
run;

proc sort data=udo;
	by cod_udo;
run;

DATA au;
	MERGE adt (IN=A) UDO (IN=B);
	BY cod_udo;

	IF A and b;
RUN;

/*CONTATORE PER ULTIMA udo DI ACCOGLIENZA*/
/*ordino per codice soggetto e data ricevimento in udo*/
PROC SORT DATA=AU;
	BY codice_soggetto_bin DESCENDING DATARIC_UDO;
RUN;

DATA AU;
	SET AU;
	BY codice_soggetto_bin;

	IF FIRST.codice_soggetto_bin THEN
		PROGRESSIVO3=1;
	ELSE PROGRESSIVO3+1;
RUN;

/*ULTIMA UDO DI ACCOGLIENZA PROGRESSIVO3=1*/
DATA AU;
	SET AU;
	WHERE PROGRESSIVO3=1;
RUN;

/*DB COMUNI FILEMAKER*/
DATA COMUNI;
	SET FAR_2016.COMUNI_FILEMAKER;
RUN;

DATA COMUNI;
	SET COMUNI;
	KEEP COD_COMUNE DESCRIZIONE;
RUN;

DATA AU;
	SET AU;
	KEEP 
		CODICE_SOGGETTO_BIN
		COD_UDO
		TIPO_UDO
		REG_ENTE_GES
		COMUNE
	ULSS_UDO
	;
RUN;

DATA AU;
	SET AU;
	RENAME COMUNE=COD_COMUNE;
RUN;

proc sort data=AU;
	by COD_COMUNE;
run;

proc sort data=COMUNI;
	by COD_COMUNE;
run;

DATA au_COM;/*43861*/
	MERGE AU (IN=A) COMUNI (IN=B);
	BY COD_COMUNE;

	IF A;
RUN;

data au_com;
	set au_com;

	if ulss_udo='999' then
		DESCRIZIONE='Fuori regione';
run;

proc sort data=au_COM;
	by CODICE_SOGGETTO_BIN;
run;

PROC SORT NODUPKEY DATA=au_COM OUT=NO_DUP;
	BY CODICE_SOGGETTO_BIN;
RUN; /*NO DOPPIONI!!*/

/*MERGE PER AVERE NELLE VALUTAZIONI 
Codice dell'ultima (più recente) UDO di accoglienza
Tipologia di offerta dell'ultima UDO di accoglienza
Codice dell'Ente gestore dell'ultima UDO di accoglienza
Comune dell'ultima UDO di accoglienza (codice istat, numerico)
Comune dell'ultima UDO di accoglienza (descrizione)
Ultima (più recente) ULSS di accoglienza
*/
/*V5 è l'ultimo database delle valutazioni*/
DATA V5;
	SET V5;
	DROP ULSS_UDO;
RUN;

/*droppo ulss_udo su db valutazioni tengo solo da adt (au_com)*/
proc sort data=V5;
	by CODICE_SOGGETTO_BIN;
run;

proc sort data=au_COM;
	by CODICE_SOGGETTO_BIN;
run;

DATA ARCIPELAGO2;
	MERGE V5 (IN=A) au_COM (IN=B);
	BY CODICE_SOGGETTO_BIN;
	IF A;
RUN;

/*ci sono soggetti che hanno più di una valutazione di tipo 1
tengo solo l'ultima (data_valutazione più recente: PROGRESSIVOuv=1)
*/
proc sort data=arcipelago2; by  codice_soggetto_bin descending  data_valutazione; run; 
 
 
DATA arcipelago2;/**/
 SET arcipelago2;
 BY codice_soggetto_bin;
 IF FIRST.codice_soggetto_bin THEN PROGRESSIVOuv=1;ELSE PROGRESSIVOuv+1;
RUN;

/*proc freq data=arcipelago2; table PROGRESSIVOuv; run; */

DATA arcipelago2;/**/
 SET arcipelago2;
 where PROGRESSIVOuv=1;
 run;

/*++++++++++++
 prima di questa devo ricalcolare ULSS_A2 mettendo l'ULSS di residenza del 
 soggetto per anno >= 2017
 */
%mend;

/*TENGO LE VARIABILI PER LA TABELLA 2
(faccio due separate per il 2016 e per il >=2017 perché le medie 
dei punteggi svama vengono fatte
sulle ulss vecchie che nel 2017 non avrei*/

%macro finale2016;
data arcipelago2;
	set ARCIPELAGO2;
	keep 
	ULSS_A2
	ULSS_NEW
	ID_VALUTAZIONE
	CODICE_SOGGETTO_BIN
	ANNO_VAL
	ANNO_A2
	DIAGICPC1
	DIAGICPC2
	DIAGICPC3
	area_funzionale_num
	padl
	area_mobilita_num
	pmob
	area_cognitiva_num
	pcog
	AREA_DISTURBI_COMP
	SVAMA_RIS_DEC_VPIA_num
	SVAMA_ASS_INF_VIP_num
	SVAMA_POT_RES_VPOT_num
	NECESSITA_ASS_SAN_VSAN_num
	TS1DIABETE
	TS2SCOMPENSO
	TS3CIRROSI
	TS4TRACHEOSTOMIA
	TS5OSSIGENO
	TS6SONDINO
	TS7CATETERE_VENOSO
	TS8CATETERE_VESCICALE
	TS9ANO_ARTIF
	TS10NEFROSTOMIA
	TS11ULCERE
	TS12VENTILAZ
	TS13DIALISI
	TS14DOLORE
	TS15APPARECCHIATURE
	TS16NEOPLASIA
	SUPPORTO_RETE_SOCIALE
	PROFILO_AUTONOMIA
	punteggio_svama_num
	MOD_FINANZIAMENTO
	ALTERNATIVE_ISTIT
	GIORNI_ATTESA
	INIZIATIVA_DOMANDA_VAL
	MEDICO_DISTRETTO
	MMG
	PLS
	MEDICO_SPECIALISTA
	MEDICO_ESPERTO
	PSICOLOGO
	INFERMIERE
	FISIOTERA_LOGOPEDISTA
	ASS_SOC_ULS
	ASS_SOC_COMUNE
	ASS_SOC_ALTRO
	EDUCATORE_PROF
	TERAPISTA
	VOLONTARIATO
	OSS
	PERSONALE_AMMVO
	FAMILIARE
	ALTRO
	PROGETTO_ASS_PRINCIPALE
	PROGETTO_ASS_SECONDARIO
	REFERENTE_ORG
	INVALIDITA
	INDENNITA
	TRATTAMENTO_DEMENZE
	MPI_SVAMA_M
	MPI_SVAMA_Y
	SESSO
	ETA
	COD_UDO
	TIPO_UDO
	REG_ENTE_GES
	COD_COMUNE
	DESCRIZIONE
	ULSS_UDO
	;
run;

proc summary data=arcipelago2 ;
	class ULSS_a2;
	var punteggio_svama_num MPI_SVAMA_M MPI_SVAMA_Y;
	output out=y mean(punteggio_svama_num)=AVG_SVAMA_ULSS 
mean(MPI_SVAMA_M)=AVG_MPI_M_ULSS 
mean(MPI_SVAMA_Y)=AVG_MPI_Y_ULSS;
run;

PROC SORT DATA=arcipelago2;
	BY ULSS_A2;
RUN;/*27155*/

PROC SORT DATA=Y;
	BY ULSS_A2;
RUN;
/*qui calcolo le medie per ulss NUOVA 
nel 2017 bisogna cambiare con ulss vecchia */
data arcipelago3;
	MERGE arcipelago2 (in=a) Y (in=b);
	BY ULSS_A2;

	if a;
RUN;

DATA ARCIPELAGO3;
	SET ARCIPELAGO3;
	DROP _FREQ_ _TYPE_;
RUN;
/* Y_1 serve a tenere le medie regionali */ 
data y_1; set y; where _type_=0;  
run;

data Y_1; set Y_1; anno_a2=&anno; run;
data Y_1; set Y_1; rename avg_svama_ulss=avg_svama_reg
avg_mpi_m_ulss=avg_mpi_m_reg 
avg_mpi_y_ulss=avg_mpi_y_reg; 
run;
/* Y_1 serve a tenere le medie regionali */ 
proc sort data=Y_1; by anno_a2; run; 
proc sort data=arcipelago3; by anno_a2; run; 

data arcipelago33; merge arcipelago3 (in=a) y_1(in=b); by anno_a2; if a ; run; 

DATA ARCIPELAGO2_OK;
	SET arcipelago33;
RUN;

data arcipelago2_ok; set arcipelago2_ok; drop _freq_ _type_ anno; run; 

data ARCIPELAGO2_OK;/**/
	retain 
		ULSS_A2
		ULSS_NEW
		ID_VALUTAZIONE
		CODICE_SOGGETTO_BIN
		ANNO_VAL
		ANNO_A2
		TIPO_VALUTAZIONE
		ETA 
		SESSO
		DIAGICPC1
		DIAGICPC2
		DIAGICPC3
		area_funzionale_num
		padl
		area_mobilita_num
		pmob
		area_cognitiva_num
		pcog
		AREA_DISTURBI_COMP
		SVAMA_RIS_DEC_VPIA_num
		SVAMA_ASS_INF_VIP_num
		SVAMA_POT_RES_VPOT_num
		NECESSITA_ASS_SAN_VSAN_num
		TS1DIABETE
		TS2SCOMPENSO
		TS3CIRROSI
		TS4TRACHEOSTOMIA
		TS5OSSIGENO
		TS6SONDINO
		TS7CATETERE_VENOSO
		TS8CATETERE_VESCICALE
		TS9ANO_ARTIF
		TS10NEFROSTOMIA
		TS11ULCERE
		TS12VENTILAZ
		TS13DIALISI
		TS14DOLORE
		TS15APPARECCHIATURE
		TS16NEOPLASIA
		SUPPORTO_RETE_SOCIALE
		PROFILO_AUTONOMIA
		punteggio_svama_num
		avg_svama_ULSS
		avg_svama_reg
		MOD_FINANZIAMENTO
		ALTERNATIVE_ISTIT
		GIORNI_ATTESA
		INIZIATIVA_DOMANDA_VAL
		MEDICO_DISTRETTO
		MMG
		PLS
		MEDICO_SPECIALISTA
		MEDICO_ESPERTO
		PSICOLOGO
		INFERMIERE
		FISIOTERA_LOGOPEDISTA
		ASS_SOC_ULS
		ASS_SOC_COMUNE
		ASS_SOC_ALTRO
		EDUCATORE_PROF
		TERAPISTA
		VOLONTARIATO
		OSS
		PERSONALE_AMMVO
		FAMILIARE
		ALTRO
		PROGETTO_ASS_PRINCIPALE
		PROGETTO_ASS_SECONDARIO
		REFERENTE_ORG
		INVALIDITA
		INDENNITA
		TRATTAMENTO_DEMENZE
		MPI_SVAMA_M
		AVG_MPI_M_ULSS
		AVG_MPI_M_REG
		MPI_SVAMA_Y
		AVG_MPI_Y_ULSS
		AVG_MPI_Y_REG
		SESSO
		ETA
		COD_UDO
		TIPO_UDO
		REG_ENTE_GES
		COD_COMUNE
		DESCRIZIONE
		ULSS_UDO
	;
	set arcipelago2_OK;
run;

DATA arcipelago2_OK;/*27155*/
	set arcipelago2_OK;
	format 
		TRATTAMENTO_DEMENZE $NO_SI.
		iniziativa_domanda_val  $iniziativa_inserimento. 
		referente_org $referente.  		
	;
run;
%MEND; 


%macro finale2017;

proc sort data=arcipelago2;  by istres_in; run; 
proc sort data=comuni_per_merge; by istres_in; run; 
data arcipelago21; merge  arcipelago2 (in=a) comuni_per_merge (in=b); by istres_in; if a ; run; 
/*metto a 999 i soggetti con ulss di residenza fuori veneto*/
data arcipelago21; set arcipelago21; if ulss_a1_comuni =. then ulss_a1_comuni=999; run; 

data arcipelago21; set arcipelago21; drop ulss_a2 ulss_udo; run; 
data arcipelago21; set arcipelago21; rename ulss_a1_comuni = ulss_a2; run; 
data arcipelago21; set arcipelago21; if &anno ne . then ulss_udo=ulss_a2; run; 


data arcipelago21;
	set ARCIPELAGO21;
	keep 
	ULSS_A2
	ULSS_NEW
	ID_VALUTAZIONE
	CODICE_SOGGETTO_BIN
	ANNO_VAL
	ANNO_A2
	DIAGICPC1
	DIAGICPC2
	DIAGICPC3
	area_funzionale_num
	padl
	area_mobilita_num
	pmob
	area_cognitiva_num
	pcog
	AREA_DISTURBI_COMP
	SVAMA_RIS_DEC_VPIA_num
	SVAMA_ASS_INF_VIP_num
	SVAMA_POT_RES_VPOT_num
	NECESSITA_ASS_SAN_VSAN_num
	TS1DIABETE
	TS2SCOMPENSO
	TS3CIRROSI
	TS4TRACHEOSTOMIA
	TS5OSSIGENO
	TS6SONDINO
	TS7CATETERE_VENOSO
	TS8CATETERE_VESCICALE
	TS9ANO_ARTIF
	TS10NEFROSTOMIA
	TS11ULCERE
	TS12VENTILAZ
	TS13DIALISI
	TS14DOLORE
	TS15APPARECCHIATURE
	TS16NEOPLASIA
	SUPPORTO_RETE_SOCIALE
	PROFILO_AUTONOMIA
	punteggio_svama_num
	MOD_FINANZIAMENTO
	ALTERNATIVE_ISTIT
	GIORNI_ATTESA
	INIZIATIVA_DOMANDA_VAL
	MEDICO_DISTRETTO
	MMG
	PLS
	MEDICO_SPECIALISTA
	MEDICO_ESPERTO
	PSICOLOGO
	INFERMIERE
	FISIOTERA_LOGOPEDISTA
	ASS_SOC_ULS
	ASS_SOC_COMUNE
	ASS_SOC_ALTRO
	EDUCATORE_PROF
	TERAPISTA
	VOLONTARIATO
	OSS
	PERSONALE_AMMVO
	FAMILIARE
	ALTRO
	PROGETTO_ASS_PRINCIPALE
	PROGETTO_ASS_SECONDARIO
	REFERENTE_ORG
	INVALIDITA
	INDENNITA
	TRATTAMENTO_DEMENZE
	MPI_SVAMA_M
	MPI_SVAMA_Y
	SESSO
	ETA
	COD_UDO
	TIPO_UDO
	REG_ENTE_GES
	COD_COMUNE
	DESCRIZIONE
	ULSS_UDO
	;
run;

proc summary data=arcipelago21 ;
	class ULSS_a2;
	var punteggio_svama_num MPI_SVAMA_M MPI_SVAMA_Y;
	output out=y mean(punteggio_svama_num)=AVG_SVAMA_ULSS 
mean(MPI_SVAMA_M)=AVG_MPI_M_ULSS 
mean(MPI_SVAMA_Y)=AVG_MPI_Y_ULSS;
run;

PROC SORT DATA=arcipelago21;
	BY ULSS_A2;
RUN;/*27155*/

PROC SORT DATA=Y;
	BY ULSS_A2;
RUN;
/**/
data arcipelago3;
	MERGE arcipelago21 (in=a) Y (in=b);
	BY ULSS_A2;

	if a;
RUN;

DATA ARCIPELAGO3;
	SET ARCIPELAGO3;
	DROP _FREQ_ _TYPE_;
RUN;
/* Y_1 serve a tenere le medie regionali */ 
data y_1; set y; where _type_=0;  
run;

data Y_1; set Y_1; anno_a2=&anno; run;
data Y_1; set Y_1; rename avg_svama_ulss=avg_svama_reg
avg_mpi_m_ulss=avg_mpi_m_reg 
avg_mpi_y_ulss=avg_mpi_y_reg; 
run;
/* */ 
proc sort data=Y_1; by anno_a2; run; 
proc sort data=arcipelago3; by anno_a2; run; 

data arcipelago33; merge arcipelago3 (in=a) y_1(in=b); by anno_a2; if a ; run; 

DATA ARCIPELAGO2_OK;
	SET arcipelago33;
RUN;

data arcipelago2_ok; set arcipelago2_ok; drop _freq_ _type_ anno; run; 

data ARCIPELAGO2_OK;/**/
	retain 
		ULSS_A2
		ULSS_NEW
		ID_VALUTAZIONE
		CODICE_SOGGETTO_BIN
		ANNO_VAL
		ANNO_A2
		TIPO_VALUTAZIONE
		ETA 
		SESSO
		DIAGICPC1
		DIAGICPC2
		DIAGICPC3
		area_funzionale_num
		padl
		area_mobilita_num
		pmob
		area_cognitiva_num
		pcog
		AREA_DISTURBI_COMP
		SVAMA_RIS_DEC_VPIA_num
		SVAMA_ASS_INF_VIP_num
		SVAMA_POT_RES_VPOT_num
		NECESSITA_ASS_SAN_VSAN_num
		TS1DIABETE
		TS2SCOMPENSO
		TS3CIRROSI
		TS4TRACHEOSTOMIA
		TS5OSSIGENO
		TS6SONDINO
		TS7CATETERE_VENOSO
		TS8CATETERE_VESCICALE
		TS9ANO_ARTIF
		TS10NEFROSTOMIA
		TS11ULCERE
		TS12VENTILAZ
		TS13DIALISI
		TS14DOLORE
		TS15APPARECCHIATURE
		TS16NEOPLASIA
		SUPPORTO_RETE_SOCIALE
		PROFILO_AUTONOMIA
		punteggio_svama_num
		avg_svama_ULSS
		avg_svama_reg
		MOD_FINANZIAMENTO
		ALTERNATIVE_ISTIT
		GIORNI_ATTESA
		INIZIATIVA_DOMANDA_VAL
		MEDICO_DISTRETTO
		MMG
		PLS
		MEDICO_SPECIALISTA
		MEDICO_ESPERTO
		PSICOLOGO
		INFERMIERE
		FISIOTERA_LOGOPEDISTA
		ASS_SOC_ULS
		ASS_SOC_COMUNE
		ASS_SOC_ALTRO
		EDUCATORE_PROF
		TERAPISTA
		VOLONTARIATO
		OSS
		PERSONALE_AMMVO
		FAMILIARE
		ALTRO
		PROGETTO_ASS_PRINCIPALE
		PROGETTO_ASS_SECONDARIO
		REFERENTE_ORG
		INVALIDITA
		INDENNITA
		TRATTAMENTO_DEMENZE
		MPI_SVAMA_M
		AVG_MPI_M_ULSS
		AVG_MPI_M_REG
		MPI_SVAMA_Y
		AVG_MPI_Y_ULSS
		AVG_MPI_Y_REG
		SESSO
		ETA
		COD_UDO
		TIPO_UDO
		REG_ENTE_GES
		COD_COMUNE
		DESCRIZIONE
		ULSS_UDO
	;
	set arcipelago2_OK;
run;

DATA arcipelago2_OK;/*27155*/
	set arcipelago2_OK;
	format 
		TRATTAMENTO_DEMENZE $NO_SI.
		iniziativa_domanda_val  $iniziativa_inserimento. 
		referente_org $referente.  		
	;
run;



%MEND; 

/*esecuzione delle macro*/
%let anno=2016; /*anno di interesse*/
%let fase=12; /*fase di interesse*/

%SET_ANAGRAFICA_FAR;
%SET_ADT_FAR;
%SET_UDO;
%SET_VALUTAZIONI_FAR;

/*PER ACCODAMENTO DI PIù ANNI*/
/*ANNO 2016*/
%finale2016;
DATA TMP_2016; SET arcipelago2_OK; RUN; 

data tmp_2016;
	set tmp_2016;
	ulss_a2_num=input(ulss_a2, 3.);
	ulss_udo_num=input(ulss_udo, 3.);
	drop ulss_a2 ulss_udo;
	rename ulss_a2_num = ULSS_A2
		ulss_udo_num = ULSS_UDO;
run;

data tmp_2016;
retain
		ULSS_A2
		ULSS_NEW
		ID_VALUTAZIONE
		CODICE_SOGGETTO_BIN
		ANNO_VAL
		ANNO_A2
		TIPO_VALUTAZIONE
		ETA 
		SESSO
		DIAGICPC1
		DIAGICPC2
		DIAGICPC3
		area_funzionale_num
		padl
		area_mobilita_num
		pmob
		area_cognitiva_num
		pcog
		AREA_DISTURBI_COMP
		SVAMA_RIS_DEC_VPIA_num
		SVAMA_ASS_INF_VIP_num
		SVAMA_POT_RES_VPOT_num
		NECESSITA_ASS_SAN_VSAN_num
		TS1DIABETE
		TS2SCOMPENSO
		TS3CIRROSI
		TS4TRACHEOSTOMIA
		TS5OSSIGENO
		TS6SONDINO
		TS7CATETERE_VENOSO
		TS8CATETERE_VESCICALE
		TS9ANO_ARTIF
		TS10NEFROSTOMIA
		TS11ULCERE
		TS12VENTILAZ
		TS13DIALISI
		TS14DOLORE
		TS15APPARECCHIATURE
		TS16NEOPLASIA
		SUPPORTO_RETE_SOCIALE
		PROFILO_AUTONOMIA
		punteggio_svama_num
		avg_svama_ULSS
		avg_svama_reg
		MOD_FINANZIAMENTO
		ALTERNATIVE_ISTIT
		GIORNI_ATTESA
		INIZIATIVA_DOMANDA_VAL
		MEDICO_DISTRETTO
		MMG
		PLS
		MEDICO_SPECIALISTA
		MEDICO_ESPERTO
		PSICOLOGO
		INFERMIERE
		FISIOTERA_LOGOPEDISTA
		ASS_SOC_ULS
		ASS_SOC_COMUNE
		ASS_SOC_ALTRO
		EDUCATORE_PROF
		TERAPISTA
		VOLONTARIATO
		OSS
		PERSONALE_AMMVO
		FAMILIARE
		ALTRO
		PROGETTO_ASS_PRINCIPALE
		PROGETTO_ASS_SECONDARIO
		REFERENTE_ORG
		INVALIDITA
		INDENNITA
		TRATTAMENTO_DEMENZE
		MPI_SVAMA_M
		AVG_MPI_M_ULSS
		AVG_MPI_M_REG
		MPI_SVAMA_Y
		AVG_MPI_Y_ULSS
		AVG_MPI_Y_REG
		SESSO
		ETA
		COD_UDO
		TIPO_UDO
		REG_ENTE_GES
		COD_COMUNE
		DESCRIZIONE
		ULSS_UDO
	;
set tmp_2016;
run; 

%let anno=2018; /*anno di interesse*/
%let fase=7; /*fase di interesse*/

%SET_ANAGRAFICA_FAR;
%SET_ADT_FAR;
%SET_UDO;
%SET_VALUTAZIONI_FAR;

/*ANNO 2017 e successivi (modificato ulss_a2 e ulss_udo con l'ulss di residenza) */
%comuni; 
%finale2017;
DATA TMP_&anno; SET arcipelago2_OK; RUN; 
DATA TMP1_&anno; SET arcipelago2_OK; RUN; 


DATA ARCIPELAGO_002; SET TMP_2016 TMP_2017 TMP_2018 TMP1_&anno; RUN; 



/*manca il merge con la nuova tabella delle diagnosi ARCIPE.diagnosi*/
data diag; set ARCIPE.diagnosi; 
rename COD_DIAGNOSI_ICPC=DIAGICPC1; run; 
proc sort data=arcipelago_002; by DIAGICPC1; run; 
proc sort data=diag; by DIAGICPC1; run; 
data arcipelago_2_1; merge arcipelago_002 (in=a) diag (in=b); by DIAGICPC1; if a ;  run;
data arcipelago_2_1; set arcipelago_2_1; 
	rename categoria=categoria_icpc1 cod_desc=cod_desc_icpc1;
run;

data diag; set diag; 
rename DIAGICPC1=DIAGICPC2; run; 

proc sort data=arcipelago_2_1; by DIAGICPC2; run; 
proc sort data=diag; by DIAGICPC2; run; 

data arcipelago_2_2; merge arcipelago_2_1 (in=a) diag (in=b); by DIAGICPC2; if a ;  run;

proc sort data=arcipelago_2_1; by DIAGICPC2; run; 
proc sort data=diag; by DIAGICPC2; run; 

data arcipelago_2_2; merge arcipelago_2_1 (in=a) diag (in=b); by DIAGICPC2; if a ;  run;

data arcipelago_2_2; set arcipelago_2_2; 
	rename categoria=categoria_icpc2 cod_desc=cod_desc_icpc2;
run;

data diag; set diag; 
rename DIAGICPC2=DIAGICPC3; run; 

proc sort data=arcipelago_2_2; by DIAGICPC3; run; 
proc sort data=diag; by DIAGICPC3; run; 

data arcipelago_002_ok; merge arcipelago_2_2 (in=a) diag (in=b); by DIAGICPC3; if a ;  run;

data arcipelago_002_ok; set arcipelago_002_ok; 
	rename categoria=categoria_icpc3 cod_desc=cod_desc_icpc3;
run;



data arcipelago_002_ok; set arcipelago_002_ok;
if tipo_udo eq . then tipo_udo='0'; 
run; 


data arcipelago_002_ok; 
set arcipelago_002_ok;
format tipo_udo $tipoudo_far.; 
run; 

/*aggiungo variabile ULSS_UDO_NEW*/
data arcipelago_002_ok; 
set arcipelago_002_ok;
	if ulss_udo= 101  THEN ULSS_UDO_NEW=501;
	if ulss_udo= 102  THEN ULSS_UDO_NEW=501;
	if ulss_udo= 109  THEN ULSS_UDO_NEW=502;
	if ulss_udo= 107  THEN ULSS_UDO_NEW=502;
	if ulss_udo= 108  THEN ULSS_UDO_NEW=502;
	if ulss_udo= 112  THEN ULSS_UDO_NEW=503;
	if ulss_udo= 113  THEN ULSS_UDO_NEW=503;
	if ulss_udo= 114  THEN ULSS_UDO_NEW=503;
	if ulss_udo= 110  THEN ULSS_UDO_NEW=504;
	if ulss_udo= 118  THEN ULSS_UDO_NEW=505;
	if ulss_udo= 119  THEN ULSS_UDO_NEW=505;
	if ulss_udo= 115  THEN ULSS_UDO_NEW=506;
	if ulss_udo= 116  THEN ULSS_UDO_NEW=506;
	if ulss_udo= 117  THEN ULSS_UDO_NEW=506;
	if ulss_udo= 103  THEN ULSS_UDO_NEW=507;
	if ulss_udo= 104  THEN ULSS_UDO_NEW=507;
	if ulss_udo= 106  THEN ULSS_UDO_NEW=508;
	if ulss_udo= 105  THEN ULSS_UDO_NEW=508;
	if ulss_udo= 120  THEN ULSS_UDO_NEW=509;
	if ulss_udo= 121  THEN ULSS_UDO_NEW=509;
	if ulss_udo= 122  THEN ULSS_UDO_NEW=509;
	if ULSS_UDO= 501  then ULSS_UDO_NEW= 501 ;
	if ULSS_UDO= 502  then ULSS_UDO_NEW= 502 ;
	if ULSS_UDO= 503  then ULSS_UDO_NEW= 503 ;
	if ULSS_UDO= 504  then ULSS_UDO_NEW= 504 ;
	if ULSS_UDO= 505  then ULSS_UDO_NEW= 505 ;
	if ULSS_UDO= 506  then ULSS_UDO_NEW= 506 ;
	if ULSS_UDO= 507  then ULSS_UDO_NEW= 507 ;
	if ULSS_UDO= 508  then ULSS_UDO_NEW= 508 ;
	if ULSS_UDO= 509  then ULSS_UDO_NEW= 509 ;
run; 
/*PER IL MOMENTO METTO ZERO SE NON CALCOLO GIORNI ATTESA E PUNTEGGIO SVAMA */
data arcipelago_002_ok; 
set arcipelago_002_ok;
IF GIORNI_ATTESA =. THEN GIORNI_ATTESA =0;
IF punteggio_svama_num=. THEN PUNTEGGIO_SVAMA_NUM=0;
IF ULSS_UDO=. THEN ULSS_UDO=999; 
IF ULSS_UDO_new=. THEN ULSS_UDO_new=999;
IF eta=. THEN eta=0; 
if mpi_svama_m=. then mpi_svama_m=0; 
if mpi_svama_y=. then mpi_svama_y=0; 
RUN; 


/*proc freq data=arcipelago_002_ok; table tipo_udo; run; 
proc freq data=arcipelago_002_ok; table ULSS_UDO; run;
proc print data=arcipelago_002_ok; var cod_udo ulss_udo ; where ulss_udo = .; run; 

per esportare faccio tre tabelle perché Arcipelago va in timeout*/
/*proc freq data=arcipelago_002_ok; table anno_a2; run; */
%let today=%sysfunc(today(),yymmddn8.);
%put &today.;

data TAB_002_2016_&today.; set arcipelago_002_ok; where anno_a2=2016; run; 
data TAB_002_2017_&today.; set arcipelago_002_ok; where anno_a2=2017; run; 
data TAB_002_2018_&today.; set arcipelago_002_ok; where anno_a2=2018; run; 


/*eof*/
