**// Outcome rate comparisons - groups 1,2 and 3

clear
do `c(pwd)'/analysis/000_filepaths.do

use $outdir/input_part1_clean.dta, clear

local grouplabel1="COVID-19 with diabetes"
local grouplabel2="COVID-19 without diabetes"
local grouplabel3="Pneumonia with diabetes"

set more off

tempname rates
	postfile `rates' outindex groupindex str31(mytype) str30(outcome) str30(group) person_time numevents str30(rate) using $resultsdir/option1_table2_rates.dta, replace
	
	local outindex=0
	
	**// Outcomes
	foreach outcome in "stroke" "death" {
		
		local outindex=`outindex'+1
		
		if "`outcome'"=="stroke" | "`outcome'"=="mi" | "`outcome'"=="dvt" | "`outcome'"=="pe" | "`outcome'"=="heart_failure" {
			local mytypetxt="Cardiovascular"
		}
		if "`outcome'"=="aki" {
			local mytypetxt="Renal"
		}
		if "`outcome'"=="liver_failure" | "`outcome'"=="chronic_liver"{
			local mytypetxt="Hepatic"
		}
		if "`outcome'"=="anxiety" | "`outcome'"=="depression" | "`outcome'"=="psychosis" | "`outcome'"=="psych_meds" | {
			local mytypetxt="Mental illness"
		}
		if "`outcome'"=="insomnia" | "`outcome'"=="hypersomnia" | "`outcome'"=="sleep_apnoea" | "`outcome'"=="sleep_meds" | "`outcome'"=="fatigue_syndr" {
			local mytypetxt="Symptoms of post-COVID syndrome"
		}
		if "`outcome'"=="death" {
			local mytypetxt="Death from any cause"
		}
		
		gen myend=(min(date_`outcome', date_censor)-date_patient_index)/(365.25/12)
		gen myselect=(myend>0)
		gen delta=(date_`outcome'==min(date_`outcome', date_censor))
		stset myend, f(delta) id(patient_id)
		
		forvalues k=1(1)3 {
			stptime if group==`k' & myselect==1, title(person-months) per(10000) dd(1)
			local myrate=int((10*`r(rate)')+0.5)/10
			local myrate="`myrate'"	
			if strpos("`myrate'",".")==1 {
				local myrate="0"+"`myrate'"
			}
			if strpos("`myrate'",".")==0 {
				local myrate="`myrate'"+".0"
			}
			local mylb=int((10*`r(lb)')+0.5)/10
			local mylb="`mylb'"
			if strpos("`mylb'",".")==1 {
				local mylb="0"+"`mylb'"
			}
			if strpos("`mylb'",".")==0 {
				local mylb="`mylb'"+".0"
			}
			local myub=int((10*`r(ub)')+0.5)/10
			local myub="`myub'"
			if strpos("`myub'",".")==1 {
				local myub="0"+"`myub'"
			}
			if strpos("`myub'",".")==0 {
				local myub="`myub'"+".0"
			}		
			local myrate="`myrate' ("+"`mylb', "+"`myub')"
			post `rates' (`outindex') (`k') ("`mytypetxt'") ("`outcome'") ("`grouplabel`k''") (`r(ptime)') (`r(failures)') ("`myrate'")
		}
		
		drop myselect myend delta _st _d _t _t0
	}
	
postclose `rates'

**// Tidy and convert to csv
use $resultsdir/option1_table2_rates.dta, clear
sort outindex groupindex
gen temp1=1 if mytype==mytype[_n-1]
replace mytype="" if temp1==1
gen temp2=1 if outcome==outcome[_n-1]
replace outcome="" if (temp2==1 | outcome=="death")
drop outindex groupindex temp1 temp2
rename mytype type
save $resultsdir/option1_table2_rates.dta, replace
export delimited using $resultsdir/option1_table2_rates.csv, replace
