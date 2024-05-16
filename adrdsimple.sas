/*********************************************************************************************/
* Main Code*

/*********************************************************************************************/;

Libname users "/Volumes/My Passport for Mac/adrdproject"; /*NRD Datasets Library*/
Libname adrd "/Volumes/My Passport for Mac/adrdproject/adrd";

/**************************************************************************
**************************************************************************/

/*Start Data Pre-Processing*/

/*2010-2015 NRD inpatient cohort/;
/*2010 N= 13,907,610;
/*2011 N= 13,915,176;
/*2012 N= 13,459,216;
/*2013 N= 14,325,172;
/*2014 N= 14,894,613;
/*2015 N= 17,198,125;

/*Total sample for our inpatient cohort 87,699,912*/; 

/*keep relevent variables in core*Year 2010 to 2014*/

%Macro coret (input, output);

data &output;
set &input (keep= year hosp_nrd key_nrd nrd_stratum discwt nrd_visitlink
		nrd_daystoevent age female zipinc_qrtl died npr los totchg pay1 
		drg ndx dispuniform rehabtransfer dx:);
run;

%mend coret;

%coret (adrd.core10, c10);
%coret (adrd.core11, c11);
%coret (adrd.core12, c12);
%coret (adrd.core13, c13);
%coret (adrd.core14, c14);

/*apply inclusion criteria*/

%Macro corincl (input, output,dx);

data &output;
set &input;
if age>=30 then do;
	array dxn $ &dx;
	do over dxn;

if dxn in ('3310','3311x','3312','3317','2900','2901x','33182',
	'2902x','2903','2904x','2940','2941','2941x','2948','797') then adrd=1;

if dxn in ('3310','3311x','3312','3317','33182') then pdiagad=1;
else pdiagad=0;

if dxn in ('2900','2901x','2902x','2903','2904x','2940','2941', 
	'2941x','2948','797') then pdiagrd=1;
else pdiagrd=0;

	end;
end;
if adrd=1;
run;
quit;

%mend corincl;

%corincl (c10,c10,dx1-dx25);
%corincl (c11,c11,dx1-dx25);
%corincl (c12,c12,dx1-dx25);
%corincl (c13,c13,dx1-dx25);
%corincl (c14,c14,dx1-dx25);


/*keep relevent variables in Sever*/

%Macro coret (input, output);

data &output;
set &input (drop= APRDRG APRDRG_Risk_Mortality APRDRG_Severity);
run;

%mend coret;

%coret (adrd.sever10, s10);
%coret (adrd.sever11, s11);
%coret (adrd.sever12, s12);
%coret (adrd.sever13, s13);
%coret (adrd.sever14, s14);


/*Merging core with Sever*/; 

%Macro reta (input1, input2, output);

proc sort data=&input1;
by key_nrd;
run;

proc sort data=&input2;
by key_nrd;
run;

options mergenoby=warn;
data &output;
merge &input1(in=in1) &input2(in=in2);
by key_nrd;
if (in1=1) then output &output;
run;

%mend reta;

%reta (c10, s10, c10);
%reta (c11, s11, c11);
%reta (c12, s12, c12);
%reta (c13, s13, c13);
%reta (c14, s14, c14);


/*Merging core_Sever with Hosp*/; 

%Macro retb (input1, input2, output);

proc sort data=&input1;
by Hosp_nrd;
run;

proc sort data=&input2;
by Hosp_nrd;
run;

options mergenoby=warn;
data &output;
merge &input1(in=in1) &input2(in=in2);
by Hosp_nrd;
if (in1=1) then output &output;
run;

%mend retb;

%retb (c10, adrd.hosp10, c10); /*obs 790676*/
%retb (c11, adrd.hosp11, c11); /*obs 719555*/
%retb (c12, adrd.hosp12, c12); /*obs 338224*/
%retb (c13, adrd.hosp13, c13); /*obs 301958*/
%retb (c14, adrd.hosp14, c14); /*obs 285744*/


/*keep relevent variables in core *Year 2015*/

%Macro coret (input, output);

data &output;
set &input (keep= year hosp_nrd key_nrd nrd_stratum discwt nrd_visitlink
	nrd_daystoevent age female zipinc_qrtl died los totchg pay1 dispuniform rehabtransfer);
run;

%mend coret;

%coret (adrd.core15, c15);


data dx1_3q15;
set adrd.dxgfp3q15 (keep=drg npr ndx key_nrd dx: );
run;

data dxq1;
set adrd.dxgfp4q15(rename =(i10_ndx=ndx)); 
run;

data dxq15;
set dxq1(rename =(i10_npr=npr)); 
run;

data dx4q15;
set dxq15 (keep=drg npr ndx key_nrd  I10_dx: );
run;

/*merge dxgfp3q15 and dxgfp4q with core*/

%Macro coretq (input1, input2, input3, output);

proc sort data=&input1;
by key_nrd;
run;

proc sort data=&input2;
by key_nrd;
run;

proc sort data=&input3;
by key_nrd;
run;

options mergenoby=warn;
data &output;
merge &input1(in=in1) &input2(in=in2) &input3(in=in3);
by key_nrd;
if (in1=1) then output &output;
run;

%mend coretq;

%coretq (c15,dx1_3q15,dx4q15,cq15);


/*apply inclusion criteria*/

/*data set with full 2015 cohort*/

%Macro corincl (input, output,dx,i10_dx);

data &output;
set &input;
if age>=30 then do;
	array dxn $ &dx &i10_dx;
	do over dxn;

if dxn in ('3310','3311x','3312','3317','2900','2901x', 
	'2902x','2903','2904x','2940','2941','2941x','2948', 
	'797','F000','F001','F05','G300','G301','G308','G309') then adrd=1;

if dxn in ('3310','3311x','3312','3317','33182','G300', 
'G301', 'G308', 'G309') then pdiagad=1;
else pdiagad=0;

if dxn in ('2900','2901x','2902x','2903','2904x','2940','2941', 
	'2941x','2948','797','F000', 'F001', 'F05') then pdiagrd=1;
else pdiagrd=0;

	end;
end;
if adrd=1;
run;
quit;

%mend corincl;

%corincl (cq15,c15,dx1-dx25,i10_dx1-i10_dx25);

