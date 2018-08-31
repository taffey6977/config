/*																		*/
/* Descrittive Cristina settembre 2018									*/
/*																		*/
/* 																		*/
%include '/sasprd/staging/staging_san1/S1_ORPSS/config/MACRO_ORPSS/caced_anagrafica.sas' ;
%include '/sasprd/staging/staging_san1/S1_ORPSS/config/MACRO_ORPSS/caced_cdc.sas' ;
%include '/sasprd/staging/staging_san1/S1_ORPSS/config/MACRO_ORPSS/caced_episodi_cura.sas' ;
%include '/sasprd/staging/staging_san1/S1_ORPSS/config/MACRO_ORPSS/comandi_orpss.sas' ;

%LET ANNO_a='2018'; 	/*anno anagrafica e struttura*/
%LET ANNO_EPI='2018'; 	/*anno episodio di cura*/
%LET FASE='6';			/*fase */
%let anno_eta=2018; 	/*mi serve per definire l'anno per calcolare l'età (anno caricamento file)*/
%let mese_eta=6; 		/*mi serve per definire il mese per calcolare l'età (mese caricamento file)*/

%import_ana_cacedem(anno_a, fase);
%import_cdc(anno_a, fase);
%import_episodi(anno_epi, fase);

/*	per eliminare eventualmente i record errati: 
/*
/*	tracciato anagrafica utenti*/
/*	proc freq data=anagrafica_caced; table flag_errore_a1; run; */
data ANAGRAFICA_CACED; set ANAGRAFICA_CACED; where flag_errore_a1 ne 'S'; run; 
/*
/*	tracciato anagrafica strutture*/
/*	proc freq data=CDC; table flag_errore_b1; run; */
data CDC; set CDC; where flag_errore_b1 ne 'S'; run; 
/*
/*	tracciato episodi di cura*/
/*	proc freq data=EPISODI_CURA; table flag_errore_c1; run; */
data EPISODI_CURA; set EPISODI_CURA; where flag_errore_c1 ne 'S'; run; 


data a_2018; set anagrafica_caced; run; 
data a_2017; set anagrafica_caced; run; 
data a_2016; set anagrafica_caced; run; 
Data a ; set a_2018 a_2017 a_2016; run; 

data e_2018; set episodi_cura; run; 
data e_2017; set episodi_cura; run; 
data e_2016; set episodi_cura; run; 
Data e ; set e_2018 e_2017 e_2016; run; 
/*tolgo i duplicati per stesso codice_soggetto_bin e stessa data di visita*/
proc sort data=e out=e1 nodupkey ; by codice_soggetto_bin data_cura  ; run; 


/*seleziono i morti dall'anagrafe regionale*/
proc sql;
	create table morti_aur as
	select *
	from dwhbt.ANAG_BTDETT_ASSISTITI_AUR
	where data_decesso ne . ;
quit;

data morti_aur; set morti_aur (keep= codice_soggetto data_decesso ) ; run; 
data morti_aur; set morti_aur (rename=(codice_soggetto=codice_soggetto_bin data_decesso=data_decesso_aur));run; 

%left_outer(a,morti_aur, CODICE_SOGGETTO_bin, out1); 
proc freq data=out1; table data_decesso_aur; run; /*non ce ne sono*/




/***********************************************************/
data a;
	set a;
	DOD=INPUT(data_decesso,DDMMYY8.);
	FORMAT DOD  DATE9.;
run;

/*calcolo eta al giorno di caricamento dei dati per l'anno in corso 
e al 31/12 per gli anni chiusi 
*/
data a; set a; 
anno_num=input(anno, 4.);
run; 

DATA a;
	SET a;

	IF ( &mese_eta in (1,3,5,7,8,10,12) ) THEN
		giorno_eta=31;

	IF ( &mese_eta in (4,6,9,11) ) THEN
		giorno_eta=30;

	IF ( (mod(&anno_eta,4) eq 0) and &mese_eta = 2) THEN
		giorno_eta=29;

	IF ( (mod(&anno_eta,4) ne 0) and &mese_eta = 2) THEN
		giorno_eta=28;
run;

data a ; set a; 
	if (anno_num < &anno_eta) then eta_flag=1; else eta_flag=0; run; 

