clear
do `c(pwd)'/analysis/000_filepaths.do

import delimited $outdir/input_part1.csv

replace date_of_birth=date_of_birth+"-15"

describe date_*, varlist
foreach myvar in `r(varlist)' {
	gen temp=date(`myvar',"YMD")
	format temp %td
	drop `myvar'
	rename temp `myvar'
	format `myvar' %td
}

order patient_id practice_id date_discharged_covid date_discharged_pneum date_patient_index has_follow_up date_diabetes_diagnosis date_of_birth sex region date_deregistered date_of_death
sort patient_id

replace date_patient_index=min(date_discharged_covid, date_discharged_pneum)

drop if (has_follow_up!=1 | min(date_deregistered, date_of_death)<=date_patient_index)

**// Exposure group
gen group=.
replace group=1 if date_discharged_covid<=date_discharged_pneum & (date_diabetes_diagnosis<=(date_patient_index+30) | min(date_t1dm_hospital_first, date_t2dm_hospital_first)<=date_patient_index)
replace group=2 if date_discharged_covid<=date_discharged_pneum &  date_diabetes_diagnosis> (date_patient_index+30) & min(date_t1dm_hospital_first, date_t2dm_hospital_first)> date_patient_index
replace group=3 if date_discharged_covid> date_discharged_pneum & (date_diabetes_diagnosis<=(date_patient_index+30) | min(date_t1dm_hospital_first, date_t2dm_hospital_first)<=date_patient_index)
replace group=4 if date_discharged_covid> date_discharged_pneum &  date_diabetes_diagnosis> (date_patient_index+30) & min(date_t1dm_hospital_first, date_t2dm_hospital_first)> date_patient_index
label define grouplab 1 "Covid with diabetes" 2 "Covid without diabetes" 3 "Pneumonia with diabetes" 4 "Pneumonia without diabetes"
label values group grouplab

**// Age group
gen age=(date_patient_index-date_of_birth)/365.25
gen ageband=.
replace ageband=1 if age>=18 & age<50
replace ageband=2 if age>=50 & age<60
replace ageband=3 if age>=60 & age<70
replace ageband=4 if age>=70 & age<80
replace ageband=5 if age>=80
label define agebandlab 1 "18-49" 2 "50-59" 3 "60-69" 4 "70-79" 5 "80+"
label values ageband agebandlab

**// Ethnicity
recode ethnicity .=6
label define ethniclab 1 "White" 2 "Mixed" 3 "Asian/Asian British" 4 "Black" 5 "Other" 6 "Unknown"
label values ethnicity ethniclab

**// IMD


save $outdir/input_part1_clean.dta, replace
