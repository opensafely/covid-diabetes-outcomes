clear
do `c(pwd)'/analysis/000_filepaths.do

use $outdir/matched_groups_1_and_2.dta, clear
append using $outdir/matched_groups_1_and_3.dta

order setid group patient_id
sort setid group patient_id
drop if setid==setid[_n-1] & group==group[_n-1] & patient_id==patient_id[_n-1]

sort setid group
count if setid!=setid[_n-1]
local mycount=r(N)
if `mycount'>0 {
	by setid: egen mysum=sum(group)
	drop if mysum<6
	drop mysum
}

save $outdir/matched_groups_1_2_and_3.dta, replace
