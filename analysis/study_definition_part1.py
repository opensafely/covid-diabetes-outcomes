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
           date_discharged_covid
        OR date_discharged_pneum
        """,    
    ),
    date_discharged_covid=patients.admitted_to_hospital(	
	    with_these_diagnoses=covid_codelist,
	    on_or_after="2020-02-01",
	    find_first_match_in_period=True,
	    returning="date_discharged",
	    date_format="YYYY-MM-DD",
	    return_expectations={"date": {"earliest": "2020-02-01"}, "incidence": 0.5},
    ),
    date_discharged_pneum=patients.admitted_to_hospital(	
	    with_these_diagnoses=pneumonia_codelist,
	    on_or_after="2019-02-01",
	    find_first_match_in_period=True,
	    returning="date_discharged",
	    date_format="YYYY-MM-DD",
	    return_expectations={"date": {"earliest": "2018-02-01"}, "incidence": 0.5},
    ),
    date_patient_index=patients.admitted_to_hospital(
        with_these_diagnoses=combine_codelists(covid_codelist, pneumonia_codelist),
	    on_or_after="2019-02-01",
	    find_first_match_in_period=True,
	    returning="date_discharged",
	    date_format="YYYY-MM-DD",
	    return_expectations={"date": {"earliest": "2018-02-01"}, "incidence": 1},
    ),
    has_follow_up=patients.registered_with_one_practice_between("date_patient_index - 1 year", "date_patient_index"),
    **study_variables
)
