/*********************************************************************************************/;

Libname users "C:\Users\Vassiki Sanogo\Desktop\adrdproject"; /*nrd Datasets Library*/
Libname dat "C:\Users\Vassiki Sanogo\Desktop\adrdproject\dat"; /*ardr Datasets Library*/
Libname adrd "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd"; /*adrd results Library*/

/**************************************************************************
**************************************************************************/

/*Start Multilevel Explanatory Analysis*/

data datainn; set dat.datainn; run;

/*Mortality is the Outcome Variable*/

/*Model 1 unweighted */

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table11.csv" style=karamtables;

title "Multilevel Model 1 unweighted for Hospital Mortality of ADRD Patients";

proc glimmix data=datainn method = laplace noclprint;
class hosp_urcat4;
model died(event=last)=/cl dist=binary link=logit solution oddsratio (diff=first label);
random intercept / sub=hosp_urcat4 type=vc solution cl;
covtest /wald;
run;

/*Model 1 weighted */

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table11a.csv" style=karamtables;

title "Multilevel Model 1 weighted for Hospital Mortality of ADRD Patients";

proc glimmix data=datainn method = laplace noclprint;
class hosp_urcat4;
weight nrd_stratum;
model died(event=last)=/cl dist=binary link=logit solution oddsratio (diff=first label);
random intercept / sub=hosp_urcat4 type=vc solution cl;
covtest /wald;


/*Model 2 unweighted*/

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table12.csv" style=karamtables;

title "Multilevel Model 2 unweighted for Hospital Mortality of ADRD Patients";

proc glimmix data=datainn method = laplace noclprint;
class hosp_urcat4;
model died = age year female wagadj pay1 zipinc_qrtl rehabtransfer 
dispuniform ndx npr mortal_score/cl dist=binary link=logit solution oddsratio (diff=first label);
random intercept /sub=hosp_urcat4 type=vc solution cl;
covtest /wald;

/*Model 2 weighted*/

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table12a.csv" style=karamtables;

title "Multilevel Model 2 weighted for Hospital Mortality of ADRD Patients";

proc glimmix data=datainn method = laplace noclprint;
class hosp_urcat4;
weight nrd_stratum;
model died = age year female wagadj pay1 zipinc_qrtl rehabtransfer 
dispuniform ndx npr mortal_score/cl dist=binary link=logit solution oddsratio (diff=first label);
random intercept /sub=hosp_urcat4 type=vc solution cl;
covtest /wald;


/*Model 3 unweighted*/

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table13.csv" style=karamtables;

title "Multilevel Model 3 unweighted for Hospital Mortality of ADRD Patients";

proc glimmix data=datainn method = laplace noclprint;
class hosp_urcat4; 
model died = age year female wagadj pay1 zipinc_qrtl rehabtransfer 
dispuniform ndx npr mortal_score / cl dist=binary link=logit solution oddsratio (diff=first label);
random intercept age year female wagadj pay1 zipinc_qrtl rehabtransfer 
dispuniform ndx npr mortal_score/ sub=hosp_urcat4 type=vc solution cl;
covtest /wald;

/*Model 3 weighted*/

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table13a.csv" style=karamtables;

title "Multilevel Model 3 weighted for Hospital Mortality of ADRD Patients";

proc glimmix data=datainn method = laplace noclprint;
class hosp_urcat4; 
weight nrd_stratum;
model died = age year female wagadj pay1 zipinc_qrtl rehabtransfer 
dispuniform ndx npr mortal_score / cl dist=binary link=logit solution oddsratio (diff=first label);
random intercept age year female wagadj pay1 zipinc_qrtl rehabtransfer 
dispuniform ndx npr mortal_score/ sub=hosp_urcat4 type=vc solution cl;
covtest /wald;


/*Model 4 unweighted */

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table14.csv" style=karamtables;

title "Multilevel Model 4 unweighted for Hospital Mortality of ADRD Patients";