data a;
	set a;

	if dod ne . then
		do;
			eta = int((dod-DATA_NASCITA)/365.25);
		end;
	else
		do;
			if eta_flag =1 and dod eq . then
				eta = int(((mdy(12,31,anno_num)-DATA_NASCITA)/365.25));
			else eta=int(((mdy(&mese_eta,giorno_eta,&anno_eta)-DATA_NASCITA)/365.25));
		end;
run;

/********************************/
/* tolgo i soggetti con eta <30 */
/********************************/
data a; set a; where eta >=30; run; 

/*definisco le classi d'età*/
DATA A;
	SET A;

	if 30<=eta<=59 then
		ageclass=1;

	if 60<=eta<=64 then
		ageclass=2;

	if 65<=eta<=74 then
		ageclass=3;

	if 75<=eta<=84 then
		ageclass=4;

	if 85<=eta<=90 then
		ageclass=5;

	if eta>=90 then
		ageclass=6;
run;

proc format;
	value ageclass 
		1='30-59'
		2='60-64'
		3='65-74'
		4='75-84'
		5='85-90'
		6='Over 90';
RUN;

data a;
	set a;
	format ageclass ageclass.;
run;

PROC FREQ DATA=A;TABLE eta ageclass ;RUN;

/*proc sort data=a; by codice_soggetto_bin; run; 
proc sort data=a; by id_assistito; run;

/*occhio che per contare le teste devo togliere i duplicati
anche nel tracciato anagrafico vengono duplicati i record a seconda di 
quante visite effettuano nell'anno di riferimento 
la chiave è per codice soggetto e anno*/
PROC SORT NODUPKEY DATA=a OUT=NO_DUPL_PIC2;
	BY codice_soggetto_bin anno;
RUN;


/*
devo togliere dalle visite i soggetti più giovani di 30 anni
*/
proc sort data=a out=unici (keep=codice_soggetto_bin); 
by codice_soggetto_bin;
run;

%inner(e,unici,codice_soggetto_bin,e_over30); 



/* Tabella 1*/
/* Frequenza assoluta dei soggetti per anno*/
proc freq data=no_dupl_pic2; table anno; run; 
/*	
/* conto le PIC/visite*/
/* tolgo quelli che hanno pic duplicata per data di cura*/
proc sort data=e_over30 out=e2 nodupkey;
	by codice_soggetto_bin data_cura;
run;
proc freq data=e2; table tipo_cura * anno /norow nopercent nocol; run; 
/*
/* genere*/
proc freq data=no_dupl_pic2; table sesso * anno /norow nopercent nocol; run; 
/* eta alla prima visita castare a numero*/
data no_dupl_pic2; set no_dupl_pic2;
eta_prima_visita_num=input(eta_prima_visita, 3.); 
run; 

proc summary data=no_dupl_pic2 nway;
class anno ;
var eta_prima_visita_num ;
output out=eta_prima_visita_caced (drop = _type_ _freq_) mean=media  std=ds;
run; 
/*
/* classi d'età
/**/
PROC FREQ DATA=no_dupl_pic2;TABLE  ageclass * anno /norow nopercent nocol;RUN;
/*
calcolo la distanza in giorni fra una visita e l'altra
*/
proc sort data=e2;
	by codice_soggetto_bin descending data_cura;
run;

data tempo_visite;
	set e2 (keep= codice_soggetto_bin data_cura anno);
run;
/*
PROC TRANSPOSE DATA=tempo_visite OUT=p;
	BY codice_soggetto_bin;
	VAR data_cura;
RUN;
*/
proc sort data=tempo_visite;
	by codice_soggetto_bin data_cura;
run;

data lag_difg;
	set tempo_visite;
	by codice_soggetto_bin data_cura;
	days_dif = dif(data_cura);

	if  first.codice_soggetto_bin then
		do;
			days_dif=.;
		end;
run;

data ff; set lag_difg; where days_dif ne . ; run; 
proc summary data=ff ;
class anno ;
var days_dif ;
output out=gi  mean=media  std=ds;
run; 

data gi; set gi; mesi=media/30.25; ds_mesi=ds/30.25; run; 
/********************/
/* 	Tabella 2 
	Diagnosi
/********************/

/* prendo l'ultima visita in ordine cronologico 
 (db e2)
*/

