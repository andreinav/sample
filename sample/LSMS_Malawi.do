***************************************************************************************
*This do-file creates a dataset containing the HH total consumption drawn from the Malawi IHS2. Three components are created for each household:
**1. total consumption per food item 
**2. sum of consumption of the food items that make up the 60% list
**3. sum of consumption of the food items that make up the 80% list

***NOTE on the food lists: the first part of the do-file seeks to construct:
**1. list of food items that compose 60% of food consumption (aggregate)
**2. list of food items that compose 80% of food consumption (aggregate)
 
*  INPUT DATA SETS:
*  Subcomponent data sets created by dofiles specified below
*
*  OUTPUT DATA SET:
*  valuesfood_w.dta
*******************************************************************************************
clear
set more off
set mem 350m
cd "C:\Users\Andreina\Dropbox\WB"
	
global rawdata "expagg_food1.dta"
global dataoth "itemexpenditure.dta"
global dataoth "itemexpenditure_1.dta"
global dataoth2 "totalitem.dta"
global dataoth3 "fooditem_w.dta"
global dataoth4 "fooditem_l.dta"
global dofiles "finalmalawi.do"
global logfile "Malawi_foodlists_2005.smcl"
global output "finalfood.dta"
**********************************************************************

*log using "Malawi_foodlists_2005.smcl"

***STEP 1: transform weekly item consumption to annual
use rawdata/expagg_food1.dta, clear
mvencode exp_seci, mv(.=0) override
gen exp=exp_seci*52 
label var exp "Annual Total Expenditure on Item (nominal)"
keep case_id i02 exp
save rawdata/itemexpenditure,replace

**STEP2: convert to real terms
use rawdata/ihs2_pov.dta, clear
merge 1:m case_id using rawdata/itemexpenditure
drop _merge


qui for var exp*: gen rX=X/price_index*100
label var  rexp "Annual Expenditure on Item (real)"
keep case_id i02 rexp
save rawdata/itemexpenditure_1,replace

**STEP3: construct annual expenditure
collapse (sum) rexp, by (case_id)
rename rexp rexpfood
label var rexpfood "Annual Expenditure on Food (real)"
save rawdata/totalitem,replace

**STEP 4: transform to wide form version**
use rawdata/itemexpenditure_1
reshape wide rexp, i(case_id) j(i02)
mvencode rexp*, mv(.=0) override
save rawdata/fooditem_w,replace

reshape long rexp, i(case_id) j(i02)
label var rexp "Annual Expenditure on Item (real)"
save rawdata/fooditem_l,replace

**STEP 5: merge data with total food expenditure (annual&real) and item expenditure (annual&real)
use rawdata/totalitem 
merge 1:m case_id using rawdata/fooditem_l 
drop _merge

**STEP6: construct shares and check
mvencode rexpfood rexp, mv(.=0) override
gen share= rexp/rexpfood
label var share "share of value of item(real)"
**collapse (sum) share, by (case_id)
**check:all shares=1

**STEP 7: take average of shares and sort descending order
collapse (mean) share, by (rexpfood)
gsort -share

**STEP 8: calculate list of items making up to 80% and 60% of consumption
gen v_80=0
replace v_80=1 if sum(share)<=.80
gen v_60=0
replace v_60=1 if sum(share)<=.60
list if  v_80==1
list if  v_60==1
save rawdata/finalfood,replace


**CREATE DATASET**
use rawdata/fooditem_w
gen total_80= rexp101+rexp102+rexp502+rexp105+rexp801+rexp404+rexp304+rexp302+rexp408+rexp507+rexp803+rexp106+rexp201+rexp503+rexp303+rexp810+rexp410+rexp501+rexp403+rexp505+rexp802
gen total_60= rexp101+rexp102+rexp502+rexp105+rexp801+rexp404+rexp304+rexp302+rexp408
label var total_80 "Total consumption making 80% of consumption "
label var total_60 "Total consumption making 60% of consumption"
save rawdata/valuesfood_w,replace

**Step 8: additional variables and deflate if necessary
use rawdata/expagg_food2.dta
merge 1:1 case_id using rawdata/valuesfood_w
drop _merge
merge 1:1 case_id using rawdata/ihs2_pov.dta
drop exp_cat012_i exp_cat021 exp_cat111 region reside dist area type add ta ea poor ultra_poor decile _merge ultrapovline povline
merge 1:1 case_id using  rawdata/valuesfood_w
drop _merge
qui for var exp_cat*: gen rX=X/price_index*100
label var rexp_cat011 "Food Annual HH Exp, non-vendor"
rename EA psu
label var psu "Cluster or PSU"
drop rexpfood rexpnfd price_index
label var case_id "Unique HH Identifier"
save rawdata/valuefood_2005, replace

