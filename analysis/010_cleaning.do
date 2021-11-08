clear
do `c(pwd)'/analysis/000_filepaths.do

import delimited $outdir/input_part1.csv

gen date_studyend="2021-09-30"

replace date_birth=date_birth+"-15"
rename hba1c_date date_hba1c
rename hba1c_percentage_date date_hba1c_percent

describe date_*, varlist
foreach myvar in `r(varlist)' {
	gen temp=date(`myvar',"YMD")
	format temp %td
	drop `myvar'
	rename temp `myvar'
	format `myvar' %td
}

order patient_id practice_id date_discharged_covid date_discharged_pneum date_patient_index has_follow_up date_diabetes_diagnosis date_birth sex region date_deregistered date_death
sort patient_id

replace date_patient_index=min(date_discharged_covid, date_discharged_pneum)

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
gen date_first_covid=min(date_covid_test, date_covid_hospital, date_covid_icu)
gen date_censor=date_admitted_pneum if (group==1 | group==2)
replace date_censor=date_first_covid if (group==3 | group==4)
replace date_censor=min(date_deregistered, date_death, date_studyend) if min(date_deregistered, date_death, date_studyend)<date_censor

**// Sex
gen cat_sex=1 if sex=="F"
replace cat_sex=2 if sex=="M"
label define cat_sexlab 1 "Female" 2 "Male"
label values cat_sex cat_sexlab
drop sex

**// Age group
gen age=(date_patient_index-date_birth)/365.25
gen     cat_age=.
replace cat_age=1 if age>=18
replace cat_age=2 if age>=50
replace cat_age=3 if age>=60
replace cat_age=4 if age>=70
replace cat_age=5 if age>=80
drop if cat_age==.
label define cat_agelab 1 "18-49" 2 "50-59" 3 "60-69" 4 "70-79" 5 "80+"
label values cat_age cat_agelab
drop age

**// Ethnicity
capture gen cat_ethnic=ethnicity_gp
capture replace cat_ethnic=ethnicity_sus if cat_ethnic==.
if _rc==0 {
	recode cat_ethnic .=6
	label define cat_ethniclab 1 "White" 2 "Mixed" 3 "Asian/Asian British" 4 "Black" 5 "Other" 6 "Unknown"
	label values cat_ethnic cat_ethniclab
	drop ethnicity_gp ethnicity_sus
}

**// IMD
capture describe imd
if _rc==0 {
	egen cat_imd=cut(imd), group(5) icodes
	replace cat_imd=cat_imd+1
	replace cat_imd=. if imd==-1
	replace cat_imd=6-cat_imd
	label define cat_imdlab 1 "1 (least deprived)" 2 "2" 3 "3" 4 "4" 5 "5 (most deprived)" .u "Unknown"
	label values cat_imd cat_imdlab
	drop imd
}

**// Type of diabetes

**// History of CVD
capture gen cat_hist_cvd=max(hist_cvd, hist_cvd_opcs)+1
if _rc==0 {
	recode cat_hist_cvd .=3
	label define cat_hist_cvdlab 1 "No" 2 "Yes" 3 "Unknown"
	label values cat_hist_cvd cat_hist_cvdlab
	drop hist_cvd hist_cvd_opcs
}

**// History of renal disease

**// Type of treatment for COVID-19 (during hospitalisation)

**// Smoking status
capture gen cat_smoking=2 if latest_smoking=="N" & ever_smoked==1
if _rc==0 {
	replace cat_smoking=1 if latest_smoking=="N" & ever_smoked==0
	replace cat_smoking=2 if latest_smoking=="E"
	replace cat_smoking=3 if latest_smoking=="S"
	recode cat_smoking .=4
	label define cat_smoklab 1 "Never" 2 "Ex" 3 "Current" 4 "Unknown"
	label values cat_smoking cat_smoklab
	drop latest_smoking ever_smoked
}

**// Hazardous alcohol consumption (in the year prior to baseline)
capture gen cat_alcohol=haz_alcohol+1
if _rc==0 {
	recode cat_alcohol .=3
	label define cat_alcohollab 1 "No" 2 "Yes" 3 "Unknown"
	label values cat_alcohol cat_alcohollab
	drop haz_alcohol
}

**// BMI
capture describe bmi
if _rc==0 {
	replace bmi=. if bmi<0
	gen    cat_bmi=.
	recode cat_bmi .=1 if bmi<18.5
	recode cat_bmi .=2 if bmi<25
	recode cat_bmi .=3 if bmi<30
	recode cat_bmi .=4 if bmi!=.
	recode cat_bmi .=5
	label define cat_bmilab 1 "Underweight" 2 "Healthy" 3 "Overweight" 4 "Obese" 5 "Unknown"
	label values cat_bmi cat_bmilab
	drop bmi*
}

**// HbA1c
capture describe hba1c
if _rc==0 {
	gen cat_hba1c=.
	recode cat_hba1c .=1 if hba1c<42
	recode cat_hba1c .=2 if hba1c<48
	recode cat_hba1c .=3 if hba1c!=.
	recode cat_hba1c .=4
}
capture describe hba1c_percent
if _rc==0 {
	gen cat_hba1c_percent=.
	recode cat_hba1c_percent .=1 if hba1c_percent<6
	recode cat_hba1c_percent .=2 if hba1c_percent<6.5
	recode cat_hba1c_percent .=3 if hba1c_percent!=.
	recode cat_hba1c_percent .=4
}
capture replace cat_hba1c=cat_hba1c_percent if date_hba1c_percent>date_hba1c & date_hba1c_percent!=. & cat_hba1c_percent<4
label define cat_hba1clab 1 "Normal" 2 "Prediabetes" 3 "Diabetes" 4 "Unknown"
capture label values cat_hba1c cat_hba1clab
capture drop hba1c* cat_hba1c_percent date_hba1c*

**// COVID-19 vaccination status


**// OUTCOMES
**///////////////

**// Stroke
gen date_stroke=min(date_stroke_gp, date_stroke_hospital, date_stroke_ons)
drop date_stroke_*

**// Myocardial Infarction (MI)
gen date_mi=min(date_mi_gp, date_mi_hospital, date_mi_ons)
drop date_mi_*

**// Deep Vein Thrombosis (DVT)
gen date_dvt=min(date_dvt_gp, date_dvt_hospital, date_dvt_ons)
drop date_dvt_*

**// Pulmonary Embolism (PE)
gen date_pe=min(date_pe_gp, date_pe_hospital, date_pe_ons)
drop date_pe_*

**// Heart Failure
gen date_hf=min(date_hf_gp, date_hf_hospital, date_hf_ons)
drop date_hf_*

**// Renal
**// Hepatic
**// Mental Illness
**// Symptoms of post-COVID syndrome outcome


save $outdir/input_part1_clean.dta, replace
