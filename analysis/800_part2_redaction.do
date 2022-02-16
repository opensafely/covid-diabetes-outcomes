clear
do `c(pwd)'/analysis/000_filepaths.do
		
**// Part2, Option 1
**///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
**// Part2, Option 1: Table 1. Demographics
capture use $resultsdir/part2_option1_table1_demographics.dta, clear
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
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table1_demographics_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table1_demographics_redacted.csv, replace
}

**// Part2, Option 1: Table 2a. Rates
capture use $resultsdir/part2_option1_table2a_rates.dta, clear
if _rc==0 {
	if _N>0 {
		replace person_time=. if numevents<8
		replace numevents=.   if numevents<8
		
		replace rate="[REDACTED]" if numevents==.
	
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
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table2a_rates_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table2a_rates_redacted.csv, replace
}

**// Part2, Option 1: Table 2b. Rate ratios
capture use $resultsdir/part2_option1_table2b_rateratios.dta, clear
if _rc==0 {
	if _N>0 {
		
		replace person_time=. if numevents<8
		replace numevents=.   if numevents<8
		
		replace rate="[REDACTED]" if numevents==.

		foreach myvar in "rateratio" "adj_rateratio" "fulladj_rateratio" "ipw_rateratio" "sipw_rateratio" {
			replace `myvar'="-" if group=="COVID-19 with diabetes"
			replace `myvar'="[REDACTED]" if (numevents==. | numevents[_n-1]==.) & group=="COVID-19 without diabetes"
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
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table2b_rateratios_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table2b_rateratios_redacted.csv, replace
}

**// Part2, Option 1: Table 3a. Hazard ratios
capture use $resultsdir/part2_option1_table3a_hazardratios.dta, clear
if _rc==0{
	if _N>0 {
		forvalues k=1(1)3 {
			replace hr`k'="[REDACTED]" if hr`k'==". (., .)"
			replace hr`k'="[FAILED]" if hr`k'=="999999.00 (999999.00, 999999.00)"
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table3a_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table3a_hazardratios_redacted.csv, replace
}

**// Part2, Option 1: Table 3b. Hazard ratios - version 2
capture use $resultsdir/part2_option1_table3b_hazardratios_v2.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues k=1(1)4 {
			replace hr`k'="[REDACTED]" if hr`k'==". (., .)"
			replace hr`k'="[FAILED]" if hr`k'=="999999.00 (999999.00, 999999.00)"
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table3b_hazardratios_v2_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table3b_hazardratios_v2_redacted.csv, replace
}

**// Part2, Option 1: Table 4a. Stratified rates
capture use $resultsdir/part2_option1_table4a_stratified_rates.dta, clear
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
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table4a_stratified_rates_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table4a_stratified_rates_redacted.csv, replace
}

**// Part2, Option 1: Table 4b. Stratified rate ratios
capture use $resultsdir/part2_option1_table4b_stratified_rateratios.dta, clear
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
		foreach mytype in "rr" "adj_rr" "fuladj_rr" "ipw_rr" "sipw_rr" {
			describe *_`mytype', varlist
			foreach myvar in `r(varlist)' {
				replace `myvar'="-" if group=="COVID-19 with diabetes"
				local myname=substr("`myvar'",1,strpos("`myvar'","_`mytype'")-1)
				capture replace `myvar'="[REDACTED]" if (`myname'_events=="[REDACTED]" | `myname'_events[_n-1]=="[REDACTED]") & group=="COVID-19 without diabetes"
			}
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table4b_stratified_rateratios_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table4b_stratified_rateratios_redacted.csv, replace
}

**// Part2, Option 1: Table 5a. Stratified hazard ratios
capture use $resultsdir/part2_option1_table5a_stratified_hazardratios.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues m=1(1)3 {
			describe *_hr`m', varlist
			foreach myvar in `r(varlist)' {
				replace `myvar'="[REDACTED]" if (`myvar'==". (., .)" | `myvar'=="-" | `myvar'==".")
				replace `myvar'="[FAILED]" if `myvar'=="999999.00 (999999.00, 999999.00)"
			}
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table5a_stratified_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table5a_stratified_hazardratios_redacted.csv, replace
}

**// Part2, Option 1: Table 5b. Stratified hazard ratios (version 2)
capture use $resultsdir/part2_option1_table5b_stratified_hazardratios_v2.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues m=1(1)4 {
			describe *_hr`m', varlist
			foreach myvar in `r(varlist)' {
				replace `myvar'="[REDACTED]" if (`myvar'==". (., .)" | `myvar'=="-" | `myvar'==".")
				replace `myvar'="[FAILED]" if `myvar'=="999999.00 (999999.00, 999999.00)"
				replace `myvar'="[OMITTED]" if `myvar'=="888888.00 (888888.00, 888888.00)"
			}
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table5b_stratified_hazardratios_v2_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table5b_stratified_hazardratios_v2_redacted.csv, replace
}

