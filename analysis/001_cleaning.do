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

gen group=.
replace group=1 if date_discharged_covid<=date_discharged_pneum & (date_diabetes_diagnosis<=(date_patient_index+30) | min(date_t1dm_hospital_first, date_t1dm_hospital_last)<=date_patient_index)
replace group=2 if date_discharged_covid<=date_discharged_pneum &  date_diabetes_diagnosis> (date_patient_index+30) & min(date_t1dm_hospital_first, date_t1dm_hospital_last)> date_patient_index
replace group=3 if date_discharged_covid> date_discharged_pneum & (date_diabetes_diagnosis<=(date_patient_index+30) | min(date_t1dm_hospital_first, date_t1dm_hospital_last)<=date_patient_index)
replace group=4 if date_discharged_covid> date_discharged_pneum &  date_diabetes_diagnosis> (date_patient_index+30) & min(date_t1dm_hospital_first, date_t1dm_hospital_last)> date_patient_index

label define grouplab 1 "Covid with diabetes" 2 "Covid without diabetes" 3 "Pneumonia with diabetes" 4 "Pneumonia without diabetes"
label values group grouplab