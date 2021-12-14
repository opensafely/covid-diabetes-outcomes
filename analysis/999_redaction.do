clear
do `c(pwd)'/analysis/000_filepaths.do
		
**\\ Option 1
**\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
		
**\\ Option 1: Table 1. Demographics
capture use $resultsdir/option1_table1_demographics.dta, clear
if _rc==0 {
	describe *_n, varlist
	foreach myvar in `r(varlist)' {
		replace `myvar'=round(`myvar',5)
		tostring `myvar', replace force
		replace `myvar'="[REDACTED]" if (`myvar'=="." | `myvar'=="0" | `myvar'=="5")
	}
	drop *_pmonths
	save $resultsdir/option1_table1_demographics_redacted.dta, replace
	export delimited using $resultsdir/option1_table1_demographics_redacted.csv, replace
}

**\\ Option 1: Table 2. Rates
capture use $resultsdir/option1_table2_rates.dta, clear
if _rc==0 {
	replace numevents=round(numevents,5)
	tostring numevents, replace force
	replace numevents="[REDACTED]" if (numevents=="." | numevents=="0" | numevents=="5")
	replace person_time=round(person_time,1000)/10000
	format person_time %9.1f
	tostring person_time, replace force u
	replace person_time="[REDACTED]" if (numevents=="[REDACTED]" | person_time==".")
	replace rate="[REDACTED]" if (numevents=="[REDACTED]" | rate==". (., .)")
	save $resultsdir/option1_table2_rates_redacted.dta, replace
	export delimited using $resultsdir/option1_table2_rates_redacted.csv, replace
}

**\\ Option 1: Table 3. Hazard ratios
capture use $resultsdir/option1_table3_hazardratios.dta, clear
if _rc==0{
	forvalues k=1(1)3 {
		replace hr`k'="[REDACTED]" if hr`k'==". (., .)"
		replace hr`k'="[FAILED]" if hr`k'=="999999.00 (999999.00, 999999.00)"
	}
	save $resultsdir/option1_table3_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/option1_table3_hazardratios_redacted.csv, replace
}

**\\ Option 1: Table 3. Hazard ratios - version 2
capture use $resultsdir/option1_table3_hazardratios_v2.dta, clear
if _rc==0 {
	forvalues k=1(1)4 {
		replace hr`k'="[REDACTED]" if hr`k'==". (., .)"
		replace hr`k'="[FAILED]" if hr`k'=="999999.00 (999999.00, 999999.00)"
	}
	save $resultsdir/option1_table3_hazardratios_v2_redacted.dta, replace
	export delimited using $resultsdir/option1_table3_hazardratios_v2_redacted.csv, replace
}

**\\ Option 1: Table 4. Stratified rates
capture use $resultsdir/option1_table4_stratified_rates.dta, clear
if _rc==0 {
	describe *_events, varlist
	foreach myvar in `r(varlist)' {
		replace `myvar'=round(`myvar',5)
		tostring `myvar', replace force
		replace `myvar'="[REDACTED]" if (`myvar'=="." | `myvar'=="0" | `myvar'=="5")
	}
	describe *_ptime, varlist
	foreach myvar in `r(varlist)' {
		replace `myvar'=round(`myvar',1000)/10000
		format `myvar' %9.1f
		tostring `myvar', replace force u
		local myname=substr("`myvar'",1,strpos("`myvar'","_ptime")-1)
		replace `myvar'="[REDACTED]" if (`myname'_events=="[REDACTED]" | `myvar'==".")
	}
	describe *_rate, varlist
	foreach myvar in `r(varlist)' {
		local myname=substr("`myvar'",1,strpos("`myvar'","_rate")-1)
		replace `myvar'="[REDACTED]" if (`myname'_events=="[REDACTED]" | `myvar'==". (., .)")
	}
	save $resultsdir/option1_table4_stratified_rates_redacted.dta, replace
	export delimited using $resultsdir/option1_table4_stratified_rates_redacted.csv, replace
}

