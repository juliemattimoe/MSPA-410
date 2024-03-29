* Connect to data ;
libname mydata "/courses/d54816e5ba27fe300" access=readonly;

* Shorten data name, save to work library ; 
data ames;
set mydata.ames_housing_data; 
run;

proc contents data=ames order=varnum;

* examination of the correlation to saleprice ; 
proc corr data=ames nosimple;
var saleprice;
with LotFrontage LotArea MasVnrArea BsmtFinSF1 BsmtFinSF2 BsmtUnfSF TotalBsmtSF FirstFlrSF SecondFlrSF LowQualFinSF GrLivArea GarageArea WoodDeckSF OpenPorchSF EnclosedPorch ThreeSsnPorch ScreenPorch PoolArea MiscVal;
run;

* examination of the correlation to saleprice ; 
proc corr data=ames nosimple;
var saleprice;
with LotFrontage LotArea MasVnrArea BsmtFinSF1 BsmtUnfSF TotalBsmtSF FirstFlrSF SecondFlrSF GrLivArea GarageArea WoodDeckSF OpenPorchSF EnclosedPorch ScreenPorch PoolArea;
run;

* examination of the correlation to saleprice ; 
proc corr data=ames nosimple;
var saleprice;
with MasVnrArea BsmtFinSF1 BsmtUnfSF TotalBsmtSF FirstFlrSF GrLivArea GarageArea; 
run;

* look at sales price to check for outliers ; 
proc sort data=ames out=sorted;
by saleprice; 
run;

proc print data=sorted; var saleprice;
run;

* look at total basement sq ft to check for outliers; 
proc sort data=ames out=sorted;
by TotalBsmtSF; 
run;

proc print data=sorted; var TotalBsmtSF;
run;

* look at first floor sq ft to check for outliers ; 
proc sort data=ames out=sorted;
by FirstFlrSF; 
run;

proc print data=sorted; var FirstFlrSF;
run;

* correlation matrix ;
proc corr data=ames plot=matrix(histogram);
var MasVnrArea TotalBsmtSF FirstFlrSF GrLivArea GarageArea; 
run;

* create scatter plot matrix for the 5 remaining indicators ; 
proc sgscatter data=ames;
matrix MasVnrArea TotalBsmtSF FirstFlrSF GrLivArea GarageArea; 
run;

* scatter plots with highest correlation ;
proc corr data=ames nosimple rank plots=(scatter);
var TotalBsmtSF;
with FirstFlrSF; 
run;

* LOESS scatter plots with highest correlation ; 
proc sgscatter data=ames;
compare x=(TotalBsmtSF) y=FirstFlrSF / loess;
run;

* scatter plots with lowest correlation ;
proc corr data=ames nosimple rank plots=(scatter);
var GarageArea;
with MasVnrArea; 
run;

* LOESS scatter plots with lowest correlation ; 
proc sgscatter data=ames;
compare x=(GarageArea) y=MasVnrArea / loess;
run;

* scatter plots with correlation closest to .5 ;
proc corr data=ames nosimple rank plots=(scatter);
var FirstFlrSF;
with GarageArea; 
run;

* LOESS scatter plots with correlation closest to .5 ; 
proc sgscatter data=ames;
compare x=(FirstFlrSF) y=GarageArea / loess;
run;

* frequency distrobution ; 
proc freq data=ames;
tables GarageCars; 
run;

* bar graph of freq ;
proc gchart data=ames;
vbar GarageCars / type=sum sumvar=saleprice discrete; 
run;

* SORT ;
PROC SORT DATA = ames;
BY GarageCars;
run;

* mean ;
PROC MEANS DATA = ames N Mean;
var saleprice;
by GarageCars; 
RUN;

* frequency distrobution ; 
proc freq data=ames;
tables MoSold; 
run;

* bar graph of freq ;
proc gchart data=ames;
vbar MoSold / type=sum sumvar=saleprice discrete; 
run;

* SORT ;
PROC SORT DATA = ames;
BY MoSold; 
run;

* mean ;
PROC MEANS DATA = ames N Mean;
var saleprice;
by MoSold; 
RUN;

* frequency distrobution ; 
proc freq data=ames;
tables Fireplaces; 
run;

* bar graph of freq ;
proc gchart data=ames;
vbar Fireplaces / type=sum sumvar=saleprice discrete; 
run;

* SORT ;
PROC SORT DATA = ames;
BY Fireplaces;
run;

* mean ;
PROC MEANS DATA = ames N Mean;
var saleprice;
by Fireplaces; 
RUN;

* examination of the correlation to saleprice ; 
proc corr data=ames nosimple;
var saleprice;
with GarageCars MoSold Fireplaces; 
run;