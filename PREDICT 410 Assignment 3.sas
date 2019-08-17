* Connect to data;
libname mydata "/courses/d54816e5ba27fe300" access=readonly ;

* Shorten data name, save to work library;
data ames;
set mydata.ames_housing_data;
run;

* at this point, create the logged data for SalePrice and GrlivArea;
* also, keep the initial 7 vatiables from the last assignment;
* also, create a square root of Sale Price for an code later in the assignment;
data ames;
 set mydata.ames_housing_data;
 log_SalePrice = log(SalePrice);
 log_GrLivArea = log(GrLivArea);
 sqrt_SalePrice = sqrt(SalePrice);
 keep SalePrice log_salePrice sqrt_SalePrice GrLivArea log_GrLivArea MasVnrArea BsmtUnfSF
BsmtFinSF1 FirstFlrSF TotalBsmtSF GarageArea;
ods graphics on;

* select 5 observations;
proc print data=ames (obs=5);

* Create 4 models for comparison;
proc reg data=ames;
 model SalePrice = GrLivArea;
 model SalePrice = log_GrLivArea;
 model log_SalePrice = GrLivArea;
 model log_SalePrice = log_GrLivA
* Make sure GrLivArea is still best correlation with data;

* Then create scatter plot of that data;
proc corr data=ames nosimple rank;
 var GrLivArea MasVnrArea BsmtUnfSF BsmtFinSF1 FirstFlrSF TotalBsmtSF GarageArea;
 with log_saleprice;
run;

proc sgscatter data=ames;
 plot (SalePrice log_SalePrice) * GrLivArea;

* Retrieve information to compare sqrt of saleprice to other models;
proc reg data=ames;
 model SalePrice = GrLivArea;

proc reg data=ames;
 model sqrt_SalePrice = GrLivArea;

* initial univariate visuals to detect outliers;
proc univariate normal plot data=ames;
 var SalePrice;
 histogram SalePrice / normal (color=red w=5);

* remove the top and bottom 1% of outliers;
data outliers;
 set ames;
 keep SalePrice price_outlier GrLivArea MasVnrArea BsmtUnfSF;
 if SalePrice <= 61500 then price_outlier = 1;
 else if SalePrice > 61500 & SalePrice < 457347 then price_outlier = 2;
 else if SalePrice >= 457347 then price_outlier = 3;

proc sort data=outliers;
 by price_outlier;

proc means data=outliers;
 by price_outlier;
 var SalePrice;

* move pruned data into new dataset and re-do univariate plot;
data pruned;
 set outliers;
 if price_outlier = 1 then delete;
 else if price_outlier = 3 then delete;

proc univariate normal plot data=pruned;
 var SalePrice;
 histogram SalePrice / normal (color=red w=5);

* regression model for non-manipulated data set;
proc reg data=ames;
 model SalePrice = GrLivArea;
 model SalePrice = GrLivArea MasVnrArea;
 model SalePrice = GrLivArea MasVnrArea BsmtUnfSF;

* regression model for pruned data set;
proc reg data=pruned;
 model SalePrice = GrLivArea;
 model SalePrice = GrLivArea MasVnrArea;
 model SalePrice = GrLivArea MasVnrArea BsmtUnfSF;
run;