**\\ Option 1: Table 5. Stratified hazard ratios
capture use $resultsdir/option1_table5_stratified_hazardratios.dta, clear
if _rc==0 {
	forvalues m=1(1)3 {
		describe *_hr`m', varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'="[REDACTED]" if (`myvar'==". (., .)" | `myvar'=="-" | `myvar'==".")
			replace `myvar'="[FAILED]" if `myvar'=="999999.00 (999999.00, 999999.00)"
		}
	}
	save $resultsdir/option1_table5_stratified_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/option1_table5_stratified_hazardratios_redacted.csv, replace
}

**\\ Option 1: Table 5. Stratified hazard ratios (version 2)
capture use $resultsdir/option1_table5_stratified_hazardratios_v2.dta, clear
if _rc==0 {
	forvalues m=1(1)4 {
		describe *_hr`m', varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'="[REDACTED]" if (`myvar'==". (., .)" | `myvar'=="-" | `myvar'==".")
			replace `myvar'="[FAILED]" if `myvar'=="999999.00 (999999.00, 999999.00)"
			replace `myvar'="[OMITTED]" if `myvar'=="888888.00 (888888.00, 888888.00)"
		}
	}
	save $resultsdir/option1_table5_stratified_hazardratios_v2_redacted.dta, replace
	export delimited using $resultsdir/option1_table5_stratified_hazardratios_v2_redacted.csv, replace
}

**\\ Option 1: Table 6. Period-specific hazard ratios
capture use $resultsdir/option1_table6_periodspecific_hazardratios.dta, clear
if _rc==0 {
	describe hr_*, varlist
	foreach myvar in `r(varlist)' {
		replace `myvar'="[REDACTED]" if (`myvar'==". (., .)" | `myvar'=="-" | `myvar'==".")
		replace `myvar'="[FAILED]" if `myvar'=="999999.00 (999999.00, 999999.00)"
	}
	save $resultsdir/option1_table6_periodspecific_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/option1_table6_periodspecific_hazardratios_redacted.csv, replace
}

**\\ Option 2
**\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

**\\ Option 2: Table 1a. Demographics (groups 1 and 2)
capture use $resultsdir/option2_table1a_demographics_groups_1_and_2.dta, replace
if _rc==0 {
	if _N>0 {
		describe *_n, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'=round(`myvar',5)
			tostring `myvar', replace force
			replace `myvar'="[REDACTED]" if (`myvar'=="." | `myvar'=="0" | `myvar'=="5")
		}
		drop *_pmonths		
	}
	save $resultsdir/option2_table1a_demographics_groups_1_and_2_redacted.dta, replace
	export delimited using $resultsdir/option2_table1a_demographics_groups_1_and_2_redacted.csv, replace
}

**\\ Option 2: Table 1b. Demographics (groups 1 and 3)
capture use $resultsdir/option2_table1b_demographics_groups_1_and_3.dta, replace
if _rc==0 {
	if _N>0 {
		describe *_n, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'=round(`myvar',5)
			tostring `myvar', replace force
			replace `myvar'="[REDACTED]" if (`myvar'=="." | `myvar'=="0" | `myvar'=="5")
		}
		drop *_pmonths
	}
	save $resultsdir/option2_table1b_demographics_groups_1_and_3_redacted.dta, replace
	export delimited using $resultsdir/option2_table1b_demographics_groups_1_and_3_redacted.csv, replace
}

**\\ Option 3
**\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

**\\ Option 3: Table 1. Demographics
capture use $resultsdir/option3_table1_demographics.dta, replace
if _rc==0 {
	if _N>0 {
		describe *_n, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'=round(`myvar',5)
			tostring `myvar', replace force
			replace `myvar'="[REDACTED]" if (`myvar'=="." | `myvar'=="0" | `myvar'=="5")
		}
		drop *_pmonths	
	}
	save $resultsdir/option3_table1_demographics_redacted.dta, replace
	export delimited using $resultsdir/option3_table1_demographics_redacted.csv, replace
}