/*data set without 4th quarter 2015 cohort*/

%Macro corincl (input,output,dx);

data &output;
set &input;
if age>=30 then do;
	array dxn $ &dx;
	do over dxn;

if dxn in ('3310','3311x','3312','3317','2900','2901x','33182',
	'2902x','2903','2904x','2940','2941','2941x','2948','797') then adrd=1;

if dxn in ('3310','3311x','3312','3317','33182') then pdiagad=1;
else pdiagad=0;

if dxn in ('2900','2901x','2902x','2903','2904x','2940','2941', 
	'2941x','2948','797') then pdiagrd=1;
else pdiagrd=0;

	end;
end;
if adrd=1;
run;
quit;

%mend corincl;

%corincl (cq15,c15q13,dx1-dx25);


/*keep relevent variables in Sever*/

%Macro coret (input, output);

data &output;
set &input (drop= APRDRG APRDRG_Risk_Mortality APRDRG_Severity);
run;

%mend coret;

%coret (adrd.sever3q15, s15);


/*Merging core with Sever*/; 

%Macro reta (input1, input2, output);

proc sort data=&input1;
by key_nrd;
run;

proc sort data=&input2;
by key_nrd;
run;

options mergenoby=warn;
data &output;
merge &input1(in=in1) &input2(in=in2);
by key_nrd;
if (in1=1) then output &output;
run;

%mend reta;

%reta (c15, s15, c15);
%reta (c15q13, s15, c15q13);


/*Merging core_Sever with Hosp*/; 

%Macro retb (input1, input2, output);

proc sort data=&input1;
by Hosp_nrd;
run;

proc sort data=&input2;
by Hosp_nrd;
run;

options mergenoby=warn;
data &output;
merge &input1(in=in1) &input2(in=in2);
by Hosp_nrd;
if (in1=1) then output &output;
run;

%mend retb;

%retb (c15, adrd.hosp15, c15); /*55,879 obs*/
%retb (c15q13, adrd.hosp15, c15q13); /*37,994 obs*/


/*Merging adrd with ccr*/

%Macro retc (input1, input2, output);

proc sort data=&input1;
by hosp_nrd;
run;

proc sort data=&input2;
by hosp_nrd;
run;

options mergenoby=warn;
data &output;
merge &input1(in=in1) &input2(in=in2);
by hosp_nrd;
if (in1=1) then output &output;
run;

%mend retc;

%retb (c10, adrd.ccr10, c10); /*obs 790676*/
%retb (c11, adrd.ccr11, c11); /*obs 719555*/
%retb (c12, adrd.ccr12, c12); /*obs 338224*/
%retb (c13, adrd.ccr13, c13); /*obs 301958*/
%retb (c14, adrd.ccr14, c14); /*obs 285744*/
%retb (c15, adrd.ccr15, c15); /*obs 292012*/
%retb (c15q13, adrd.ccr15, c15q13); /*obs 240008*/


/*data consolidation for the work data set with full 2015 cohort*/

data adrd.datadrd; /*obs 2728169*/
set c10 c11 c12 c13 c14 c15;
drop adrd;
if pdiagad=1 and cm_depress=1 then addepr=1;
else addepr=0;
if 30 <= age < 55 then agegrp=1;
else if 55 <= age < 65 then agegrp=2;
else if 65 <= age < 75 then agegrp=3;
else if 75 <= age < 85 then agegrp=4;
else if 85 <= age then agegrp=5;
costs= totchg*ccr_nrd;
wages= totchg*wageindex;
run;


/*data consolidation for the work data set without 4th quarter 2015 cohort*/

data adrd.datadrd1; /*obs 2676165*/
set c10 c11 c12 c13 c14 c15q13;
drop adrd;
if pdiagad=1 and cm_depress=1 then addepr=1;
else addepr=0;
if 30 <= age < 55 then agegrp=1;
else if 55 <= age < 65 then agegrp=2;
else if 65 <= age < 75 then agegrp=3;
else if 75 <= age < 85 then agegrp=4;
else if 85 <= age then agegrp=5;
costs= totchg*ccr_nrd;
wages= totchg*wageindex;
run;

/*Returning data sets into work shell*/

data datadrd; set adrd.datadrd; run;
data datadrd1; set adrd.datadrd1; run;


/*Creating the comorbidities including the ALD and ARD comorbidities*/

Libname in1 "/Volumes/My Passport for Mac/adrdproject/data/in1";
Libname out1 "/Volumes/My Passport for Mac/adrdproject/data/out1";
data in1.adrdcomob; set datadrd (keep= drg ndx key_nrd dx1-dx30 i10_dx1-i10_dx30 ); run;
data dtadrdw; set datadrd (drop=drg dx: i10_dx: ); run;
data dtadrdw1; set datadrd1 (drop=drg dx: i10_dx:); run;
data analysis; set out1.analysis; run;


proc sort data= dtadrdw nodupkey; by key_nrd; run; /*obs 2728169*/
proc sort data= dtadrdw1 nodupkey;by key_nrd; run; /*obs 2676165*/

/*Joining the comorbidities with the data set with 2015 cohort, obs 2728471*/

proc sql;
create table datwork as select a.*,b.* 
from dtadrdw a left join analysis b
on a. key_nrd = b. key_nrd;
quit;

/*Joining the comorbidities with the data set without 4th q of 2015 cohort, obs	2676467*/

proc sql;
create table datwork1 as select a.*,b.* 
from dtadrdw1 a left join analysis b
on a. key_nrd = b. key_nrd;
quit;


/*Creating the Alzheimer's disease and related dementias variable with 2015 cohort*/

data data; 
set datwork;
if pdiagad=1 and ard=1 or pdiagrd=1 then adrdv=1;
else adrdv=0;
run;

data data1;
set data;
if adrdv=1 then stratif=1;
else if pdiagad=1 then stratif=2;
else if pdiagrd=1 then stratif=3;
run;

/*Creating the Alzheimer's disease and related dementias variable without 4th q of 2015 cohort*/

data dataa; 
set datwork1;
if pdiagad=1 and ard=1 or pdiagrd=1 then adrdv=1;
else adrdv=0;
run;

data data2;
set dataa;
if adrdv=1 then stratif=1;
else if pdiagad=1 then stratif=2;
else if pdiagrd=1 then stratif=3;
run;