proc glimmix data=datainn method = laplace noclprint;
class hosp_urcat4;
model died = age agegrp year female wagadj pay1 zipinc_qrtl rehabtransfer 
dispuniform mortal_score ndx npr hosp_bedsize hosp_urcat4 hosp_ur_teach 
h_contrl /cl dist=binary link=logit solution oddsratio (diff=first label);
random intercept age year female wagadj pay1 zipinc_qrtl rehabtransfer 
dispuniform ndx npr mortal_score / sub=hosp_urcat4 type=vc solution cl;
covtest /wald;

/*Model 4 weighted*/

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table14a.csv" style=karamtables;

title "Multilevel Model 4 weighted for Hospital Mortality of ADRD Patients";

proc glimmix data=datainn method = laplace noclprint;
class hosp_urcat4;
weight nrd_stratum;
model died = age agegrp year female wagadj pay1 zipinc_qrtl rehabtransfer 
dispuniform mortal_score ndx npr hosp_bedsize hosp_urcat4 hosp_ur_teach 
h_contrl /cl dist=binary link=logit solution oddsratio (diff=first label) chisq;
random intercept age year female wagadj pay1 zipinc_qrtl rehabtransfer 
dispuniform ndx npr mortal_score / sub=hosp_urcat4 type=vc solution cl;
covtest /wald;
output out=gmxout pred=xbeta pred(ilink)=predprob pred(ilink
noblup)=fix_predprob;
run;

ods graphics on;
proc logistic data=gmxout plots(only)=roc;
model died=predprob;
ods select roccurve;
run;

/*LOS, TOTCHG, and COST are the Outcome Variables*/

/*Model 1 unweighted*/

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table15.csv" style=karamtables;

title "Multilevel Model 1 unweighted for Length of Stay for In-patient with ADRD";

proc mixed data=datainn covtest noclprint method = ML;
class hosp_urcat4;
model los=/solution ddfm=satterthwaite;
random intercept / sub=hosp_urcat4 type=vc solution cl;
run;

/*Model 1 weighted*/

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table15a.csv" style=karamtables;

title "Multilevel Model 1 weighted for Length of Stay for In-patient with ADRD";

proc mixed data=datainn covtest noclprint method = ML;
class hosp_urcat4;
weight nrd_stratum;
model los=/solution ddfm=satterthwaite;
random intercept / sub=hosp_urcat4 type=vc solution cl;
run;


/*Model 2 unweighted */

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table16.csv" style=karamtables;

title "Multilevel Model 2 unweighted for Length of Stay for In-patient with ADRD";

proc mixed data=datainn covtest noclprint method = ML;
class hosp_urcat4;
model los = age agegrp female year wagadj pay1 zipinc_qrtl
    rehabtransfer ndx npr none mild moderate severe cm_alcohol cm_anemdef cm_arth 
    cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_htn_c cm_hypothy cm_lytes 
    cm_neuro cm_obese cm_perivasc cm_psych cm_renlfail 
    cm_valve cm_wghtloss /solution ddfm=satterthwaite;
random intercept / sub=hosp_urcat4 type=vc solution cl;
run;

/*Model 2 weighted */

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table16a.csv" style=karamtables;

title "Multilevel Model 2 weighted for Length of Stay for In-patient with ADRD";

proc mixed data=datainn covtest noclprint method = ML;
class hosp_urcat4;
weight nrd_stratum;
model los = age agegrp female year wagadj pay1 zipinc_qrtl
    rehabtransfer ndx npr none mild moderate severe cm_alcohol cm_anemdef cm_arth 
    cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_htn_c cm_hypothy cm_lytes 
    cm_neuro cm_obese cm_perivasc cm_psych cm_renlfail 
    cm_valve cm_wghtloss /solution ddfm=satterthwaite;
random intercept / sub=hosp_urcat4 type=vc solution cl;
run;


/*Model 3 unweighted*/

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table17.csv" style=karamtables;

title "Multilevel Model 3 unweighted for Length of Stay for In-patient with ADRD";

proc mixed data=datainn covtest noclprint method=ML; 
class hosp_urcat4; 
model los = age agegrp female year wagadj pay1 zipinc_qrtl
    rehabtransfer ndx npr none mild moderate severe cm_alcohol cm_anemdef cm_arth 
    cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_htn_c cm_hypothy cm_lytes 
    cm_neuro cm_obese cm_perivasc cm_psych cm_renlfail 
    cm_valve cm_wghtloss /solution ddfm=satterthwaite;
