from cohortextractor import codelist, codelist_from_csv

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
