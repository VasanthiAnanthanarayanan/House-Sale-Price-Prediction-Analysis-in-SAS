libname mylib "C:\Users\vasan\OneDrive\Desktop\MIS Coursework\SAS\Final Project";

proc contents data=mylib.Team8;
run;

*Question 1 - Use %LET statements to name the macro variables and set their values. The macro variables are
referred to in the SAS code as &categorical and &interval, to distinguish those names from
those of variables.
*Part 1: Assigning character and numeric variables to categorical and interval %let statements;
%let categorical = House_Style Overall_Qual Overall_Cond Heating_QC Central_Air Bedroom_AbvGr Fireplaces Mo_Sold 
Yr_Sold Full_Bathroom Half_Bathroom Total_Bathroom 
Season_Sold Garage_Type_2 Foundation_2 Masonry_Veneer Lot_Shape_2 House_Style2 Overall_Qual2 Overall_Cond2 Bonus ;

%let interval =Lot_Area Year_Built Gr_Liv_Area Garage_Area SalePrice Basement_Area Deck_Porch_Area Age_Sold; 

*Question 2 - Use PROC UNIVARIATE to generate plots and descriptive statistics for continuous variables and
PROC FREQ to generate plots and tables for categorical variables.;
title "Categorical Variable Descriptive Statistics";
proc freq data = mylib.Team8;
	tables &categorical / plots = freqplot (type = bar);
run;
	
proc univariate data=mylib.Team8 noprint;
 var &interval;
 histogram &interval / normal kernel;
 title "Interval Variable Distribution";
run;

*Question 3 - Use the TTEST procedure to test whether the mean of SalePrice is $135,000 in the data set. Is the
mean value in the sample statistically significantly different from $135,000 at an alpha level of
0.05?;
proc ttest data=mylib.Team8 h0=135000
 plots(only shownull)=interval;
 var SalePrice;
 title 'Testing Whether the Mean Sale Price is 135000';
run;
*P-value < alpha => 0.0002 < 0.05 => Yes, the mean value is statistically significant;
*Here, the p-value, 0.0002 is less than the alpha of 0.05. Hence the mean value is statistically significant, and different 
than 135000. In fact, the value is greater than 135000.

*Question 4 - Use the TTEST procedure to test whether the mean of SalePrice is the same for homes with
masonry veneer and those without. Provide your insights.
:Using TTEST to find whether the mean of SalePrice is the same for homes with masonry veneer and those without;

proc ttest data=mylib.Team8 plots(only shownull)=interval;
class Masonry_Veneer;
var SalePrice;
title "Two-sample t-Test Comparing homes with masonry veneer and those without";
run;

*Question 5 - Create scatter plots to show relationships between continuous predictors and SalePrice and
comparative box plots to show relationships between categorical predictors and SalePrice using Macro program;

ods graphics / reset=all imagemap;
ods select scatterplot;
proc corr data=mylib.Team8 rank
      	plots(only)=scatter(nvar=all ellipse=none);
   var &interval;
   with SalePrice;
   title "Scatter Plots";
run;

%macro Boxplot(name);
proc sgplot data=mylib.Team8;
vbox SalePrice/ category=&name connect=mean;
run;
%mend Boxplot;

%Boxplot(House_Style);

*Question 6 - Examine the relationships between SalePrice and the continuous predictor variables in the data
set;
* continuous predcitor variables in our dataset are considered as follows;
%let variable= Lot_Area Gr_Liv_Area Garage_Area Basement_Area Deck_Porch_Area Age_Sold;

proc corr data=mylib.Team8 PLOTS=SCATTER(NVAR=all);
 var &variable;
 with SalePrice;
 title "Correlations Plots";
run;

/* Output of question 6 is as follows
Pearson Correlation Coefficients, N = 800  
  		  Lot_Area Gr_Liv_Area Garage_Area Basement_Area Deck_Porch_Area Age_Sold 
SalePrice 0.22170  0.59629 		0.50223 	0.61098			0.40526		-0.63645 */
 
*Question 7 - Perform a simple linear regression analysis with SalePrice as the response variable, and one of
the significant predictors. Explain why you have chosen that variable. What’s the prediction
equation?;
* Selecting Age_Sold as the most significant predictors as its negatively correlated with SalePrice with highest corr coefficient as -0.63 as compared to other independent variables 
Regression analysis code of Sale Price with Age sold --;

proc reg data=mylib.Team8;
model SalePrice=Age_Sold  / R P VIF SLENTRY = 0.01 ; 
run;
*Answer- The prediction equation is SalePrice = 178230 - 883.45296(Age_Sold);