**// Part2, Option 1: Table 6. Period-specific rates
capture use $resultsdir/part2_option1_table6_periodspecific_rates.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues k=1(1)3 {
			replace person_time`k'=. if numevents`k'<8
			replace numevents`k'=.   if numevents`k'<8
			
			replace rate_period`k'="[REDACTED]" if numevents`k'==.
	
			replace person_time`k'=round(person_time`k',1000)/10000
			format person_time`k' %9.1f
			tostring person_time`k', replace force u
			replace person_time`k'="[REDACTED]" if person_time`k'=="."

			replace numevents`k'=round(numevents`k',5)
			tostring numevents`k', replace force u
			replace numevents`k'="[REDACTED]" if numevents`k'=="."
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table6_periodspecific_rates_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table6_periodspecific_rates_redacted.csv, replace
}

**// Part2, Option 1: Table 7. Period-specific hazard ratios
capture use $resultsdir/part2_option1_table7_periodspecific_hazardratios.dta, clear
if _rc==0 {
	if _N>0 {
		describe hr_*, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'="[REDACTED]" if (`myvar'==". (., .)" | `myvar'=="-" | `myvar'==".")
			replace `myvar'="[FAILED]" if `myvar'=="999999.00 (999999.00, 999999.00)"
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table7_periodspecific_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table7_periodspecific_hazardratios_redacted.csv, replace
}

**// Part2, Option 1: Table 8. Split follow-up rates
capture use $resultsdir/part2_option1_table8_splitfollowup_rates.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues k=1(1)5 {
			replace ptime`k'=. if numevents`k'<8
			replace numevents`k'=.   if numevents`k'<8
			
			replace rate_increm`k'="[REDACTED]" if numevents`k'==.

			replace ptime`k'=round(ptime`k',1000)/10000
			format ptime`k' %9.1f
			tostring ptime`k', replace force u
			replace ptime`k'="[REDACTED]" if ptime`k'=="."

			replace numevents`k'=round(numevents`k',5)
			tostring numevents`k', replace force u
			replace numevents`k'="[REDACTED]" if numevents`k'=="."
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table8_splitfollowup_rates_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table8_splitfollowup_rates_redacted.csv, replace
}

**// Part2, Option 1: Table 9. Split follow-up hazard ratios
capture use $resultsdir/part2_option1_table9_splitfollowup_hazardratios.dta, clear
if _rc==0 {
	if _N>0 {
		describe hr_*, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'="[REDACTED]" if (`myvar'==". (., .)" | `myvar'=="-" | `myvar'==".")
			replace `myvar'="[FAILED]" if `myvar'=="999999.00 (999999.00, 999999.00)"
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option1_table9_splitfollowup_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/part2_option1_table9_splitfollowup_hazardratios_redacted.csv, replace
}

**// Part2, Option 2
**///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
**// Part2, Option 2: Table 1. Demographics
capture use $resultsdir/part2_option2_table1_demographics.dta, clear
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
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table1_demographics_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table1_demographics_redacted.csv, replace
}

**// Part2, Option 2: Table 2a. Rates
capture use $resultsdir/part2_option2_table2a_rates.dta, clear
if _rc==0 {
	if _N>0 {
		replace person_time=. if numevents<8
		replace numevents=.   if numevents<8
		
		replace rate="[REDACTED]" if numevents==.
	
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
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table2a_rates_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table2a_rates_redacted.csv, replace
}

**// Part2, Option 2: Table 2b. Rate ratios
capture use $resultsdir/part2_option2_table2b_rateratios.dta, clear
if _rc==0 {
	if _N>0 {
		replace person_time=. if numevents<8
		replace numevents=.   if numevents<8
		
		replace rate="[REDACTED]" if numevents==.

		foreach myvar in "rateratio" "adj_rateratio" "fulladj_rateratio" "ipw_rateratio" "sipw_rateratio" {
			replace `myvar'="-" if group=="COVID-19 with diabetes"
			replace `myvar'="[REDACTED]" if (numevents==. | numevents[_n-1]==.) & group=="COVID-19 without diabetes"
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
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table2b_rateratios_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table2b_rateratios_redacted.csv, replace
}

**// Part2, Option 2: Table 3a. Hazard ratios
capture use $resultsdir/part2_option2_table3a_hazardratios.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues k=1(1)3 {
			replace hr`k'="[REDACTED]" if hr`k'==". (., .)"
			replace hr`k'="[FAILED]" if hr`k'=="999999.00 (999999.00, 999999.00)"
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table3a_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table3a_hazardratios_redacted.csv, replace
}

**// Part2, Option 2: Table 3b. Hazard ratios - version 2
capture use $resultsdir/part2_option2_table3b_hazardratios_v2.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues k=1(1)4 {
			replace hr`k'="[REDACTED]" if hr`k'==". (., .)"
			replace hr`k'="[FAILED]" if hr`k'=="999999.00 (999999.00, 999999.00)"
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table3b_hazardratios_v2_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table3b_hazardratios_v2_redacted.csv, replace
}

**// Part2, Option 2: Table 4a. Stratified rates
capture use $resultsdir/part2_option2_table4a_stratified_rates.dta, clear
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
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table4a_stratified_rates_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table4a_stratified_rates_redacted.csv, replace
}

**// Part2, Option 2: Table 4b. Stratified rate ratios
capture use $resultsdir/part2_option2_table4b_stratified_rateratios.dta, clear
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
		foreach mytype in "rr" "adj_rr" "fuladj_rr" "ipw_rr" "sipw_rr" {
			describe *_`mytype', varlist
			foreach myvar in `r(varlist)' {
				replace `myvar'="-" if group=="COVID-19 with diabetes"
				local myname=substr("`myvar'",1,strpos("`myvar'","_`mytype'")-1)
				capture replace `myvar'="[REDACTED]" if (`myname'_events=="[REDACTED]" | `myname'_events[_n-1]=="[REDACTED]") & group=="COVID-19 without diabetes"
			}
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table4b_stratified_rateratios_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table4b_stratified_rateratios_redacted.csv, replace
}

**// Part2, Option 2: Table 5a. Stratified hazard ratios
capture use $resultsdir/part2_option2_table5a_stratified_hazardratios.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues m=1(1)3 {
			describe *_hr`m', varlist
			foreach myvar in `r(varlist)' {
				replace `myvar'="[REDACTED]" if (`myvar'==". (., .)" | `myvar'=="-" | `myvar'==".")
				replace `myvar'="[FAILED]" if `myvar'=="999999.00 (999999.00, 999999.00)"
			}
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table5a_stratified_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table5a_stratified_hazardratios_redacted.csv, replace
}

**// Part2, Option 2: Table 5b. Stratified hazard ratios (version 2)
capture use $resultsdir/part2_option2_table5b_stratified_hazardratios_v2.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues m=1(1)4 {
			describe *_hr`m', varlist
			foreach myvar in `r(varlist)' {
				replace `myvar'="[REDACTED]" if (`myvar'==". (., .)" | `myvar'=="-" | `myvar'==".")
				replace `myvar'="[FAILED]" if `myvar'=="999999.00 (999999.00, 999999.00)"
				replace `myvar'="[OMITTED]" if `myvar'=="888888.00 (888888.00, 888888.00)"
			}
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table5b_stratified_hazardratios_v2_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table5b_stratified_hazardratios_v2_redacted.csv, replace
}

**// Part2, Option 2: Table 6. Period-specific rates
capture use $resultsdir/part2_option2_table6_periodspecific_rates.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues k=1(1)3 {
			replace person_time`k'=. if numevents`k'<8
			replace numevents`k'=.   if numevents`k'<8
			
			replace rate_period`k'="[REDACTED]" if numevents`k'==.
	
			replace person_time`k'=round(person_time`k',1000)/10000
			format person_time`k' %9.1f
			tostring person_time`k', replace force u
			replace person_time`k'="[REDACTED]" if person_time`k'=="."

			replace numevents`k'=round(numevents`k',5)
			tostring numevents`k', replace force u
			replace numevents`k'="[REDACTED]" if numevents`k'=="."
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table6_periodspecific_rates_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table6_periodspecific_rates_redacted.csv, replace
}

**// Part2, Option 2: Table 7. Period-specific hazard ratios
capture use $resultsdir/part2_option2_table7_periodspecific_hazardratios.dta, clear
if _rc==0 {
	if _N>0 {
		describe hr_*, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'="[REDACTED]" if (`myvar'==". (., .)" | `myvar'=="-" | `myvar'==".")
			replace `myvar'="[FAILED]" if `myvar'=="999999.00 (999999.00, 999999.00)"
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table7_periodspecific_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table7_periodspecific_hazardratios_redacted.csv, replace
}

**// Part2, Option 2: Table 8. Split follow-up rates
capture use $resultsdir/part2_option2_table8_splitfollowup_rates.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues k=1(1)5 {
			replace ptime`k'=. if numevents`k'<8
			replace numevents`k'=.   if numevents`k'<8
			
			replace rate_increm`k'="[REDACTED]" if numevents`k'==.
	
			replace ptime`k'=round(ptime`k',1000)/10000
			format ptime`k' %9.1f
			tostring ptime`k', replace force u
			replace ptime`k'="[REDACTED]" if ptime`k'=="."

			replace numevents`k'=round(numevents`k',5)
			tostring numevents`k', replace force u
			replace numevents`k'="[REDACTED]" if numevents`k'=="."
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table8_splitfollowup_rates_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table8_splitfollowup_rates_redacted.csv, replace
}

**// Part2, Option 2: Table 9. Split follow-up hazard ratios
capture use $resultsdir/part2_option2_table9_splitfollowup_hazardratios.dta, clear
if _rc==0 {
	if _N>0 {
		describe hr_*, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'="[REDACTED]" if (`myvar'==". (., .)" | `myvar'=="-" | `myvar'==".")
			replace `myvar'="[FAILED]" if `myvar'=="999999.00 (999999.00, 999999.00)"
		}
	}
	describe, varlist
	foreach myvar in `r(varlist)' {
		capture replace `myvar'="-" if `myvar'=="-0"
	}
	save $resultsdir/part2_option2_table9_splitfollowup_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/part2_option2_table9_splitfollowup_hazardratios_redacted.csv, replace
}
