from cohortextractor import (
    StudyDefinition,
    patients,
    codelist,
    codelist_from_csv,
    combine_codelists,
)

from study_variables import generate_study_variables
from codelists import *

dummy_data_date = "2020-02-01"
study_variables = generate_study_variables(index_date_variable="patient_index_date")

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.7,
    },
    population=patients.satisfying(
        """
           discharged_covid
        OR discharged_pneum
        """,    
    ),
    discharged_covid=patients.admitted_to_hospital(	
	    with_these_diagnoses=covid_codelist,
	    on_or_before="today",
	    find_first_match_in_period=True,
	    returning="date_discharged",
	    date_format="YYYY-MM-DD",
	    return_expectations={
            "date": {"latest": "today"},
		    "incidence": 0.5,
	    },
    ),
    discharged_pneum=patients.admitted_to_hospital(	
	    with_these_diagnoses=pneumonia_codelist,
	    on_or_before="today",
	    find_first_match_in_period=True,
	    returning="date_discharged",
	    date_format="YYYY-MM-DD",
	    return_expectations={
		    "date": {"latest": "today"},
		    "incidence": 0.5,
	    },
    ),
    patient_index_date=patients.admitted_to_hospital(
        with_these_diagnoses=combine_codelists(covid_codelist, pneumonia_codelist),
        on_or_before="today",
	    find_first_match_in_period=True,
	    returning="date_discharged",
	    date_format="YYYY-MM-DD",
	    return_expectations={
		    "date": {"latest": "today"},
		    "incidence": 0.5,
	    },
    ),
    **study_variables
)
