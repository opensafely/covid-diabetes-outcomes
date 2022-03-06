clear
do `c(pwd)'/analysis/000_filepaths.do
	
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

**// Type of diabetes
gen temp1=(min(date_t1dm_gp_first, date_t1dm_hospital_first)<=date_patient_index)
gen temp2=(min(date_t2dm_gp_first, date_t2dm_hospital_first)<=date_patient_index)
gen temp3=(date_unknown_diabetes_gp_first<=date_patient_index)
gen     cat_diabetes=2
replace cat_diabetes=1 if temp1==1 & temp2!=1
replace cat_diabetes=1 if temp1==1 & temp2==1            & insulin_lastyear==1 & antidiabetic_lastyear!=1
replace cat_diabetes=1 if temp1!=1 & temp2!=1 & temp3==1 & insulin_lastyear==1 & antidiabetic_lastyear!=1
replace cat_diabetes=3 if temp1!=1 & temp2!=1 & temp3!=1
label define cat_diablab 1 "1" 2 "2" 3 "None"
label values cat_diabetes cat_diablab
**// Drop Type 1 diabetes
drop if cat_diabetes==1
drop temp* date_diabetes* date_t1dm* date_t2dm* date_unknown_diabetes* antidiabetic_lastyear insulin_lastyear cat_diabetes


**// Sex
gen cat_sex=1 if sex=="F"
replace cat_sex=2 if sex=="M"
drop if cat_sex==.
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
	capture egen cat_imd=cut(imd), group(5) icodes
	if _rc==0 {
	replace cat_imd=cat_imd+1
	replace cat_imd=. if imd==-1
	replace cat_imd=6-cat_imd
	label define cat_imdlab 1 "1 (least deprived)" 2 "2" 3 "3" 4 "4" 5 "5 (most deprived)" .u "Unknown"
	label values cat_imd cat_imdlab
	}
	if _rc!=0 {
		gen cat_imd=.
	}
	drop imd
}

**// History of CVD
capture gen cat_hist_cvd=max(hist_cvd_gp, hist_cvd_hospital, hist_cvd_opcs2)+1
if _rc==0 {
	recode cat_hist_cvd .=3
	label define cat_hist_cvdlab 1 "No" 2 "Yes" 3 "Unknown"
	label values cat_hist_cvd cat_hist_cvdlab
	drop hist_cvd_gp hist_cvd_hospital hist_cvd_opcs2
}

**// History of renal disease
gen gfr_flag=.
capture describe creatinine
if _rc==0 {
	gen temp_age=(date_patient_index-date_birth)/365.25
	gen temp_female=(cat_sex==1)
	gen temp_black=(cat_ethnic==4)
	gen gfr=175*((creatinine/88.4)^-1.154)*(temp_age^-0.203)*(1-(1-0.742)*temp_female)*(1+0.212*temp_black) 
	replace gfr_flag=(gfr<60 & creatinine>0 & creatinine!=.)
	drop creatinine temp_age temp_female temp_black gfr
}
recode gfr_flag .=0
capture gen cat_hist_renal=max(gfr_flag, ckd_gp, ckd_hospital, hist_rrt)+1
if _rc==0 {
	recode cat_hist_renal .=3
	label define cat_hist_renallab 1 "No" 2 "Yes" 3 "Unknown"
	label values cat_hist_renal cat_hist_renallab
	drop gfr_flag ckd_gp ckd_hospital hist_rrt
}

**// Required critical care (during hospitalisation)
capture describe critical_care_days
if _rc==0 {
	gen cat_critical=1
	replace cat_critical=2 if critical_care_days>0 & critical_care_days!=.
}
label define cat_criticallab 1 "No" 2 "Yes"
label values cat_critical cat_criticallab
drop critical_care_days

**// COVID-19 vaccination status (at baseline)
gen cat_vaccin=1
capture replace cat_vaccin=2 if date_vaccin_gp_1<date_patient_index
capture replace cat_vaccin=3 if date_vaccin_gp_2<date_patient_index
label define cat_vaccinlab 1 "None" 2 "One dose" 3 "Two doses"
label value cat_vaccin cat_vaccinlab
drop date_vaccin_* date_covid_hospital

**// Smoking status
capture describe latest_smoking ever_smoked
if _rc==0 {
	gen     cat_smoking=1 if latest_smoking=="N" & (ever_smoked==0 | ever_smoked==.)
	replace cat_smoking=2 if latest_smoking=="E" | (latest_smoking=="N" & ever_smoked==1)
	replace cat_smoking=3 if latest_smoking=="S"
	recode cat_smoking .=4
	label define cat_smoklab 1 "Never" 2 "Ex" 3 "Current" 4 "Unknown"
	label values cat_smoking cat_smoklab
	drop latest_smoking ever_smoked
}

**// Hazardous alcohol consumption
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
	*drop if (bmi==. | bmi<0)
	replace bmi=. if bmi<=0
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
	recode cat_hba1c .=1 if hba1c>0 & hba1c<42
	recode cat_hba1c .=2 if hba1c>=42 & hba1c<48
	recode cat_hba1c .=3 if hba1c>=48 & hba1c!=.
	recode cat_hba1c .=4
}
capture describe hba1c_percent
if _rc==0 {
	gen cat_hba1c_percent=.
	recode cat_hba1c_percent .=1 if hba1c_percent>0 & hba1c_percent<6
	recode cat_hba1c_percent .=2 if hba1c_percent>=6 & hba1c_percent<6.5
	recode cat_hba1c_percent .=3 if hba1c_percent>=6.5 & hba1c_percent!=.
	recode cat_hba1c_percent .=4
}
capture replace cat_hba1c=cat_hba1c_percent if date_hba1c_percent>date_hba1c & date_hba1c_percent!=. & cat_hba1c_percent<4
label define cat_hba1clab 1 "Normal" 2 "Prediabetes" 3 "Diabetes" 4 "Unknown"
capture label values cat_hba1c cat_hba1clab
capture drop hba1c* cat_hba1c_percent date_hba1c*


**// OUTCOMES
**///////////////

**// Cardiovascular/Cerebrovascular

**// Stroke - Thrombotic/Ischaemic
gen  date_stroke_thrombotic=min(date_stroke_thrombotic_gp, date_stroke_thrombotic_hospital, date_stroke_thrombotic_ons)
drop date_stroke_thrombotic_*
**// Stroke - Haemorrhagic
gen  date_stroke_haemorrhagic=min(date_stroke_haemorr_gp, date_stroke_haemorr_hospital, date_stroke_haemorr_ons)
drop date_stroke_haemorr_*
**// Stroke - TIA
gen  date_stroke_tia=min(date_stroke_tia_gp, date_stroke_tia_hospital, date_stroke_tia_ons)
drop date_stroke_tia_*
**// Stroke - In pregnancy or puerperium
gen  date_stroke_pregnancy=min(date_stroke_pregnancy_gp, date_stroke_pregnancy_hospital, date_stroke_pregnancy_ons)
drop date_stroke_pregnancy_*
**// Stroke - Any
gen  date_stroke_any=min(date_stroke_thrombotic, date_stroke_haemorrhagic, date_stroke_tia, date_stroke_pregnancy)

**// Myocardial Infarction (MI)
gen  date_mi=min(date_mi_gp, date_mi_hospital, date_mi_ons)
drop date_mi_*

**// Deep Vein Thrombosis (DVT) - Non-pregnancy-related
gen  date_dvt_nopregnancy=min(date_dvt_nopregnancy_gp, date_dvt_nopregnancy_hospital, date_dvt_nopregnancy_ons)
drop date_dvt_nopregnancy_gp date_dvt_nopregnancy_hospital date_dvt_nopregnancy_ons
**// Deep Vein Thrombosis (DVT) - In pregnancy or puerperium
gen  date_dvt_pregnancy=min(date_dvt_pregnancy_gp, date_dvt_pregnancy_hospital, date_dvt_pregnancy_ons)
drop date_dvt_pregnancy_gp date_dvt_pregnancy_hospital date_dvt_pregnancy_ons
**// Deep Vein Thrombosis (DVT) - Cerebral venous thrombosis in pregnancy
gen  date_dvt_pregnancy_cvt=min(date_dvt_pregnancy_cvt_gp, date_dvt_pregnancy_cvt_hospital, date_dvt_pregnancy_cvt_ons)
drop date_dvt_pregnancy_cvt_gp date_dvt_pregnancy_cvt_hospital date_dvt_pregnancy_cvt_ons
**// Deep Vein Thrombosis (DVT) - Any
gen  date_dvt_any=min(date_dvt_nopregnancy, date_dvt_pregnancy, date_dvt_pregnancy_cvt)

**// Pulmonary Embolism (PE) - Non-pregnancy-related
gen  date_pe_nopregnancy=min(date_pe_nopregnancy_gp, date_pe_nopregnancy_hospital, date_pe_nopregnancy_ons)
drop date_pe_nopregnancy_gp date_pe_nopregnancy_hospital date_pe_nopregnancy_ons
**// Pulmonary Embolism (PE) - In pregnancy or puerperium
gen  date_pe_pregnancy=min(date_pe_pregnancy_gp, date_pe_pregnancy_hospital, date_pe_pregnancy_ons)
drop date_pe_pregnancy_gp date_pe_pregnancy_hospital date_pe_pregnancy_ons
**// Pulmonary Embolism (PE) - Any
gen  date_pe_any=min(date_pe_nopregnancy, date_pe_pregnancy)

**// Heart Failure
gen  date_hf=min(date_hf_gp, date_hf_hospital, date_hf_ons)
drop date_hf_*

**// Any Cardiovascular/Cerebrovascular (non-pregnancy-related)
gen date_any_cvd=min(date_stroke_any, date_mi, date_dvt_any, date_pe_any, date_hf)

**// Renal

**// Acute Kidney Injury (AKI) - Non-pregnancy-related
gen  date_aki_nopregnancy=min(date_aki_nopregnancy_gp, date_aki_nopregnancy_hospital, date_aki_nopregnancy_ons)
drop date_aki_nopregnancy_gp date_aki_nopregnancy_hospital date_aki_nopregnancy_ons
**// Acute Kidney Injury (AKI) - In pregnancy or puerperium
gen  date_aki_pregnancy=min(date_aki_pregnancy_gp, date_aki_pregnancy_hospital, date_aki_pregnancy_ons)
drop date_aki_pregnancy_gp date_aki_pregnancy_hospital date_aki_pregnancy_ons
**// Acute Kidney Injury (AKI) - Any
gen  date_aki_any=min(date_aki_nopregnancy, date_aki_pregnancy)

**// Hepatic

**// Liver disease/failure
gen  date_liver=min(date_liver_gp, date_liver_hospital, date_liver_ons)
drop date_liver_*

**// Mental Illness

**// Anxiety
gen  date_anxiety=min(date_anxiety_gp, date_anxiety_hospital, date_anxiety_ons)
drop date_anxiety_*

**// Depression
gen  date_depression=min(date_depression_gp, date_depression_hospital, date_depression_ons)
drop date_depression_*

**// Psychosis
gen  date_psychosis=min(date_psychosis_gp, date_psychosis_hospital, date_psychosis_ons)
drop date_psychosis_*

**// Psychotropic medication (written into the cohort derivation)
**// Antidepressants
**// Anxiolytics
**// Antipsychotics
**// Mood stabilisers

order date_antidepressant date_anxiolytic date_antipsychotic date_mood_stabiliser, after(date_psychosis)

**// Symptoms of post-COVID syndrome outcome

**// Insomnia
gen  date_sleep_insomnia=min(date_sleep_insomnia_gp, date_sleep_insomnia_hospital, date_sleep_insomnia_ons)
drop date_sleep_insomnia_*

**// Hypersomnia
gen  date_sleep_hypersomnia=min(date_sleep_hypersomnia_gp, date_sleep_hypersomnia_hospital, date_sleep_hypersomnia_ons)
drop date_sleep_hypersomnia_*

**// Sleep apnoea
gen  date_sleep_apnoea=min(date_sleep_apnoea_gp, date_sleep_apnoea_hospital, date_sleep_apnoea_ons)
drop date_sleep_apnoea_*

**// Fatigue
gen  date_fatigue=min(date_fatigue_gp, date_fatigue_hospital, date_fatigue_ons)
drop date_fatigue_*

format date_* %td

save $outdir/input_part1_clean.dta, replace
