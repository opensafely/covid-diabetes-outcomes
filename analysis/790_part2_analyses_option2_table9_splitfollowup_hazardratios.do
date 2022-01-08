local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Split follow-up hazard ratios - groups 1 and 2
**///////////////////////////////////////////////////

use $outdir/matched_part2_groups_1_and_2.dta, clear

local refgroup2="Without diabetes"

gen expos=(group==1)

**// Increments (days)
local incr=122

set more off

tempname hazardratios
	postfile `hazardratios' outindex groupindex str30(outcome) str30(refgroup) hr1 hr1_lo hr1_hi hr2 hr2_lo hr2_hi hr3 hr3_lo hr3_hi hr4 hr4_lo hr4_hi hr5 hr5_lo hr5_hi ///
	using $resultsdir/part2_option2_table9_splitfollowup_hazardratios.dta, replace
	**// Outcomes
	local outindex=0
	foreach outcome in "stroke_thrombotic" "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
	"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {	
		local outindex=`outindex'+1
		forvalues k=2(1)2 {
			forvalues j=1(1)5 {
				gen mystart=date_patient_index+(`j'-1)*`incr'
				gen myend=min(date_`outcome', date_censor, date_patient_index+`j'*`incr')
				gen mypmonths=(myend-mystart)/(365.25/12)
				gen myselect=(myend>mystart & (group==1 | group==`k'))
				gen delta=(myend==date_`outcome')
				capture stset mypmonths, f(delta) id(patient_id)				
				count if myselect==1 & group==1 & delta==1
				local counta=r(N)
				count if myselect==1 & group==`k' & delta==1
				local countb=r(N)
				if `counta'>=8 & `countb'>=8 {
					capture stcox expos i.cat_sex i.cat_age i.cat_ethnic i.cat_imd i.cat_hist_cvd i.cat_hist_renal i.cat_smoking i.cat_alcohol i.cat_bmi ///
					if (group==1 | group==`k') & myselect==1, vce(robust)				
					if _rc==0 {
						matrix M1=e(b)
						matrix M2=e(V)
						local hr`j'   =exp(M1[1,1])
						local hr`j'_lo=exp(M1[1,1]-1.96*(M2[1,1]^0.5))
						local hr`j'_hi=exp(M1[1,1]+1.96*(M2[1,1]^0.5))			
					} 
					if _rc!=0 {
						local hr`j'   =999999
						local hr`j'_lo=999999
						local hr`j'_hi=999999					
					}
				}
				else {
					local hr`j'   =.
					local hr`j'_lo=.
					local hr`j'_hi=.
				}
				foreach myvar in mystart myend mypmonths myselect delta _st _d _t _t0 {
					capture drop `myvar'
				}
			}
			post `hazardratios' (`outindex') (`k') ("`outcome'") ("`refgroup`k''") ///
			(`hr1') (`hr1_lo') (`hr1_hi') ///
			(`hr2') (`hr2_lo') (`hr2_hi') ///
			(`hr3') (`hr3_lo') (`hr3_hi') ///
			(`hr4') (`hr4_lo') (`hr4_hi') ///
			(`hr5') (`hr5_lo') (`hr5_hi')
		}		
	}
postclose `hazardratios'

use $resultsdir/part2_option2_table9_splitfollowup_hazardratios.dta, clear

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

describe type-refgroup, varlist
foreach myvar in `r(varlist)' {
	gen str=strlen(`myvar')
	summ str
	format `myvar' %-`r(max)'s
	drop str
}

format hr* %12.2f
describe hr*, varlist
foreach myvar in `r(varlist)' {
	tostring `myvar', replace force usedisplayformat
}
forvalues j=1(1)5 {
	gen new_hr`j'=hr`j'+" ("+hr`j'_lo+", "+hr`j'_hi+")"
}
drop hr*
forvalues j=1(1)5 {
	rename new_hr`j' hr_increm`j'
}

do `mypath'/005_table_edit.do

save $resultsdir/part2_option2_table9_splitfollowup_hazardratios.dta, replace
