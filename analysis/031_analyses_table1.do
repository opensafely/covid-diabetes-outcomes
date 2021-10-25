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
		
postclose `demographics'

**// Convert to csv
use $resultsdir/table1_demographics.dta, replace		
export delimited using $resultsdir/table1_demographics.csv, replace
* erase $resultsdir/table1_demographics.dta