*Question 8 - Perform a regression model of SalePrice with Lot_Area and Basement_Area as predictor
variables;
*Regression analysis code considering only  independent variables (Lot_Area & Basement_Area)--;

proc reg data=mylib.Team8;
model SalePrice=Lot_Area Basement_Area; 
plot RESIDUAL. * Lot_Area Basement_Area;
run;

*70892 = 1.07517(Lot_Area)+66.19581(Basement_Area)
R squared value is 0.3835 and both p-values are less than 0.01;

*Question 9 - Call to macro to run SELECT for the options SL, AIC, BIC, AICC, and SBC
and compare the selected models from the output. Does the significance level for entry
into and staying in the model have any impact when you use options other than SL?
Which variables stay in the model for each 5 options? Which selection methods and
criteria would you recommend? 
Regression of salePrice with all the interval variables using GLMSELECT with select options SL, AIC, BIC, AICC, SBC;

%let interval = Lot_Area Year_Built Gr_Liv_Area Bedroom_AbvGr Fireplaces Garage_Area Mo_Sold Yr_Sold Basement_Area Total_Bathroom Deck_Porch_Area Age_Sold;

%macro modelsel(mod, type, slent=0.05, slst =0.05);

	title "&mod and &type";
	proc glmselect data=orion.Team8 plots=all;
		model SalePrice = &interval / selection = &mod
						  details = steps
						  select = &type
						  slentry = &slent
						  slstay = &slst;
	run;
%mend modelsel;

%modelsel(stepwise,SL)
%modelsel(stepwise, AIC)
%modelsel(stepwise, BIC)
%modelsel(stepwise, AICC)
%modelsel(stepwise, SBC)

*All the select option produces the same result.

*Question 10 - Invoke PROC REG with the plots option using rsquare adjrsq cp to produce a
regression of SalePrice on all the other interval variables in the data set. Which model you would suggest, and why?
Regression of salePrice with all the interval variables and comparing the models with selection options R-square, Adjusted R-square and Cp;

ods graphics on;
title "Regression of SalePrice with selection using R-square, Adjusted R-square and Cp";
proc reg data =mylib.Team8 plots(only) = (rsquare cp adjrsq);
model SalePrice = Lot_Area Year_Built Gr_Liv_Area Bedroom_AbvGr 
       Fireplaces Garage_Area Mo_Sold Yr_Sold
                   Basement_Area Total_Bathroom Deck_Porch_Area Age_Sold                                                    /selection = rsquare cp adjrsq;
run; 
quit;
ods graphics off;
 
*Question 11 - create one-way frequency tables for the variables Bonus,
Fireplaces, and Lot_Shape_2 and create two-way frequency tables for the variables
Bonus by Fireplaces, and Bonus by Lot_Shape_2. For the continuous variable,
Basement_Area, create histograms for each level of Bonus?;

proc freq data = mylib.Team8;
tables Bonus;
run;
proc freq data = mylib.Team8;
tables Fireplaces;
run;
proc freq data = mylib.Team8;
tables Lot_Shape_2 ;
run;
proc freq data = mylib.Team8;
tables Bonus *Fireplaces;
run;
proc freq data = mylib.Team8;
tables Bonus *Lot_Shape_2;
run;

proc univariate data=mylib.Team8;
class Bonus;
   histogram;
   var Basement_Area;
run;
*Answer a There are missing values in the dataset. There are present in the table since misssing option wasn't added in the tables statement.
*Asnwer b  Basement area is normally distributed when Bonus = 0 and it is left-skewed when there is a bonus for the sale. It is also evident that incresase in
basement area increases the chance of bonus.

*Question 12 - Use PROC FREQ to test whether an ordinal association exists between Bonus and
Fireplaces.;

proc freq data=mylib.Team8;
tables Fireplaces*Bonus / chisq cl;
Run;
*Answer a;
*There is Bonus and Fireplaces have a significant ordinal association as p value is less than 0.001
*Answer b;
*For the Spearman correlation statistic, the relationship is significant at the 0.05 significance 
Value - 0.2898
95% Confidence Limit - 0.2203,0.3593;

*Question 13 - Fit a binary logistic regression model in PROC LOGISTIC. Select Bonus as the outcome
variable and VARIABLE assigned to your team as the predictor variable. ;
*Answer a;
proc logistic data =mylib.Team8;
	model Bonus(event='1') = Total_Bathroom  / CTABLE PPOB = (0 to 1 by .1) /*classification table */
	LACKFIT clodds=pl/*Goodness-of-fit test ? Hosmer & Lemeshow*/
	RISKLIMITS /*odds ratios for each varb with 95% CI*/
       OUTROC=ROC ALPHA=.10 ;
run;

