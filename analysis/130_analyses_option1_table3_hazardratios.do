local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Hazard ratios - groups 1,2 and 1,3
**/////////////////////////////////////////////

set more off
		
use $outdir/input_part1_clean.dta, clear

gen expos=(group==1)

local refgroup2="COVID-19 without diabetes"
local refgroup3="Pneumonia with diabetes"

tempname hazardratios
	postfile `hazardratios' outindex groupindex str30(outcome) str30(refgroup) hr1 hr1_lo hr1_hi hr2 hr2_lo hr2_hi hr3 hr3_lo hr3_hi using $resultsdir/option1_table3_hazardratios.dta, replace
	local outindex=0
	foreach outcome in "stroke" "mi" "dvt" "pe" "hf" "any_cvd" "aki" "anxiety" "depression" "psychosis" "death" {
		local outindex=`outindex'+1
		gen myend=(min(date_`outcome', date_censor)-date_patient_index)/(365.25/12)
		gen myselect=(myend>0)
		gen delta=(date_`outcome'==min(date_`outcome', date_censor))
		stset myend, f(delta) id(patient_id)
		forvalues k=2(1)3 {
			count if group==1 & delta==1
			local mycount1=r(N)
			count if group==`k' & delta==1
			local mycount`k'=r(N)
			if `mycount1'>=10 & `mycount`k''>=10 {
				forvalues m=1(1)3 {
					if `m'==1 {
						capture stcox expos if (group==1 | group==`k') & myselect==1
					}
					if `m'==2 {
						capture stcox expos i.cat_sex i.cat_age if (group==1 | group==`k') & myselect==1
					}
					if `m'==3 {
						capture stcox expos i.cat_* if (group==1 | group==`k') & myselect==1
					}				
					if _rc==0 {
						matrix M1=e(b)
						matrix M2=e(V)
						local hr`m'   =exp(M1[1,1])
						local hr`m'_lo=exp(M1[1,1]-1.96*(M2[1,1]^0.5))
						local hr`m'_hi=exp(M1[1,1]+1.96*(M2[1,1]^0.5))			
					} 
					if _rc!=0 {
						local hr`m'   =.
						local hr`m'_lo=.
						local hr`m'_hi=.					
					}
				}
				post `hazardratios' (`outindex') (`k') ("`outcome'") ("`refgroup`k''") (`hr1') (`hr1_lo') (`hr1_hi') (`hr2') (`hr2_lo') (`hr2_hi') (`hr3') (`hr3_lo') (`hr3_hi')
			}
			if `mycount1'<10 | `mycount`k''<10 {
				post `hazardratios' (`outindex') (`k') ("`outcome'") ("`refgroup`k''") (.) (.) (.) (.) (.) (.) (.) (.) (.)
			}
		}
		drop myend myselect delta _st _d _t _t0
	}
postclose `hazardratios'

use $resultsdir/option1_table3_hazardratios.dta, clear

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
	rename new_hr`m' hr`m'
}

describe, varlist
foreach myvar in `r(varlist)' {
	gen str=strlen(`myvar')
	summ str
	format `myvar' %-`r(max)'s
	drop str
}

save $resultsdir/option1_table3_hazardratios.dta, replace

**// Convert to csv
export delimited using $resultsdir/option1_table3_hazardratios.csv, replace
