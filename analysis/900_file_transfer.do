**// Set filepaths and create final directory (to transfer output tables for release)

global projectdir `c(pwd)'
global outdir $projectdir/output 
global resultsdir $projectdir/output/results

global finaldir $projectdir/release

capture mkdir "$finaldir"


**// PART 1 (Option 1 only)
**///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

**// Option 1: Table 1. Demographics
use $resultsdir/option1_table1_demographics_redacted.dta, clear
export delimited using $finaldir/option1_table1_demographics_redacted.csv, replace

**// Option 1: Table 2b. Rate ratios
use $resultsdir/option1_table2b_rateratios_redacted.dta, clear
export delimited using $finaldir/option1_table2b_rateratios_redacted.csv, replace

**// Option 1: Table 3a. Hazard ratios
use $resultsdir/option1_table3a_hazardratios_redacted.dta, clear
export delimited using $finaldir/option1_table3a_hazardratios_redacted.csv, replace

**// Option 1: Table 3b. Hazard ratios - version 2
use $resultsdir/option1_table3b_hazardratios_v2_redacted.dta, clear
export delimited using $finaldir/option1_table3b_hazardratios_v2_redacted.csv, replace

**// Option 1: Table 4b. Stratified rate ratios
use $resultsdir/option1_table4b_stratified_rateratios_redacted.dta, clear
export delimited using $finaldir/option1_table4b_stratified_rateratios_redacted.csv, replace

**// Option 1: Table 6. Period-specific rates
use $resultsdir/option1_table6_periodspecific_rates_redacted.dta, clear
export delimited using $finaldir/option1_table6_periodspecific_rates_redacted.csv, replace

**// Option 1: Table 8. Split follow-up rates
use $resultsdir/option1_table8_splitfollowup_rates_redacted.dta, clear
export delimited using $finaldir/option1_table8_splitfollowup_rates_redacted.csv, replace


**// PART 2 (Option 1 only)
**///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
**// Part2, Option 1: Table 1. Demographics
use $resultsdir/part2_option1_table1_demographics_redacted.dta, clear
export delimited using $finaldir/part2_option1_table1_demographics_redacted.csv, replace

**// Part2, Option 1: Table 2b. Rate ratios
use $resultsdir/part2_option1_table2b_rateratios_redacted.dta, clear
export delimited using $finaldir/part2_option1_table2b_rateratios_redacted.csv, replace

**// Part2, Option 1: Table 3a. Hazard ratios
use $resultsdir/part2_option1_table3a_hazardratios_redacted.dta, clear
export delimited using $finaldir/part2_option1_table3a_hazardratios_redacted.csv, replace

**// Part2, Option 1: Table 3b. Hazard ratios - version 2
use $resultsdir/part2_option1_table3b_hazardratios_v2_redacted.dta, clear
export delimited using $finaldir/part2_option1_table3b_hazardratios_v2_redacted.csv, replace

**// Part2, Option 1: Table 4b. Stratified rate ratios
use $resultsdir/part2_option1_table4b_stratified_rateratios_redacted.dta, clear
export delimited using $finaldir/part2_option1_table4b_stratified_rateratios_redacted.csv, replace

**// Part2, Option 1: Table 6. Period-specific rates
use $resultsdir/part2_option1_table6_periodspecific_rates_redacted.dta, clear
export delimited using $finaldir/part2_option1_table6_periodspecific_rates_redacted.csv, replace

**// Part2, Option 1: Table 8. Split follow-up rates
use $resultsdir/part2_option1_table8_splitfollowup_rates_redacted.dta, clear
export delimited using $finaldir/part2_option1_table8_splitfollowup_rates_redacted.csv, replace