/*Work data sets building*/

/*2015 cohort in (obs 2728471)*/

data adrd.datain; set data1 (drop=n_disc_u n_hosp_u s_disc_u s_hosp_u total_disc ccr_nrd wageindex ald ard aids alcohol anemdef arth
	bldloss chf chrnlung coag depress dm dmcx drug htn_c hypothy 
	liver lymph lytes mets neuro para perivasc psych pulmcirc 
	renlfail tumor ulcer valve wghtloss); run;

/*2015 cohort out (obs 2676467)*/

data adrd.dataout; set data2 (drop=n_disc_u n_hosp_u s_disc_u s_hosp_u total_disc ccr_nrd wageindex ald ard aids alcohol anemdef arth
	bldloss chf chrnlung coag depress dm dmcx drug htn_c hypothy 
	liver lymph lytes mets neuro para perivasc psych pulmcirc 
	renlfail tumor ulcer valve wghtloss); run;


/*Turn data sets in the work shell*/

/*By doing the following procedure on the LOS the .A (Invalid), 
.B (Unavailable from source), and .C (Inconsistent) 
will be turned into missing values*/

/*(obs 254,752)*/
data datain; set adrd.datain; overall=1;; nLOS = input(LOS, 3.); drop LOS; rename nLOS=LOS; run; 

/*(obs 236,867)*/
data dataout; set adrd.dataout (drop =i10_dx:); overall=1; nLOS = input(LOS, 3.); drop LOS; rename nLOS=LOS; run; 


/*Adjusting for inflation*/

/* data set with 2015 cohort*/

data adrd.adjdatain; 
set datain;
if year='2010' then costadj=costs*(1+0.087);
if year='2010' then totchgadj=totchg*(1+0.087);
if year='2010' then wagadj=wages*(1+0.087);
if year='2011' then costadj=costs*(1+0.054);
if year='2011' then totchgadj=totchg*(1+0.054);
if year='2011' then wagadj=wages*(1+0.032);
if year='2012' then costadj=costs*(1+0.032);
if year='2012' then totchgadj=totchg*(1+0.032);
if year='2012' then wagadj=wages*(1+0.032);
if year='2013' then costadj=costs*(1+0.017);
if year='2013' then totchgadj=totchg*(1+0.017);
if year='2013' then wagadj=wages*(1+0.017);
if year='2014' then costadj=costs*(1+0.01);
if year='2014' then totchgadj=totchg*(1+0.01);
if year='2014' then wagadj=wages*(1+0.01);
run;

/* data set without 4th q of 2015 cohort*/

data adrd.adjdataout; 
set dataout;
if year='2010' then costadj=costs*(1+0.087);
if year='2010' then totchgadj=totchg*(1+0.087);
if year='2010' then wagadj=wages*(1+0.087);
if year='2011' then costadj=costs*(1+0.054);
if year='2011' then totchgadj=totchg*(1+0.054);
if year='2011' then wagadj=wages*(1+0.032);
if year='2012' then costadj=costs*(1+0.032);
if year='2012' then totchgadj=totchg*(1+0.032);
if year='2012' then wagadj=wages*(1+0.032);
if year='2013' then costadj=costs*(1+0.017);
if year='2013' then totchgadj=totchg*(1+0.017);
if year='2013' then wagadj=wages*(1+0.017);
if year='2014' then costadj=costs*(1+0.01);
if year='2014' then totchgadj=totchg*(1+0.01);
if year='2014' then wagadj=wages*(1+0.01);
run;


/*Return data sets into work shell*/

data datain; set adrd.adjdatain; drop stratif costs totchg wages addepr; run;
data dataout; set adrd.adjdataout; drop stratif costs totchg wages addepr; run;


/*End Data Pre-Processing*/

/**************************************************************************
**************************************************************************/

/*Start Data Analysis*/


/* Formating */

proc format;
value yesno_ 1='   Yes'
0='   No'
.='   Missing';           
value dispuniform_ 1='   Routine'
2='   Transfer to short-term hospital'
5='   Transfer other'
6= '   Home Health Care'
7='   Against medical advice'
20='   Died in hospital'
21= '   Discharged/transferred to court/law enforcement'
99='   Discharged alive, destination unknown'
.='   Missing';
value female_ 1='   Female'
0='   Male'
3= '   Unknown';
value agegrp_ 1='   30-44'
2='   45-54'
3='   55-64'
4='   64<'
.='   Missing';
value hosp_bedsize_ 1='   Small'
2='   Medium'
3= '   Large'
.='   Missing';
value h_contrl_ 1='   Government, nonfederal'
2='   Private, not-profit'
3= '   Private, invest-own'
.='   Missing';
value pay1_ 1='   Medicare'
2='   Medicaid'
3= '   Private insurance'
4= '   Self-pay'
5='   No charge'
6= '   Other'
.='   Missing';
value hosp_urcat4_ 1='   Large metropolitan areas '
2='   Small metropolitan areas'
3= '   Micropolitan areas'
4='   Not metropolitan'
6='   Collapsed category for any urban-rural location'
7= '   Collapsed category of small metropolitan'
8='   Metropolitan, collapsed category of large and small metropolitan'
9= '   Non-metropolitan, collapsed category of micropolitan and non-urban'
.='   Missing';
value hosp_ur_teach_ 0='   Metropolitan non-Teaching'
1='   Metropolitan Teaching'
2= '   Non-Metropolitan Hospital'
.='   Missing';
value zipinc_qrtl_ 1='   0-25th Percentile'
2='   0-25th percentile'
3= '   51st to 75th percentile'
4= '   76th to 100th percentile'
.='   Other';
value stratif_ 1='   Patients with Alzheimer Disease and Related Dementias'
2='   Only Patients with Alzheimer Disease'
3= '   Only Patients with Dementias Relating Alzheimer Disease'
0='   Other';
value overall 1='   Overall';
value totchgadj; 
value los;
value costadj; 
value wagadj;
value age;
value readmit_score;
value mortal_score;
picture pctfmt(round)low-high= '   009.9)' (prefix='(');
run;


/* create a journal style template */