proc sort data=e2 ; by codice_soggetto_bin descending data_cura; run; 
data e2; set e2;
by codice_soggetto_bin;
if first.codice_soggetto_bin then num_visita=1 ; else num_visita+1; 
run;


data ultima_visita; set e2; where num_visita=1; run; 


proc freq data=ultima_visita; table 
(
COD_ICD9_AD
COD_ICD9_PCA
COD_ICD9_DLB
COD_ICD9_PSP
COD_ICD9_CBD
COD_ICD9_FTLDC
COD_ICD9_SD
COD_ICD9_PAA
COD_ICD9_AF_LOGOPENICA
COD_ICD9_ATROFIA_MULTI
COD_ICD9_ATROFIA_MULTI_P
COD_ICD9_ATROFIA_MULTI_C
COD_ICD9_ATROFIA_NONSPEC
COD_ICD9_PD
COD_ICD9_PDD
COD_ICD9_VD
COD_ICD9_MD
COD_ICD9_NPH
COD_ICD9_HC
COD_ICD9_CJD
COD_ICD9_UMORE_ALTRO
COD_ICD9_APERTO_ALTRO1
COD_ICD9_APERTO_ALTRO2
COD_ICD9_APERTO_ALTRO3
COD_ICD9_APERTO_ALTRO4
COD_ICD9_APERTO_ALTRO5
COD_ICD9_APERTO_ALTRO6
COD_ICD9_APERTO_ALTRO7
) * anno /norow nopercent nocol

; run; 

/*proc contents data=ultima_visita order=varnum; run;*/
/*
quanti soggetti hanno avuto più di una diagnosi?
*/

proc freq data=ultima_visita; table anno; run; 

data ultima_visita; set ultima_visita; 
if COD_ICD9_AD ne .  then ynAD =1;	else ynAD = 0; 
if COD_ICD9_PCA ne .  then ynPCA =1;	else ynPCA = 0; 
if COD_ICD9_DLB ne .  then ynDLB =1;	else ynDLB = 0; 
if COD_ICD9_PSP ne .  then ynPSP =1;	else ynPSP = 0; 
if COD_ICD9_CBD ne .  then ynCBD =1;	else ynCBD = 0; 
if COD_ICD9_FTLDC ne .  then ynFTLDC =1;	else ynFTLDC = 0; 
if COD_ICD9_SD ne .  then ynSD =1;	else ynSD = 0; 
if COD_ICD9_PAA ne .  then ynPAA =1;	else ynPAA = 0; 
if COD_ICD9_AF_LOGOPENICA ne .  then ynAF_LOGOPENICA =1;	else ynAF_LOGOPENICA = 0; 
if COD_ICD9_ATROFIA_MULTI ne .  then ynATROFIA_MULTI =1;	else ynATROFIA_MULTI = 0; 
if COD_ICD9_ATROFIA_MULTI_P ne .  then ynATROFIA_MULTI_P =1;	else ynATROFIA_MULTI_P = 0; 
if COD_ICD9_ATROFIA_MULTI_C ne .  then ynATROFIA_MULTI_C =1;	else ynATROFIA_MULTI_C = 0; 
if COD_ICD9_ATROFIA_NONSPEC ne .  then ynATROFIA_NONSPEC =1;	else ynATROFIA_NONSPEC = 0; 
if COD_ICD9_PD ne .  then ynPD =1;	else ynPD = 0; 
if COD_ICD9_PDD ne .  then ynPDD =1;	else ynPDD = 0; 
if COD_ICD9_VD ne .  then ynVD =1;	else ynVD = 0; 
if COD_ICD9_MD ne .  then ynMD =1;	else ynMD = 0; 
if COD_ICD9_NPH ne .  then ynNPH =1;	else ynNPH = 0; 
if COD_ICD9_HC ne .  then ynHC =1;	else ynHC = 0; 
if COD_ICD9_CJD ne .  then ynCJD =1;	else ynCJD = 0; 
if COD_ICD9_UMORE_ALTRO ne .  then ynUMORE_ALTRO =1;	else ynUMORE_ALTRO = 0; 
if COD_ICD9_APERTO_ALTRO1 ne .  then ynAPERTO_ALTRO1 =1;	else ynAPERTO_ALTRO1 = 0; 
if COD_ICD9_APERTO_ALTRO2 ne .  then ynAPERTO_ALTRO2 =1;	else ynAPERTO_ALTRO2 = 0; 
if COD_ICD9_APERTO_ALTRO3 ne .  then ynAPERTO_ALTRO3 =1;	else ynAPERTO_ALTRO3 = 0; 
if COD_ICD9_APERTO_ALTRO4 ne .  then ynAPERTO_ALTRO4 =1;	else ynAPERTO_ALTRO4 = 0; 
if COD_ICD9_APERTO_ALTRO5 ne .  then ynAPERTO_ALTRO5 =1;	else ynAPERTO_ALTRO5 = 0; 
if COD_ICD9_APERTO_ALTRO6 ne .  then ynAPERTO_ALTRO6 =1;	else ynAPERTO_ALTRO6 = 0; 
if COD_ICD9_APERTO_ALTRO7 ne .  then ynAPERTO_ALTRO7 =1;	else ynAPERTO_ALTRO7 = 0; 
run; 

