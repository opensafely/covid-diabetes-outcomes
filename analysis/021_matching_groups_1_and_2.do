clear
do `c(pwd)'/analysis/000_filepaths.do

use $outdir/input_part1_clean.dta

set more off

**// Specify the maximum number of controls per case
local maxcontrols=5

**// Retain relevant groups of cases (group 1) and potential comparators (group 2)
keep if (group==1 | group==2)

**// Generate a case indicator
gen case=(group==1)

**// Create unique case IDs
gsort -case date_patient_index
gen case_id=_n if case==1

**// Count the number of cases
count if case==1
local numcases=r(N)

**// Matching each case with up to `maxcontrols' comparators
set seed 76518273
gen setid=.

forvalues j=1(1)`numcases' {
	gen     incl=1 if case_id==`j'
	replace incl=2 if case_id==. & setid==.
	sort incl
	gen age_diff_days=((date_of_birth-date_of_birth[1])^2)^0.5
	gen index_diff_days=((date_patient_index-date_patient_index[1])^2)^0.5
	replace incl=. if sex!=sex[1]
	replace incl=. if practice_id!=practice_id[1]
	replace incl=. if age_diff_days>(365.25*3)
	replace incl=. if index_diff_days>21
	sum age_diff_days if incl==2
	local var_age=r(Var)
	sum index_diff_days if incl==2
	local var_index=r(Var)
	gen D=((age_diff_days^2)/`var_age')+((index_diff_days^2)/`var_index')
	**// Enforce random selection from equally viable neighbours
	gen rand=runiform() 
	sort incl D rand
	replace setid=`j' if incl!=. & _n<=(`maxcontrols'+1) 
	drop incl age_diff_days index_diff_days D rand
}
drop if setid==.
gsort setid -case patient_id
compress

save $outdir/matched_groups_1_and_2.dta, replace