proc template;
	define style Styles.karamtables;
		parent = Styles.Default;
		STYLE SystemTitle /
			FONT_FACE = "Times New Roman, Helvetica, sans-serif"
			FONT_SIZE = 8
			FONT_WEIGHT = bold
			FONT_STYLE = roman
			FOREGROUND = midnightblue
			BACKGROUND = white;
		STYLE SystemFooter /
			FONT_FACE = "Comic Sans MS, Helvetica, sans-serif"
			FONT_SIZE = 2
			FONT_WEIGHT = bold
			FONT_STYLE = italic
			FOREGROUND = midnightblue
			BACKGROUND = white;
		STYLE Header /
			FONT_FACE = "Times New Roman, Helvetica, sans-serif"
			FONT_SIZE = 4
			FONT_WEIGHT = medium
			FONT_STYLE = roman
			FOREGROUND = midnightblue
			BACKGROUND = white;
		STYLE Data /
			FONT_FACE = "Times New Roman, Helvetica, sans-serif"
			FONT_SIZE = 2
			FONT_WEIGHT = medium
			FONT_STYLE = roman
			FOREGROUND = black
			BACKGROUND = white;
		STYLE Table /
			FOREGROUND = black
			BACKGROUND = white
			CELLSPACING = 0
			CELLPADDING = 3
			FRAME = HSIDES
			RULES = NONE;
		STYLE Body /
			FONT_FACE = "Arial, Helvetica, sans-serif"
			FONT_SIZE = 3
			FONT_WEIGHT = medium
			FONT_STYLE = roman
			FOREGROUND = black
			BACKGROUND = white;
		STYLE SysTitleAndFooterContainer /
			CELLSPACING=0;
	end;
run;

/**************************************************************************
**************************************************************************/

/*Start Descriptive Analysis*/

/* Labeling Categorical Variables data set with 2015 cohort*/

data tabin;
set datain;
label pay1='Payer';
label female = 'Gender';
label agegrp='Age Groups';
label totchgadj='Total Charges Adjusted';
label costadj='Cost of Service Adjusted';
label wagadj='Hospital Wage Level in the Patient Area Adjusted';
label los='Lenght of Stay';
label died='Mortality';
label pdiagad='Patients with Alzheimer Disease';
label pdiagrd='Patients with Dementias Relating Alzheimer Disease';
label adrdv='Patients with Alzheimer Disease and Related ';
label readmit_score='Readmission Score';
label mortal_score='Mortality Score';
label year = 'Year of Discharge'; 
label overall = 'overall data set';

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table1.csv" style=karamtables;

title1 "Yearly Differences in Clinical Characteristic of ADRD Patients";

/******************* TABLE 1 in TEXT *************************************************/

proc tabulate data=tabin missing order=formatted;
	class year died cm_aids cm_alcohol cm_anemdef cm_arth onset
			cm_bldloss cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_drug cm_htn_c cm_hypothy 
			cm_liver cm_lymph cm_lytes cm_mets cm_neuro cm_obese cm_para cm_perivasc cm_psych cm_pulmcirc 
			cm_renlfail cm_tumor cm_ulcer  cm_valve cm_wghtloss overall;
	classlev died cm_aids cm_alcohol cm_anemdef cm_arth onset
			cm_bldloss cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_drug cm_htn_c cm_hypothy 
			cm_liver cm_lymph cm_lytes cm_mets cm_neuro cm_obese cm_para cm_perivasc cm_psych cm_pulmcirc 
			cm_renlfail cm_tumor cm_ulcer  cm_valve cm_wghtloss /style=[cellwidth=3in asis=on];
	table died cm_aids cm_alcohol cm_anemdef cm_arth onset
			cm_bldloss cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_drug cm_htn_c cm_hypothy 
			cm_liver cm_lymph cm_lytes cm_mets cm_neuro cm_obese cm_para cm_perivasc cm_psych cm_pulmcirc 
			cm_renlfail cm_tumor cm_ulcer  cm_valve cm_wghtloss,
		overall=''*(n*f=4.0 colpctn='(%)'*f=pctfmt.)
		year= 'Year of Discharge'*(n*f=4.0 colpctn='(%)'*f=pctfmt.)/misstext='0' rts=15;
format  died yesno_. cm_aids yesno_. cm_alcohol yesno_. onset yesno_.
		cm_anemdef yesno_. cm_arth yesno_. cm_bldloss yesno_. cm_chf yesno_. cm_chrnlung yesno_. cm_coag yesno_. 
		cm_depress yesno_. cm_dm yesno_. cm_dmcx yesno_. cm_drug yesno_. cm_htn_c yesno_. cm_hypothy yesno_. cm_liver yesno_. 
		cm_lymph yesno_. cm_lytes yesno_. cm_mets yesno_. cm_neuro yesno_. cm_obese yesno_. cm_para yesno_. cm_perivasc yesno_. 
		cm_psych yesno_. cm_pulmcirc yesno_. cm_renlfail yesno_. cm_tumor yesno_. cm_ulcer yesno_. cm_valve yesno_. 
		cm_wghtloss yesno_. overall overall.;
run;


ods csv file= "/Volumes/My Passport for Mac/adrdproject/table1a.csv" style=karamtables;

title1 "Yearly Differences in Demographic and Socioeconomic Characteristic of ADRD Patients";

/******************* TABLE 1A in TEXT *************************************************/

proc tabulate data=tabin missing order=formatted;
	class year female dispuniform pay1 agegrp zipinc_qrtl pdiagad pdiagrd adrdv hosp_bedsize 
			h_contrl hosp_urcat4 hosp_ur_teach rehabtransfer overall;
	classlev female dispuniform pay1 agegrp zipinc_qrtl pdiagad pdiagrd adrdv hosp_bedsize 
			h_contrl hosp_urcat4 hosp_ur_teach rehabtransfer /style=[cellwidth=3in asis=on];
	table female dispuniform pay1 agegrp zipinc_qrtl pdiagad pdiagrd adrdv hosp_bedsize 
			h_contrl hosp_urcat4 hosp_ur_teach rehabtransfer,
		overall=''*(n*f=4.0 colpctn='(%)'*f=pctfmt.)
		year= 'Year of Discharge'*(n*f=4.0 colpctn='(%)'*f=pctfmt.)/misstext='0' rts=15;
