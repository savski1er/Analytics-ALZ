/*********************************************************************************************/
* Main Code*

/*********************************************************************************************/;

Libname users "C:\Users\Vassiki Sanogo\Desktop\adrdproject"; /*NRD Datasets Library*/
Libname dat "C:\Users\Vassiki Sanogo\Desktop\adrdproject\dat";
Libname adrd "C:\Users\Vassiki Sanogo\Desktop\adrdproject\adrd";

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
age female zipinc_qrtl died npr los totchg pay1 drg ndx dispuniform rehabtransfer dx:);
run;

%mend coret;

%coret (adrd.core10, cor10);
%coret (adrd.core11, cor11);
%coret (adrd.core12, cor12);
%coret (adrd.core13, cor13);
%coret (adrd.core14, cor14);

/*apply inclusion criteria*/

%Macro corincl (input, output);

data &output;
set &input;
if age>=30 then do;
if dx1 in ('3310', '2940', '2941') or dx2 in ('3310', '2940', '2941') then adrd=1;

if dx1='3310' or dx2='3310' then pdiagad=1;
else pdiagad=0;
if dx1 in ('2940', '2941') or dx2 in ('2940', '2941') then pdiagrd=1;
else pdiagrd=0;
end;
if adrd=1;
run;

%mend corincl;

%corincl (cor10, i10);
%corincl (cor11, i11);
%corincl (cor12, i12);
%corincl (cor13, i13);
%corincl (cor14, i14);


/*keep relevent variables in Sever*/

%Macro coret (input, output);

data &output;
set &input (drop= APRDRG APRDRG_Risk_Mortality APRDRG_Severity);
run;

%mend coret;

%coret (adrd.sever10, sev10);
%coret (adrd.sever11, sev11);
%coret (adrd.sever12, sev12);
%coret (adrd.sever13, sev13);
%coret (adrd.sever14, sev14);


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

%reta (i10, sev10, j10);
%reta (i11, sev11, j11);
%reta (i12, sev12, j12);
%reta (i13, sev13, j13);
%reta (i14, sev14, j14);


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

%retb (j10, adrd.hosp10, adrd10); /*47,666 obs*/
%retb (j11, adrd.hosp11, adrd11); /*44,644 obs*/
%retb (j12, adrd.hosp12, adrd12); /*37,889 obs*/
%retb (j13, adrd.hosp13, adrd13); /*35,231 obs*/
%retb (j14, adrd.hosp14, adrd14); /*33,141 obs*/


/*keep relevent variables in core *Year 2015*/

%Macro coret (input, output);

data &output;
set &input (keep= year hosp_nrd key_nrd nrd_stratum discwt nrd_visitlink
	age female zipinc_qrtl died los totchg pay1 dispuniform rehabtransfer);
run;

%mend coret;

%coret (adrd.core15, cor15);


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

%coretq (cor15, dx1_3q15, dx4q15, corq15);


/*apply inclusion criteria*/

/*data set with full 2015 cohort*/

%Macro corincl (input, output);

data &output;
set &input;
if age>=30 then do;
if dx1 in ('3310', '2940', '2941') or i10_dx1 in ('F000', 'F001', 'F05', 'G300', 'G301', 'G308', 'G309') 
or dx2 in ('3310', '2940', '2941') or i10_dx2 in ('F000', 'F001', 'F05', 'G300', 'G301', 'G308', 'G309') then adrd=1;

if dx1 in ('3310') or i10_dx1 in ('G300', 'G301', 'G308', 'G309') or 
	dx2 in ('3310') or i10_dx2 in ('G300', 'G301', 'G308', 'G309') then pdiagad=1;
else pdiagad=0;
if dx1 in ('2940', '2941') or i10_dx1 in ('F000', 'F001', 'F05') or
	 dx2 in ('2940', '2941') or i10_dx2 in ('F000', 'F001', 'F05') then pdiagrd=1;
else pdiagrd=0;
end;
if adrd=1;
run;

%mend corincl;

%corincl (corq15, i15);

/*data set without 4th quarter 2015 cohort*/

%Macro corincl (input, output);

data &output;
set &input;
if age>=30 then do;
if dx1 in ('3310', '2940', '2941') or dx2 in ('3310', '2940', '2941') then adrd=1;

if dx1 in ('3310') or dx2 in ('3310') then pdiagad=1;
else pdiagad=0;
if dx1 in ('2940', '2941') or dx2 in ('2940', '2941') then pdiagrd=1;
else pdiagrd=0;
end;
if adrd=1;
run;

%mend corincl;

%corincl (corq15, i15q13);


/*keep relevent variables in Sever*/

%Macro coret (input, output);

data &output;
set &input (drop= APRDRG APRDRG_Risk_Mortality APRDRG_Severity);
run;

%mend coret;

%coret (adrd.sever3q15, sev15);


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

%reta (i15, sev15, j15);
%reta (i15q13, sev15, j15q13);


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

