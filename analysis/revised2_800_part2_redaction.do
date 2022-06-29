clear
do `c(pwd)'/analysis/000_filepaths.do
		
**// Part 2, Option 1
**///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
**// Part 2, Option 1: Table 2b. Rate ratios
capture noisily use $revisedresultsdir/revised2_part2_option1_table2b_rateratios.dta, clear
if _rc==0 {
	if _N>0 {
		
		replace person_time=. if numevents<8
		replace numevents=.   if numevents<8
		
		replace rate="[REDACTED]" if numevents==.

		foreach myvar in "adj_rateratio" {
			replace `myvar'="Ref." if group=="COVID-19 with diabetes"
			replace `myvar'="[REDACTED]" if (numevents==. | numevents[_n-1]==.) & group=="COVID-19 without diabetes"
			replace `myvar'="[REDACTED]" if (numevents==. | numevents[_n-2]==.) & group=="No COVID-19 with diabetes"
			replace `myvar'="[FAILED]" if (`myvar'==". (., .)" | `myvar'=="0.00 (0.00, 0.00)") & group!="COVID-19 with diabetes"
		}

		replace person_time=round(person_time,1000)/10000
		format person_time %9.1f
		tostring person_time, replace force u
		replace person_time="[REDACTED]" if person_time=="."

		replace numevents=round(numevents,5)
		tostring numevents, replace force u
		replace numevents="[REDACTED]" if numevents=="."
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture noisily replace `myvar'="-" if `myvar'=="-0"
	}
	save $revisedresultsdir/revised2_part2_option1_table2b_rateratios_redacted.dta, replace
	export delimited using $revisedresultsdir/revised2_part2_option1_table2b_rateratios_redacted.csv, replace
}
