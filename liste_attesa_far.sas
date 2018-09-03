/*
elaborazioni dati liste d'attesa FAR
marco.braggion@azero.veneto.it
*/
%let anno=2018;
%let fase=7;

%include '/sasprd/staging/staging_san1/S1_ORPSS/config/MACRO_ORPSS/comandi_orpss.sas' ;

/*CHECK SU FLERRORA

proc sql;
	create table anagrafica_liste_attesa as
	select *
	from FLERRORA.FAR_WEB_ERRORI_A1_ANAGRAFICO
	where (anno=&anno and fase =&fase and flg_tipo_utente='7');
quit;

proc sql;
	create table val_liste_attesa as
	select *
	from FLERRORA.FAR_WEB_ERRORI_A2_VALUTAZIONE
	where (anno=&anno and fase =&fase);
quit;

/*query dalle DEF*/

proc sql;
	create table ANA_LISTE_ATTESA as
	select *
	from dwhodd.ODD_FAR_UNI_A1_DEF
	where (anno=&anno and fase =&fase and flg_tipo_utente='7');
quit;

/*proc freq data = ANA_LISTE_ATTESA; table flg_tipo_utente; run; 

/* attacco le valutazioni (tengo solo le uvmd)*/

proc sql;
	create table v as
	select *
	from dwhodd.ODD_FAR_UNI_A2_DEF
	where (anno=&anno and fase =&fase);
quit;

data v;
	set v;
	parte_intera_svama=substr(punteggio_svama, 1, 3);
	parte_decimale_svama=substr(punteggio_svama, 5, 2);
	i=input(parte_intera_svama, best3.);
	d=input(parte_decimale_svama, best2.);
	punteggio_svama_num=i+((d)/100);
	format  
		progetto_ass_principale progetto_ass_secondario $progetto_ass.;
run;

data uvmd; set v; where tipo_valutazione='1'; run;  

%inner(ANA_LISTE_ATTESA,uvmd, id_assistito, out); 

/* verifico che i soggetti siano vivi con link su anagrafe regionale */

data out;
	set out;
	rename codice_soggetto_bin=codice_soggetto anno=annofar data_nascita=data_nascita_far;
run;

data out; set out; drop 
FLG_CHK_CODICE_FISCALE 
FLG_CHK_CODICE_SSN 
FLG_CHK_COGNOME_E_NOME 
FLG_CHIAVE_LINK_CODICE_UNICO 
FLG_CHK_DATI_ANAG_CONGRUENTI; 
run;  

/*seleziono i morti dall'anagrafe regionale*/
proc sql;
	create table morti_ana as
	select *
	from dwhbt.ANAG_BTDETT_ASSISTITI_AUR
	where data_decesso ne . ;
quit;

%left_outer(out,morti_ana, CODICE_SOGGETTO, out1); 

/*tolgo i morti*/

data out1; set out1; if data_decesso ne . then delete; run; 

/*aggiungo i formati alle date*/

data out1;
	set out1;
	DATA_VALUTAZIONE_TEMP=input(DATA_VALUTAZIONE,ddmmyy8.);
	DATA_DOMANDA_TEMP=input(DATA_DOMANDA,ddmmyy8.);
	DATA_VERIFICA_TEMP=input(DATA_VERIFICA,ddmmyy8.);
	format DATA_VALUTAZIONE_TEMP DATA_DOMANDA_TEMP DATA_VERIFICA_TEMP date9.;
	drop DATA_VALUTAZIONE DATA_DOMANDA DATA_VERIFICA;
	rename DATA_VALUTAZIONE_TEMP = data_valutazione
	data_domanda_temp = data_domanda
	data_verifica_temp = data_verifica; 
	DATANASC_TEMP=input(DATA_NASCITA_far,ddmmyy8.);
	DATA_CAMBIO_RES_TEMP=input(DATA_CAMBIO_RES,ddmmyy8.);
	format DATANASC_TEMP DATA_CAMBIO_RES_TEMP date9.;
	drop DATA_NASCITA_far DATA_CAMBIO_RES;
	rename datanasc_temp = dob data_cambio_res_temp = data_cambio_res; 
run;




/*costruisco variabile giorni_attesa
rappresenta la differenza fra la fine del mese di scarico dei dati e 
la data di valutazione, cioè quanto stanno in lista d'attesa gli utenti*/
data out1;
  set out1;
	IF ( &fase in (1,3,5,7,8,10,12) ) 		THEN giorni_mese	=	31;
	IF ( &fase in (4,6,9,11) ) 				THEN giorni_mese	= 	30;	
	IF ( (mod(&anno,4)=0) and &fase = 2)	THEN giorni_mese 	= 	29;
	IF ( (mod(&anno,4) ne 0) and &fase = 2) THEN giorni_mese 	= 	28;

data_conteggio=mdy(&fase, giorni_mese, &anno);
  format data_conteggio date9.;
run;
data out1; set out1; giorni_attesa =  data_conteggio - data_valutazione ; run; 

