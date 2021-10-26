**// Demographics and baseline risk factors (BEFORE MATCHING!)

clear
do `c(pwd)'/analysis/000_filepaths.do

use $outdir/input_part1_clean.dta

set more off

**// Declare variable names and filename (.dta) to save results to

tempname demographics
	postfile `demographics' str20(demographic) str20(category) covid_diab covid_nodiab pneum_diab pneum_nodiab using $resultsdir/table1_demographics.dta, replace
						
		**// Total
		forvalues k=1(1)4 {
			count if group==`k'
			local group`k'=r(N)
		}
		* Add new observation to the table
		post `demographics'  ("Total") ("") (`group1') (`group2') (`group3') (`group4')
		
		**// Age-groups
		local mylabel1="18-49"
		local mylabel2="50-59"
		local mylabel3="60-69"
		local mylabel4="70-79"
		local mylabel5="80+"
		forvalues j=1(1)5 {
			forvalues k=1(1)4 {
				count if ageband==`j' & group==`k'
				local group`k'=r(N)
			}
			post `demographics'  ("Age") ("`mylabel`j''") (`group1') (`group2') (`group3') (`group4')
		}
		
		**// Sex
		local mylabelM="Male"
		local mylabelF="Female"
		foreach sex in "M" "F" {
			forvalues k=1(1)4 {
				count if sex=="`sex'" & group==`k'
				local group`k'=r(N)
			}
			post `demographics'  ("Sex") ("`mylabel`sex''") (`group1') (`group2') (`group3') (`group4')
		}
		
		**// Ethnicity
		local mylabel1="White"
		local mylabel2="Mixed"
		local mylabel3="Asian/Asian British"
		local mylabel4="Black"
		local mylabel5="Other"
		local mylabel6="Unknown"
		forvalues j=1(1)6 {
			forvalues k=1(1)4 {
				count if ethnicity==`j' & group==`k'
				local group`k'=r(N)
			}
			post `demographics'  ("Ethnicity") ("`mylabel`j''") (`group1') (`group2') (`group3') (`group4')
		}
		
		**// IMD
		**// Type of diabetes
		
postclose `demographics'

**// Convert to csv
use $resultsdir/table1_demographics.dta, clear
gen temp=1 if demographic==demographic[_n-1]
replace demographic="" if temp==1
drop temp
save $resultsdir/table1_demographics.dta, replace
export delimited using $resultsdir/table1_demographics.csv, replace
* erase $resultsdir/table1_demographics.dta
