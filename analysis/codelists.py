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
    "codelists/opensafely-type-1-diabetes-secondary-care.csv",
    system="icd10",
    column="icd10_code",
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
    "codelists/opensafely-covid-identification.csv",
    system="icd10",
    column="icd10_code",
)

# Pneumonia (secondary care only)
pneumonia_codelist = codelist_from_csv(
    "codelists/opensafely-pneumonia-secondary-care.csv",
    system="icd10",
    column="ICD code",
)


### BASELINE FACTORS

# Ethnicity (as recorded in primary care)
ethnicity_codes = codelist_from_csv(
	"codelists/opensafely-ethnicity.csv",
	system="ctv3",
	column="Code",
	category_column="Grouping_6",
)

# Smoking
smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv", 
    system="ctv3", 
    column="CTV3Code", 
    category_column="Category",
)
smoking_unclear_codes = codelist_from_csv(
    "codelists/opensafely-smoking-unclear.csv", 
    system="ctv3", 
    column="CTV3Code", 
    category_column="Category",
)
        # /* Current smoker - most recent smoking code is S
        #    Ex-smoker - (most recent code is E) OR (most recent code is N AND an S or E code at any point)
        #    Never smoker - most recent code is N AND doesn't have any S or E codes at any point
        #    Missing - no S, E or N smoking codes on record */

# Hazardous alcohol intake
hazardous_alcohol_codes = codelist_from_csv(
    "codelists/opensafely-hazardous-alcohol-drinking.csv", 
    system="ctv3", 
    column="code",
)

# HbA1c
hba1c_new_codes = codelist(["XaPbt", "Xaeze", "Xaezd"], system="ctv3")
hba1c_old_codes = codelist(["X772q", "XaERo", "XaERp"], system="ctv3")

# History of CVD
hist_cvd_codes = codelist_from_csv(
    "codelists/opensafely-chronic-cardiac-disease.csv",
    system="ctv3",
    column="CTV3ID",
)
# The following list (opensafely-cardiac-surgery-opcs-4-codes.csv) not currently available:
#hist_cvd_codes_OPCS4 = codelist_from_csv(
    #"codelists/opensafely-cardiac-surgery-opcs-4-codes.csv",
    #system="opcs4",
    #column="Code",
#)
# Therefore, use our list
hist_cvd_codes_OPCS4_2 = codelist_from_csv(
    "local_codelists/uom-revascularisation.csv",
    system="opcs4",
    column="Code",
)

# History of renal disease (creatinine codes, RRT codes, CKD stage codes?-can't find CTV3 codes, SNOMED available)
creatinine_codes = codelist(["XE2q5"], system="ctv3")
ckd3_5_codes_hospital = codelist(["N183", "N184", "N185"], system="icd10")
rrt_codes = codelist_from_csv(
    "codelists/opensafely-renal-replacement-therapy.csv",
    system="ctv3",
    column="CTV3ID",
)


### OUTCOMES

## Cardiovascular

# Stroke
stroke_codes = codelist_from_csv(
    "codelists/opensafely-stroke-updated.csv",
    system="ctv3",
    column="CTV3ID",
)
stroke_codes_2 = codelist_from_csv(
    "codelists/opensafely-incident-non-traumatic-stroke.csv",
    system="ctv3",
    column="CTV3ID",
    category_column="type",
)
stroke_codes_hospital = codelist_from_csv(
    "codelists/opensafely-stroke-secondary-care.csv",
    system="icd10",
    column="icd",
    category_column="type",
)

# Myocardial Infarction (MI)
mi_codes = codelist_from_csv(
    "codelists/opensafely-myocardial-infarction-2.csv",
    system="ctv3",
    column="CTV3Code",
)
mi_codes_hospital = codelist(["I21", "I210", "I211", "I212", "I213", "I214", "I219", "I22", "I220", "I221", "I228", "I229", "I23", "I230", "I231", "I232", "I233", "I234", "I235", "I236", "I238"], system="icd10")

