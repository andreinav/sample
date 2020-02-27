**to build qbr.do
**This do file is used to build from the DEMs and the querry file the QBR.
set more off
**Ado needed
*ssc install sxpose

**Set locals/globals
**Set year
global year "2016"
local year "$year"
**Set main folder path
global mainfolder "C:/Users/mgibbons/Dropbox/DEM_Data/Data/DEMs_for_QBR_`year'/"
global mainfolder "/Users/admin/Dropbox/DEM_Data/Data/DEMs_for_QBR_`year'/"
global program_folder "/Users/admin/Dropbox/DEM_Data/Programs/building_qbr_programs/"
local mainfolder "$mainfolder"
local program_folder "$program_folder"
**Set where excel data is (datain) and where dta file are going to be drawn (dataout)
global datain "`mainfolder'/datain/"
global dataout "`mainfolder'/dataout/"     
local datain "$datain"
local dataout "$dataout"
**Creates datain and dataout folders (if they do not exist)
capture mkdir "$datain"
capture mkdir "$dataout"
**Set the format years used for the project in the year being built.
global format_years "2015 2016b"
global qrr_format_years "2015 2016b"
global opc_format_years "2016b"
local format_years "$format_years"
local qrr_format_years "$qrr_format_years"
local opc_format_years "$opc_format_years"
**Set if the program is being run to begin a QBR or to add a new quarter (new/add)
global set "new"
local set "$set"
**Set the quarter being added or the last quarter to import new QBR (1, 2, 3, 4).
global quarter_adding "1"
local quarter_adding "$quarter_adding"     
local q "$quarter_adding"

**To build query file
**Name of the query file                                                        
local query_file "approvals QBR 1 2016"
local sheet_query_file "Sheet1"                     

**Program
** Section names                           
global section_1 "DEM (Strategic Alignment)"
global section_2 "DEM (Strategic Alignment)"
global section_3 "DEM (Evaluability)"       
global section_4 "DEM (Evaluability)"       
global section_5 "DEM (Evaluability)"       
global section_6 "DEM ( Risk)"              
global section_7 "DEM (Additionality)"      

if "`set'"=="new" {
	**Copy clean file to build the new QBR
	copy "`program_folder'DEM QBRq year_clean.xlsx" "`dataout'DEM QBR`quarter_adding' `year'.xlsx", replace  

	** Rows where to export info from Stata to Excel
	foreach fy in `format_years' {
	global row_qrr_`fy' =  2
	global row_opc_`fy' =  2
	}
}

if "`set'"=="add" {
	copy "`dataout'DEM QBR`=`quarter_adding'-1' `year'.xlsx" "`dataout'DEM QBR`quarter_adding' `year'.xlsx", replace 
	
	foreach fy in `format_years' {
	import excel "`dataout'DEM QBR`=`quarter_adding'-1' `year'.xlsx", sheet("QRR_f`fy'") case(lower) clear
	drop if A==""
	qui describe
	global row_qrr_`fy' =  `r(N)'
	import excel "`dataout'DEM QBR`=`quarter_adding'-1' `year'.xlsx", sheet("Approved_OPC_f`fy'") case(lower) clear
	drop if A==""
	qui describe
	global row_opc_`fy' =  `r(N)'
	} 
}

capture program drop build_qbr 
program define build_qbr
**Redefine locals
local q "$q"
local year "$year"
**Set main folder path
local mainfolder "$mainfolder" 
**Set where excel data is (datain) and where dta file are going to be drawn (dataout)
local datain   "$datain" 
local dataout  "$dataout"
**Set the format years used for the project in the year being built.
local format_years "$format_years"
**Set if the program is being run to begin a QBR or to add a new quarter (new/add)
local set "$set" 
**Set the quarter being added or the last quarter to import new QBR (1, 2, 3, 4).
local quarter_adding "$quarter_adding"
local q "$quarter_adding"
** Section names                           
local section_1 "$section_1"
local section_2 "$section_2"
local section_3 "$section_3"
local section_4 "$section_4"
local section_5 "$section_5"
local section_6 "$section_6"
local section_7 "$section_7"
 
