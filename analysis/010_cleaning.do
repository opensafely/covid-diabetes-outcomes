clear
do `c(pwd)'/analysis/000_filepaths.do

import delimited $outdir/input_part1.csv

gen date_studyend="2021-09-30"

replace date_birth=date_birth+"-15"

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

**// Exposure group
gen     group=.
replace group=1 if date_discharged_covid<=date_discharged_pneum & (date_diabetes_diagnosis<=date_patient_index | min(date_t1dm_hospital_first, date_t2dm_hospital_first)<=date_patient_index)
replace group=2 if date_discharged_covid<=date_discharged_pneum &  date_diabetes_diagnosis> date_patient_index & min(date_t1dm_hospital_first, date_t2dm_hospital_first)> date_patient_index
replace group=3 if date_discharged_covid> date_discharged_pneum & (date_diabetes_diagnosis<=date_patient_index | min(date_t1dm_hospital_first, date_t2dm_hospital_first)<=date_patient_index)
replace group=4 if date_discharged_covid> date_discharged_pneum &  date_diabetes_diagnosis> date_patient_index & min(date_t1dm_hospital_first, date_t2dm_hospital_first)> date_patient_index
label define grouplab 1 "Covid with diabetes" 2 "Covid without diabetes" 3 "Pneumonia with diabetes" 4 "Pneumonia without diabetes"
label values group grouplab

**// Censoring
gen date_first_covid=min(date_covid_test, date_covid_hospital, date_covid_icu)
gen date_censor=date_admitted_pneum if (group==1 | group==2)
replace date_censor=date_first_covid if (group==3 | group==4)
replace date_censor=min(date_deregistered, date_death, date_studyend)

**// Sex
gen cat_sex=0 if sex=="F"
replace cat_sex=1 if sex=="M"

**// Age group
gen age=(date_patient_index-date_birth)/365.25
gen     cat_age=.
replace cat_age=1 if age>=18
replace cat_age=2 if age>=50
replace cat_age=3 if age>=60
replace cat_age=4 if age>=70
replace cat_age=5 if age>=80
label define cat_agelab 1 "18-49" 2 "50-59" 3 "60-69" 4 "70-79" 5 "80+"
label values cat_age cat_agelab

**// Ethnicity
capture rename ethnicity cat_ethnic
if _rc==0 {
	recode cat_ethnic .=6
	label define cat_ethniclab 1 "White" 2 "Mixed" 3 "Asian/Asian British" 4 "Black" 5 "Other" 6 "Unknown"
	label values cat_ethnic cat_ethniclab
}

**// IMD
capture describe imd
if _rc==0 {
	egen cat_imd=cut(imd), group(5) icodes
	replace cat_imd=cat_imd+1
	replace cat_imd=. if imd==-1
	recode cat_imd 5=1 4=2 3=3 2=4 1=5
	label define cat_imdlab 1 "1 (least deprived)" 2 "2" 3 "3" 4 "4" 5 "5 (most deprived)" .u "Unknown"
	label values cat_imd cat_imdlab
	order cat_imd, after(imd)
}

**// Type of diabetes

**// History of CVD

**// History of renal disease

**// Type of treatment for COVID-19 (during hospitalisation)

**// Smoking status

**// Alcohol intake

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
	order cat_bmi, after(bmi)
}

**// HbA1c
capture describe hba1c
if _rc==0 {
	gen cat_hba1c=.
	recode cat_hba1c .=1 if hba1c<42
	recode cat_hba1c .=2 if hba1c<48
	recode cat_hba1c .=3 if hba1c!=.
	recode cat_hba1c .=4
	label define cat_hba1clab 1 "Normal" 2 "Prediabetes" 3 "Diabetes" 4 "Unknown"
	label values cat_hba1c cat_hba1clab
	order cat_hba1c, after(hba1c)
}

**// OUTCOMES
**///////////////

**// Stroke
gen date_stroke=min(date_stroke_gp, date_stroke_hospital, date_stroke_ons)


save $outdir/input_part1_clean.dta, replace