/*genero la variabile classe_giorni_attesa  */
data out1; set out1;
if 0 	<= giorni_attesa	<=	30 then classe_gg_attesa	= 	'1'; /*1 mese*/
if 31 	<= giorni_attesa	<=	60 then classe_gg_attesa	= 	'2'; /*2 mesi*/
if 61	<= giorni_attesa	<=	180 then classe_gg_attesa	= 	'3'; /*3-6 mesi*/
if 181	<= giorni_attesa	<=	366 then classe_gg_attesa	= 	'4'; /*7-12 mesi*/
if giorni_attesa	>=	367 then classe_gg_attesa	= 	'5'; /*>12 mesi*/
format classe_gg_attesa $classe_liste_attesa.; 
run; 

/*seleziono solo le prime valutazioni*/
proc sort data=out1; by codice_soggetto data_valutazione; run; 
data out1; set out1; 
BY codice_soggetto;
 IF FIRST.codice_soggetto THEN conteggio_val=1;ELSE conteggio_val+1;
RUN; 
data prime_valutazioni; set out1; where conteggio_val=1; run; 

/*genero i cutpoint per i quartili dei giorni di attesa/*
%quart(prime_valutazioni, giorni_attesa, giorni_attesa_quart); 
%quart(prime_valutazioni, punteggio_svama_num, svama_quart);

/*definisco il dataset prime_valutazioni_cod per calcolare i quartili di ogni ulss
si può passare un vettore????? per farle tutte in un colpo?*/
%let cod=505;
data prime_valutazioni_&cod; set prime_valutazioni; where cod_ente = "&cod"; run;  
%quart(prime_valutazioni_&cod, giorni_attesa, giorni_attesa_quart_&cod); 
%quart(prime_valutazioni_&cod, punteggio_svama_num, svama_quart_&cod);

/* test to make sure it worked */
proc means data=prime_valutazioni missing;
class giorni_attesa_quart;
var giorni_attesa;
run;
proc means data=prime_valutazioni missing;
class svama_quart;
var punteggio_svama_num;
run;

proc freq data=prime_valutazioni; table giorni_attesa_quart; run; 

/****************************************************************/
/*
/* 		Indicatori Allegato A DDR 69/2018
/*
/****************************************************************/
/*
/* 1. 	Numero complessivo di utenti presenti in lista d'attesa 
/* 	  	nella fase selezionata 
/*
/****************************************************************/
proc sort data=out1 nodupkey out=teste; by codice_soggetto; run; 
proc freq data=teste; table cod_ente; run; 
/****************************************************************/
/*
/* 2.1 	Numero di utenti per classi di durata (prime valutazioni) 
/*
/****************************************************************/
proc freq data=prime_valutazioni;
	table classe_gg_attesa * cod_ente /norow nocol nopercent;
run;
/****************************************************************/
/*
/* 2.2 	Numero di utenti per tipologia di offerta programmata.
/*   	Progetto assistenziale principale 
/*    	(prime valutazioni) 
/*
/****************************************************************/
proc freq data=prime_valutazioni;
	table PROGETTO_ASS_PRINCIPALE * cod_ente /norow nocol nopercent;
run;
/****************************************************************/
/*
/* 2.3 	Numero di utenti per tipologia di offerta programmata.
/*   	Progetto assistenziale secondario 
/*    	(prime valutazioni) 
/*
/****************************************************************/
proc freq data=prime_valutazioni;
	table PROGETTO_ASS_SECONDARIO * cod_ente /norow nocol nopercent;
run;
/****************************************************************/
/*
/* 3.1 	Distribuzione dei quartili dei tempi di attesa  
/*    	(prime valutazioni) 
/*
/****************************************************************/
proc summary data=prime_valutazioni missing ;
class giorni_attesa_quart;
var giorni_attesa;
	output out=quartili_giorni (drop = _type_) 
min(giorni_attesa)=min_quartile max(giorni_attesa)=max_quartile;
run;

proc summary data=prime_valutazioni_&cod missing ;
class giorni_attesa_quart;
var giorni_attesa;
	output out=quartili_giorni_&cod (drop = _type_) 
min(giorni_attesa)=min_quartile max(giorni_attesa)=max_quartile;
run;

/*
proc summary data=prime_valutazioni;
	var giorni_attesa ;
	output out=quartili_giorni (drop = _type_) 
	q1(giorni_attesa)		=	IQ_attesa
	median(giorni_attesa)	=	Mediana_attesa
	q3(giorni_attesa)		=	IIIQ_attesa	
;
run;
/****************************************************************/
/*
/* 3.2 	Distribuzione dei quartili del punteggio svama  
/*    	(prime valutazioni) 
/*
/****************************************************************/
proc means data=prime_valutazioni missing nway;
class svama_quart ;
var punteggio_svama_num;
	output out=quartili_svama (drop = _type_) 
min(punteggio_svama_num)=min_quartile max(punteggio_svama_num)=max_quartile;
run;


proc means data=prime_valutazioni_&cod missing nway;
class svama_quart ;
var punteggio_svama_num;
	output out=quartili_svama_&cod (drop = _type_) 
min(punteggio_svama_num)=min_quartile max(punteggio_svama_num)=max_quartile;
run;

