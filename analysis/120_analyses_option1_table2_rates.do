local mypath="`c(pwd)'/analysis/"
do `mypath'/000_filepaths.do


**// Outcome rates - groups 1,2 and 3
**//////////////////////////////////////////////

use $outdir/input_part1_clean.dta, clear

local grouplabel1="COVID-19 with diabetes"
local grouplabel2="COVID-19 without diabetes"
local grouplabel3="Pneumonia with diabetes"

set more off

tempname rates
	postfile `rates' outindex groupindex str30(outcome) str30(group) person_time numevents rate rate_lo rate_hi using $resultsdir/option1_table2_rates.dta, replace
	**// Outcomes
	local outindex=0
	foreach outcome in "stroke" "death" {	
		local outindex=`outindex'+1
		gen myend=(min(date_`outcome', date_censor)-date_patient_index)/(365.25/12)
		gen myselect=(myend>0)
		gen delta=(date_`outcome'==min(date_`outcome', date_censor))
		stset myend, f(delta) id(patient_id)
		forvalues k=1(1)3 {
			stptime if group==`k' & myselect==1, title(person-months) per(10000)
			post `rates' (`outindex') (`k') ("`outcome'") ("`grouplabel`k''") (`r(ptime)') (`r(failures)') (`r(rate)') (`r(lb)') (`r(ub)')
		}
		drop myselect myend delta _st _d _t _t0
	}
postclose `rates'

use $resultsdir/option1_table2_rates.dta, clear

**// Labelling
gen type=""
order type, before(outcome)
do `mypath'/003_outlab.do
do `mypath'/004_typelab.do

**// Tidy
sort outindex groupindex
gen temp1=1 if type==type[_n-1]
replace type="" if temp1==1
gen temp2=1 if outcome==outcome[_n-1]
replace outcome="" if (temp2==1 | lower(outcome)=="death")
drop outindex groupindex temp1 temp2

describe type-group, varlist
foreach myvar in `r(varlist)' {
	gen str=strlen(`myvar')
	summ str
	format `myvar' %-`r(max)'s
	drop str
}

format person_time %12.1fc
format numevents %12.0fc

format rate* %12.1fc
tostring rate,    gen(temp1) force usedisplayformat
tostring rate_lo, gen(temp2) force usedisplayformat
tostring rate_hi, gen(temp3) force usedisplayformat
gen rate_ci=temp1+" ("+temp2+", "+temp3+")"
drop rate rate_lo rate_hi temp*
rename rate_ci rate

gen str=strlen(rate)
summ str
format rate %`r(max)'s
drop str

save $resultsdir/option1_table2_rates.dta, replace

**// Convert to csv
export delimited using $resultsdir/option1_table2_rates.csv, replace