format female female_. dispuniform dispuniform_. pay1 pay1_. agegrp agegrp_. zipinc_qrtl zipinc_qrtl_.
		hosp_bedsize hosp_bedsize_. h_contrl h_contrl_. hosp_urcat4 hosp_urcat4_. hosp_ur_teach hosp_ur_teach_. 
		pdiagad yesno_. pdiagrd yesno_. adrdv yesno_. rehabtransfer yesno_. overall overall.;
run;


* Creating table 1b*;
options orientation=landscape;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table1b.csv" style=karamtables;

title1 "Yearly Differences in Hospital Resource Utilization of ADRD Patients";

proc tabulate data=tabin missing order=formatted;
	class year stratif;
	var totchgadj los age costadj wagadj mortal_score readmit_score;
	table totchgadj los age costadj wagadj mortal_score readmit_score,
		year='Year of Diagnosis'*(mean*f=6.1 stddev*f=6.1)
		stratif='Stratif'*(mean*f=6.1 stddev*f=6.1);
	format stratif stratif_. overall overall. totchgadj totchgadj. los los. age age. costadj costadj. wagadj wagadj.
	readmit_score readmit_score. mortal_score mortal_score.;
run;


/* Chi-Square Categorical Variables data set with 2015 cohort*/

data tabin;
set datain;
label pay1='Payer';
label female = 'Gender';
label agegrp='Age Groups';
label totchgadj='Total Charges Adjusted';
label costadj='Cost of Service Adjusted';
label wagadj='Hospital Wage Level in the Patient Area Adjusted';
label los='Lenght of Stay';
label died='Mortality';
label pdiagad='Patients with Alzheimer Disease';
label pdiagrd='Patients with Dementias Relating Alzheimer Disease';
label adrdv='Patients with Alzheimer Disease and Related ';
label readmit_score='Readmission Score';
label mortal_score='Mortality Score';
label year = 'Year of Discharge'; 
label overall = 'overall data set';

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table1c.csv" style=karamtables;

title1 "Chisquare Test for Clinical Characteristic of ADRD Patients";

/******************* TABLE 1c in TEXT *************************************************/

proc freq data=tabin order=formatted;
	tables (year)*(died cm_aids cm_alcohol cm_anemdef cm_arth onset
			cm_bldloss cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_drug cm_htn_c cm_hypothy 
			cm_liver cm_lymph cm_lytes cm_mets cm_neuro cm_obese cm_para cm_perivasc cm_psych cm_pulmcirc 
			cm_renlfail cm_tumor cm_ulcer  cm_valve cm_wghtloss)/ chisq;
	format died yesno_. cm_aids yesno_. cm_alcohol yesno_. onset yesno_.
		cm_anemdef yesno_. cm_arth yesno_. cm_bldloss yesno_. cm_chf yesno_. cm_chrnlung yesno_. cm_coag yesno_. 
		cm_depress yesno_. cm_dm yesno_. cm_dmcx yesno_. cm_drug yesno_. cm_htn_c yesno_. cm_hypothy yesno_. cm_liver yesno_. 
		cm_lymph yesno_. cm_lytes yesno_. cm_mets yesno_. cm_neuro yesno_. cm_obese yesno_. cm_para yesno_. cm_perivasc yesno_. 
		cm_psych yesno_. cm_pulmcirc yesno_. cm_renlfail yesno_. cm_tumor yesno_. cm_ulcer yesno_. cm_valve yesno_. 
		cm_wghtloss yesno_.;
run;

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table1d.csv" style=karamtables;

title1 "Chisquare Test for Demographic and Socioeconomic Characteristic of ADRD Patients";

/******************* TABLE 1d in TEXT *************************************************/

proc freq data=tabin order=formatted;
	tables (year)*(female dispuniform pay1 agegrp zipinc_qrtl pdiagad pdiagrd adrdv hosp_bedsize 
			h_contrl hosp_urcat4 hosp_ur_teach rehabtransfer)/ chisq;
	format female female_. dispuniform dispuniform_. pay1 pay1_. agegrp agegrp_. zipinc_qrtl zipinc_qrtl_.
	hosp_bedsize hosp_bedsize_. h_contrl h_contrl_. hosp_urcat4 hosp_urcat4_. hosp_ur_teach hosp_ur_teach_. 
		pdiagad yesno_. pdiagrd yesno_. adrdv yesno_. rehabtransfer yesno_.;
run;


/* Test for continiuos Variables data set with 2015 cohort*/

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table1e.csv" style=karamtables;

title1 "Yearly Differences in Hospital Resource Utilization of ADRD Patients";

/******************* TABLE 1e in TEXT *************************************************/

/* with Year */

proc glm data=tabin order=formatted;
	class year;
	model totchgadj = year;
	means year/bon; 
run;

proc glm data=tabin order=formatted;
	class year;
	model los = year;
	means year/bon; 
run;

proc glm data=tabin order=formatted;
	class year;
	model costadj = year;
	means year/bon; 
run;

proc glm data=tabin order=formatted;
	class year;
	model wagadj = year;
	means year/bon; 
run;

proc glm data=tabin order=formatted;
	class year;
	model mortal_score = year;
	means year/bon; 
run;

proc glm data=tabin order=formatted;
	class year;
	model readmit_score = year;
	means year/bon; 
run;

/* with stratif */

proc glm data=tabin order=formatted;
	class stratif;
	model totchgadj = stratif;
	means stratif/bon; 
run;

proc glm data=tabin order=formatted;
	class stratif;
	model los = stratif;
	means stratif/bon; 
run;

proc glm data=tabin order=formatted;
	class stratif;
	model costadj = stratif;
	means stratif/bon; 
run;

proc glm data=tabin order=formatted;
	class stratif;
	model wagadj = stratif;
	means stratif/bon; 
run;

proc glm data=tabin order=formatted;
	class stratif;
	model mortal_score = stratif;
	means stratif/bon; 
run;

proc glm data=tabin order=formatted;
	class stratif;
	model readmit_score = stratif;
	means stratif/bon; 
run;


/* Labeling Categorical Variables data set without 4th q of 2015 cohort*/

