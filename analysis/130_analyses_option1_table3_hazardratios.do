**// Hazard ratios - groups 1,2 and 3

clear
do `c(pwd)'/analysis/000_filepaths.do

use $outdir/input_part1_clean.dta, clear
gen expos=(group==1)

local refgroup2="COVID-19 without diabetes"
local refgroup3="Pneumonia with diabetes"

set more off

tempname hazardratios
	postfile `hazardratios' outindex groupindex str20(mytype) str20(outcome) str25(refgroup) str20(hr1) str20(hr2) str20(hr3) using $resultsdir/option1_table3_hazardratios.dta, replace
	
	local outindex=0
	
	foreach outcome in "stroke" "death" {
		
		local outindex=`outindex'+1
		
		if "`outcome'"=="stroke" | "`outcome'"=="mi" | "`outcome'"=="dvt" | "`outcome'"=="pe" | "`outcome'"=="heart_failure" {
			local mytypetxt="Cardiovascular"
		}
		if "`outcome'"=="aki" {
			local mytypetxt="Renal"
		}
		if "`outcome'"=="liver_failure" | "`outcome'"=="chronic_liver"{
			local mytypetxt="Hepatic"
		}
		if "`outcome'"=="anxiety" | "`outcome'"=="depression" | "`outcome'"=="psychosis" | "`outcome'"=="psych_meds" | {
			local mytypetxt="Mental illness"
		}
		if "`outcome'"=="insomnia" | "`outcome'"=="hypersomnia" | "`outcome'"=="sleep_apnoea" | "`outcome'"=="sleep_meds" | "`outcome'"=="fatigue_syndr" {
			local mytypetxt="Symptoms of post-COVID syndrome"
		}
		if "`outcome'"=="death" {
			local mytypetxt="Death from any cause"
		}
		
		gen myend=(min(date_`outcome', date_censor)-date_patient_index)/(365.25/12)
		gen myselect=(myend>0)
		gen delta=(date_`outcome'==min(date_`outcome', date_censor))
		stset myend, f(delta) id(patient_id)
		
		forvalues k=2(1)3 {
			forvalues m=1(1)3 {
				if `m'==1 {
					stcox expos if (group==1 | group==`k') & myselect==1
				}
				if `m'==2 {
					stcox expos i.cat_sex i.cat_age if (group==1 | group==`k') & myselect==1
				}
				if `m'==3 {
					stcox expos i.cat_* if (group==1 | group==`k') & myselect==1
				}				
				matrix M1=e(b)
				matrix M2=e(V)
				local hr`m'   =exp(M1[1,1])
				local hr`m'_lo=exp(M1[1,1]-1.96*(M2[1,1]^0.5))
				local hr`m'_hi=exp(M1[1,1]+1.96*(M2[1,1]^0.5))
				
				local hr`m'=int((100*`hr`m'')+0.5)/100
				local hr`m'="`hr`m''"
				if strpos("`hr`m''",".")==1 {
					local hr`m'="0"+"`hr`m''"
				}
				if strpos("`hr`m''",".")==0 {
					local hr`m'="`hr`m''"+".00"
				}
				if strlen("`hr`m''")-strpos("`hr`m''",".")==1 {
					local hr`m'="`hr`m''"+"0"
				}
				local hr`m'_lo=int((100*`hr`m'_lo')+0.5)/100
				local hr`m'_lo="`hr`m'_lo'"
				if strpos("`hr`m'_lo'",".")==1 {
					local hr`m'_lo="0"+"`hr`m'_lo'"
				}
				if strpos("`hr`m'_lo'",".")==0 {
					local hr`m'_lo="`hr`m'_lo'"+".00"
				}
				if strlen("`hr`m'_lo'")-strpos("`hr`m'_lo'",".")==1 {
					local hr`m'_lo="`hr`m'_lo'"+"0"
				}
				local hr`m'_hi=int((100*`hr`m'_hi')+0.5)/100
				local hr`m'_hi="`hr`m'_hi'"
				if strpos("`hr`m'_hi'",".")==1 {
					local hr`m'_hi="0"+"`hr`m'_hi'"
				}
				if strpos("`hr`m'_hi'",".")==0 {
					local hr`m'_hi="`hr`m'_hi'"+".00"
				}
				if strlen("`hr`m'_hi'")-strpos("`hr`m'_hi'",".")==1 {
					local hr`m'_hi="`hr`m'_hi'"+"0"
				}						
				local hr`m'="`hr`m'' ("+"`hr`m'_lo', "+"`hr`m'_hi')"		
			}
			post `hazardratios' (`outindex') (`k') ("`mytypetxt'") ("`outcome'") ("`refgroup`k''") ("`hr1'") ("`hr2'") ("`hr3'")
		}
		
		drop myend myselect delta _st _d _t _t0
	}
	
postclose `hazardratios'

**// Tidy and convert to csv
use $resultsdir/option1_table3_hazardratios.dta, clear
sort outindex groupindex
gen temp1=1 if mytype==mytype[_n-1]
replace mytype="" if temp1==1
gen temp2=1 if outcome==outcome[_n-1]
replace outcome="" if (temp2==1 | outcome=="death")
drop outindex groupindex temp1 temp2
rename mytype type
save $resultsdir/option1_table3_hazardratios.dta, replace
export delimited using $resultsdir/option1_table3_hazardratios.csv, replace