# Deep Vein Thrombosis (DVT)
dvt_codes = codelist(["G801.", "G80y.", "Xa6Yr", "X205e", "XE0VY", "G801z", "G801B", "XaJxo", "Xa9Bs", "XaQIV", "X205n", "X205m", "L417.", "G80y8", "Xa07G", "X76Lh", "Xacve", "XaZ43", "J4202", "XaDyD", "G8018", "G80y4", "G8019", "G80y6", "G8016", "G80y7", "G80y5", "G8017", "G801A", "Xacvd"], system="ctv3")
dvt_codes_hospital = codelist(["I80","I800", "I801", "I802", "I803", "I808", "I809", "I821"], system="icd10")

# Pulmonary Embolism (PE)
pe_codes = codelist(["X202y", "7A093", "X012b", "XE0Um", "X202x", "XaOYV", "X202z", "X012d"], system="ctv3")
pe_codes_hospital = codelist(["I26", "I260", "I269"], system="icd10")

# Heart Failure (HF)
hf_codes = codelist(["G1yz1", "G2101", "G2111", "G21z1", "G232.", "G234.", "G400.", "G41..", "G41y.", "G41yz", "G41z.", "G58..", "G580.", "G5800", "G5801", "G5802", "G5803", "G581.", "G5810", "G582.", "G58z.", "G5y4z", "H541z", "H584.", "H584z", "Q48y1", "SP111", "X102X", "X102Y", "X202k", "X202l", "X203E", "Xa0TT", "Xa0TU", "Xaacj", "Xaapw", "XaBLt", "XabM9", "XaEgY", "XafeB", "XaIIq", "XaIpn", "XaItG", "XaJ98", "XaJ99", "XaJ9G", "XaJ9H", "XaJ9I", "XaJ9J", "XaKNW", "XaO5n", "XaWyi", "XaXLu", "XaYYr", "XaYYs", "XaZih", "XE0V8", "XE0V9", "XE0WM", "XE0Wo", "XE1p9", "XE2QG", "XM1Qn"], system="ctv3")
hf_codes_hospital = codelist(["I50", "I500", "I501", "I509"], system="icd10")

## Renal 

# Acute Kidney Injury (AKI)
aki_codes = codelist(["J624.", "K034.", "K04..", "K040.", "K041.", "K04y.", "K04z.", "SP143", "X30Ip", "X30Ir", "X30Is", "X30Ix", "Xa85t", "Xaa8O", "Xaa8P", "Xaa8Q", "XaB3Y", "XaPwv", "XaZ6J", "XaZe5", "XaZPp", "XaZPs", "XaZPt", "XaZPu", "XaZSx", "XaZZ0", "XM08q", "XM199"], system="ctv3")
aki_codes_hospital = codelist(["N17", "N170", "N171", "N172", "N178", "N179"], system="icd10")

## Hepatic

# Liver failure
#liver_transplant_codes = codelist_from_csv(
    #"local_codelists/uom-liver-transplant.csv",
    #system="ctv3",
    #column="CTV3ID",
#)

# Chronic liver disease
#chronic_liver_dis_codes = codelist_from_csv(
    #"local_codelists/uom-liver-disease.csv",
    #system="ctv3",
    #column="CTV3ID",
#)

## Mental illness

# Anxiety 
# Need to update CTV3 list and add ICD-10 list
anxiety_codes = codelist(["X00Sc", "E200z", "E2000", "E2004", "E2002", "X00Sb", "X00RP", "XE1Y7", "XaMFU", "XE1YA", "E2005", "E2920", "Eu41y"], system="ctv3")

# Depression
# Need to update CTV3 list and add ICD-10 list
depression_codes = codelist_from_csv(
    "codelists/opensafely-depression.csv",
    system="ctv3",
    column="CTV3Code",
)

# Affective/non-affective psychosis
# Need to update CTV3 list and add ICD-10 list
psychosis_codes = codelist_from_csv(
    "codelists/opensafely-psychosis-schizophrenia-bipolar-affective-disease.csv",
    system="ctv3",
    column="CTV3Code",
)

# Psychotropic medications
# >>> Here

## Symptoms of post-COVID syndrome outcome
# >>> Here