data ultima_visita;set ultima_visita; 
somma_diagnosi=
ynAD+
ynPCA+
ynDLB+
ynPSP+
ynCBD+
ynFTLDC+
ynSD+
ynPAA+
ynAF_LOGOPENICA+
ynATROFIA_MULTI+
ynATROFIA_MULTI_P+
ynATROFIA_MULTI_C+
ynATROFIA_NONSPEC+
ynPD+
ynPDD+
ynVD+
ynMD+
ynNPH+
ynHC+
ynCJD+
ynUMORE_ALTRO+
ynAPERTO_ALTRO1+
ynAPERTO_ALTRO2+
ynAPERTO_ALTRO3+
ynAPERTO_ALTRO4+
ynAPERTO_ALTRO5+
ynAPERTO_ALTRO6+
ynAPERTO_ALTRO7;
run; 

proc freq data=ultima_visita; table somma_diagnosi * anno /norow nocol nopercent; run; 


/* definisco le classi del punteggio mmse */
proc freq data=ultima_visita ; table mmse_num; run; 
DATA ultima_visita;
	SET ultima_visita;

	if 0 <= mmse_num < 10 then
		mmseclass=1;

	if 10 <= mmse_num < 19 then
		mmseclass=2;

	if 19 <= mmse_num < 24 then
		mmseclass=3;

	if 24 <= mmse_num <26 then
		mmseclass=4;

	if mmse_num = 26 then
		mmseclass=5;

	if mmse_num > 26 then
		mmseclass=6;
run;

proc format;
	value mmseclass 
		1='< 10'
		2='10-18'
		3='19-23'
		4='24-25'
		5='26'
		6='>=27';
RUN;

data ultima_visita;
	set ultima_visita;
	format mmseclass mmseclass.;
run;

proc freq data=ultima_visita; table mmseclass *anno /norow nopercent nocol; run; 

/* ADL 
AUTONOMI <=3/6 autonomia_adl=1
NON AUTONOMI <=4/6 autonomia_adl=0
*/

data ultima_visita; set ultima_visita;
funzioni_perse_adl = input(substr(punteggio_adl,1,1), 1.);
funzioni_perse_iadl = input(substr(punteggio_iadl,1,1), 1.);
funzioni_misurate_iadl = input(substr(punteggio_iadl,3,1), 1.);
run; 

data ultima_visita; set ultima_visita;
if funzioni_perse_adl in (0,1,2,3) 	then autonomia_adl=1; 
if funzioni_perse_adl in (4,5,6)	then autonomia_adl=0;
/*iadl femmine*/
if funzioni_perse_iadl in (0 1 2 3 4) and funzioni_misurate_iadl eq 8	then autonomia_iadl=1; 
if funzioni_perse_iadl in (5 6 7 8 ) and funzioni_misurate_iadl eq 8	then autonomia_iadl=0; 
/*iadl maschi*/
if funzioni_perse_iadl in (0,1,2,3) and funzioni_misurate_iadl eq 5	then autonomia_iadl=1; 
if funzioni_perse_iadl in (4 5 ) and funzioni_misurate_iadl eq 5	then autonomia_iadl=0; 
run; 

proc freq data=ultima_visita; 
	table (autonomia_adl autonomia_iadl)* anno /norow nocol nopercent;
run;

