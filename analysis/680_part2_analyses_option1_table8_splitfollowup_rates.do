local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Split follow-up rates - groups 1,2 and 3
**//////////////////////////////////////////////

use $outdir/input_part2_clean.dta, clear

local grouplabel1="COVID-19 with diabetes"
local grouplabel2="COVID-19 without diabetes"

**// Increments (days)
local incr=122

set more off

tempname rates
	postfile `rates' outindex groupindex str30(outcome) str30(group) ///
	ptime1 numevents1 rate1 rate1_lo rate1_hi ///
	ptime2 numevents2 rate2 rate2_lo rate2_hi ///
	ptime3 numevents3 rate3 rate3_lo rate3_hi ///
	ptime4 numevents4 rate4 rate4_lo rate4_hi ///
	ptime5 numevents5 rate5 rate5_lo rate5_hi ///
	using $resultsdir/part2_option1_table8_splitfollowup_rates.dta, replace
	**// Outcomes
	local outindex=0
	foreach outcome in "stroke_thrombotic" "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
	"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {	
		local outindex=`outindex'+1
		forvalues k=1(1)2 {
			forvalues j=1(1)5 {
				gen mystart=date_patient_index+(`j'-1)*`incr'
				gen myend  =min(date_`outcome', date_censor, date_patient_index+`j'*`incr')
				gen myselect=(myend>mystart)
				gen delta=(myend==date_`outcome')
				gen mypmonths=(myend-mystart)/(365.25/12)
				capture stset mypmonths, f(delta) id(patient_id)
				capture stptime if group==`k' & myselect==1, title(person-months) per(10000)
				if _rc==0 {
					local ptime`j'    =r(ptime)
					local numevents`j'=r(failures)
					local rate`j'     =r(rate)
					local rate`j'_lo  =r(lb)
					local rate`j'_hi  =r(ub)
				}
				if _rc!=0 {
					local ptime`j'    =.
					local numevents`j'=.
					local rate`j'     =.
					local rate`j'_lo  =.
					local rate`j'_hi  =.
				}
				foreach myvar in mystart myend myselect delta mypmonths _st _d _t _t0 {
					capture drop `myvar'
				}
			}
			post `rates' (`outindex') (`k') ("`outcome'") ("`grouplabel`k''") ///
			(`ptime1') (`numevents1') (`rate1') (`rate1_lo') (`rate1_hi') ///
			(`ptime2') (`numevents2') (`rate2') (`rate2_lo') (`rate2_hi') ///
			(`ptime3') (`numevents3') (`rate3') (`rate3_lo') (`rate3_hi') ///
			(`ptime4') (`numevents4') (`rate4') (`rate4_lo') (`rate4_hi') ///
			(`ptime5') (`numevents5') (`rate5') (`rate5_lo') (`rate5_hi')
		}		
	}
postclose `rates'

use $resultsdir/part2_option1_table8_splitfollowup_rates.dta, clear

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

format ptime* %12.1fc
format numevents* %12.0fc
format rate* %12.1fc

forvalues j=1(1)5 {
	tostring rate`j',    gen(temp1) force usedisplayformat
	tostring rate`j'_lo, gen(temp2) force usedisplayformat
	tostring rate`j'_hi, gen(temp3) force usedisplayformat
	gen rate`j'_ci=temp1+" ("+temp2+", "+temp3+")"
	drop rate`j' rate`j'_lo rate`j'_hi temp*
	rename rate`j'_ci rate_increm`j'
	gen str=strlen(rate_increm`j')
	summ str
	format rate_increm`j' %`r(max)'s
	drop str
}

order *1 *2 *3 *4 *5, after(group)

do `mypath'/005_table_edit.do

save $resultsdir/part2_option1_table8_splitfollowup_rates.dta, replace
