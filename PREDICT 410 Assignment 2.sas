* Connect to data ;
libname mydata "/courses/d54816e5ba27fe300" access=readonly ;

* Shorten data name, save to work library ;
data ames;
set mydata.ames_housing_data;
run;

* examination of the correlation to saleprice from assignment 1 ;
proc corr data=ames nosimple;
 var saleprice;
 with MasVnrArea BsmtFinSF1 BsmtUnfSF TotalBsmtSF FirstFlrSF GrLivArea GarageArea;
run;

ods graphics on;
proc reg data = ames plots = cooksd;
model SalePrice = MasVnrArea;
run;

proc reg;
model SalePrice = MasVnrArea BsmtFinSF1 BsmtUnfSF TotalBsmtSF FirstFlrSF GrLivArea GarageArea/
selection=rsquare start=1 stop=1;
run;

proc reg data=ames plots = cooksd;
model SalePrice = GrLivArea;
run;

proc reg data=ames plots = cooksd;
model SalePrice = MoSold;
run;

proc reg data=ames plots = cooksd;
model SalePrice = MasVnrArea GrLivArea;
run;

proc reg data=ames plots = cooksd;
model SalePrice = MasVnrArea GrLivArea BsmtUnfSF;
run;