data tabout;
set dataout;
label pay1='Payer';
label female = 'Gender';
label agegrp='Age Groups';
label totchgadj='Total Charges Adjusted';
label costadj='Cost of Service Adjusted';
label wagadj='Hospital Wage Level in the Patient Area Adjusted';
label los='Lenght of Stay';
label died='Mortality';
label pdiagad='Patients with Alzheimer Disease';
label pdiagrd='Patients with Dementias Relating Alzheimer Disease';
label adrdv='Patients with Alzheimer Disease and Related ';
label readmit_score='Readmission Score';
label mortal_score='Mortality Score';
label year = 'Year of Discharge'; 
label overall = 'overall data set';

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table2.csv" style=karamtables;

title1 "Yearly Differences in Clinical Characteristic of ADRD Patients";

/******************* TABLE 2 in TEXT *************************************************/

proc tabulate data=tabout missing order=formatted;
	class year died cm_aids cm_alcohol cm_anemdef cm_arth onset
			cm_bldloss cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_drug cm_htn_c cm_hypothy 
			cm_liver cm_lymph cm_lytes cm_mets cm_neuro cm_obese cm_para cm_perivasc cm_psych cm_pulmcirc 
			cm_renlfail cm_tumor cm_ulcer  cm_valve cm_wghtloss overall;
	classlev died cm_aids cm_alcohol cm_anemdef cm_arth onset
			cm_bldloss cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_drug cm_htn_c cm_hypothy 
			cm_liver cm_lymph cm_lytes cm_mets cm_neuro cm_obese cm_para cm_perivasc cm_psych cm_pulmcirc 
			cm_renlfail cm_tumor cm_ulcer  cm_valve cm_wghtloss /style=[cellwidth=3in asis=on];
	table died cm_aids cm_alcohol cm_anemdef cm_arth onset
			cm_bldloss cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_drug cm_htn_c cm_hypothy 
			cm_liver cm_lymph cm_lytes cm_mets cm_neuro cm_obese cm_para cm_perivasc cm_psych cm_pulmcirc 
			cm_renlfail cm_tumor cm_ulcer  cm_valve cm_wghtloss,
		overall=''*(n*f=4.0 colpctn='(%)'*f=pctfmt.)
		year= 'Year of Discharge'*(n*f=4.0 colpctn='(%)'*f=pctfmt.)/misstext='0' rts=15;
format  died yesno_. cm_aids yesno_. cm_alcohol yesno_. onset yesno_.
		cm_anemdef yesno_. cm_arth yesno_. cm_bldloss yesno_. cm_chf yesno_. cm_chrnlung yesno_. cm_coag yesno_. 
		cm_depress yesno_. cm_dm yesno_. cm_dmcx yesno_. cm_drug yesno_. cm_htn_c yesno_. cm_hypothy yesno_. cm_liver yesno_. 
		cm_lymph yesno_. cm_lytes yesno_. cm_mets yesno_. cm_neuro yesno_. cm_obese yesno_. cm_para yesno_. cm_perivasc yesno_. 
		cm_psych yesno_. cm_pulmcirc yesno_. cm_renlfail yesno_. cm_tumor yesno_. cm_ulcer yesno_. cm_valve yesno_. 
		cm_wghtloss yesno_. overall overall.;
run;


ods csv file= "/Volumes/My Passport for Mac/adrdproject/table2a.csv" style=karamtables;

title1 "Yearly Differences in Demographic and Socioeconomic Characteristic of ADRD Patients";

/******************* TABLE 2A in TEXT *************************************************/

proc tabulate data=tabout missing order=formatted;
	class year female dispuniform pay1 agegrp zipinc_qrtl pdiagad pdiagrd adrdv hosp_bedsize 
			h_contrl hosp_urcat4 hosp_ur_teach rehabtransfer overall;
	classlev female dispuniform pay1 agegrp zipinc_qrtl pdiagad pdiagrd adrdv hosp_bedsize 
			h_contrl hosp_urcat4 hosp_ur_teach rehabtransfer /style=[cellwidth=3in asis=on];
	table female dispuniform pay1 agegrp zipinc_qrtl pdiagad pdiagrd adrdv hosp_bedsize 
			h_contrl hosp_urcat4 hosp_ur_teach rehabtransfer,
		overall=''*(n*f=4.0 colpctn='(%)'*f=pctfmt.)
		year= 'Year of Discharge'*(n*f=4.0 colpctn='(%)'*f=pctfmt.)/misstext='0' rts=15;
format female female_. dispuniform dispuniform_. pay1 pay1_. zipinc_qrtl zipinc_qrtl_.
		hosp_bedsize hosp_bedsize_. h_contrl h_contrl_. hosp_urcat4 hosp_urcat4_. hosp_ur_teach hosp_ur_teach_. 
		pdiagad yesno_. pdiagrd yesno_. adrdv yesno_. rehabtransfer yesno_. overall overall.;
run;


* Creating table 2b*;
options orientation=landscape;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table2b.csv" style=karamtables;

title1 "Yearly Differences in Hospital Resource Utilization of ADRD Patients";

proc tabulate data=tabout missing order=formatted;
	class year stratif;
	var totchgadj los age costadj wagadj mortal_score readmit_score;
	table totchgadj los age costadj wagadj mortal_score readmit_score,
		year='Year of Diagnosis'*(mean*f=6.1 stddev*f=6.1)
		stratif='Stratif'*(mean*f=6.1 stddev*f=6.1);
	format stratif stratif_. overall overall. totchgadj totchgadj. los los. age age. costadj costadj. wagadj wagadj.
	readmit_score readmit_score. mortal_score mortal_score.;
run;

/* Chi-Square Categorical Variables data set without 4th q of 2015 cohort*/

data tabout;
set dataout;
label pay1='Payer';
label female = 'Gender';
label agegrp='Age Groups';
label totchgadj='Total Charges Adjusted';
label costadj='Cost of Service Adjusted';
label wagadj='Hospital Wage Level in the Patient Area Adjusted';
label los='Lenght of Stay';
label died='Mortality';
label pdiagad='Patients with Alzheimer Disease';
label pdiagrd='Patients with Dementias Relating Alzheimer Disease';
label adrdv='Patients with Alzheimer Disease and Related ';
label readmit_score='Readmission Score';
label mortal_score='Mortality Score';
label year = 'Year of Discharge'; 
label overall = 'overall data set';

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table2c.csv" style=karamtables;

title1 "Chisquare Test for Clinical Characteristic of ADRD Patients";

