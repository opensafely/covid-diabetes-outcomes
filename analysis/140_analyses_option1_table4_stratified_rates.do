local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Stratified outcome rate comparisons - groups 1,2 and 3
**///////////////////////////////////////////////////////////////////

use $outdir/input_part1_clean.dta, clear

local grouplabel1="COVID-19 with diabetes"
local grouplabel2="COVID-19 without diabetes"
local grouplabel3="Pneumonia with diabetes"

set more off

**// Loop over each outcome
foreach outcome in "stroke" "death" {
	use $outdir/input_part1_clean.dta, clear
	gen myend=(min(date_`outcome', date_censor)-date_patient_index)/(365.25/12)
	gen myselect=(myend>0)
	gen delta=(date_`outcome'==min(date_`outcome', date_censor))
	stset myend, f(delta) id(patient_id)
	local demogindex=0
	**// Loop over each demographic/characteristic
	foreach demog in "sex" "age" "ethnic" "imd" {
		local demogindex=`demogindex'+1
		summ cat_`demog'
		local numcat_`demog'=r(max)
		**// Loop over categories of the demographic/characteristic
		forvalues catindex=1(1)`numcat_`demog'' {
			capture erase $resultsdir/rates_`outcome'_`demog'_`catindex'.dta
			**// Calculate rates and post
			preserve
			keep if cat_`demog'==`catindex'
			tempname rates
				postfile `rates' demogindex catindex groupindex str20(demographic) str25(group) `outcome'_ptime `outcome'_events `outcome'_rate `outcome'_rate_lo `outcome'_rate_hi ///
				using $resultsdir/rates_`outcome'_`demog'_`catindex'.dta, replace
				if _N>0 {
					forvalues k=1(1)3 {
						stptime if group==`k' & myselect==1, title(person-months) per(10000)
						post `rates' (`demogindex') (`catindex') (`k') ("`demog'") ("`grouplabel`k''") (`r(ptime)') (`r(failures)') (`r(rate)') (`r(lb)') (`r(ub)')
					}		
				}
				if _N==0 {
					forvalues k=1(1)3 {
						post `rates' (`demogindex') (`catindex') (`k') ("`demog'") ("`grouplabel`k''") (.) (.) (.) (.) (.)
					}					
				}								
			postclose `rates' 	
			restore
		}
	}
}

**// Append categories within each demographic for each outcome
foreach outcome in "stroke" "death" {
	foreach demog in "sex" "age" "ethnic" "imd" {
		clear
		set obs 0
		forvalues catindex=1(1)`numcat_`demog'' {
			append using $resultsdir/rates_`outcome'_`demog'_`catindex'.dta
			erase $resultsdir/rates_`outcome'_`demog'_`catindex'.dta
		}
		tostring catindex, gen(category) force
		order category, after(demographic)
		do `mypath'/002_catlab.do
		save $resultsdir/rates_`outcome'_`demog'.dta, replace
	}
}

**// Append demographics within each outcome
foreach outcome in "stroke" "death" {
	clear
	set obs 0
	foreach demog in "sex" "age" "ethnic" "imd" {
		append using $resultsdir/rates_`outcome'_`demog'.dta
		erase $resultsdir/rates_`outcome'_`demog'.dta
	}
	sort demogindex catindex groupindex
	**// Tidy presentation of rates and CIs
	format `outcome'_ptime `outcome'_events %12.0f
	describe `outcome'_rate*, varlist
	foreach myvar in `r(varlist)' {
		format `myvar' %12.1f
		tostring `myvar', replace force usedisplayformat
		
	}
	gen newvar=`outcome'_rate+" ("+`outcome'_rate_lo+", "+`outcome'_rate_hi+")"
	replace newvar="-" if newvar==". (., .)"
	drop `outcome'_rate*
	rename newvar `outcome'_rate
	save $resultsdir/rates_`outcome'.dta, replace
}

**// Merge outcomes
use $resultsdir/rates_stroke.dta, clear
foreach outcome in "death" {
	capture merge 1:1 demogindex catindex groupindex using $resultsdir/rates_`outcome'.dta
	if _rc==0 {
	   drop _merge
	   erase $resultsdir/rates_`outcome'.dta
	}
}
erase $resultsdir/rates_stroke.dta	
sort demogindex catindex groupindex

**// Labelling
do `mypath'/001_demoglab.do

**// Tidy
gen temp1=1 if demographic==demographic[_n-1]
replace demographic="" if temp1==1
gen temp2=1 if category==category[_n-1]
replace category="" if temp2==1
drop temp1 temp2

describe, varlist
foreach myvar in `r(varlist)' {
	capture gen str=strlen(`myvar')
	if _rc==0 {
		summ str
		format `myvar' %-`r(max)'s
		drop str			
	}
}
drop demogindex catindex groupindex
save $resultsdir/option1_table4_stratified_rates.dta, replace
	
**// Convert to csv
export delimited $resultsdir/option1_table4_stratified_rates.csv, replace
