from cohortextractor import codelist, codelist_from_csv

### EXPOSURE CLASSIFICATION

# Diabetes
diabetes_t1_codes = codelist_from_csv(
   "codelists/opensafely-type-1-diabetes.csv", system="ctv3", column="CTV3ID"
)
diabetes_t2_codes = codelist_from_csv(
    "codelists/opensafely-type-2-diabetes.csv", system="ctv3", column="CTV3ID"
)
diabetes_unknown_codes = codelist_from_csv(
    "codelists/opensafely-diabetes-unknown-type.csv", system="ctv3", column="CTV3ID"
)
diabetes_t1_codes_hospital = codelist_from_csv(
    "codelists/opensafely-type-1-diabetes-secondary-care.csv", system="icd10", column="icd10_code"
)
diabetes_t2_codes_hospital = codelist(
    ["E11", "E110", "E112", "E113", "E114", "E115", "E116", "E118", "E119"],
    system="icd10",
)
# Diabetes medications
antidiabetic_codes = codelist_from_csv(
    "codelists/opensafely-antidiabetic-drugs.csv", system="snomed", column="id"
)
insulin_codes = codelist_from_csv(
    "codelists/opensafely-insulin-medication.csv", system="snomed", column="id"
)

# COVID
covid_codelist = codelist_from_csv(
    "codelists/opensafely-covid-identification.csv", system="icd10", column="icd10_code"
)

# Pneumonia (secondary care only)
pneumonia_codelist = codelist_from_csv(
    "codelists/opensafely-pneumonia-secondary-care.csv", system="icd10", column="ICD code"
)


### BASELINE FACTORS

# Ethnicity (as recorded in primary care)
ethnicity_codes = codelist_from_csv(
	"codelists/opensafely-ethnicity.csv", system="ctv3", column="Code", category_column="Grouping_6"
)

# Smoking
smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv", system="ctv3", column="CTV3Code", category_column="Category"
)
smoking_unclear_codes = codelist_from_csv(
    "codelists/opensafely-smoking-unclear.csv", system="ctv3", column="CTV3Code", category_column="Category"
)
        # /* Current smoker - most recent smoking code is S
        #    Ex-smoker - (most recent code is E) OR (most recent code is N AND an S or E code at any point)
        #    Never smoker - most recent code is N AND doesn't have any S or E codes at any point
        #    Missing - no S, E or N smoking codes on record */

# Hazardous alcohol intake
hazardous_alcohol_codes = codelist_from_csv(
    "codelists/opensafely-hazardous-alcohol-drinking.csv", system="ctv3", column="code"
)

# HbA1c
hba1c_new_codes = codelist(["XaPbt", "Xaeze", "Xaezd"], system="ctv3")
hba1c_old_codes = codelist(["X772q", "XaERo", "XaERp"], system="ctv3")

# History of CVD
hist_cvd_codes = codelist_from_csv(
    "codelists/opensafely-chronic-cardiac-disease.csv", system="ctv3", column="CTV3ID"
)
hist_cvd_codes_OPCS4_2 = codelist_from_csv(
    "local_codelists/uom-revascularisation-opcs4.csv", system="opcs4", column="Code"
)

# History of renal disease (creatinine codes, RRT codes, CKD stage codes?-can't find CTV3 codes, SNOMED available)
creatinine_codes = codelist(["XE2q5"], system="ctv3")
ckd3_5_codes = codelist_from_csv("local_codelists/uom-ckd-ctv3.csv", system="ctv3", column="CTV3ID")
ckd3_5_codes_hospital = codelist(["N183", "N184", "N185"], system="icd10")
rrt_codes = codelist_from_csv("codelists/opensafely-renal-replacement-therapy.csv", system="ctv3", column="CTV3ID")


### OUTCOMES

## Cardiovascular

