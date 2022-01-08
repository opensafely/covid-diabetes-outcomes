from cohortextractor import (
    StudyDefinition,
    patients,
    codelist,
    codelist_from_csv,
    combine_codelists,
)

from study_variables import generate_study_variables
from codelists import *

#dummy_data_date = "2020-02-01"
study_variables = generate_study_variables(index_date_variable="date_patient_index")

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.7,
    },
    population=patients.satisfying(
        """
            date_covid_test_1
        OR date_covid_hospital_1
        """,    
    ),
    date_covid_test_1=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-02-01"}},
    ),
    date_covid_hospital_1=patients.admitted_to_hospital(
	        with_these_diagnoses=covid_codelist,
	        find_first_match_in_period=True,
	        returning="date_admitted",
	        date_format="YYYY-MM-DD",
	        return_expectations={"date": {"earliest": "2020-02-01"}},
    ),
    date_patient_index=patients.minimum_of("date_covid_test_1", "date_covid_hospital_1"),
    has_follow_up_=patients.registered_with_one_practice_between("date_patient_index - 1 year", "date_patient_index"),
    **study_variables
)