random intercept age agegrp female year wagadj pay1 zipinc_qrtl
    rehabtransfer ndx npr none mild moderate severe cm_alcohol cm_anemdef cm_arth 
    cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_htn_c cm_hypothy cm_lytes 
    cm_neuro cm_obese cm_perivasc cm_psych cm_renlfail 
    cm_valve cm_wghtloss / sub=hosp_urcat4 type=vc solution cl;
run;

/*Model 3 weighted*/

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table17a.csv" style=karamtables;

title "Multilevel Model 3 weighted for Length of Stay for In-patient with ADRD";

proc mixed data=datainn covtest noclprint method=ML; 
class hosp_urcat4; 
weight nrd_stratum;
model los = age agegrp female year wagadj pay1 zipinc_qrtl
    rehabtransfer ndx npr none mild moderate severe cm_alcohol cm_anemdef cm_arth 
    cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_htn_c cm_hypothy cm_lytes 
    cm_neuro cm_obese cm_perivasc cm_psych cm_renlfail 
    cm_valve cm_wghtloss /solution ddfm=satterthwaite;
random intercept age agegrp female year wagadj pay1 zipinc_qrtl
    rehabtransfer ndx npr none mild moderate severe cm_alcohol cm_anemdef cm_arth 
    cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_htn_c cm_hypothy cm_lytes 
    cm_neuro cm_obese cm_perivasc cm_psych cm_renlfail 
    cm_valve cm_wghtloss / sub=hosp_urcat4 type=vc solution cl;
run;

/*Model 4 unweighted*/

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table18.csv" style=karamtables;

title "Multilevel Model 4 unweighted for Length of Stay for In-patient with ADRD";

proc mixed data=datainn covtest noclprint method= ML;
class hosp_urcat4;
model los = age agegrp female year wagadj pay1 zipinc_qrtl
    rehabtransfer ndx npr none mild moderate severe cm_alcohol cm_anemdef cm_arth 
    cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_htn_c cm_hypothy cm_lytes 
    cm_neuro cm_obese cm_perivasc cm_psych cm_renlfail 
    cm_valve cm_wghtloss hosp_bedsize hosp_urcat4 
    hosp_ur_teach h_contrl/solution ddfm=satterthwaite;
random intercept age agegrp female year wagadj pay1 zipinc_qrtl
    rehabtransfer ndx npr none mild moderate severe cm_alcohol cm_anemdef cm_arth 
    cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_htn_c cm_hypothy cm_lytes 
    cm_neuro cm_obese cm_perivasc cm_psych cm_renlfail 
    cm_valve cm_wghtloss / sub=hosp_urcat4 type=vc solution cl;
run;

	/*Model 4 weighted*/

options orientation=portrait;

ods csv file= "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd\table18a.csv" style=karamtables;

title "Multilevel Model 4 weighted for Length of Stay for In-patient with ADRD";

proc mixed data=datainn covtest noclprint method= ML;
class hosp_urcat4;
weight nrd_stratum;
model los = age agegrp female year wagadj pay1 zipinc_qrtl
    rehabtransfer ndx npr none mild moderate severe cm_alcohol cm_anemdef cm_arth 
    cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_htn_c cm_hypothy cm_lytes 
    cm_neuro cm_obese cm_perivasc cm_psych cm_renlfail 
    cm_valve cm_wghtloss hosp_bedsize hosp_urcat4 
    hosp_ur_teach h_contrl/solution ddfm=satterthwaite;
random intercept age agegrp female year wagadj pay1 zipinc_qrtl
    rehabtransfer ndx npr none mild moderate severe cm_alcohol cm_anemdef cm_arth 
    cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_htn_c cm_hypothy cm_lytes 
    cm_neuro cm_obese cm_perivasc cm_psych cm_renlfail 
    cm_valve cm_wghtloss / sub=hosp_urcat4 type=vc solution cl;
run;

/*End Multilevel Explanatory Analysis*/

/**************************************************************************
**************************************************************************/

/*Exporting data files for the csv format*/