# Stroke
# >>> Original list 'opensafely-stroke-updated.csv' replaced,
# >>> Original list 'opensafely-incident-non-traumatic-stroke.csv' replaced,
# >>> Original list 'opensafely-stroke-secondary-care.csv' replaced:
stroke_any_incl_history_codes = codelist_from_csv(
    "local_codelists/uom-stroke-any-incl-history-ctv3.csv", system="ctv3", column="CTV3ID"
)
stroke_any_incl_history_codes_hospital = codelist_from_csv(
    "local_codelists/uom-stroke-any-incl-history-icd10.csv", system="icd10", column="icd"
)
stroke_thrombotic_codes = codelist_from_csv(
    "local_codelists/uom-stroke-thrombotic-ctv3.csv", system="ctv3", column="CTV3ID"
)
stroke_thrombotic_codes_hospital = codelist_from_csv(
    "local_codelists/uom-stroke-thrombotic-icd10.csv", system="icd10", column="icd"
)
stroke_haemorrhagic_codes = codelist_from_csv(
    "local_codelists/uom-stroke-haemorrhagic-ctv3.csv", system="ctv3", column="CTV3ID"
)
stroke_haemorrhagic_codes_hospital = codelist_from_csv(
    "local_codelists/uom-stroke-haemorrhagic-icd10.csv", system="icd10", column="icd"
)
stroke_tia_codes = codelist_from_csv(
    "local_codelists/uom-stroke-tia-ctv3.csv", system="ctv3", column="CTV3ID"
)
stroke_tia_codes_hospital = codelist_from_csv(
    "local_codelists/uom-stroke-tia-icd10.csv", system="icd10", column="icd"
)
stroke_pregnancy_codes = codelist_from_csv(
    "local_codelists/uom-stroke-pregnancy-ctv3.csv", system="ctv3", column="CTV3ID"
)
stroke_pregnancy_codes_hospital = codelist_from_csv(
    "local_codelists/uom-stroke-pregnancy-icd10.csv", system="icd10", column="icd"
)

# Myocardial Infarction (MI)
# >>> Original list 'opensafely-myocardial-infarction-2.csv' replaced:
mi_codes = codelist_from_csv(
    "local_codelists/uom-mi-ctv3.csv", system="ctv3", column="CTV3ID"
)
# >>> Original list replaced:
mi_codes_hospital = codelist_from_csv(
    "local_codelists/uom-mi-icd10.csv", system="icd10", column="icd"
)

# Deep Vein Thrombosis (DVT)
# >>> Original lists replaced:
dvt_codes = codelist_from_csv(
    "local_codelists/uom-dvt-ctv3.csv", system="ctv3", column="CTV3ID"
)
dvt_pregnancy_codes = codelist_from_csv(
    "local_codelists/uom-dvt-pregnancy-ctv3.csv", system="ctv3", column="CTV3ID"
)
dvt_pregnancy_cvt_codes = codelist_from_csv(
    "local_codelists/uom-dvt-pregnancy-cvt-ctv3.csv", system="ctv3", column="CTV3ID"
)
dvt_codes_hospital = codelist_from_csv(
    "local_codelists/uom-dvt-icd10.csv", system="icd10", column="icd"
)
dvt_pregnancy_codes_hospital = codelist_from_csv(
    "local_codelists/uom-dvt-pregnancy-icd10.csv", system="icd10", column="icd"
)
dvt_pregnancy_cvt_codes_hospital = codelist_from_csv(
    "local_codelists/uom-dvt-pregnancy-cvt-icd10.csv", system="icd10", column="icd"
)

# Pulmonary Embolism (PE)
# >>> Original lists replaced:
pe_codes = codelist_from_csv(
    "local_codelists/uom-pe-ctv3.csv", system="ctv3", column="CTV3ID"
)
pe_pregnancy_codes = codelist_from_csv(
    "local_codelists/uom-pe-pregnancy-ctv3.csv", system="ctv3", column="CTV3ID"
)
pe_codes_hospital = codelist_from_csv(
    "local_codelists/uom-pe-icd10.csv", system="icd10", column="icd"
)
pe_pregnancy_codes_hospital = codelist_from_csv(
    "local_codelists/uom-pe-pregnancy-icd10.csv", system="icd10", column="icd"
)

# Heart Failure (HF)
# >>> Original lists replaced:
hf_codes = codelist_from_csv(
    "local_codelists/uom-hf-ctv3.csv", system="ctv3", column="CTV3ID"
)
hf_codes_hospital = codelist_from_csv(
    "local_codelists/uom-hf-icd10.csv", system="icd10", column="icd"
)

## Renal 

