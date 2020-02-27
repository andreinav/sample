*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* GLOBALS & INSTALLING PROGRAMS
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// globals 
set more off
global original_data "C:\Users\gaparicio\Desktop\Mapas Metro Lima\original data\"
global temp_data "C:\Users\gaparicio\Desktop\Mapas Metro Lima\temp data\"
* global gdal "C:\Program Files\QGIS Essen\OSGeo4W.bat"

/*
// installing programs 
net install spgrid, from("http://fmwww.bc.edu/RePEc/bocode/s")
net install geoinpoly, from("http://fmwww.bc.edu/RePEc/bocode/g")
net install spkde, from("http://fmwww.bc.edu/RePEc/bocode/s")
net install mergepoly, from("http://fmwww.bc.edu/RePEc/bocode/m")
*/

// CHOOSE PARAMETERS FOR GRIDS
	* Diameter of hexagonal grids
	* Latitude: 1 deg = 110.574 km
	* 25km = 0.226 deg
	* 0.25 km = 0.00226
	global diameter_a=0.00226 // equivalent to 0.25 km
	global diameter_b=0.0226 // equivalent to 2.5 km

// CHOOSE PARAMETERS FOR KERNELS
	// global tkernel="epa" // epachinov kernel
	* parameters for mixed method
	// uses bandwith "h" if at least "ndp" obs within "h"
	// otherwise uses the bandwith that give you at least "ndp" obs
	// drop if the radius at which it needs to search is bigger than "maxdist"
	
	** Model 0: METRO-CURRENT
	global h_0=0.00452 // equiv to 0.5 km
	global ndp_0=5 // always have at least five obs
	// global maxdist=0.0452 // equiv to 5 km // Oscar thinks too large
	
	** Model 1: METRO-CURRENT
	global h_1=0.00226 // equivalent to 0.25 km
	global ndp_1=5 // always have at least five obs	
	// global maxdist_1=0.031532 // approx 3.5 km (median value)
	
	** Model 2: Rent
	global h_2=0.00904 // equiv 1 km 
	global ndp_2=5
	// global ndp_r=10 // always have at least five obs
	// global maxdist_2=0.08 define it based on the median
	
	** Model 3: Rent
	global h_3=0.0113 // equiv 1.25 km 
	global ndp_3=7	
	
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* GENERATE GRIDS 
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

foreach diameter in a b {
local name diameter_`diameter'
spgrid using "$original_data\coord_distri_latlon.dta",   ///
        shape(hex) resolution(w$`name') unit(degrees) ///
		verbose replace compress             ///
        cells("$temp_data\Distritos-GridCells_`diameter'.dta")  ///
        points("$temp_data\Distritos-GridPoints_`diameter'.dta")
}
		
* Look at map
/* 
use "$temp_data\Distritos-GridPoints_a.dta", clear
	spmap using "$temp_data\Distritos-GridCells_a.dta", id(spgrid_id)
use "$temp_data\Distritos-GridPoints_b.dta", clear
	spmap using "$temp_data\Distritos-GridCells_b.dta", id(spgrid_id)
*/

* MERGE POLYGON: Make a border of Lima
use "$original_data\db_distritos.dta", clear
	ren idgeo _ID
	mergepoly using "$original_data\coord_distri_latlon.dta", coordinates("$temp_data\coord_distri_border.dta") replace
	// use "coord_distri_border.dta", clear


*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* IDENTIFY DATA TO GRAPH
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// ENAHO: generate new variables
use "$original_data\Enaho2014_tatiana_3_28_2016.dta", clear
* generate differences in p-variables for metro and current
	foreach dist of numlist 15 30 45 60 {
		gen impact_`dist'p=Metro_`dist'p-Curr_`dist'p
		replace impact_`dist'p=0 if impact_`dist'p<0
	}
* Check if missing values
	count if impact_15p==.
	count if impact_30p==.
	count if impact_45p==.	
	count if impact_60p==.	
	drop if  impact_15p==.
save "$temp_data\data_with_impact.dta", replace

// RENT DATA: split years (alquiler)
foreach year in 2007 2013 2014 {
use "$original_data\data_rents07-14.dta", clear
	// browse rent year alquiler longitud latitud id_hh
	keep year alquiler longitud latitud id_hh
	keep if year=="`year'"
	drop if alquiler==.
save "$temp_data\alquiler_`year'.dta", replace
}


*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* MAKE KERNELS 
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