/******************* TABLE 2c in TEXT *************************************************/

proc freq data=tabout order=formatted;
	tables (year)*(died cm_aids cm_alcohol cm_anemdef cm_arth onset
			cm_bldloss cm_chf cm_chrnlung cm_coag cm_depress cm_dm cm_dmcx cm_drug cm_htn_c cm_hypothy 
			cm_liver cm_lymph cm_lytes cm_mets cm_neuro cm_obese cm_para cm_perivasc cm_psych cm_pulmcirc 
			cm_renlfail cm_tumor cm_ulcer  cm_valve cm_wghtloss)/ chisq;
	format died yesno_. cm_aids yesno_. cm_alcohol yesno_. onset yesno_.
		cm_anemdef yesno_. cm_arth yesno_. cm_bldloss yesno_. cm_chf yesno_. cm_chrnlung yesno_. cm_coag yesno_. 
		cm_depress yesno_. cm_dm yesno_. cm_dmcx yesno_. cm_drug yesno_. cm_htn_c yesno_. cm_hypothy yesno_. cm_liver yesno_. 
		cm_lymph yesno_. cm_lytes yesno_. cm_mets yesno_. cm_neuro yesno_. cm_obese yesno_. cm_para yesno_. cm_perivasc yesno_. 
		cm_psych yesno_. cm_pulmcirc yesno_. cm_renlfail yesno_. cm_tumor yesno_. cm_ulcer yesno_. cm_valve yesno_. 
		cm_wghtloss yesno_.;
run;

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table2d.csv" style=karamtables;

title1 "Chisquare Test for Demographic and Socioeconomic Characteristic of ADRD Patients";

/******************* TABLE 2d in TEXT *************************************************/

proc freq data=tabout order=formatted;
	tables (year)*(female dispuniform pay1 agegrp zipinc_qrtl pdiagad pdiagrd adrdv hosp_bedsize 
			h_contrl hosp_urcat4 hosp_ur_teach rehabtransfer)/ chisq;
	format female female_. dispuniform dispuniform_. pay1 pay1_. agegrp agegrp_. zipinc_qrtl zipinc_qrtl_.
		hosp_bedsize hosp_bedsize_. h_contrl h_contrl_. hosp_urcat4 hosp_urcat4_. hosp_ur_teach hosp_ur_teach_. 
		pdiagad yesno_. pdiagrd yesno_. adrdv yesno_. rehabtransfer yesno_.;
run;


/* Test for continiuos Variables data set without 4th q of 2015 cohort*/

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table2e.csv" style=karamtables;

title1 "Yearly Differences in Hospital Resource Utilization of ADRD Patients";

/******************* TABLE 2e in TEXT *************************************************/

/* with Year */

proc glm data=tabout order=formatted;
	class year;
	model totchgadj = year;
	means year/bon; 
run;

proc glm data=tabout order=formatted;
	class year;
	model los = year;
	means year/bon; 
run;

proc glm data=tabout order=formatted;
	class year;
	model costadj = year;
	means year/bon; 
run;

proc glm data=tabout order=formatted;
	class year;
	model wagadj = year;
	means year/bon; 
run;

proc glm data=tabout order=formatted;
	class year;
	model mortal_score = year;
	means year/bon; 
run;

proc glm data=tabout order=formatted;
	class year;
	model readmit_score = year;
	means year/bon; 
run;

/* with stratif */

proc glm data=tabout order=formatted;
	class stratif;
	model totchgadj = stratif;
	means stratif/bon; 
run;

proc glm data=tabout order=formatted;
	class stratif;
	model los = stratif;
	means stratif/bon; 
run;

proc glm data=tabout order=formatted;
	class stratif;
	model costadj = stratif;
	means stratif/bon; 
run;

proc glm data=tabout order=formatted;
	class stratif;
	model wagadj = stratif;
	means stratif/bon; 
run;

proc glm data=tabout order=formatted;
	class stratif;
	model mortal_score = stratif;
	means stratif/bon; 
run;

proc glm data=tabout order=formatted;
	class stratif;
	model readmit_score = stratif;
	means stratif/bon; 
run;

/*End Descriptive Analysis*/


/*Droping the overall variable*/

data datain; set adrd.adjdatain; drop overall totchg costs wages; run;
data dataout; set adrd.adjdataout; drop overall totchg costs wages; run;

/**************************************************************************
**************************************************************************/

/*Start Explanatory Analysis*/


/* Correlation test */;

/* data set with 2015 cohort*/

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table3.csv" style=karamtables;

title3 "Correlation Test for Clinical, Demographic and Socioeconomic Characteristic of ADRD Patients";

proc corr data=datain ;
var 
    agegrp age year female wagadj pay1 zipinc_qrtl rehabtransfer 
    hosp_bedsize hosp_urcat4 hosp_ur_teach h_contrl 
    cm_aids cm_alcohol cm_anemdef cm_arth cm_bldloss cm_chf cm_chrnlung cm_coag 
    cm_depress cm_dm cm_dmcx cm_drug cm_htn_c cm_hypothy cm_liver cm_lymph 
    cm_lytes cm_mets cm_neuro cm_obese cm_para cm_perivasc cm_psych cm_pulmcirc 
    cm_renlfail cm_tumor cm_ulcer cm_valve cm_wghtloss;
run;

/* data set without 4th q of 2015 cohort*/

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table4.csv" style=karamtables;

title4 "Correlation Test for Clinical, Demographic and Socioeconomic Characteristic of ADRD Patients";

proc corr data=dataout ;
var 
    agegrp age year female wagadj pay1 zipinc_qrtl rehabtransfer 
    hosp_bedsize hosp_urcat4 hosp_ur_teach h_contrl 
    cm_aids cm_alcohol cm_anemdef cm_arth cm_bldloss cm_chf cm_chrnlung cm_coag 
    cm_depress cm_dm cm_dmcx cm_drug cm_htn_c cm_hypothy cm_liver cm_lymph 
    cm_lytes cm_mets cm_neuro cm_obese cm_para cm_perivasc cm_psych cm_pulmcirc 
    cm_renlfail cm_tumor cm_ulcer cm_valve cm_wghtloss;
run;


*some correlations do exist such as alcohol abuse and coag;