**STEP 9: labels
label var	 rexp101	"Maize ufa mgaiwa (normal flour)"
label var	 rexp102	"Maize ufa refined (fine flour)"
label var	 rexp103	"Maize ufa madeya (bran flour)"
label var	 rexp104	"Maize grain (not as ufa)"
label var	 rexp105	"Green maize"
label var	 rexp106	"Rice"
label var	 rexp107	"Finger millet"
label var	 rexp108	"Sorghum"
label var	 rexp109	"Pearl millet"
label var	 rexp110	"Wheat flour"
label var	 rexp111	"Bread"
label var	 rexp112	"Buns, scones"
label var	 rexp113	"Biscuits"
label var	 rexp114	"Spaghetti, macaroni, pasta"
label var	 rexp115	"Breakfast cereal"
label var	 rexp116	"Infant feeding cereals"
label var	 rexp117	"Other cereals"
label var	 rexp201	"Meat eaten at restaurant"
label var	 rexp202	"Other cooked foods"
label var	 rexp203	"Tea"
label var	 rexp204	"Coffee"
label var	 rexp205	"Squash (sobo drink concentrate)"
label var	 rexp206	"Fruit juice"
label var	 rexp207	"Freezes (flavoured ice)"
label var	 rexp208	"Soft drinks (coca cola, fanta)"
label var	 rexp209	"Chibuku/ Napolo"
label var 	rexp301	"Bean, white"	
label var 	rexp302	"Bean, brown"	
label var 	rexp303	"Pigeon pea (nandolo)"	
label var 	rexp304	"Groundnut"	
label var 	rexp305	"Groundnut flour"	
label var 	rexp306	"Soyabean flour"	
label var 	rexp307	"Ground bean"	
label var 	rexp308	"Cowpea (khobwe)"	
label var 	rexp309	"Other pulses"	
label var 	rexp401	"Onion"	
label var 	rexp402	"Cabbage"	
label var 	rexp403	"Tanaposi rape"	
label var 	rexp404	"Nkwani"	
label var 	rexp405	"Chinese cabbage"	
label var 	rexp406	"Other cultivated green leafy vegetable"	
label var 	rexp407	"Gathered wild green leaves"	
label var 	rexp408	"Tomato"	
label var 	rexp409	"Cucumber"	
label var 	rexp410	"Pumpkin"	
label var 	rexp411	"Okra / Therere"	
label var 	rexp412	"Tinned vegetables"	
label var 	rexp413	"Other vegetable"	
label var 	rexp501	"Eggs"	
label var 	rexp502	"Dried Fish"	
label var 	rexp503	"Fresh fish"	
label var 	rexp504	"Beef"	
label var 	rexp505	"Goat"	
label var 	rexp506	"Pork"	
label var 	rexp507	"Chicken"	
label var 	rexp508	"Other poultry-guinea fowl, doves"	
label var 	rexp509	"Small animal- rabbit, mice"	
label var 	rexp510	"Termites, other insect"	
label var 	rexp511	"Tinned meat or fish"	
label var 	rexp512	"Other meat fish and animal product"	
label var 	rexp601	"Mango"	
label var 	rexp602	"Banana"	
label var 	rexp603	"Citrus, naartje, orange, etc."	
label var 	rexp604	"Pineapple"	
label var 	rexp605	"Papaya"	
label var 	rexp606	"Guava"	
label var 	rexp607	"Avocado"	
label var 	rexp608	"Wild fruit (masau, mlambe, etc.)"	
label var 	rexp609	"Apple"	
label var 	rexp610	"Other fruits"	
label var 	rexp701	"Fresh milk"	
label var 	rexp702	"Powdered milk"	
label var 	rexp703	"Margarine"	
label var 	rexp704	"Butter"	
label var 	rexp705	"Chambiko - soured milk"	
label var 	rexp706	"Yoghurt"	
label var 	rexp707	"Cheese"	
label var 	rexp708	"Infant feeding formula"	
label var 	rexp709	"Other milk and milk products"	
label var 	rexp801	"Sugar"	
label var 	rexp802	"Sugar cane"	
label var 	rexp803	"Cooking oil"	
label var 	rexp804	"Other fats and oil"	
label var 	rexp810	"Salt"	
label var 	rexp811	"Spices"	
label var 	rexp812	"Yeast, baking powder, bicarbonate of soda"	
label var 	rexp813	"Tomato sauce (bottle)"	
label var 	rexp814	"Hot sauce (nali, etc.)"	
label var 	rexp815	"Jam, jelly, honey"	
label var 	rexp816	"Sweets, candy, chocolates"	
label var 	rexp817	"Other spices/ miscellaneous"	

label var	rexp820	"	Maize - boiled or roasted	"
label var	rexp821	"	Chips (vendor)	"
label var	rexp822	"	Cassava - boiled (vendor)	"
label var	rexp823	"	Eggs - boiled (vendor)	"
label var	rexp824	"	Chicken (vendor)	"
label var	rexp825	"	Meat (vendor)	"
label var	rexp826	"	Fish (vendor)	"
label var	rexp827	"	Mandazi, doughnut (vendor)	"
label var	rexp828	"	Samosa (vendor)	"
label var	rexp829	"	Meat eaten at restaurant	"
label var	rexp830	"	Other cooked foods	"
label var	 rexp901	"	Tea	"
label var	 rexp902	"	Coffee	"
label var	 rexp903	"	Squash (sobo drink concentrate)	"
label var	 rexp904	"	Fruit juice	"
label var	 rexp905	"	Freezes (flavoured ice)	"
label var	 rexp906	"	Soft drinks (coca cola, fanta)	"
label var	 rexp907	"	Chibuku/ Napolo	"
label var	 rexp908	"	Bottled/ canned beer	"
label var	 rexp909	"	Local sweet beer (thobwa)	"
label var	 rexp910	"	Traditional beer (masase)	"
label var	 rexp911	"	Wine or commercial liquor	"
label var	 rexp912	"	Locally brewed liquor	"
label var	 rexp913	"	Other beverages	"

save results/valuefood_2005, replace

**TEST**
preserve
sum food
reshape long rexp, i (case_id) j(item)
collapse (sum) rexp, by ( case_id)
sum rexp
restore

log close
