local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Hazard ratios - groups 1,2 and 1,3
**/////////////////////////////////////////////

set more off
		
use $outdir/matched_groups_1_2_and_3.dta, clear

if _N>0 {

gen expos=(group==1)

local refgroup2="COVID-19 without diabetes"
local refgroup3="Pneumonia with diabetes"

tempname hazardratios
	postfile `hazardratios' outindex groupindex str30(outcome) str30(refgroup) hr1 hr1_lo hr1_hi hr2 hr2_lo hr2_hi hr3 hr3_lo hr3_hi hr4 hr4_lo hr4_hi ///
	using $resultsdir/option3_table3_hazardratios_v2.dta, replace
	local outindex=0
	foreach outcome in "stroke_thrombotic" "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
	"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {	
		local outindex=`outindex'+1
		gen myend=(min(date_`outcome', date_censor)-date_patient_index)/(365.25/12)
		gen myselect=(myend>0)
		gen delta=(date_`outcome'==min(date_`outcome', date_censor))
		forvalues k=2(1)3 {
			count if group==1 & delta==1 & myselect==1
			local mycount1=r(N)
			count if group==`k' & delta==1 & myselect==1
			local mycount`k'=r(N)
			if `mycount1'>=8 & `mycount`k''>=8 {
				forvalues m=1(1)4 {
					if `m'==1 {
						**// Using propensity scores as inverse probability weights
						**////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						preserve						
						**// Estimate propensity scores
						keep if (group==1 | group==`k') & myselect==1						
						foreach mytype in "critical" "vaccin" "hba1c" {
							rename cat_`mytype' excl_`mytype'
						}						
						capture logistic expos i.cat_*					
						if _rc==0 {
							predict propensity							
							**// IP weights
							gen ipw=(expos/propensity)+((1-expos)/(1-propensity))							
							**// Set as weighted survival data
							capture stset myend [pweight=ipw], f(delta) id(patient_id)
							**// Estimate hazard ratio
							capture stcox expos, vce(robust)
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
						if _rc!=0 {
							local hr`m'   =999999
							local hr`m'_lo=999999
							local hr`m'_hi=999999								
						}
						restore						
					}				
					if `m'==2 {						
						**// Using propensity scores as inverse probability weights - with trimming
						**////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						preserve						
						**// Estimate propensity scores
						keep if (group==1 | group==`k') & myselect==1						
						foreach mytype in "critical" "vaccin" "hba1c" {
							rename cat_`mytype' excl_`mytype'
						}						
						capture logistic expos i.cat_*				
						if _rc==0 {
							predict propensity
							**// Trimming (replaces common support restriction)
							drop if (propensity<0.1 | propensity>0.9)
							**// IP weights
							gen ipw=(expos/propensity)+((1-expos)/(1-propensity))
							**// Set as weighted survival data
							capture stset myend [pweight=ipw], f(delta) id(patient_id)
							**// Estimate hazard ratio
							capture stcox expos, vce(robust)
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
						if _rc!=0 {
							local hr`m'   =999999
							local hr`m'_lo=999999
							local hr`m'_hi=999999								
						}
						restore						
					}				
					if `m'==3 {						
						**// Using propensity scores as inverse probability weights - with trimming and stabilisation
						**////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						preserve						
						**// Estimate propensity scores
						keep if (group==1 | group==`k') & myselect==1						
						foreach mytype in "critical" "vaccin" "hba1c" {
							rename cat_`mytype' excl_`mytype'
						}						
						capture logistic expos i.cat_*				
						if _rc==0 {
							predict propensity							
							**// Trimming (replaces common support restriction)
							drop if (propensity<0.1 | propensity>0.9)							
							**// Stabilised IP weights
							count if expos==1
							local count_expos=r(N)
							local myp=`count_expos'/_N
							gen sipw=(expos*`myp'/propensity)+(((1-expos)*(1-`myp'))/(1-propensity))							
							**// Set as weighted survival data
							capture stset myend [pweight=sipw], f(delta) id(patient_id)
							**// Estimate hazard ratio
							capture stcox expos, vce(robust)
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
						if _rc!=0 {
							local hr`m'   =999999
							local hr`m'_lo=999999
							local hr`m'_hi=999999								
						}
						restore						
					}				
					if `m'==4 {						
						**// Using propensity scores as inverse probability weights - with trimming and stabilisation - incorporating all two-way interactions
						**////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						preserve						
						**// Estimate propensity scores (incorporating all two-way interactions)
						keep if (group==1 | group==`k') & myselect==1						
						foreach mytype in "critical" "vaccin" "hba1c" {
							rename cat_`mytype' excl_`mytype'
						}						
						describe cat_*, varlist
						local mylist=""
						foreach myvarA in `r(varlist)' {
							foreach myvarB in `r(varlist)' {
								local mylist="`mylist'"+" "+"`myvarA'##`myvarB'"
							}			
						}						
						capture logistic expos `mylist'						
						if _rc==0 {
							predict propensity							
							**// Trimming (replaces common support restriction)
							drop if (propensity<0.1 | propensity>0.9)							
							**// Stabilised IP weights
							count if expos==1
							local count_expos=r(N)
							local myp=`count_expos'/_N
							gen sipw=(expos*`myp'/propensity)+(((1-expos)*(1-`myp'))/(1-propensity))							
							**// Set as weighted survival data
							capture stset myend [pweight=sipw], f(delta) id(patient_id)
							**// Estimate hazard ratio
							capture stcox expos, vce(robust)
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
						if _rc!=0 {
							local hr`m'   =999999
							local hr`m'_lo=999999
							local hr`m'_hi=999999								
						}
						restore						
					}				
				}
				post `hazardratios' (`outindex') (`k') ("`outcome'") ("`refgroup`k''") (`hr1') (`hr1_lo') (`hr1_hi') (`hr2') (`hr2_lo') (`hr2_hi') (`hr3') (`hr3_lo') (`hr3_hi') ///
				(`hr4') (`hr4_lo') (`hr4_hi')
			}
			else {
				post `hazardratios' (`outindex') (`k') ("`outcome'") ("`refgroup`k''") (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.)
			}
		}
		drop myend myselect delta
	}
postclose `hazardratios'

use $resultsdir/option3_table3_hazardratios_v2.dta, clear

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
forvalues m=1(1)4 {
	gen new_hr`m'=hr`m'+" ("+hr`m'_lo+", "+hr`m'_hi+")"
}
drop hr*
forvalues m=1(1)4 {
	rename new_hr`m' hr`m'
}

describe, varlist
foreach myvar in `r(varlist)' {
	gen str=strlen(`myvar')
	summ str
	format `myvar' %-`r(max)'s
	drop str
}

do `mypath'/005_table_edit.do

save $resultsdir/option3_table3_hazardratios_v2.dta, replace
}
