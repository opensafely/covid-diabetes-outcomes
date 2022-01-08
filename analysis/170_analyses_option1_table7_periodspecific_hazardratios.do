local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Period-specific hazard ratios - groups 1,2 and 1,3
**/////////////////////////////////////////////////////

set more off
		
use $outdir/input_part1_clean.dta, clear

gen expos=(group==1)

local refgroup2="COVID-19 without diabetes"
local refgroup3="Pneumonia with diabetes"

gen     period=.
replace period=1 if date_patient_index>=mdy(2,1,2020)  & (group==1 | group==2)
replace period=2 if date_patient_index>=mdy(6,16,2020) & (group==1 | group==2)
replace period=3 if date_patient_index>=mdy(3,24,2021) & (group==1 | group==2)

replace period=1 if date_patient_index>=mdy(2,1,2019)  & (group==3)
replace period=2 if date_patient_index>=mdy(6,16,2019) & (group==3)
replace period=3 if date_patient_index>=mdy(3,24,2020) & (group==3)

tempname hazardratios
	postfile `hazardratios' outindex groupindex str30(outcome) str30(refgroup) hr1 hr1_lo hr1_hi hr2 hr2_lo hr2_hi hr3 hr3_lo hr3_hi using ///
	$resultsdir/option1_table7_periodspecific_hazardratios.dta, replace
	local outindex=0
	foreach outcome in "stroke_thrombotic" "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
	"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {	
		local outindex=`outindex'+1
		gen myend=(min(date_`outcome', date_censor)-date_patient_index)/(365.25/12)
		gen myselect=(myend>0)
		gen delta=(date_`outcome'==min(date_`outcome', date_censor))
		capture stset myend, f(delta) id(patient_id)
		forvalues k=2(1)3 {
			forvalues m=1(1)3 {
				count if group==1   & delta==1 & myselect==1 & period==`m'
				local mycounta=r(N)
				count if group==`k' & delta==1 & myselect==1 & period==`m'
				local mycountb=r(N)
				if `mycounta'>=8 & `mycountb'>=8 {
					capture stcox expos i.cat_sex i.cat_age i.cat_ethnic i.cat_imd i.cat_hist_cvd i.cat_hist_renal i.cat_smoking i.cat_alcohol i.cat_bmi ///
					if (group==1 | group==`k') & myselect==1 & period==`m', vce(robust)				
					if _rc==0 {
						matrix M1=e(b)
						matrix M2=e(V)
						local hr`m'   =exp(M1[1,1])
						local hr`m'_lo=exp(M1[1,1]-1.96*(M2[1,1]^0.5))
						local hr`m'_hi=exp(M1[1,1]+1.96*(M2[1,1]^0.5))			
					} 
					if _rc!=0 {
						local hr`m'   =999999
						local hr`m'_lo=999999
						local hr`m'_hi=999999					
					}
				}
				else {
					local hr`m'   =.
					local hr`m'_lo=.
					local hr`m'_hi=.
				}
			}	
			post `hazardratios' (`outindex') (`k') ("`outcome'") ("`refgroup`k''") (`hr1') (`hr1_lo') (`hr1_hi') (`hr2') (`hr2_lo') (`hr2_hi') (`hr3') (`hr3_lo') (`hr3_hi')
		}
		foreach myvar in myend myselect delta _st _d _t _t0 {
			capture drop `myvar'
		}
	}
postclose `hazardratios'

use $resultsdir/option1_table7_periodspecific_hazardratios.dta, clear

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

format hr* %12.2f
describe hr*, varlist
foreach myvar in `r(varlist)' {
	tostring `myvar', replace force usedisplayformat
}
forvalues m=1(1)3 {
	gen new_hr`m'=hr`m'+" ("+hr`m'_lo+", "+hr`m'_hi+")"
}
drop hr*
forvalues m=1(1)3 {
	rename new_hr`m' hr_period`m'
}

describe, varlist
foreach myvar in `r(varlist)' {
	gen str=strlen(`myvar')
	summ str
	format `myvar' %-`r(max)'s
	drop str
}

do `mypath'/005_table_edit.do

save $resultsdir/option1_table7_periodspecific_hazardratios.dta, replace
