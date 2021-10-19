from cohortextractor import (
    StudyDefinition,
    patients,
    codelist,
    codelist_from_csv,
    combine_codelists,
)

from common_variables import generate_common_variables
from codelists import *

dummy_data_date = "2020-02-01"
common_variables = generate_common_variables(index_date_variable="patient_index_date")

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1980-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.7,
    },
    population=patients.satisfying(
        """
            has_follow_up
        AND (age >=18 AND age <= 110)
        AND (sex = "M" OR sex = "F")
        AND prior_diabetes
        AND exposure_hospitalisation
        """,      
    ),
    index_date="2020-02-01",
    patient_index_date=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codelist,
        on_or_after="index_date",
        find_first_match_in_period=True,
        returning="date_discharged",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "index_date"},
            "incidence": 1,
        },
    ),
    has_follow_up=patients.registered_with_one_practice_between(
        "patient_index_date - 1 year", "patient_index_date"
    ),
    prior_diabetes=patients.with_these_clinical_events(
        combine_codelists(
            diabetes_t1_codes, diabetes_t2_codes, diabetes_unknown_codes
        ),
        on_or_before="patient_index_date",
        return_first_date_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"incidence": 1},
    ),
    exposure_hospitalisation=patients.admitted_to_hospital(
        with_these_diagnoses=covid_codelist,
        on_or_after="index_date",
        find_first_match_in_period=True,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "index_date"}},
    ),
    date_icu_admission=patients.admitted_to_icu(
        on_or_after="index_date",
        find_first_match_in_period=True,
        returning="date_admitted",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "index_date"}},
    ),
    **common_variables
)
