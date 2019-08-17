* Connect to data;
libname mydata "/courses/d54816e5ba27fe300" access=readonly ;

* Shorten data name, save to work library;
data temp;
set mydata.stock_portfolio_data;
run;

* start of Q1;
proc sort data=temp; by date; run; quit;

data temp;
set temp;
 return_AA = log(AA/lag1(AA));
 return_BAC = log(BAC/lag1(BAC));
 return_BHI = log(BHI/lag1(BHI));
 return_CVX = log(CVX/lag1(CVX));
 return_DD = log(DD/lag1(DD));
 return_DOW = log(DOW/lag1(DOW));
 return_HUN = log(HUN/lag1(HUN));
 return_JPM = log(JPM/lag1(JPM));
 return_KO = log(KO/lag1(KO));
 return_MMM = log(MMM/lag1(MMM));
 return_MPC = log(MPC/lag1(MPC));
 return_PEP = log(PEP/lag1(PEP));
 return_SLB = log(SLB/lag1(SLB));
 return_WFC = log(WFC/lag1(WFC));
 return_XOM = log(XOM/lag1(XOM));
 response_VV = log(VV/lag1(VV));
run;
response_VV = log(VV/lag1(VV));
run;
* end of Q1;

* start of Q2;
proc print data=temp(obs=10); run; quit;
ods output PearsonCorr=portfolio_correlations;
proc corr data=temp;
var return_:;
with response_VV;
run; quit;
proc print data=portfolio_correlations; run; quit;
* end of Q2;

* start of Q3;
data wide_correlations;
 set portfolio_correlations (keep=return_:);
run;

proc transpose data=wide_correlations out=long_correlations;
run; quit;

data long_correlations;
 set long_correlations;
 tkr = substr(_NAME_,8,3);
 drop _NAME_;
 rename COL1=correlation;
run;

proc print data=long_correlations; run; quit;
* end of Q3;

* start of Q4;
data sector;
input tkr $ 1-3 sector $ 4-35;
datalines;
AA Industrial - Metals
BAC Banking
BHI Oil Field Services
CVX Oil Refining
DD Industrial - Chemical
DOW Industrial - Chemical
DPS Soft Drinks
GS Banking
HAL Oil Field Services
HES Oil Refining
HON Manufacturing
HUN Industrial - Chemical
JPM Banking
KO Soft Drinks
MMM Manufacturing
MPC Oil Refining
PEP Soft Drinks
SLB Oil Field Services
WFC Banking
XOM Oil Refining
VV Market Index
;
run;

proc print data=sector; run; quit;

proc sort data=sector; by tkr; run;

proc sort data=long_correlations; by tkr; run;

data long_correlations;
 merge long_correlations (in=a) sector (in=b);
 by tkr;
 if (a=1) and (b=1);
run;

proc print data=long_correlations; run; quit;

ods graphics on;
title 'Correlations with the Market Index';

proc sgplot data=long_correlations;
 format correlation 3.2;
 vbar tkr / response=correlation group=sector groupdisplay=cluster datalabel;
run; quit;
ods graphics off;

proc means data=long_correlations nway noprint;
class sector;
var correlation;
output out=mean_correlation mean(correlation)=mean_correlation;
run; quit;

proc print data=mean_correlation; run;

ods graphics on;
proc sgplot data=mean_correlation;
 format mean_correlation 3.2;
 vbar sector / response=mean_correlation datalabel;
run; quit;
ods graphics off;

ods graphics on;
proc sgplot data=long_correlations;
 format correlation 3.2;
 vbar sector / response=correlation stat=mean datalabel;
run; quit;
ods graphics off;
title '';
* end of Q4;

* start of Q5;
data return_data;
 set temp (keep= return_:);
run;

proc print data=return_data(obs=10); run;

ods graphics on;
proc princomp data=return_data out=pca_output outstat=eigenvectors plots=scree(unpackpanel);
run; quit;
ods graphics off;

proc print data=pca_output(obs=10); run;

proc print data=eigenvectors(where=(_TYPE_='SCORE')); run;

data pca2;
 set eigenvectors(where=(_NAME_ in ('Prin1','Prin2')));
 drop _TYPE_ ;
run;

proc print data=pca2; run;

proc transpose data=pca2 out=long_pca; run; quit;

proc print data=long_pca; run;

data long_pca;
 set long_pca;
 format tkr $3.;
 tkr = substr(_NAME_,8,3);
 drop _NAME_;
run;

proc print data=long_pca; run;

ods graphics on;
proc sgplot data=long_pca;
scatter x=Prin1 y=Prin2 / datalabel=tkr;
run; quit;
ods graphics off;
* end Q5;

* start Q6;
data cv_data;
 merge pca_output temp(keep=response_VV);
 u = uniform(123);
 if (u < 0.70) then train = 1;
 else train = 0;
 if (train=1) then train_response=response_VV;
 else train_response=.;
run;

proc print data=cv_data(obs=10); run;

proc print data=temp(keep=response_VV obs=10); run; quit;
* end Q6;

* start Q7 & Q8;
ods graphics on;
proc reg data=cv_data;
model train_response = return_: / vif ;
output out=model1_output predicted=Yhat ;
run; quit;
ods graphics off;

ods graphics on;
proc reg data=cv_data;
model train_response = prin1-prin8 / vif ;
output out=model2_output predicted=Yhat ;
run; quit;
ods graphics off;

proc print data=model1_output(obs=10); run;

* Model 1;
data model1_output;
 set model1_output;
 square_error = (response_VV - Yhat)**2;
 absolute_error = abs(response_VV - Yhat);
run;

proc means data=model1_output nway noprint;
class train;
var square_error absolute_error;
output out=model1_error
 mean(square_error)=MSE_1
 mean(absolute_error)=MAE_1;
run; quit;

proc print data=model1_error; run;

* Model 2;
data model2_output;
 set model2_output;
 square_error = (response_VV - Yhat)**2;
 absolute_error = abs(response_VV - Yhat);
run;

proc means data=model2_output nway noprint;
class train;
var square_error absolute_error;
output out=model2_error
 mean(square_error)=MSE_2
 mean(absolute_error)=MAE_2;
run; quit;

proc print data=model2_error; run;

* Merge;
data error_table;
 merge model1_error(drop= _TYPE_ _FREQ_) model2_error(drop= _TYPE_ _FREQ_);
 by train;
run;

proc print data=error_table; run;
* Model 2 has higher accuracy both in-sample and out-of-sample, hence we prefer Model 2;
* end Q7 & Q8;