foreach fy in `format_years' {
local row_qrr_`fy' "${row_qrr_`fy'}" 
local row_opc_`fy' "${row_opc_`fy'}"  
di "`row_qrr_`fy''"
di "`row_opc_`fy''"              
}
                        
**Program       
local types "qrr opc"
	foreach t in `types' {
		local `year'_q`q'_`t' : dir "`mainfolder'Q`q'/`t'" dirs "*"
 
 di ""``year'_q`q'_`t''""
 
 		foreach format in ``year'_q`q'_`t'' {
 			cd "`mainfolder'Q`q'/`t'/`format'"
 			capture erase .DS_Store
			local files_`year'_q`q'_`t'_`format' : dir "`mainfolder'Q`q'/`t'/`format'" files "*"
 			local format_year "`=substr("`format'",8,.)'"
		  include "$program_folder/format_`format_year'"

di ""`files_`year'_q`q'_`t'_`format''""

			foreach file in `files_`year'_q`q'_`t'_`format'' {
			local projectnumber "`=substr("`file'",1,8)'" 

	di "`row_`t'_`format_year''"
  di "`projectnumber'"
	di "`format_year'"
	di "`file'"
	di "`t'"

** Export sheet
if inlist("`t'","qrr") {
	local exp_sheet "QRR_f`format_year'"
	local row_`t'_`format_year' = `row_`t'_`format_year''+1
}
if inlist("`t'","opc") {
	local exp_sheet "Approved_OPC_f`format_year'"
	**local row_`t'_`format_year' = max(`row_`t'_2014',`row_`t'_2015')+1
	local row_`t'_`format_year' = `row_`t'_`format_year''+1
}

clear
set obs 1
gen n="`projectnumber'"
replace n=upper(n)
export excel using "`dataout'DEM QBR`q' `year'.xlsx" , sheet("`exp_sheet'") sheetmodify cell(C`row_`t'_`format_year'') 
	sleep 2000
**QBR
clear
	set obs 1
	gen n="`q'"
	export excel using "`dataout'DEM QBR`q' `year'.xlsx" , sheet("`exp_sheet'") sheetmodify cell(A`row_`t'_`format_year'') 
	sleep 2000  

**Project Number
forvalues i=1/7 {
forvalues ii=1/`n_sections_`t'_`i'' {
	import excel "`mainfolder'Q`q'/`t'/`format'/`file'", sheet("`section_`i''") cellrange("`ic`t'_s`i'_`ii''") case(lower) clear
	sxpose, clear force
	di "`ec`t'_s`i'_`ii''" 
	di "`i'"
	di "`ii'"
	di "`t'"
	export excel using "`dataout'DEM QBR`q' `year'.xlsx" , sheet("`exp_sheet'") sheetmodify cell("`ec`t'_s`i'_`ii''`row_`t'_`format_year''") 
	sleep 2000
}
}   
}
}
}
end

	
if "`set'"=="new" {
	** CHECK forvalues q=1/ $quarter_adding {
  forvalues q=1/1 {
	build_qbr
	}
}

if "`set'"=="add" {
 global q=$quarter_adding 
 build_qbr
}

**include "`mainfolder'/programs/build_query_dataset"
**Import it to Stata and keep variables necessary for the QBR                   
import excel "`datain'/`query_file'", firstrow case(lower) clear sheet("`sheet_query_file'")
keep country opernum opername instrumenttype division approvaldate              
                                                                                
gen country_name=""                                                             
replace country_name=         "Argentina" if country=="AR"                      
replace country_name=           "Bahamas" if country=="BH"                      
replace country_name=          "Barbados" if country=="BA"                      
replace country_name=            "Belize" if country=="BL"                      
replace country_name=           "Bolivia" if country=="BO"                      
replace country_name=            "Brazil" if country=="BR"                      
replace country_name=             "Chile" if country=="CH"                      
replace country_name=          "Colombia" if country=="CO"                      
replace country_name=        "Costa Rica" if country=="CR"                      
replace country_name="Dominican Republic" if country=="DR"                      
replace country_name=           "Ecuador" if country=="EC"                      
replace country_name=       "El Salvador" if country=="ES"                      
replace country_name=         "Guatemala" if country=="GU"                      
replace country_name=            "Guyana" if country=="GY"                      
replace country_name=             "Haiti" if country=="HA"                      
replace country_name=          "Honduras" if country=="HO"                      
replace country_name=           "Jamaica" if country=="JA"                      
replace country_name=            "Mexico" if country=="ME"                      
replace country_name=         "Nicaragua" if country=="NI"                      
replace country_name=            "Panama" if country=="PN"                      
replace country_name=          "Paraguay" if country=="PR"                      
replace country_name=              "Peru" if country=="PE"                      
replace country_name=          "Suriname" if country=="SU"                      
replace country_name= "Trinidad & Tobago" if country=="TT"                      
replace country_name=           "Uruguay" if country=="UR"                      
replace country_name=         "Venezuela" if country=="VE"                      
                                                                                
rename country_name Country                                                     
rename opernum ProjectNumber                                                    
rename opername Name                                                            
rename instrumenttype Type                                                      
rename division Sector                                                                                                        
drop country
gen BODApprovedDate= string(approvaldate, "%tdddMonYY")                                                                    
saveold "`dataout'query_dataset.dta", replace                                   
                                                                                
**ADD QUERY DATASET
**include "`mainfolder'/programs/add_query_dataset"
copy "`dataout'DEM QBR`q' `year'.xlsx" "`dataout'DEM QBR`q' `year'_2.xlsx", replace 

if regexm("`qrr_format_years'","2015")==1 {
**QRR_2015
import excel "`dataout'DEM QBR`q' `year'.xlsx" , sheet("QRR_f2015") firstrow clear
**Deletes empty rows
drop if QBR==""

drop EVAScore
tostring EVALevel, replace
destring Section3ProgramLogic Section4EconomicAnalysis Section5MonitoringEvaluati, replace
egen EVAScore=rowmean(Section3ProgramLogic Section4EconomicAnalysis Section5MonitoringEvaluati)
label var EVAScore "EVA Score"
replace EVALevel="Highly Evaluable" if EVAScore>=8.95
replace EVALevel="Evaluable" if EVAScore>=7 & EVAScore<8.95
replace EVALevel="Partially Evaluable" if EVAScore>=5 & EVAScore<7
replace EVALevel="Partially Unevaluable" if EVAScore>=4 & EVAScore<5
replace EVALevel="Unevaluable" if EVAScore>=2 & EVAScore<4
replace EVALevel="Highly Unevaluable" if EVAScore<2
	foreach var of varlist Name Country Type Sector {
	tostring `var', replace
	replace `var'="" if `var'=="."
	}		
	foreach var of varlist Section1IDB9StrategicAlign LendingProgram Lendingtosmallandvulnerable Barbados Bahamas Belize Bolivia CostaRica DominicanRepublic Ecuador ElSalvador Guatemala Guyana Haiti Honduras Jamaica Nicaragua Panama Paraguay Suriname TrinidadandTobago Uruguay Lendingforpovertyreductionan AG Geographic BeneficiariesHeadcountor Lendingtosupportclimatechang Mitigation Adaptation Sustainablepractices Lendingtosupportregionalcoop Infrastructure RegionalInitiatives InstitutionalStrengthening RegionalPublicGoods CapacityDevelopment RegionalDevelopmentGoals Socialpolicyforequityandpro Extremepovertyrate Ginicoefficientofpercapitah Shareofyouthages15to19who Maternalmortalityratio Infantmortalityratio Shareofformalemploymentinto Infrastructureforcompetitivene Incidenceofwaterbornediseases PavedroadcoverageKmKm2 Percentofhouseholdswithelect Proportionofurbanpopulationl Institutionsforgrowthandsoci PercentoffirmsusingBanksto Ratioofactualtopotentialtax Percentofchildrenunder5whos Publicexpendituremanagedatth Homicidesper100000inhabitant Competitiveregionalandglobal Tradeopennesstradeaspercent IntraregionaltradeinLACaspe Foreigndirectinvestmentnetin Protectingtheenvironmentresp CO2emissionskilogramsper1 Countrieswithplanningcapacity Annualreportedeconomicdamages Proportionofterrestrialandma Annualgrowthrateofagricultur BankOutputContributiontoRegi BX Studentsbenefitedbyeducation All Girls Boys Teacherstrained Individualsreceivingabasicpa CE Indigenous Afrodescendant Individualsreceivingtargeteda CI CJ CK Individualsbenefitedfromprogr CM Men Women Numberofjobsaddedtoformals CQ Householdswithneworupgraded CS CT CU CV CW CX CY Kmofinterurbanroadsbuiltor Kmofelectricitytransmissiona Numberofhouseholdswithnewor DC DD DE DF Microsmallmediumproductiveen Publicfinancialsystemsimpleme Personsincorporatedintoacivi DJ DK DL DM DN Municipalorothersubnational Citiesbenefitedwithcitizense DQ Numberofpublictradeofficials DS DT DU Regionalandsubregionalintegr Numberofcrossborderandtrans Numberofinternationaltradetr MobilizationvolumebyNSGfinan DZ Percentageofpowergenerationc Numberofpeoplegivenaccessto EC ED EE Nationalframeworksforclimate Climatechangepilotprojectsin Numberofprojectswithcomponen Farmersgivenaccesstoimproved EJ EK EL EM EN EO Section2CountryStrategyCoun CountryStrategyResultsMatrix Theinterventionisalignedwith TheCountryStrategyCSorCSU CountryProgramResultsMatrix TheprojectisincludedintheC Iftheinterventionisnotalign Providejustificationofthere {
	tostring `var', replace
	replace `var'="" if `var'=="."
	replace Section1IDB9StrategicAlign="Aligned" if strpos(`var', "Yes") | strpos(`var', "yes") 
	replace Section1IDB9StrategicAlign="Not Aligned" if Section1IDB9StrategicAlign!="Aligned"
	}
			foreach v of varlist Theinterventionisalignedwith TheprojectisincludedintheC {
			tostring `v', replace
			replace Section2CountryStrategyCoun="Aligned" if strpos(`v', "Yes") | strpos(`v', "yes") | strpos(`v', "YES") 
			replace Section2CountryStrategyCoun="Not Aligned" if Section2CountryStrategyCoun!="Aligned"
			}
			foreach v of varlist AG Geographic BeneficiariesHeadcountor {
			replace Lendingforpovertyreductionan="Yes" if strpos(`v', "Yes") | strpos(`v', "yes") | strpos(`v', "YES") 
			}
			foreach v of varlist Mitigation Adaptation Sustainablepractices {
			replace Lendingtosupportclimatechang="Yes" if strpos(`v', "Yes") | strpos(`v', "yes") | strpos(`v', "YES") 
			}	
			foreach v of varlist Infrastructure RegionalInitiatives InstitutionalStrengthening RegionalPublicGoods CapacityDevelopment {
			replace Lendingtosupportregionalcoop="Yes" if strpos(`v', "Yes") | strpos(`v', "yes") | strpos(`v', "YES") 
			}	
			replace Individualsreceivingabasicpa ="yes" if CE=="yes" | CE=="Yes" | CE=="YES"
			replace Individualsreceivingtargeteda="yes" if CI=="yes" | CI=="Yes" | CI=="YES" 
			replace Individualsbenefitedfromprogr="yes" if CM=="yes" | CM=="Yes" | CM=="YES"  
	
	order	 QBR Country ProjectNumber Name Type Sector BODApprovedDate EVAScore EVALevel, first
	sort QBR
	foreach var of varlist Section3ProgramLogic ProgramDiagnosis Themainproblemsbeingaddresse Theintendedbeneficiarypopulat Themainfactorsorcausescon Empiricalevidenceofthemaind Magnitudesofdeficienciesarep Diagnosistakesintoaccountspe ProposedInterventionsorSoluti ProposedInterventionsarecle Evidenceoftheeffectivenessof Informationabouttheapplicabil Thedimensionoftheproposedso ResultsMatrixQuality VerticalLogic VerifytheverticallogicEach Impactoftheprogram Thedesiredmediumorlongterm ThereisatleastoneSMARTindi Theresultsmatrixincludesexa Theresultsmatrixincludesapr Theresultsmatrixorthemonito Outcomes Thedesiredimprovementseffect FV FW FX FY Outputs Projectdeliverablesareclearly GB GC GD GE GF Section4EconomicAnalysis CostBenefitAnalysisCBA TheprojecthasanERRandorNP Theeconomicbenefitsareadequa Allrealresourcecostsgenerate Assumptionsusedintheanalysis Sensitivityanalysisisperforme CostEffectivenessCEA Theprojecthasacosteffective Keyoutcomesareadequatelyiden Allavailablealternativesarec Theeconomiccostsofeachalter Reasonableassumptionsareused GT GeneralEconomicAnalysisGEA TheGeneralEconomicAnalysisAn Theabovementionedeconomicrat Theeconomicbenefitsdirecta Allrelevantdirectandindire GZ HA Sensitivityanalysisisbasedon HC Section5MonitoringEvaluati IMonitoring TheBankandborrowerhaveagree Outputindicatorshaveannualta Totalprojectcostsaregrouped Costsforeachoutputhaveannua Thesumofthetotalplannedcos Monitoringmechanismshavebeen Ensurethatthesourceormeans IIEvaluation General Theprojecthasanevaluationpl Timelinesaredefinedtodesign Theevaluationplanhasanalloc Methodologytomeasureincrement Methodusedtoevaluater RandomAssignment NonExperimentalMethodsDiffer ExpostCostBenefitAnalysis ExpostCostEffectivenessAnaly BeforeAfterorWithWithoutCom Evaluationaspectsrequir Avalidcomparisoncontrolgroup Thedefinitionofthecounterfac Poweranalysiswasperformedto Thenumberofwavesofdatacoll Theinformationthatneedstobe {
	destring `var', replace
	}
	foreach var of varlist Section6RiskManagement Overallriskratemagnitudeof Environmentalsocialriskclas RiskMatrix Identifiedriskshavebeenrated IJ MitigationMeasures Majorriskshaveidentifiedprop Mitigationmeasureshaveindicat Section7Additionality Theprojectreliesontheuseof FiduciarySystemsVPCFMPcriter FinancialManagement Budget Treasury AccountingandReportin Externalcontrol InternalAudit Procurement InformationSystem ShoppingMethod Contractingindividual NationalPublicBidding UseofsomeNatio AdvanceduseofN NonFiduciarySystems StrategicPlanningNational UseofsomeSectorial MonitoringandEvaluationN JH StatisticsNationalSystem EnvironmentalAssessmentNa TheIDBsinvolvementpromotesa GenderEquality Labor Environment Additionaltoprojectpreparati Theexpostimpactevaluationof {
	tostring `var', replace
	replace `var'="" if `var'=="."
	}
	**CHECK
	if inlist("`sheet'","Approved_OPC") replace TheprojectisincludedintheC="No" if TheprojectisincludedintheC==""
	merge m:1 ProjectNumber using "`dataout'query_dataset.dta", update replace force
	keep if _merge==3 | _merge==4
	drop _merge
	sort QBR ProjectNumber
	drop BODApprovedDate
	rename approvaldate BODApprovedDate
	order	 QBR Country ProjectNumber Name Type Sector BODApprovedDate EVAScore EVALevel, first
	replace EVAScore=round(EVAScore, 0.1)
	**format BODApprovedDate %tdddMonYY

**Individual changes (CHECK)
capture replace RandomAssignment=. if projectnumber=="UR-L1106"
capture replace NonExperimentalMethodsDiffer=3.15 if projectnumner=="UR-L1106"	

export excel using "`dataout'DEM QBR`q' `year'_2.xlsx" , sheet("QRR_f2015") sheetmodify cell(A3) datestring("%tdddMonYY")	
}

foreach type in qrr opc {
	
if regexm("``type'_format_years'","2016b")==1 & "`type'"=="qrr" {
**QRR
import excel "`dataout'DEM QBR`q' `year'.xlsx" , sheet("QRR_f2016b") cellrange(A2:HQ40) firstrow clear
} 
if regexm("``type'_format_years'","2016b")==1 & "`type'"=="opc" {
**Approved OPC
import excel "`dataout'DEM QBR`q' `year'.xlsx" , sheet("Approved_OPC_f2016b") cellrange(A2:HQ40) firstrow clear	
}

drop if QBR==""
drop EVAScore
tostring EVALevel, replace
destring Section3ProgramLogic Section4EconomicAnalysis Section5MonitoringEvaluati, replace
egen EVAScore=rowmean(Section3ProgramLogic Section4EconomicAnalysis Section5MonitoringEvaluati)
label var EVAScore "EVA Score"
replace EVALevel="Highly Evaluable" if EVAScore>=8.95
replace EVALevel="Evaluable" if EVAScore>=7 & EVAScore<8.95
replace EVALevel="Partially Evaluable" if EVAScore>=5 & EVAScore<7
replace EVALevel="Partially Unevaluable" if EVAScore>=4 & EVAScore<5
replace EVALevel="Unevaluable" if EVAScore>=2 & EVAScore<4
replace EVALevel="Highly Unevaluable" if EVAScore<2
		foreach var of varlist Name Country Type Sector {
	  tostring `var', replace
	  replace `var'="" if `var'=="."
	  }   
	  
	  foreach var of varlist Section1IDB9StrategicAlign DevelopmentChallenges SocialInclusionandEquality ProductivityandInnovation EconomicIntegration CrosscuttingThemes GenderEqualityandDiversity ClimateChangeandEnvironmental InstitutionalCapacityandtheR RegionalContextIndicators PovertyheadcountratioUS4p Ginicoefficient SocialProgressIndex GrowthrateofGDPperpersonem GlobalInnovationIndexLACave Researchanddevelopmentexpendi Intraregionaltradeingoods Growthrateofthevalueoftota Foreigndirectinvestmentnetin Greenhousegasemissionskgof Proportionofterrestrialandma Governmenteffectivenessaverag RuleoflawaverageLACpercent CountryDevelopmentResultsIndi IntermediateOutcomes Countriesintheregionwithimp Maternalmortalityrationumber Propertyvaluewithinprojectar Reductionofemissionswithsupp Publicagenciesprocessingtime Formalemploymentofwomen PercentofGDPcollectedintaxe ImmediateOutcomes Studentsbenefitedbyeducation Beneficiariesreceivinghealths Beneficiariesoftargetedantip Beneficiariesofimprovedmanage Householdsbenefittingfromhous Beneficiariesofonthejobtrai Jobscreatedbysupportedfirms Womenbeneficiariesofeconomic Microsmallmediumenterpris AZ Outputs Householdswithneworupgraded BC Installedpowergenerationfrom Roadsbuiltorupgradedkm Professionalsfrompublicandpr Regionalsubregionalandextra Subnationalgovernmentsbenefite Governmentagenciesbenefitedby BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ CA CB CC CD CE CF CG CH CI CJ CK CL CM Section2CountryStrategyCoun CountryStrategyResultsMatrix Theinterventionisalignedwith TheCountryStrategyCSorCSU CountryProgramResultsMatrix TheprojectisincludedintheC Iftheinterventionisnotalign Providejustificationofthere CV {
		tostring `var', replace       
		replace `var'="" if `var'=="."
 		}
**		foreach var of varlist Section1IDB9StrategicAlign LendingProgram Lendingtosmallandvulnerable Barbados Bahamas Belize Bolivia CostaRica DominicanRepublic Ecuador ElSalvador Guatemala Guyana Haiti Honduras Jamaica Nicaragua Panama Paraguay Suriname TrinidadandTobago Uruguay Lendingforpovertyreductionan AG Geographic BeneficiariesHeadcountor Lendingtosupportclimatechang Mitigation Adaptation Sustainablepractices Lendingtosupportregionalcoop Infrastructure RegionalInitiatives InstitutionalStrengthening RegionalPublicGoods CapacityDevelopment RegionalDevelopmentGoals Socialpolicyforequityandpro Extremepovertyrate Ginicoefficientofpercapitah Shareofyouthages15to19who Maternalmortalityratio Infantmortalityratio Shareofformalemploymentinto Infrastructureforcompetitivene Incidenceofwaterbornediseases PavedroadcoverageKmKm2 Percentofhouseholdswithelect Proportionofurbanpopulationl Institutionsforgrowthandsoci PercentoffirmsusingBanksto Ratioofactualtopotentialtax Percentofchildrenunder5whos Publicexpendituremanagedatth Homicidesper100000inhabitant Competitiveregionalandglobal Tradeopennesstradeaspercent IntraregionaltradeinLACaspe Foreigndirectinvestmentnetin Protectingtheenvironmentresp CO2emissionskilogramsper1 Countrieswithplanningcapacity Annualreportedeconomicdamages Proportionofterrestrialandma Annualgrowthrateofagricultur BankOutputContributiontoRegi BX Studentsbenefitedbyeducation All Girls Boys Teacherstrained Individualsreceivingabasicpa CE Indigenous Afrodescendant Individualsreceivingtargeteda CI CJ CK Individualsbenefitedfromprogr CM Men Women Numberofjobsaddedtoformals CQ Householdswithneworupgraded CS CT CU CV CW CX CY Kmofinterurbanroadsbuiltor Kmofelectricitytransmissiona Numberofhouseholdswithnewor DC DD DE DF Microsmallmediumproductiveen Publicfinancialsystemsimpleme Personsincorporatedintoacivi DJ DK DL DM DN Municipalorothersubnational Citiesbenefitedwithcitizense DQ Numberofpublictradeofficials DS DT DU Regionalandsubregionalintegr Numberofcrossborderandtrans Numberofinternationaltradetr MobilizationvolumebyNSGfinan DZ Percentageofpowergenerationc Numberofpeoplegivenaccessto EC ED EE Nationalframeworksforclimate Climatechangepilotprojectsin Numberofprojectswithcomponen Farmersgivenaccesstoimproved EJ EK EL EM EN EO Section2CountryStrategyCoun CountryStrategyResultsMatrix Theinterventionisalignedwith TheCountryStrategyCSorCSU CountryProgramResultsMatrix TheprojectisincludedintheC Iftheinterventionisnotalign Providejustificationofthere {
**		tostring `var', replace
**		replace `var'="" if `var'=="."
**		replace Section1IDB9StrategicAlign="Aligned" if strpos(`var', "Yes") | strpos(`var', "yes") 
**		replace Section1IDB9StrategicAlign="Not Aligned" if Section1IDB9StrategicAlign!="Aligned"
**		}
			foreach v of varlist Theinterventionisalignedwith TheprojectisincludedintheC {
			tostring `v', replace
			replace Section2CountryStrategyCoun="Aligned" if strpos(`v', "Yes") | strpos(`v', "yes") | strpos(`v', "YES") 
			replace Section2CountryStrategyCoun="Not Aligned" if Section2CountryStrategyCoun!="Aligned"
			}
**			foreach v of varlist AG Geographic BeneficiariesHeadcountor {
**			replace Lendingforpovertyreductionan="Yes" if strpos(`v', "Yes") | strpos(`v', "yes") | strpos(`v', "YES") 
**			}
**			foreach v of varlist Mitigation Adaptation Sustainablepractices {
**			replace Lendingtosupportclimatechang="Yes" if strpos(`v', "Yes") | strpos(`v', "yes") | strpos(`v', "YES") 
**			}	
**			foreach v of varlist Infrastructure RegionalInitiatives InstitutionalStrengthening RegionalPublicGoods CapacityDevelopment {
**			replace Lendingtosupportregionalcoop="Yes" if strpos(`v', "Yes") | strpos(`v', "yes") | strpos(`v', "YES") 
**			}	
**			replace Individualsreceivingabasicpa ="yes" if CE=="yes" | CE=="Yes" | CE=="YES"
**			replace Individualsreceivingtargeteda="yes" if CI=="yes" | CI=="Yes" | CI=="YES" 
**			replace Individualsbenefitedfromprogr="yes" if CM=="yes" | CM=="Yes" | CM=="YES"  
**	
	order	 QBR Country ProjectNumber Name Type Sector BODApprovedDate EVAScore EVALevel, first
	sort QBR
	foreach var of varlist Section3ProgramLogic ProgramDiagnosis Themainproblemsbeingaddresse Theintendedbeneficiarypopulat Themainfactorsorcausescon Empiricalevidenceofthemaind Magnitudesofdeficienciesarep Diagnosistakesintoaccountspe ProposedInterventionsorSoluti ProposedInterventionsarecle Evidenceoftheeffectivenessof Informationabouttheapplicabil Thedimensionoftheproposedso ResultsMatrixQuality VerticalLogic VerifytheverticallogicEach Impactoftheprogram Thedesiredmediumorlongterm ThereisatleastoneSMARTindi Theresultsmatrixincludesexa Theresultsmatrixincludesapr Theresultsmatrixorthemonito Outcomes Thedesiredimprovementseffect DU DV DW DX DY Projectdeliverablesareclearly EA EB EC ED EE Section4EconomicAnalysis CostBenefitAnalysisCBA TheprojecthasanERRandorNP Theeconomicbenefitsareadequa Allrealresourcecostsgenerate Assumptionsusedintheanalysis Sensitivityanalysisisperforme CostEffectivenessCEA Theprojecthasacosteffective Keyoutcomesareadequatelyiden Allavailablealternativesarec Theeconomiccostsofeachalter Reasonableassumptionsareused ES GeneralEconomicAnalysisGEA TheGeneralEconomicAnalysisAn Theabovementionedeconomicrat Theeconomicbenefitsdirecta Allrelevantdirectandindire EY EZ Sensitivityanalysisisbasedon FB Section5MonitoringEvaluati IMonitoring TheBankandborrowerhaveagree Outputindicatorshaveannualta Totalprojectcostsaregrouped Costsforeachoutputhaveannua Thesumofthetotalplannedcos Monitoringmechanismshavebeen Ensurethatthesourceormeans IIEvaluation General Theprojecthasanevaluationpl Timelinesaredefinedtodesign Theevaluationplanhasanalloc Methodologytomeasureincrement Methodusedtoevaluater RandomAssignment NonExperimentalMethodsDiffer ExpostCostBenefitAnalysis ExpostCostEffectivenessAnaly BeforeAfterorWithWithoutCom Evaluationaspectsrequir Avalidcomparisoncontrolgroup Thedefinitionofthecounterfac Poweranalysiswasperformedto Thenumberofwavesofdatacoll Theinformationthatneedstobe GD {
	destring `var', replace
	}
	foreach var of varlist Section6RiskManagement Overallriskratemagnitudeof Environmentalsocialriskclas RiskMatrix Identifiedriskshavebeenrated GJ MitigationMeasures Majorriskshaveidentifiedprop Mitigationmeasureshaveindicat GN Section7Additionality Theprojectreliesontheuseof FiduciarySystemsVPCFMPcriter FinancialManagement Budget Treasury AccountingandReportin Externalcontrol InternalAudit Procurement InformationSystem ShoppingMethod Contractingindividual NationalPublicBidding UseofsomeNatio AdvanceduseofN NonFiduciarySystems StrategicPlanningNational UseofsomeSectorial MonitoringandEvaluationN HI StatisticsNationalSystem EnvironmentalAssessmentNa TheIDBsinvolvementpromotesa GenderEquality Labor Environment Additionaltoprojectpreparati Theexpostimpactevaluationof {
	tostring `var', replace
	replace `var'="" if `var'=="."
	}
	replace TheprojectisincludedintheC="No" if TheprojectisincludedintheC==""
	merge m:1 ProjectNumber using "`dataout'query_dataset.dta", update replace force 
	keep if _merge==3 | _merge==4 | _merge==5
	drop _merge
	sort QBR ProjectNumber
	drop BODApprovedDate
	rename approvaldate BODApprovedDate
	order	 QBR Country ProjectNumber Name Type Sector BODApprovedDate EVAScore EVALevel, first
	replace EVAScore=round(EVAScore, 0.1)

		
if regexm("``type'_format_years'","2016b")==1 & "`type'"=="opc" {
**QRR
export excel using "`dataout'DEM QBR`q' `year'_2.xlsx" , sheet("Approved_OPC_f2016b") sheetmodify cell(A3) datestring("%tdddMonYY")
}

if regexm("``type'_format_years'","2016b")==1 & "`type'"=="qrr" {
**Approved OPC
export excel using "`dataout'DEM QBR`q' `year'_2.xlsx" , sheet("QRR_f2016b") sheetmodify cell(A3) datestring("%tdddMonYY")
}
}

copy "`dataout'DEM QBR`q' `year'_2.xlsx" "`dataout'DEM QBR`q' `year'_final.xlsx", replace


