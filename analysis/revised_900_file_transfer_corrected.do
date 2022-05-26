**// Set filepaths and create final directory (to transfer output tables for release)

global projectdir `c(pwd)'

global outdir $projectdir/output 
global revisedresultsdir $projectdir/output/revised_results

global revisedfinaldir $projectdir/revised_release_corrected

capture mkdir "$revisedfinaldir"


**// PART 2 (Option 1 only)
**///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
**// Part2, Option 1: Table 1. Demographics
use $revisedresultsdir/revised_part2_option1_table1_demographics_redacted.dta, clear
export delimited using $revisedfinaldir/revised_part2_option1_table1_demographics_redacted.csv, replace

**// Part2, Option 1: Table 2b. Rate ratios
use $revisedresultsdir/revised_part2_option1_table2b_rateratios_redacted.dta, clear
export delimited using $revisedfinaldir/revised_part2_option1_table2b_rateratios_redacted.csv, replace

**// Part2, Option 1: Table 4b. Stratified rate ratios
use $revisedresultsdir/revised_part2_option1_table4b_stratified_rateratios_redacted.dta, clear
export delimited using $revisedfinaldir/revised_part2_option1_table4b_stratified_rateratios_redacted.csv, replace
