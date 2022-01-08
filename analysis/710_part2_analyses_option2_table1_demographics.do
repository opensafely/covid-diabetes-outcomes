local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Demographics and baseline risk factors
**/////////////////////////////////////////

use $outdir/matched_part2_groups_1_and_2.dta, clear

set more off

gen myend=(date_censor-date_patient_index)/(365.25/12)
drop if myend<=0
gen delta=1
capture stset myend, f(delta) id(patient_id)

**// Declare variable names and filename (.dta) to save results to

tempname demographics
	postfile `demographics' str20(demographic) category covid_diab_n covid_diab_pmonths covid_nodiab_n covid_nodiab_pmonths using ///
	$resultsdir/part2_option2_table1_demographics.dta, replace
						
		**// Total
		forvalues k=1(1)2 {
			count if group==`k'
			local group`k'=r(N)
			capture stptime if group==`k', per(10000)
			if _rc==0 {			
				local pmonths`k'=`r(ptime)'
			}
			if _rc!=0 {
				local pmonths`k'=.
			}
		}
		post `demographics'  ("Total") (.) (`group1') (`pmonths1') (`group2') (`pmonths2') 
		
		**// By categories of each demographic
		foreach demog in "sex" "age" "ethnic" "imd" "hist_cvd" "hist_renal" "vaccin" "smoking" "alcohol" "bmi" "hba1c" {
			capture summ cat_`demog'
			if _rc==0 {
				local numcat=r(max)
				count if cat_`demog'==.
				if r(N)>0 {
					local numcat=`numcat'+1
					recode cat_`demog' .=`numcat'
				}
				if `numcat'==. {
					local numcat=1
				}
				forvalues j=1(1)`numcat' {
					forvalues k=1(1)2 {
						count if cat_`demog'==`j' & group==`k'
						local group`k'=r(N)
						capture stptime if cat_`demog'==`j' & group==`k', per(10000)
						if _rc==0 {			
							local pmonths`k'=`r(ptime)'
						}
						if _rc!=0 {
							local pmonths`k'=.
						}
					}
					post `demographics'  ("`demog'") (`j') (`group1') (`pmonths1') (`group2') (`pmonths2')
				}
			}
		}
		
postclose `demographics'

use $resultsdir/part2_option2_table1_demographics.dta, clear

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
format covid_diab_pmonths covid_nodiab_pmonths %12.1f
save $resultsdir/part2_option2_table1_demographics.dta, replace