* USE KERNEL
****************
// Jobs Data
foreach model in 1 {
foreach grid in a {
use "$temp_data\data_with_impact.dta", clear
gen hh_num=1
local bandwidth h_`model'
local ndp ndp_`model'
spkde hh_num impact_15p impact_30p impact_45p impact_60p using ///
	"$temp_data\Distritos-GridPoints_`grid'.dta", ///
	xcoord(longitud) ycoord(latitud) ///
	kernel(epa) bandwidth(mixed) fbw($`bandwidth') ndp($`ndp') verbose ///
	saving("$temp_data\kernel_intensity_impact_`grid'_`model'.dta", replace)
}
}


// Rent Data 
foreach grid in a {
foreach model in 3 { // 2
foreach year in 2007 2014 { // 2013
use "$temp_data\alquiler_`year'.dta", clear 
gen hh_num=1
local bandwidth h_`model'
local ndp ndp_`model'
spkde hh_num alquiler using ///
	"$temp_data\Distritos-GridPoints_`grid'.dta", ///
	xcoord(longitud) ycoord(latitud) ///
	kernel(epa) bandwidth(mixed) fbw($`bandwidth') ndp($`ndp') verbose ///
	saving("$temp_data\kernel_intensity_rent_`year'_`grid'_`model'.dta", replace)
}
}
}

/* 
local year 2007 // 2014
local grid a
use "$temp_data\Distritos-GridPoints_`grid'.dta", clear
		spmap using "$temp_data\Distritos-GridCells_`grid'.dta", id(spgrid_id) ///
		point(data("$temp_data\alquiler_`year'.dta") xcoord(longitud) ycoord(latitud) select(keep if alquiler!=. & alquiler!=0))
*/
	
	
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* MAKE GRAPHS: ENAHO
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

* generate new variables
local model 1
local grid a
use "$temp_data\kernel_intensity_impact_`grid'_`model'.dta", clear
	gen mean_impact_15=(impact_15p_lambda/hh_num_lambda)*100
	gen mean_impact_30=(impact_30p_lambda/hh_num_lambda)*100
	gen mean_impact_60=(impact_60p_lambda/hh_num_lambda)*100
	gen mean_impact_45=(impact_45p_lambda/hh_num_lambda)*100
	egen max_impact=rowmax(mean_impact_60 mean_impact_45)
save "$temp_data\kernel_intensity_impact_`grid'_`model'_F.dta", replace

local model 1
local grid a
local leg=1 // 1
foreach legend in on { // off
foreach dist of numlist 15 30 45 60 0 { 
use "$temp_data\kernel_intensity_impact_`grid'_`model'_F.dta", clear
su bandwidth, d
local median=r(p50)
if "`dist'"=="0" {
	local var max_impact
	local title "Max of 60 and 45"
}
else {
	local var mean_impact_`dist'
	local title "Metro_`dist'p - Current_`dist'p"
}
su max_impact if bandwidth<=`median' , d
	local min_value=round(r(min),1)
	local p25=round(r(p25),0.1)
	local p50=round(r(p50),1)
	local p75=round(r(p75),1)
	local p90=round(r(p90),1)
	local max_value=round(r(max),1)
if `leg'==1 {
	local clbreaks "clbreaks(`min_value' `p25' `p50' `p75' `p90' `max_value')"
	local note `"note("The categories are based on the max of dist 45 and 60" "Values in %", size(medsmall))"'
	local leg_title `"legend(size(medium) order(1 "no data" 2 "[`min_value' `p25'] or (min-p25]" 3 "(`p25'-`p50'] or (p25-p50]" 4 "(`p50'-`p75'] or (p50-p75]" 5 "(`p75'-`p90'] or (p75-p90]" 6 "(`p90'-`max_value'] or (p90-max]" )) "'
}
if `leg'==2 {
	local clbreaks "clbreaks(`min_value' `p25' `p50' `p75' `p90' `max_value')"
	local  leg_title `"legend(size(medium))"'
}
spmap `var' if bandwidth<=`median' using ///
	"$temp_data\Distritos-GridCells_`grid'.dta", ///
	id(spgrid_id) clmethod(custom) `clbreaks' fcolor(Rainbow) ///
	ocolor(none ..) legenda(`legend') `leg_title' ///
	polygon(data("$temp_data\coord_distri_border.dta")) ///
	point(data("$temp_data\data_with_impact.dta") xcoord(longitud) ycoord(latitud) size(vtiny) fcolor(red) ocolor(black) shape(x) ) ///
	line(data("$original_data\coord_lineas_metro_lima.dta"	)  size(thick)) ///
	title(`title') `note'
	graph save "$temp_data\enaho_impact_`dist'_`legend'_`grid'_`model'_`leg'.gph",  replace
	graph export "$temp_data\enaho_impact_`dist'_`legend'_`grid'_`model'_`leg'.png", as(png) replace
}
}

local leg=1
graph combine "$temp_data\enaho_impact_15_on_a_1_`leg'.gph" ///
	"$temp_data\enaho_impact_30_on_a_1_`leg'.gph" ///
	"$temp_data\enaho_impact_45_on_a_1_`leg'.gph" ///
	"$temp_data\enaho_impact_60_on_a_1_`leg'.gph"
graph export "$temp_data\combined_a_1_`leg'.png", as(png) replace 



*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* MAKE GRAPHS: ALQUILER 
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

foreach grid in a {
foreach model in 3 { //
foreach year in 2007 2014 {
use "$temp_data\kernel_intensity_rent_`year'_`grid'_`model'.dta", clear
	gen mean_alquiler_`year'=alquiler_lambda/hh_num_lambda
	ren bandwidth bandwidth_`year'
	keep spgrid_id spgrid_xcoord spgrid_ycoord mean_alquiler_`year' bandwidth_`year'
save "$temp_data\alq_`year'_`grid'_`model'.dta", replace
}
}
}

local grid a
local model 3 // 2 
use "$temp_data\alq_2007_`grid'_`model'.dta", clear
	count
	joinby spgrid_id using "$temp_data\alq_2014_`grid'_`model'.dta"
	count 
	gen alq_growth_07_14=( ( (mean_alquiler_2014/mean_alquiler_2007)^(1/8) )-1 )*100
save "$temp_data\alq_2007_`grid'_`model'_F.dta", replace
	
local grid a
local model 3 // 2 
use "$temp_data\alq_2007_`grid'_`model'_F.dta", clear	
	su bandwidth_2014, d
	local max14=r(p50)
	su bandwidth_2007, d
	local max07=r(p50)
	keep if bandwidth_2007<=`max07' & bandwidth_2014<=`max14'
	su alq_growth_07_14, d
	local max_value=round(r(max),1)
	local p10=round(r(p10),1)
	local p25=round(r(p25),1)
	local p50=round(r(p50),1)
	local p75=round(r(p75),1)
	local p90=round(r(p90),1)
	local min_value=round(r(min),1)
	spmap alq_growth_07_14 using ///
	"$temp_data\Distritos-GridCells_`grid'.dta", ///
	id(spgrid_id) clmethod(custom) clbreaks(`min_value' `p10' `p25' `p50' `p75' `p90' `max_value')  fcolor(Rainbow) ///
	ocolor(none ..) legenda(on) ///
	point(data("$temp_data\alquiler_2007.dta") xcoord(longitud) ycoord(latitud) size(vtiny) fcolor(red) ocolor(black) shape(x) ) ///
	polygon(data("$temp_data\coord_distri_border.dta")) ///
	title("Rent Annual Growth Rate 2007-14 (%)") 
	graph  export  "$temp_data\alquiler growth rate_small_`grid'_`model'.png", as(png) replace

	
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* PREPARAR BASE DE DATOS A MANDAR
*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// ENAHO
use "$original_data\Enaho2014_tatiana_3_28_2016.dta", clear
	geoinpoly latitud longitud using "$temp_data\Distritos-GridCells_a.dta"
	ren _ID spgrid_id
	joinby spgrid_id using "$temp_data\kernel_intensity_impact_a_1_F.dta", unm(b)
	drop _merge A hh_num_c hh_num_lambda hh_num_p impact_15p_c impact_15p_lambda ///
		impact_15p_p impact_30p_c impact_30p_lambda impact_30p_p impact_45p_c ///
		impact_45p_lambda impact_45p_p impact_60p_c impact_60p_lambda impact_60p_p
	joinby spgrid_id using "$temp_data\alq_2007_a_3_F.dta", unm(b)
	drop _merge
	
	label var bandwidth "bandwidth used to calculate average of change in prob of jobs for the grid"
	label var ndp "number of observations used to calculate average of change in prob of jobs for the grid"	
	foreach num of numlist 15 30 45 60 {
	label var mean_impact_`num' "Metro_p`num'-Curr_p`num' for the grid"
	}
	label var max_impact "maximum of mean_impact_45 and mean_impact_60"
	
	foreach var of varlist spgrid_id- alq_growth_07_14 {
		ren `var' _grid_`var'
	}
save "$original_data\Enaho_2014_tatiana_3_28_2016_con_variables_geograficas.dta", replace
		
		


	
	
	
	