proc sort data=ultima_visita; by anno; run; 
proc freq data=ultima_visita; by anno;
	table ( autonomia_iadl)* funzioni_misurate_iadl  /norow nocol nopercent;
run;


proc tabulate data=ultima_visita;
class funzioni_misurate_iadl anno autonomia_iadl;
var anno ;
	table  anno  , N * funzioni_misurate_iadl * (autonomia_iadl);
run;

proc freq data=ultima_visita; 
	table (punteggio_npi_icdm)* anno /norow nocol nopercent;
run;

/* 
	Tabella 3 
  	Farmaci
*/

/*antipsicotici atipici*/

proc freq data=ultima_visita; 
	table (presc_farmaci_atipici)* anno /norow nocol nopercent;
run;

/*antipsicotici tipici*/

proc freq data=ultima_visita; 
	table (presc_farmaci_tipici)* anno /norow nocol nopercent;
run;

/* prescrizione anticolinesterasico*/
proc freq data=ultima_visita; 
	table (PRESCR_ANTICOLIN)* anno /norow nocol nopercent;
run;

/* prescrizione anticolinesterasico*/
proc freq data=ultima_visita; 
	table (tipo_anticolinestr)* anno /norow nocol nopercent;
run;

/* prescrizione memantina*/
proc freq data=ultima_visita; 
	table (prescr_memantina)* anno /norow nocol nopercent;
run;




/*
*
trash below*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*

*/
/*l'unità statistica del flusso è il codice_soggetto + presa in carico
 
PROC SORT NODUPKEY DATA=a OUT=NO_DUPL_PIC2;BY codice_soggetto_bin id_assistito;RUN; 
data a; set a; K=CATS(CODICE_SOGGETTO_BIN, ID_ASSISTITO); RUN; 
PROC SORT NODUPKEY DATA=a OUT=NOD;BY K;RUN; 

data b; set a; where codice_soggetto_bin='3030323743353637'; run; 
*/


/*per prendere l'ultima presa in carico:*/
data a; set a ; 
id_num1=input(id_assistito, 11.);
run; 
proc sort data=a; by codice_soggetto_bin descending id_num1; run; 
data a;
set a;
 BY codice_soggetto_bin;
 IF FIRST.codice_soggetto_bin THEN PROGRESSIVO1=1;ELSE PROGRESSIVO1+1;
RUN;
/*prendo quelli che hanno progressivo più alto (caricati dopo)*/
data anagrafica_piu_recente; set a ; where progressivo1=1; run; 

proc freq data= anagrafica_piu_recente;
table
sesso
scolarita
stato_civile
eta_prima_visita
eta_sintomi
professione
pensionato
caregiver
relaz_careg
coab_careg
cod_comune_res
cod_comune_dom
; run;

proc print data=a; var  flag_errore_a1 cod_comune_dom ; 
where length(cod_comune_d'2018'om) ne 6; run;  

proc print data=a; var  flag_errore_a1 cod_comune_res ; 
where length(cod_comune_res) ne 6; run;  


proc freq data=a; table data_decesso; run; 
proc print data=a; var  flag_errore_a1 data_decesso ; 
where length(data_decesso) ne 8 and data_decesso ne '' ; run;  

/*tracciato 2 */
data CDC; set CDC; where flag_errore_b1 ne 'S'; run; 
PROC PRINT DATA=CDC; var az_sanitaria Flag_errore_b1; where AZ_SANITARIA=''; run; 

PROC PRINT DATA=CDC; var cod_comune_istat Flag_errore_b1;where length(cod_comune_istat)<6; run; 

/*tracciato 3 */
data EPISODI_CURA; set EPISODI_CURA; where flag_errore_c1 ne 'S'; run; 

proc sort data=EPISODI_CURA; by id_cdc; run; 
proc sort data=cdc; by id_cdc; run; 
data db3;
merge EPISODI_CURA (in=a)  cdc (in=b);
if a; 
by id_cdc;
run;
proc sort data=db3; by codice_unico_bin; run; /*qui si vede che mancano dei codici cdc*/