%retb (j15, adrd.hosp15, adrd15); /*55,823 obs*/
%retb (j15q13, adrd.hosp15, adrd15q13); /*37,994 obs*/


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

%retb (adrd10, adrd.ccr10, adrdc10); /*47,666 obs*/
%retb (adrd11, adrd.ccr11, adrdc11); /*44,644 obs*/
%retb (adrd12, adrd.ccr12, adrdc12); /*37,889 obs*/
%retb (adrd13, adrd.ccr13, adrdc13); /*35,231 obs*/
%retb (adrd14, adrd.ccr14, adrdc14); /*33,141 obs*/
%retb (adrd15, adrd.ccr15, adrdc15); /*55,879 obs*/
%retb (adrd15q13, adrd.ccr15, adrdc15q13); /*37,994 obs*/


/*data consolidation for the work data set with full 2015 cohort*/

data adrd.datadrd; /*254,450 obs*/
set adrdc10 adrdc11 adrdc12 adrdc13 adrdc14 adrdc15;
drop adrd;
if pdiagad=1 and cm_depress=1 then addepr=1;
else addepr=0;
if 30 <= age < 45 then agegrp=1;
else if 45 <= age < 55 then agegrp=2;
else if 55 <= age < 65 then agegrp=3;
else if 65 <= age then agegrp=4;
costs= totchg*ccr_nrd;
wages= totchg*wageindex;
run;


/*data consolidation for the work data set without 4th quarter 2015 cohort*/

data adrd.datadrd1; /*198,571 obs*/
set adrdc10 adrdc11 adrdc12 adrdc13 adrdc14 adrdc15q13;
drop adrd;
if pdiagad=1 and cm_depress=1 then addepr=1;
else addepr=0;
if 30 <= age < 45 then agegrp=1;
else if 45 <= age < 55 then agegrp=2;
else if 55 <= age < 65 then agegrp=3;
else if 65 <= age then agegrp=4;
costs= totchg*ccr_nrd;
wages= totchg*wageindex;
run;

/*Returning data sets into work shell*/

data datadrd; set adrd.datadrd; run;
data datadrd1; set adrd.datadrd1; run;


/*Creating the comorbidities including the ALD and ARD comorbidities*/

Libname in1 "C:\Users\Vassiki Sanogo\Desktop\adrdproject\data\in1";
Libname out1 "C:\Users\Vassiki Sanogo\Desktop\adrdproject\data\out1";
data in1.adrdcomob; set datadrd (keep= drg ndx key_nrd dx1-dx30 i10_dx1-i10_dx30 ); run;
data dtadrdw; set datadrd (drop=drg dx: i10_dx: ); run;
data dtadrdw1; set datadrd1 (drop=drg dx: i10_dx:); run;
data analysis; set out1.analysis; run;


proc sort data=  dtadrdw nodupkey; by key_nrd; run;
proc sort data=  dtadrdw1 nodupkey; by key_nrd; run;

/*Joining the comorbidities with the data set with 2015 cohort*/

proc sql;
create table datwork as
select* 
from dtadrdw left join analysis
on dtadrdw. key_nrd = analysis. key_nrd;
quit;

/*Joining the comorbidities with the data set without 4th q of 2015 cohort*/

proc sql;
create table datwork1 as
select* 
from dtadrdw1 left join analysis
on dtadrdw1. key_nrd = analysis. key_nrd;
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

/*2015 cohort in (obs 254,752)*/

data adrd.datain; set data1 (drop=nrd_visitlink n_disc_u n_hosp_u s_disc_u s_hosp_u total_disc ccr_nrd wageindex ald ard aids alcohol anemdef arth
	bldloss chf chrnlung coag depress dm dmcx drug htn_c hypothy 
	liver lymph lytes mets neuro para perivasc psych pulmcirc 
	renlfail tumor ulcer valve wghtloss); run;

/*2015 cohort out (obs 236,867)*/

data adrd.dataout; set data2 (drop=nrd_visitlink n_disc_u n_hosp_u s_disc_u s_hosp_u total_disc ccr_nrd wageindex ald ard aids alcohol anemdef arth
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

data datain; set adrd.adjdatain; drop costs totchg wages addepr; run;
data dataout; set adrd.adjdataout; drop costs totchg wages addepr; run;


/*End Data Pre-Processing*/
data datainn; set dat.datainn; run;

data datainn (drop=dxn);
set datainn;
if ndx=0 then none=1;
else none=0;
if ndx in (1,2) then mild=1;
else mild=0;
if ndx in (3,4) then moderate=1;
else moderate=0;
if ndx>=5 then severe=1;
else severe=0;
output;
run;

data datainn; set datainn;
if los in (0,1,2) then clos=1;
if los in (3,4) then clos=2;
if los in (6,5) then clos=3;
if los >=7 then clos=4;
run;

data dat.datainn; set datainn; run;

proc freq data=datainn; tables none mild moderate severe clos; run;
