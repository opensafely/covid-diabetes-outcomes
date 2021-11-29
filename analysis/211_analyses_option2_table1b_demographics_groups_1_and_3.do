local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Demographics and baseline risk factors
**/////////////////////////////////////////

use $outdir/matched_groups_1_and_3.dta, clear

set more off

gen myend=(date_censor-date_patient_index)/(365.25/12)
drop if myend<=0
gen delta=1
stset myend, f(delta) id(patient_id)

**// Declare variable names and filename (.dta) to save results to

tempname demographics
	postfile `demographics' str20(demographic) category covid_diab_n covid_diab_pmonths covid_nodiab_n covid_nodiab_pmonths pneum_diab_n pneum_diab_pmonths using ///
	$resultsdir/option2_table1b_demographics_groups_1_and_3.dta, replace
						
		**// Total
		forvalues k=1(1)3 {
			count if group==`k'
			local group`k'=r(N)
			if `group`k''>0 {
				stptime if group==`k', per(10000)
				local pmonths`k'=`r(ptime)'
			}
			if `group`k''==0 {
				local pmonths`k'=.
			}
		}
		post `demographics'  ("Total") (.) (`group1') (`pmonths1') (`group2') (`pmonths2') (`group3') (`pmonths3')
		
		**// By categories of each demographic
		foreach demog in "sex" "age" "ethnic" "imd" "diabetes" "hist_cvd" "hist_renal" "critical" "vaccin" "smoking" "alcohol" "bmi" "hba1c" {
			capture summ cat_`demog'
			if _rc==0 {
				local numcat=r(max)
				count if cat_`demog'==.
				if r(N)>0 {
					local numcat=`numcat'+1
					recode cat_`demog' .=`numcat'
				}
				forvalues j=1(1)`numcat' {
					forvalues k=1(1)3 {
						count if cat_`demog'==`j' & group==`k'
						local group`k'=r(N)
						if `group`k''>0 {
							stptime if cat_`demog'==`j' & group==`k', per(10000)
							local pmonths`k'=`r(ptime)'
						}
						if `group`k''==0 {
							local pmonths`k'=.
						}
					}
					post `demographics'  ("`demog'") (`j') (`group1') (`pmonths1') (`group2') (`pmonths2') (`group3') (`pmonths3')
				}
			}
		}
		
postclose `demographics'

use $resultsdir/option2_table1b_demographics_groups_1_and_3.dta, clear

**// Labelling
capture tostring demographic, replace force
capture tostring category, replace force
do `mypath'/001_demoglab.do
do `mypath'/002_catlab.do

**// Tidy
gen temp=1 if demographic==demographic[_n-1]
replace demographic="" if temp==1
drop temp
describe demographic category, varlist
foreach myvar in `r(varlist)' {
   gen str=strlen(`myvar')
   summ str
   format `myvar' %-`r(max)'s
   drop str
}
format covid_diab_pmonths covid_nodiab_pmonths pneum_diab_pmonths %12.1f
save $resultsdir/option2_table1b_demographics_groups_1_and_3.dta, replace

**// Convert to csv
export delimited using $resultsdir/option2_table1b_demographics_groups_1_and_3.csv, replace
