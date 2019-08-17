* Connect to data;
libname mydata "/courses/d54816e5ba27fe300" access=readonly ;

* Shorten data name, save to work library;
data ames;
set mydata.ames_housing_data;
run;

*part a of the assignment;
ods graphics off;
proc contents data=ames;
data ames_indicator;
 set ames;
 keep SalePrice GrLivArea GarageArea TotalBsmtSF FirstFlrSF MasVnrArea OverallQual HouseStyle hs_1
hs_2 hs_3 hs_4 hs_5 hs_6
 hs_3 = (HouseStyle eq '1.5Unf');
 hs_4 = (HouseStyle eq '2Story');
 hs_5 = (HouseStyle eq '2.5Fin');
 hs_6 = (HouseStyle eq '2.5Unf');
 hs_7 = (HouseStyle eq 'SFoyer');
 hs_8 = (HouseStyle eq 'SLvl');
 end;

 * Recode;
 if HouseStyle='1Story' then HouseStyle=1;
 if HouseStyle='1.5Fin' then HouseStyle=2;
 if HouseStyle='1.5Unf' then HouseStyle=3;
 if HouseStyle='2Story' then HouseStyle=4;
 if HouseStyle='2.5Fin' then HouseStyle=5;
 if HouseStyle='2.5Unf' then HouseStyle=6;
 if HouseStyle='SFoyer' then HouseStyle=7;
 if HouseStyle='SLvl' then HouseStyle=8;

 * The second category variable will be GarageType;
 if GarageType in ('2Types' 'Attchd' 'Basment' 'BuiltIn' 'CarPort' 'Detchd' 'NA') then do;
 gt_1 = (GarageType eq '2Types');
 gt_2 = (GarageType eq 'Attchd');
 gt_3 = (GarageType eq 'Basment');
 gt_4 = (GarageType eq 'BuiltIn');
 gt_5 = (GarageType eq 'CarPort');
 gt_6 = (GarageType eq 'Detchd');
 gt_7 = (GarageType eq 'NA');
 end;

 * Recode;
 if GarageType='2Types' then GarageType=1;
 if GarageType='Attchd' then GarageType=2;
 if GarageType='Basment' then GarageType=3;
 if GarageType='BuiltIn' then GarageType=4;
 if GarageType='CarPort' then GarageType=5;
 if GarageType='Detchd' then GarageType=6;
 if GarageType='NA' then GarageType=7;

proc means data=ames_indicator;
 class HouseStyle;
 var SalePrice;

proc freq data=ames_indicator;
 tables HouseStyle hs_1 hs_2 hs_3 hs_4 hs_5 hs_6 hs_7 hs_8;

proc means data=ames_indicator;
 class hs_1 hs_2 hs_3 hs_4 hs_5 hs_6 hs_7 hs_8;
 var SalePrice;

proc means data=ames_indicator;
 class GarageType;
 var SalePrice;

proc freq data=ames_indicator;
 tables GarageType gt_1 gt_2 gt_3 gt_4 gt_5 gt_6 gt_7;

proc means data=ames_indicator;
 class gt_1 gt_2 gt_3 gt_4 gt_5 gt_6 gt_7;
 var SalePrice;

proc reg data=ames_indicator;
 model SalePrice = HouseStyle;

proc reg data=ames_indicator;
 model SalePrice = hs_1 hs_2 hs_3 hs_4 hs_5 hs_6 hs_7;

* move into part b with 6 steps analysis;
proc reg data=ames_indicator outest=reg_rsq_out;
model SalePrice = gt_1 gt_2 gt_3 gt_4 gt_5 gt_6 gt_7 hs_1 hs_2 hs_3 hs_4 hs_5 hs_6 hs_7 hs_8/
selection=adjrsq aic bic 
proc print data=reg_stepwise_out;

ods graphics on;
proc reg data=ames_indicator;
 model SalePrice = gt_1 gt_2 gt_3 gt_4 gt_5 gt_6 gt_7 hs_1 hs_2 hs_3 hs_4 hs_5 hs_6 hs_7 hs_8;
ods graphics off;

* moving into part c of the assigment;
data ames_training;
 set ames_indicator;
 u = uniform(123);
 if (u < 0.70) then train = 1;
 else train = 0;
 if (train=1) then train_response=SalePrice;
 else train_response=.;

proc reg data=ames_training outest=reg_rsq_out;
model train_response = gt_1 gt_2 gt_3 gt_4 gt_5 gt_6 gt_7 hs_1 hs_2 hs_3 hs_4 hs_5 hs_6 hs_7 hs_8/
selection=adjrsq aic bic cp best=5;

proc print data=reg_rsq_out;

proc reg data=ames_training outest=reg_cp_out;
 model train_response = gt_1 gt_2 gt_3 gt_4 gt_5 gt_6 gt_7 hs_1 hs_2 hs_3 hs_4 hs_5 hs_6 hs_7 hs_8/
 selection=cp adjrsq aic bic cp best=5;

proc print data=reg_cp_out;

proc reg data=ames_training outest=reg_forward_out;
 model train_response = gt_1 gt_2 gt_3 gt_4 gt_5 gt_6 gt_7 hs_1 hs_2 hs_3 hs_4 hs_5 hs_6 hs_7 hs_8/
 selection=forward adjrsq aic bic cp best=5;

proc print data=reg_forward_out;

proc reg data=ames_training outest=reg_backward_out;
 model train_response = gt_1 gt_2 gt_3 gt_4 gt_5 gt_6 gt_7 hs_1 hs_2 hs_3 hs_4 hs_5 hs_6 hs_7 hs_8/
 selection=backward adjrsq aic bic cp best=5;

proc print data=reg_backward_out;

proc reg data=ames_training outest=reg_stepwise_out;
 model train_response = gt_1 gt_2 gt_3 gt_4 gt_5 gt_6 gt_7 hs_1 hs_2 hs_3 hs_4 hs_5 hs_6 hs_7 hs_8/
 selection=stepwise adjrsq aic bic cp best=5;

proc print data=reg_stepwise_out;

proc reg data=ames_training;
 model SalePrice = gt_1 gt_2 gt_3 gt_4 gt_5 gt_6 gt_7 hs_1 hs_2 hs_3 hs_4 hs_5 hs_6 hs_7 hs_8;
 output out=reg_indicators_yhat predicted=yhat;
run;