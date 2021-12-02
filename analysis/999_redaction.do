clear
do `c(pwd)'/analysis/000_filepaths.do
		
**\\ Option 1
**\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
		
**\\ Option 1: Table 1. Demographics
use $resultsdir/option1_table1_demographics.dta, clear
gen flag=1 if demographic=="Type of Diabetes" | demographic[_n-1]=="Type of Diabetes" | demographic[_n-2]=="Type of Diabetes"
describe *_n, varlist
foreach myvar in `r(varlist)' {
   recode `myvar' .=0
   replace `myvar'=round(`myvar',5)
   tostring `myvar', replace force
   replace `myvar'="<10" if (`myvar'=="." | `myvar'=="0" | `myvar'=="5") & flag!=1
}
drop *_pmonths flag
save $resultsdir/option1_table1_demographics_redacted.dta, replace
export delimited using $resultsdir/option1_table1_demographics_redacted.csv, replace

**\\ Option 1: Table 2. Rates
use $resultsdir/option1_table2_rates.dta, clear
replace numevents=round(numevents,5)
tostring numevents, replace force
replace numevents="<10" if (numevents=="." | numevents=="0" | numevents=="5")
replace person_time=round(person_time,1000)/10000
format person_time %9.1f
tostring person_time, replace force u
replace person_time="" if (numevents=="<10" | person_time==".")
replace rate="" if (numevents=="<10" | rate==". (., .)")
save $resultsdir/option1_table2_rates_redacted.dta, replace
export delimited using $resultsdir/option1_table2_rates_redacted.csv, replace

**\\ Option 1: Table 3. Hazard ratio
use $resultsdir/option1_table3_hazardratios.dta, clear
forvalues k=1(1)3 {
	replace hr`k'="" if hr`k'==". (., .)"
}
save $resultsdir/option1_table3_hazardratios_redacted.dta, replace
export delimited using $resultsdir/option1_table3_hazardratios_redacted.csv, replace

**\\ Option 1: Table 4. Stratified rates
use $resultsdir/option1_table4_stratified_rates.dta, clear
gen flag=.
forvalues k=0(1)8 {
	replace flag=1 if demographic[_n-`k']=="Type of Diabetes"
}
replace category=category[_n-1] if flag==1 & category==""

describe *_events, varlist
foreach myvar in `r(varlist)' {
   recode `myvar' .=0
   replace `myvar'=round(`myvar',5)
   tostring `myvar', replace force
   replace `myvar'="<10" if (`myvar'=="0" | `myvar'=="5") & flag!=1
   replace `myvar'="<10" if (`myvar'=="0" | `myvar'=="5") & flag==1 & category!="None" & group!="COVID-19 without diabetes"
   replace `myvar'="<10" if (`myvar'=="0" | `myvar'=="5") & flag==1 & category=="None" & group=="COVID-19 without diabetes"
}
describe *_ptime, varlist
foreach myvar in `r(varlist)' {
	replace `myvar'=round(`myvar',1000)/10000
	format `myvar' %9.1f
	tostring `myvar', replace force u
	local myname=substr("`myvar'",1,strpos("`myvar'","_ptime")-1)
	replace `myvar'="" if (`myname'_events=="<10")
	replace `myvar'="-" if `myvar'=="."
}
describe *_rate, varlist
foreach myvar in `r(varlist)' {
	local myname=substr("`myvar'",1,strpos("`myvar'","_rate")-1)
	replace `myvar'="" if (`myname'_events=="<10" | `myvar'==". (., .)")
}
gen flag2=1 if category==category[_n-1] & flag==1
replace category="" if flag2==1
drop flag*
save $resultsdir/option1_table4_stratified_rates_redacted.dta, replace
export delimited using $resultsdir/option1_table4_stratified_rates_redacted.csv, replace

**\\ Option 1: Table 5. Stratified hazard ratios
use $resultsdir/option1_table5_stratified_hazardratios.dta, clear
forvalues m=1(1)3 {
	describe *_hr`m', varlist
	foreach myvar in `r(varlist)' {
		replace `myvar'="" if `myvar'==". (., .)"
	}
}
save $resultsdir/option1_table5_stratified_hazardratios_redacted.dta, replace
export delimited using $resultsdir/option1_table5_stratified_hazardratios_redacted.csv, replace

**\\ Option 2
**\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

**\\ Option 2: Table 1a. Demographics (groups 1 and 2)
use $resultsdir/option2_table1a_demographics_groups_1_and_2.dta, replace
gen flag=1 if demographic=="Type of Diabetes" | demographic[_n-1]=="Type of Diabetes" | demographic[_n-2]=="Type of Diabetes"
describe *_n, varlist
foreach myvar in `r(varlist)' {
   recode `myvar' .=0
   replace `myvar'=round(`myvar',5)
   tostring `myvar', replace force
   replace `myvar'="<10" if (`myvar'=="." | `myvar'=="0" | `myvar'=="5") & flag!=1
}
drop *_pmonths flag
save $resultsdir/option2_table1a_demographics_groups_1_and_2_redacted.dta, replace
export delimited using $resultsdir/option2_table1a_demographics_groups_1_and_2_redacted.csv, replace

**\\ Option 2: Table 1b. Demographics (groups 1 and 3)
use $resultsdir/option2_table1b_demographics_groups_1_and_3.dta, replace
gen flag=1 if demographic=="Type of Diabetes" | demographic[_n-1]=="Type of Diabetes" | demographic[_n-2]=="Type of Diabetes"
describe *_n, varlist
foreach myvar in `r(varlist)' {
   recode `myvar' .=0
   replace `myvar'=round(`myvar',5)
   tostring `myvar', replace force
   replace `myvar'="<10" if (`myvar'=="." | `myvar'=="0" | `myvar'=="5") & flag!=1
}
drop *_pmonths flag
save $resultsdir/option2_table1b_demographics_groups_1_and_3_redacted.dta, replace
export delimited using $resultsdir/option2_table1b_demographics_groups_1_and_3_redacted.csv, replace

**\\ Option 3
**\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

**\\ Option 3: Table 1. Demographics
use $resultsdir/option3_table1_demographics.dta, replace
gen flag=1 if demographic=="Type of Diabetes" | demographic[_n-1]=="Type of Diabetes" | demographic[_n-2]=="Type of Diabetes"
describe *_n, varlist
foreach myvar in `r(varlist)' {
   recode `myvar' .=0
   replace `myvar'=round(`myvar',5)
   tostring `myvar', replace force
   replace `myvar'="<10" if (`myvar'=="." | `myvar'=="0" | `myvar'=="5") & flag!=1
}
drop *_pmonths flag
save $resultsdir/option3_table1_demographics_redacted.dta, replace
export delimited using $resultsdir/option3_table1_demographics_redacted.csv, replace
