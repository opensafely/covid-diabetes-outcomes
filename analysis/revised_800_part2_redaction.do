clear
do `c(pwd)'/analysis/000_filepaths.do
		
**// Part 2, Option 1
**///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
**// Part 2, Option 1: Table 1. Demographics
capture noisily use $revisedresultsdir/revised_part2_option1_table1_demographics.dta, clear
if _rc==0 {
	if _N>0 {
		describe *_n, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'=. if `myvar'<8
			replace `myvar'=round(`myvar',5)
			tostring `myvar', replace force u
			replace `myvar'="[REDACTED]" if `myvar'=="."
		}
		drop *_pmonths
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture noisily replace `myvar'="-" if `myvar'=="-0"
	}
	save $revisedresultsdir/revised_part2_option1_table1_demographics_redacted.dta, replace
	export delimited using $revisedresultsdir/revised_part2_option1_table1_demographics_redacted.csv, replace
}

**// Part 2, Option 1: Table 2b. Rate ratios
capture noisily use $revisedresultsdir/revised_part2_option1_table2b_rateratios.dta, clear
if _rc==0 {
	if _N>0 {
		
		replace person_time=. if numevents<8
		replace numevents=.   if numevents<8
		
		replace rate="[REDACTED]" if numevents==.

		foreach myvar in "ipw_rateratio" "check" {
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
	save $revisedresultsdir/revised_part2_option1_table2b_rateratios_redacted.dta, replace
	export delimited using $revisedresultsdir/revised_part2_option1_table2b_rateratios_redacted.csv, replace
}

**// Part 2, Option 1: Table 4b. Stratified rate ratios
capture noisily use $revisedresultsdir/revised_part2_option1_table4b_stratified_rateratios.dta, clear
if _rc==0 {
	if _N>0 {
		describe *_events, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'=. if `myvar'<8
			replace `myvar'=round(`myvar',5)
			tostring `myvar', replace force u
			replace `myvar'="[REDACTED]" if `myvar'=="."
		}
		describe *_ptime, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'=round(`myvar',1000)/10000
			format `myvar' %9.1f
			tostring `myvar', replace force u
			local myname=substr("`myvar'",1,strpos("`myvar'","_ptime")-1)
			replace `myvar'="[REDACTED]" if `myname'_events=="[REDACTED]"
		}
		describe *_rate, varlist
		foreach myvar in `r(varlist)' {
			local myname=substr("`myvar'",1,strpos("`myvar'","_rate")-1)
			replace `myvar'="[REDACTED]" if `myname'_events=="[REDACTED]"
		}	
		foreach mytype in "ipw_rr" "check" {
			describe *_`mytype', varlist
			foreach myvar in `r(varlist)' {
				replace `myvar'="Ref." if group=="COVID-19 with diabetes"
				local myname=substr("`myvar'",1,strpos("`myvar'","_`mytype'")-1)
				capture noisily replace `myvar'="[REDACTED]" if (`myname'_events=="[REDACTED]" | `myname'_events[_n-1]=="[REDACTED]") & group=="COVID-19 without diabetes"
				capture noisily replace `myvar'="[REDACTED]" if (`myname'_events=="[REDACTED]" | `myname'_events[_n-2]=="[REDACTED]") & group=="No COVID-19 with diabetes"
			}
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture noisily replace `myvar'="-" if `myvar'=="-0"
	}
	save $revisedresultsdir/revised_part2_option1_table4b_stratified_rateratios_redacted.dta, replace
	export delimited using $revisedresultsdir/revised_part2_option1_table4b_stratified_rateratios_redacted.csv, replace
}