proc freq data=EPISODI_CURA; table 
COD_ICD9_AD
COD_ICD9_PCA
COD_ICD9_DLB
COD_ICD9_PSP
COD_ICD9_CBD
COD_ICD9_FTLDC
COD_ICD9_SD
COD_ICD9_PAA
COD_ICD9_AF_LOGOPENICA
COD_ICD9_ATROFIA_MULTI
COD_ICD9_ATROFIA_MULTI_P
COD_ICD9_ATROFIA_MULTI_C
COD_ICD9_ATROFIA_NONSPEC
COD_ICD9_PD
COD_ICD9_PDD
COD_ICD9_VD
COD_ICD9_MD
COD_ICD9_NPH
COD_ICD9_HC
COD_ICD9_CJD
COD_ICD9_UMORE_ALTRO
COD_ICD9_APERTO_ALTRO1
COD_ICD9_APERTO_ALTRO2
COD_ICD9_APERTO_ALTRO3
COD_ICD9_APERTO_ALTRO4
COD_ICD9_APERTO_ALTRO5
COD_ICD9_APERTO_ALTRO6
COD_ICD9_APERTO_ALTRO7; run; 

/*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*/
/*descrittive per cristina*/
data solo_eta; set anagrafica_piu_recente ; keep codice_unico_bin eta; run;
%left_outer(EPISODI_CURA, solo_eta, codice_unico_bin, prova); 
data under65; set prova; where eta <=65; run; 
data under65; set under65; if eta = . then delete; run ; /*432*/
proc freq data=under65; table 
altro_demenza
COD_ICD9_AD
COD_ICD9_PCA
COD_ICD9_DLB
COD_ICD9_PSP
COD_ICD9_CBD
COD_ICD9_FTLDC
COD_ICD9_SD
COD_ICD9_PAA
COD_ICD9_AF_LOGOPENICA
COD_ICD9_ATROFIA_MULTI
COD_ICD9_ATROFIA_MULTI_P
COD_ICD9_ATROFIA_MULTI_C
COD_ICD9_ATROFIA_NONSPEC
COD_ICD9_PD
COD_ICD9_PDD
COD_ICD9_VD
COD_ICD9_MD
COD_ICD9_NPH
COD_ICD9_HC
COD_ICD9_CJD
COD_ICD9_UMORE_ALTRO
COD_ICD9_APERTO_ALTRO1
COD_ICD9_APERTO_ALTRO2
COD_ICD9_APERTO_ALTRO3
COD_ICD9_APERTO_ALTRO4
COD_ICD9_APERTO_ALTRO5
COD_ICD9_APERTO_ALTRO6
COD_ICD9_APERTO_ALTRO7
; run; 
data d; set under65; where 
COD_ICD9_AD	ne '' or
COD_ICD9_PCA	ne '' or
COD_ICD9_DLB	ne '' or
COD_ICD9_PSP	ne '' or
COD_ICD9_CBD	ne '' or
COD_ICD9_FTLDC	ne '' or
COD_ICD9_SD	ne '' or
COD_ICD9_PAA	ne '' or
COD_ICD9_AF_LOGOPENICA	ne '' or
COD_ICD9_ATROFIA_MULTI	ne '' or
COD_ICD9_ATROFIA_MULTI_P	ne '' or
COD_ICD9_ATROFIA_MULTI_C	ne '' or
COD_ICD9_ATROFIA_NONSPEC	ne '' or
COD_ICD9_PD	ne '' or
COD_ICD9_PDD	ne '' or
COD_ICD9_VD	ne '' or
COD_ICD9_MD	ne '' or
COD_ICD9_NPH	ne '' or
COD_ICD9_HC	ne '' or
COD_ICD9_CJD	ne '' or
COD_ICD9_UMORE_ALTRO	ne '' or
COD_ICD9_APERTO_ALTRO1	ne '' or
COD_ICD9_APERTO_ALTRO2	ne '' or
COD_ICD9_APERTO_ALTRO3	ne '' or
COD_ICD9_APERTO_ALTRO4	ne '' or
COD_ICD9_APERTO_ALTRO5	ne '' or
COD_ICD9_APERTO_ALTRO6	ne '' or
COD_ICD9_APERTO_ALTRO7	ne '' 
; run; 
proc sort data=d nodupkey out=soggetti_singoli; by codice_unico_bin; run; 
/*focus giovani*/
proc freq data=soggetti_singoli; table 
altro_demenza
COD_ICD9_AD
COD_ICD9_PCA
COD_ICD9_DLB
COD_ICD9_PSP
COD_ICD9_CBD
COD_ICD9_FTLDC
COD_ICD9_SD
COD_ICD9_PAA
COD_ICD9_AF_LOGOPENICA
COD_ICD9_ATROFIA_MULTI
COD_ICD9_ATROFIA_MULTI_P
COD_ICD9_ATROFIA_MULTI_C
COD_ICD9_ATROFIA_NONSPEC
COD_ICD9_PD
COD_ICD9_PDD
COD_ICD9_VD
COD_ICD9_MD
COD_ICD9_NPH
COD_ICD9_HC
COD_ICD9_CJD
COD_ICD9_UMORE_ALTRO
COD_ICD9_APERTO_ALTRO1
COD_ICD9_APERTO_ALTRO2
COD_ICD9_APERTO_ALTRO3
COD_ICD9_APERTO_ALTRO4
COD_ICD9_APERTO_ALTRO5
COD_ICD9_APERTO_ALTRO6
COD_ICD9_APERTO_ALTRO7
; run; 