/*Test for missing data*/


/* data set with 2015 cohort*/

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table5.csv" style=karamtables;

title5 "Test for Missingness on the data set of ADRD Patients";

proc mi data=datain nimpute=0; ods select misspattern; run;

/*Delete missing data*/

data datainmis; set datain; if cmiss (of _all_) ge 5 then delete; run;
proc stdize data=datainmis out=datainn reponly missing=0; run;

/* Test for missing values*/

proc mi data=datainn nimpute=0; ods select misspattern; run;



/* data set without 4th q of 2015 cohort*/

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table6.csv" style=karamtables;

title6 "Test for Missingness on the data set of ADRD Patients";

proc mi data=dataout nimpute=0; ods select misspattern; run;

/*Delete missing data*/

data dataoutmis; set dataout; if cmiss (of _all_) ge 5 then delete; run;
proc stdize data=dataoutmis out=dataoutn reponly missing=0; run;

/* Test for missing values*/

proc mi data=dataoutn nimpute=0; ods select misspattern; run;


/*saving data sets*/

data adrd.datainn; set datainn; run;
data adrd.dataoutn; set dataoutn; run;

/**********************************************************************************/

Libname users "/Volumes/My Passport for Mac/adrdproject"; /*NRD Datasets Library*/
Libname adrd "/Volumes/My Passport for Mac/adrdproject/adrd";

/**********************************************************************************/

/*Returning data sets into sas work shell*/

data datainn; set adrd.datainn; run;
data dataoutn; set adrd.dataoutn; run;


/*Logistic Regression for Mortality*/

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table7.csv" style=karamtables;

title7 "Logistic Regression Full for Mortality of ADRD Patients";

proc logistic data=datainn;
	weight discwt;
	class agegrp female pay1 rehabtransfer hosp_bedsize hosp_urcat4 hosp_ur_teach h_contrl/param=glm;
	model died(event='1')=age agegrp year female wagadj pay1 zipinc_qrtl  
    rehabtransfer hosp_bedsize hosp_urcat4 hosp_ur_teach h_contrl ndx npr
    mortal_score/link=glogit expb rsquare;
run;


/*Generalized Linear Regression for Totchg*/

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table8.csv" style=karamtables;

title8 "Generalized Linear Regression for Total Charges of ADRD Patients";

proc genmod data=datainn;
	weight discwt;
	class agegrp female pay1 rehabtransfer dispuniform hosp_bedsize hosp_urcat4 hosp_ur_teach h_contrl/param=glm;
	model totchgadj=age agegrp female wagadj year pay1 zipinc_qrtl
    rehabtransfer hosp_bedsize hosp_urcat4 hosp_ur_teach h_contrl ndx npr dispuniform
    cm_aids cm_alcohol cm_anemdef cm_arth cm_bldloss cm_chf cm_chrnlung cm_coag cm_depress cm_dm 
    cm_dmcx cm_drug cm_htn_c cm_hypothy cm_liver cm_lymph cm_lytes cm_mets cm_neuro cm_obese
    cm_para cm_perivasc cm_psych cm_pulmcirc cm_renlfail cm_tumor cm_ulcer cm_valve cm_wghtloss/ dist=tweedie link=log;
run;

/*Generalized Linear Regression for LOS*/

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table9.csv" style=karamtables;

title10 "Generalized Linear Regression for Lenght of Stay of ADRD Patients";

proc genmod data=datainn;
	weight discwt;
	class agegrp female pay1 rehabtransfer hosp_bedsize dispuniform hosp_urcat4 hosp_ur_teach h_contrl/param=glm;
	model los=age agegrp female year wagadj pay1 zipinc_qrtl dispuniform
    rehabtransfer hosp_bedsize hosp_urcat4 hosp_ur_teach h_contrl ndx npr
    cm_aids cm_alcohol cm_anemdef cm_arth cm_bldloss cm_chf cm_chrnlung cm_coag cm_depress cm_dm 
    cm_dmcx cm_drug cm_htn_c cm_hypothy cm_liver cm_lymph cm_lytes cm_mets cm_neuro cm_obese
    cm_para cm_perivasc cm_psych cm_pulmcirc cm_renlfail cm_tumor cm_ulcer cm_valve cm_wghtloss/ dist=tweedie link=log;
run;

/*Generalized Linear Regression for Costs*/

options orientation=portrait;

ods csv file= "/Volumes/My Passport for Mac/adrdproject/table10.csv" style=karamtables;

title11 "Generalized Linear Regression for Total Charges of ADRD Patients";

proc genmod data=datainn;
	weight discwt;
	class agegrp female pay1 rehabtransfer hosp_bedsize dispuniform hosp_urcat4 hosp_ur_teach h_contrl/param=glm;
	model costadj=age agegrp female year wagadj pay1 zipinc_qrtl dispuniform
    rehabtransfer hosp_bedsize hosp_urcat4 hosp_ur_teach h_contrl ndx npr
    cm_aids cm_alcohol cm_anemdef cm_arth cm_bldloss cm_chf cm_chrnlung cm_coag cm_depress cm_dm 
    cm_dmcx cm_drug cm_htn_c cm_hypothy cm_liver cm_lymph cm_lytes cm_mets cm_neuro cm_obese
    cm_para cm_perivasc cm_psych cm_pulmcirc cm_renlfail cm_tumor cm_ulcer cm_valve cm_wghtloss/ dist=tweedie link=log;
run;


/**************************************************************************
**************************************************************************/

/*Exporting data files for the csv format*/

/* data set with 2015 cohort*/

proc export data=datainn
  dbms=csv 
  outfile="/Volumes/My Passport for Mac/adrdproject/dataina.csv";
run;

/* data set without 4th q of 2015 cohort*/

proc export data=dataoutn
  dbms=csv 
  outfile="/Volumes/My Passport for Mac/adrdproject/dataouta.csv";
run;


/*Importing data files for the csv format*/

proc import datafile ="/Volumes/My Passport for Mac/adrdproject/adrd/dataina.csv"
  out=work.dataina
  dbms=csv; 
run;

/* data set without 4th q of 2015 cohort*/

proc import datafile ="/Volumes/My Passport for Mac/adrdproject/adrd/dataouta.csv"
  out=work.dataouta
  dbms=csv; 
run;


