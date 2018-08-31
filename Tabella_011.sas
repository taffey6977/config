
/********************************************
	Tabella Arcipelago 011 
	ANAGRAFICA UDO 
********************************************/

LIBNAME FAR_2016 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2016';
LIBNAME FAR_2017 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2017';
LIBNAME FAR_2018 '/sasprd/staging/staging_san1/S1_ORPSS/config/FAR_2018';
%include '/sasprd/staging/staging_san1/S1_ORPSS/config/MACRO_ORPSS/far_udo_atti.sas' ;
%include '/sasprd/staging/staging_san1/S1_ORPSS/config/MACRO_ORPSS/comandi_orpss.sas' ;

LIBNAME ARCIPE '/sasprd/staging/staging_san1/S1_ORPSS/config/Arcipelago';

%let anno=2018;

%set_udo; 

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

data comuni_per_merge; set c1; keep istres_in  descrizione; run; 

data comuni_per_merge; set comuni_per_merge; 
rename  descrizione= UDO_COMUNE_DENOMINAZIONE
istres_in=comune; run; 
%mend; 


data tmp&anno.; set udo; run; 

/*per accodamento di più anni 
far rigirare il codice sopra n volte (per n anni)
*/
data tabella011_tmp; set tmp2016 tmp2017 tmp2018; run; 

/* variazione: 
teniamo una riga per struttura per ogni anno (se una struttura è aperta da N anni avrò N righe, 
quindi questo non viene più fatto girare: 
proc sort data=tabella011_tmp nodupkey out=tabella_011; by cod_udo; run;  
*/


DATA tabella_011; SET tabella011_tmp;
UDO_NUMERO_CIVICO=0;
UDO_LOCALITA='0';
RUN; 

DATA tabella_011; SET tabella_011;
KEEP
ULSS_UDO
COD_UDO
REG_PROVV_CDS
REG_ENTE_GES
COD_STS
DATA_IN_VAL
DATA_FI_VAL
DENOMINAZIONE_UDO
INDIRIZZO_1
UDO_NUMERO_CIVICO
UDO_LOCALITA
CAP
DESCRIZIONE
COMUNE
SOMMA_POSTI_AUTO
SOMMA_POSTI_ACC
TIPO_UDO
INDIRIZZO_2
INDIRIZZO_3
ANNO
;
RUN; 

DATA tabella_011;
SET tabella_011;
RENAME 
INDIRIZZO_2=PUBB_PRIV
INDIRIZZO_3=PROFILO_GIURIDICO;
RUN;


%COMUNI;

%left_outer(tabella_011, comuni_per_merge, comune, tabella_011_ok);

data tabella_011_ok;
	set tabella_011_ok;

	if UDO_COMUNE_DENOMINAZIONE='' then
		UDO_COMUNE_DENOMINAZIONE='FUORI REGIONE';
run;

DATA tabella_011_ok; 
RETAIN
ULSS_UDO
COD_UDO
REG_PROVV_CDS
REG_ENTE_GES
COD_STS
DATA_IN_VAL
DATA_FI_VAL
DENOMINAZIONE_UDO
INDIRIZZO_1
UDO_NUMERO_CIVICO
UDO_LOCALITA
COMUNE
SOMMA_POSTI_AUTO
SOMMA_POSTI_ACC
TIPO_UDO
PROFILO_GIURIDICO
PUBB_PRIV
UDO_COMUNE_DENOMINAZIONE
ANNO
;
SET tabella_011_ok; 
RUN; 

data tabella_011_ok;
set tabella_011_ok;
format tipo_udo tipoudo_far.;run; 
 

/*in generale sempre riguardare i numeri dei posti con filemaker*/

/*proc print data=tabella_011; var cod_udo somma_posti_acc somma_posti_auto ; where somma_posti_acc ne somma_posti_auto; run; */

/*mancano PROFILO GIURIDCO E PUBBLICO PRIVATO dall'anno 2016*/
data tabella_011_2016; set tabella_011_ok; where anno eq 2016; run; 
data tabella_011_2017; set tabella_011_ok; where anno eq 2017; run; 
data tabella_011_2018; set tabella_011_ok; where anno eq 2018; run; 

data t; set tabella_011_2017 tabella_011_2018; run; 

proc sort nodupkey data=t out=tn; by cod_udo; run; 
/*prendo solo COD_UDO PROFILO E PUBBLICO poi li attacco al 2016 (senza le due variabili)*/
data m; set tn; keep cod_udo profilo_giuridico pubb_priv; run; 

data tabella_011_2016; set tabella_011_2016; drop profilo_giuridico pubb_priv; run; 

%left_outer(tabella_011_2016, m , cod_udo, tabella_011_2016_1);

DATA tabella_011_2016_1; 
RETAIN
ULSS_UDO
COD_UDO
REG_PROVV_CDS
REG_ENTE_GES
COD_STS
DATA_IN_VAL
DATA_FI_VAL
DENOMINAZIONE_UDO
INDIRIZZO_1
UDO_NUMERO_CIVICO
UDO_LOCALITA
COMUNE
SOMMA_POSTI_AUTO
SOMMA_POSTI_ACC
TIPO_UDO
PROFILO_GIURIDICO
PUBB_PRIV
UDO_COMUNE_DENOMINAZIONE
ANNO
;
SET tabella_011_2016_1; 
RUN; 

data tabella_011_finale; set  t tabella_011_2016_1 ; run; 
proc sort data=tabella_011_finale; by  cod_udo anno; run; 
