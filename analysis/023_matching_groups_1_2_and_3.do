clear
do `c(pwd)'/analysis/000_filepaths.do

use $outdir/matched_groups_1_and_2.dta, clear
append using $outdir/matched_groups_1_and_3.dta

keep setid patient_id group
order setid group patient_id
duplicates drop

sort setid group
by set: egen mysum=sum(group)
drop if mysum<6
drop mysum

save $outdir/matched_groups_1_2_and_3.dta, replace