*Answer b - BETA=0 mean that the intercept value is 0 and we'll look at the importance of independent variables when intercept is 0;
*Answer c - Since all the 3 statistics in Global Null Hypothesis has a p-value <0.0001, we can say that we reject the null hypothesis.
*Answer d - The logistic regression equation is P = 1/(e^(-6.0946+2.2333(Total_Bathroom))) or it can be written as LOG(Bonus)=-6.0946+2.2333(Total_Bathroom;
*Answer e - p-value of Total_Bathroom is <.0001 & hence is significant at the 0.10 significance level ;
*Answer f - odd ratio of Total_Bathroom calculation is
			ODDS(Bonus)when Total_Bathroom is present= exp(-6.0946+2.2333* 1) = 0.021
			ODDS(Bonus)when Total_Bathroom is absent= exp(-6.0946+2.2333* 0) = 0.0023
			Odds Ratio = 0.021/0.0023 = 9.13;

*Question 14 - Run an analysis of variance with SalePrice as the response variable and Heating_QC as the
categorical predictor variable. Output diagnostic plots and look at Levene’s test of homogeneity
of variances.

#Levene’s test of homogeneity of variances;
proc glm data=mylib.Team8
plots(only)=diagnostics;
 class Heating_QC;
 model SalePrice=Heating_QC;
 means Heating_QC / hovtest=levene;
 title "One-Way ANOVA with SalePrice as Heating_QC using levene";
run;
quit;
*Answer : According to anova analysis, SalePrice & Heating_QC seem to be significant to each other with p-value less 
than 0.0001 with both 95 & 99% confidence.

*Question 15 - Use the LSMEANS statement in PROC GLM to produce comparison information about
the mean sale prices of the different heating system quality ratings.
#Using lsmeans;

proc glm data=mylib.Team8
plots(only)=diagnostics;
 class Heating_QC;
 model SalePrice=Heating_QC;
 lsmeans Heating_QC / slice=Heating_QC;
 title "One-Way ANOVA with SalePrice as Heating_QC including lsmeans";
run;
quit;
*Answer : Using lsmeans produces the above table in addition to Q1 output. Looking at the above table, we can say FA in Heating_QC has the lowest Salepeice mean, whereas TA & GD come next with mean sale price close to each other. 
Ex has the highest SalePrice mean among all the heating_QC;

*Question 16 - Perform a two-way ANOVA of SalePrice with Heating_QC and Season_Sold as predictor
variables. Before conducting an analysis of variance, you should explore the data. To further
explore the numerous treatments, examine the means graphically. Include the interaction between
the two explanatory variables. Store the output to a dataset and adjust p-values using PROC PLM.

*Performing Bivariate analysis between variables and exploring the data before jumping into two-way anova analysis;
********bivariate analysis between Heating_QC & SalePrice;
proc sgplot data=mylib.Team8;
 vbox SalePrice / category=Heating_QC connect=mean;
 title "Sale price with Heating QC";
run;
proc means data=mylib.Team8;
 var SalePrice;
 class Heating_QC ;
 title 'Descriptive Statistics of SalePrice by Heating_QC';
run;

********bivariate analysis between Season_Sold & SalePrice;
proc sgplot data=mylib.Team8;
 vbox SalePrice / category=Season_Sold connect=mean;
 title "Sale price with Season Sold";
run;

proc means data=mylib.Team8;
 var SalePrice;
 class Season_Sold ;
 title 'Descriptive Statistics of SalePrice by Season_Sold';
run;

********bivariate analysis between Heating_QC & Season_Sold;
proc freq data = mylib.Team8;
tables Heating_QC *Season_Sold;
run;


*******Performing GLM;
proc glm data=mylib.Team8
 plots(only)=(intplot);
 class Heating_QC Season_Sold;
 model SalePrice=Heating_QC Season_Sold Heating_QC*Season_Sold;
 lsmeans Heating_QC*Season_Sold / slice=Heating_QC;
 store out=new;
 title "Model with Heating QC and Season Sold along with their interaction";
run;

*Answer : Heating_QC seems to be significant with Sale Price (p-value <0.0001) whereas Season Sold alone is not 
significant with Sale Price but when Season Sold is made to interact with Heating_QC, it acts significant with 
p-value of 0.02


*******Performing PLM;
proc plm restore=new plots=all;
 	slice Heating_QC*Season_Sold / sliceby=Heating_QC adjust=tukey;
 	effectplot interaction(sliceby = Heating_QC) / clm;
title "Model with PLM";
run;

*Answer : Used Tukey to get better insights into the interaction between Season Sold & Heating_QC. 
Anova gives us the overall result but Tukey test exactly tells us where the difference lie that is basically which 
Season_Sol with Heating_QC is actually significant with SalePrice;

