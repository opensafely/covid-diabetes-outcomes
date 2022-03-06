clear
do `c(pwd)'/analysis/000_filepaths.do
	
global checksdir $outdir/checks
capture mkdir "$checksdir"
	
import delimited $outdir/input_part1.csv

gen date_studyend="2021-11-30"

replace date_birth=date_birth+"-15"
rename hba1c_date date_hba1c
rename hba1c_percentage_date date_hba1c_percent

describe date_*, varlist
foreach myvar in `r(varlist)' {
	capture gen temp=date(`myvar',"YMD")
	if _rc==0 {
		format temp %td
		drop `myvar'
		rename temp `myvar'
		format `myvar' %td		
	}
}

order patient_id practice_id date_discharged_covid date_discharged_pneum date_patient_index has_follow_up date_diabetes_diagnosis date_birth sex region date_deregistered date_death
sort patient_id

replace date_patient_index=min(date_discharged_covid, date_discharged_pneum)
replace date_diabetes_diagnosis=min(date_t1dm_gp_first, date_t2dm_gp_first, date_unknown_diabetes_gp_first)

drop if (has_follow_up!=1 | min(date_deregistered, date_death)<=date_patient_index)
drop has_follow_up

**// Exposure group
gen     group=.
replace group=1 if date_discharged_covid<=date_discharged_pneum & (date_diabetes_diagnosis<=date_patient_index | min(date_t1dm_hospital_first, date_t2dm_hospital_first)<=date_patient_index)
replace group=2 if date_discharged_covid<=date_discharged_pneum &  date_diabetes_diagnosis> date_patient_index & min(date_t1dm_hospital_first, date_t2dm_hospital_first)> date_patient_index
replace group=3 if date_discharged_covid> date_discharged_pneum & (date_diabetes_diagnosis<=date_patient_index | min(date_t1dm_hospital_first, date_t2dm_hospital_first)<=date_patient_index)
replace group=4 if date_discharged_covid> date_discharged_pneum &  date_diabetes_diagnosis> date_patient_index & min(date_t1dm_hospital_first, date_t2dm_hospital_first)> date_patient_index
label define grouplab 1 "COVID-19 with diabetes" 2 "COVID-19 without diabetes" 3 "Pneumonia with diabetes" 4 "Pneumonia without diabetes"
label values group grouplab

**// Censoring
gen date_first_covid=min(date_covid_test, date_covid_hospital)
gen date_censor=date_admitted_pneum if (group==1 | group==2)
replace date_censor=date_first_covid if (group==3 | group==4)
replace date_censor=min(date_deregistered, date_death, date_studyend) if min(date_deregistered, date_death, date_studyend)<date_censor
drop date_covid_test date_admitted_pneum date_first_covid date_deregistered

tempname ethnicity
	postfile `ethnicity' code ethnicity_gp ethnicity_sus using $checksdir/ethnicity.dta, replace
						
		forvalues k=0(1)10 {
			count if ethnicity_gp==`k'
			local count_gp=r(N)
			count if ethnicity_sus==`k'
			local count_sus=r(N)
			post `ethnicity' (`k') (`count_gp') (`count_sus')
		}
		
		local k=.
		count if ethnicity_gp==`k'
		local count_gp=r(N)
		count if ethnicity_sus==`k'
		local count_sus=r(N)
		post `ethnicity' (`k') (`count_gp') (`count_sus')
		
postclose `ethnicity'
clear

use $checksdir/ethnicity.dta, clear
export delimited using $checksdir/ethnicity.csv, replace