# Acute Kidney Injury (AKI)
# >>> Original lists replaced:
aki_codes = codelist_from_csv(
    "local_codelists/uom-aki-ctv3.csv", system="ctv3", column="CTV3ID"
)
aki_pregnancy_codes = codelist_from_csv(
    "local_codelists/uom-aki-pregnancy-ctv3.csv", system="ctv3", column="CTV3ID"
)
aki_codes_hospital = codelist_from_csv(
    "local_codelists/uom-aki-icd10.csv", system="icd10", column="icd"
)
aki_pregnancy_codes_hospital = codelist_from_csv(
    "local_codelists/uom-aki-pregnancy-icd10.csv", system="icd10", column="icd"
)

## Hepatic

# Liver disease/failure
liver_codes = codelist_from_csv(
    "local_codelists/uom-liver-ctv3.csv", system="ctv3", column="CTV3ID"
)
liver_codes_hospital = codelist_from_csv(
    "local_codelists/uom-liver-icd10.csv", system="icd10", column="icd"
)

## Mental illness

# Anxiety
anxiety_codes = codelist_from_csv(
    "local_codelists/uom-anxiety-ctv3.csv", system="ctv3", column="CTV3ID"
)
anxiety_codes_hospital = codelist_from_csv(
    "local_codelists/uom-anxiety-icd10.csv", system="icd10", column="icd"
)

# Depression
depression_codes = codelist_from_csv(
    "local_codelists/uom-depression-ctv3.csv", system="ctv3", column="CTV3ID"
)
depression_codes_hospital = codelist_from_csv(
    "local_codelists/uom-depression-icd10.csv", system="icd10", column="icd"
)

# Affective/non-affective psychosis
psychosis_codes = codelist_from_csv(
    "local_codelists/uom-psychosis-ctv3.csv", system="ctv3", column="CTV3ID"
)
psychosis_codes_hospital = codelist_from_csv(
    "local_codelists/uom-psychosis-icd10.csv", system="icd10", column="icd"
)

# Psychotropic medications
# Antidepressants
antidepressant_codes = codelist_from_csv(
    "local_codelists/uom-antidepressants-snomed.csv", system="snomed", column="SNOMEDID"
)
# Anxiolytics
anxiolytic_codes = codelist_from_csv(
    "local_codelists/uom-anxiolytics-snomed.csv", system="snomed", column="SNOMEDID"
)
# Antipsychotics
antipsychotic_codes = codelist_from_csv(
    "local_codelists/uom-antipsychotics-snomed.csv", system="snomed", column="SNOMEDID"
)
# Mood stabilisers
mood_stabiliser_codes = codelist_from_csv(
    "local_codelists/uom-mood-stabilisers-snomed.csv", system="snomed", column="SNOMEDID"
)

## Symptoms of post-COVID syndrome outcome

# Insomnia
sleep_insomnia_codes = codelist_from_csv(
    "local_codelists/uom-sleep-insomnia-ctv3.csv", system="ctv3", column="CTV3ID"
)
sleep_insomnia_codes_hospital = codelist_from_csv(
    "local_codelists/uom-sleep-insomnia-icd10.csv", system="icd10", column="icd"
)
# Hypersomnia
sleep_hypersomnia_codes = codelist_from_csv(
    "local_codelists/uom-sleep-hypersomnia-ctv3.csv", system="ctv3", column="CTV3ID"
)
sleep_hypersomnia_codes_hospital = codelist_from_csv(
    "local_codelists/uom-sleep-hypersomnia-icd10.csv", system="icd10", column="icd"
)
# Sleep apnoea
sleep_apnoea_codes = codelist_from_csv(
    "local_codelists/uom-sleep-apnoea-ctv3.csv", system="ctv3", column="CTV3ID"
)
sleep_apnoea_codes_hospital = codelist_from_csv(
    "local_codelists/uom-sleep-apnoea-icd10.csv", system="icd10", column="icd"
)
# Fatigue
fatigue_codes = codelist_from_csv(
    "local_codelists/uom-fatigue-ctv3.csv", system="ctv3", column="CTV3ID"
)
fatigue_codes_hospital = codelist_from_csv(
    "local_codelists/uom-fatigue-icd10.csv", system="icd10", column="icd"
)
