local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Period-specific rates - groups 1,2 and 3
**//////////////////////////////////////////////

use $outdir/input_part1_clean.dta, clear

local grouplabel1="COVID-19 with diabetes"
local grouplabel2="COVID-19 without diabetes"
local grouplabel3="Pneumonia with diabetes"

gen     period=.
replace period=1 if date_patient_index>=mdy(2,1,2020)  & (group==1 | group==2)
replace period=2 if date_patient_index>=mdy(6,16,2020) & (group==1 | group==2)
replace period=3 if date_patient_index>=mdy(3,24,2021) & (group==1 | group==2)

replace period=1 if date_patient_index>=mdy(2,1,2019)  & (group==3)
replace period=2 if date_patient_index>=mdy(6,16,2019) & (group==3)
replace period=3 if date_patient_index>=mdy(3,24,2020) & (group==3)

set more off

tempname rates
	postfile `rates' outindex groupindex str30(outcome) str30(group) ///
	person_time1 numevents1 rate1 rate1_lo rate1_hi ///
	person_time2 numevents2 rate2 rate2_lo rate2_hi ///
	person_time3 numevents3 rate3 rate3_lo rate3_hi ///
	using $resultsdir/option1_table6_periodspecific_rates.dta, replace
	**// Outcomes
	local outindex=0
	foreach outcome in "stroke_thrombotic" "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
	"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {	
		local outindex=`outindex'+1
		gen myend=(min(date_`outcome', date_censor)-date_patient_index)/(365.25/12)
		gen myselect=(myend>0)
		gen delta=(date_`outcome'==min(date_`outcome', date_censor))
		capture stset myend, f(delta) id(patient_id)
		forvalues k=1(1)3 {
			forvalues m=1(1)3 {
				count if group==`k' & myselect==1 & delta==1 & period==`m'
				if r(N)>=8 {
					capture stptime if group==`k' & myselect==1 & period==`m', title(person-months) per(10000)
					if _rc==0 {
						local person_time`m'=r(ptime)
						local numevents`m'=r(failures)
						local rate`m'=r(rate)
						local rate`m'_lo=r(lb)
						local rate`m'_hi=r(ub)
					}
					if _rc!=0 {
						local person_time`m'=999999
						local numevents`m'  =999999
						local rate`m'       =999999
						local rate`m'_lo    =999999
						local rate`m'_hi    =999999					
					}					
				}
				else {
					local person_time`m'=.
					local numevents`m'=.
					local rate`m'=.
					local rate`m'_lo=.
					local rate`m'_hi=.
				}
			}
			post `rates' (`outindex') (`k') ("`outcome'") ("`grouplabel`k''") ///
			(`person_time1') (`numevents1') (`rate1') (`rate1_lo') (`rate1_hi') ///
			(`person_time2') (`numevents2') (`rate2') (`rate2_lo') (`rate2_hi') ///
			(`person_time3') (`numevents3') (`rate3') (`rate3_lo') (`rate3_hi')
		}
		foreach myvar in myselect myend delta _st _d _t _t0 {
			capture drop `myvar'
		}
	}
postclose `rates'

use $resultsdir/option1_table6_periodspecific_rates.dta, clear

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

format person_time* %12.1fc
format numevents* %12.0fc

format rate* %12.1fc

forvalues m=1(1)3 {
	tostring rate`m',    gen(temp1) force usedisplayformat
	tostring rate`m'_lo, gen(temp2) force usedisplayformat
	tostring rate`m'_hi, gen(temp3) force usedisplayformat
	gen rate`m'_ci=temp1+" ("+temp2+", "+temp3+")"
	drop rate`m' rate`m'_lo rate`m'_hi temp*
	rename rate`m'_ci rate_period`m'
}
order *1 *2 *3, after(group)

forvalues m=1(1)3 {
	gen str=strlen(rate_period`m')
	summ str
	format rate_period`m' %`r(max)'s
	drop str
}

do `mypath'/005_table_edit.do

save $resultsdir/option1_table6_periodspecific_rates.dta, replace