**\\ Option 3: Table 2. Rates
capture use $resultsdir/option3_table2_rates.dta, clear
if _rc==0 {
	if _N>0 {
		replace numevents=round(numevents,5)
		tostring numevents, replace force
		replace numevents="[REDACTED]" if (numevents=="." | numevents=="0" | numevents=="5")
		replace person_time=round(person_time,1000)/10000
		format person_time %9.1f
		tostring person_time, replace force u
		replace person_time="[REDACTED]" if (numevents=="[REDACTED]" | person_time==".")
		replace rate="[REDACTED]" if (numevents=="[REDACTED]" | rate==". (., .)")
	}
	save $resultsdir/option3_table2_rates_redacted.dta, replace
	export delimited using $resultsdir/option3_table2_rates_redacted.csv, replace
}

**\\ Option 3: Table 3. Hazard ratios
capture use $resultsdir/option3_table3_hazardratios.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues k=1(1)3 {
			replace hr`k'="[REDACTED]" if hr`k'==". (., .)"
			replace hr`k'="[FAILED]" if hr`k'=="999999.00 (999999.00, 999999.00)"
		}	
	}
	save $resultsdir/option3_table3_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/option3_table3_hazardratios_redacted.csv, replace
}

**\\ Option 3: Table 3. Hazard ratios - version 2
capture use $resultsdir/option3_table3_hazardratios_v2.dta, clear
if _rc==0 {
	if _N>0 {
		forvalues k=1(1)4 {
			replace hr`k'="[REDACTED]" if hr`k'==". (., .)"
			replace hr`k'="[FAILED]" if hr`k'=="999999.00 (999999.00, 999999.00)"
		}
	}
	save $resultsdir/option3_table3_hazardratios_v2_redacted.dta, replace
	export delimited using $resultsdir/option3_table3_hazardratios_v2_redacted.csv, replace
}

**\\ Option 3: Table 4. Stratified rates
capture use $resultsdir/option3_table4_stratified_rates.dta, clear
if _rc==0 {
	if _N>0 {
		describe *_events, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'=round(`myvar',5)
			tostring `myvar', replace force
			replace `myvar'="[REDACTED]" if (`myvar'=="." | `myvar'=="0" | `myvar'=="5")
		}
		describe *_ptime, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'=round(`myvar',1000)/10000
			format `myvar' %9.1f
			tostring `myvar', replace force u
			local myname=substr("`myvar'",1,strpos("`myvar'","_ptime")-1)
			replace `myvar'="[REDACTED]" if (`myname'_events=="[REDACTED]" | `myvar'==".")
		}
		describe *_rate, varlist
		foreach myvar in `r(varlist)' {
			local myname=substr("`myvar'",1,strpos("`myvar'","_rate")-1)
			replace `myvar'="[REDACTED]" if (`myname'_events=="[REDACTED]" | `myvar'==". (., .)")
		}		
	}
	save $resultsdir/option3_table4_stratified_rates_redacted.dta, replace
	export delimited using $resultsdir/option3_table4_stratified_rates_redacted.csv, replace
}

**\\ Option 3: Table 5. Stratified hazard ratios
capture use $resultsdir/option3_table5_stratified_hazardratios.dta, clear
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
	save $resultsdir/option3_table5_stratified_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/option3_table5_stratified_hazardratios_redacted.csv, replace
}

**\\ Option 3: Table 5. Stratified hazard ratios (version 2)
capture use $resultsdir/option3_table5_stratified_hazardratios_v2.dta, clear
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
	save $resultsdir/option3_table5_stratified_hazardratios_v2_redacted.dta, replace
	export delimited using $resultsdir/option3_table5_stratified_hazardratios_v2_redacted.csv, replace
}

**\\ Option 3: Table 6. Period-specific hazard ratios
capture use $resultsdir/option3_table6_periodspecific_hazardratios.dta, clear
if _rc==0 {
	if _N>0 {
		describe hr_*, varlist
		foreach myvar in `r(varlist)' {
			replace `myvar'="[REDACTED]" if (`myvar'==". (., .)" | `myvar'=="-" | `myvar'==".")
			replace `myvar'="[FAILED]" if `myvar'=="999999.00 (999999.00, 999999.00)"
		}	
	}
	save $resultsdir/option3_table6_periodspecific_hazardratios_redacted.dta, replace
	export delimited using $resultsdir/option3_table6_periodspecific_hazardratios_redacted.csv, replace
}