proc print data=soggetti_singoli; var eta codice_unico_bin ; where COD_ICD9_AD ne ''; run; 

proc summary data=soggetti_singoli; 
var eta;
output out=eta_under65  mean(eta)=media median(eta)=mediana ;
where COD_ICD9_AD ne ''; 
run; 


/***************/
proc print data=ANAGRAFICA_CACED;
	var sesso codice_soggetto_bin data_nascita flag_errore_a1;
	where sesso='4';
run;

proc print data=ANAGRAFICA_CACED;
	var sesso codice_soggetto_bin data_nascita flag_errore_a1 eta_prima_visita eta_sintomi;
		where eta_sintomi='-17';
run;

proc print data=ANAGRAFICA_CACED; var  flag_errore_a1 cod_comune_dom ; 
where length(cod_comune_dom) ne 6; run; 

proc print data=ANAGRAFICA_CACED; var  flag_errore_a1 cod_comune_res ; 
where length(cod_comune_res) ne 6; run;  

proc print data=a; var  flag_errore_a1 data_decesso ; 
where length(data_decesso) ne 8 and data_decesso ne '' ; run;  

proc sql;
	create table CDC as
		select *
			from DWHBT.BT_CACED_CDC
				where (anno='2018' and fase ='6');
quit;
data CDC; set CDC; where flag_errore_b1 ne 'S'; run; 

PROC PRINT DATA=CDC; var AZ_SANITARIA flag_errore_b1; where AZ_SANITARIA=''; run; 

PROC PRINT DATA=CDC; var cod_comune_istat flag_errore_b1; where length(cod_comune_istat)<6; run; 

proc sql;
	create table EPISODI_CURA as
		select *
			from DWHBT.BT_CACED_EPISODI_CURA
				where (anno='2018' and fase ='6');
quit;

proc sort data=EPISODI_CURA;
	by id_cdc;
run;

proc sort data=cdc;
	by id_cdc;
run;

data db3;
	merge EPISODI_CURA (in=a)  cdc (in=b);

	if a;
	by id_cdc;
run;

proc sort data=db3;
	by codice_unico_bin;
run;


proc freq data=EPISODI_CURA;
	table 
		COD_ICD9_AD
		COD_ICD9_PCA
		COD_ICD9_DLB
		COD_ICD9_PSP
		COD_ICD9_CBD
		COD_ICD9_FTLDC
		COD_ICD9_SD
		COD_ICD9_PAA
		COD_ICD9_AF_LOGOPENICA
		COD_ICD9_ATROFIA_MULTI
		COD_ICD9_ATROFIA_MULTI_P
		COD_ICD9_ATROFIA_MULTI_C
		COD_ICD9_ATROFIA_NONSPEC
		COD_ICD9_PD
		COD_ICD9_PDD
		COD_ICD9_VD
		COD_ICD9_MD
		COD_ICD9_NPH
		COD_ICD9_HC
		COD_ICD9_CJD
		COD_ICD9_UMORE_ALTRO
		COD_ICD9_APERTO_ALTRO1
		COD_ICD9_APERTO_ALTRO2
		COD_ICD9_APERTO_ALTRO3
		COD_ICD9_APERTO_ALTRO4
		COD_ICD9_APERTO_ALTRO5
		COD_ICD9_APERTO_ALTRO6
		COD_ICD9_APERTO_ALTRO7;
run; 
