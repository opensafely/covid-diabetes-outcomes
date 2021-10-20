from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_study_variables(index_date_variable):
    study_variables = dict(
        dob=patients.date_of_birth(
            "YYYY-MM",
            return_expectations={
                "date": {"earliest": "1950-01-01", "latest": "today"},
            },
        ),
        sex=patients.sex(
            return_expectations={
                "rate": "universal",
                "category": {"ratios": {"M": 0.49, "F": 0.51}},
            },
        ),
        practice_id=patients.registered_practice_as_of(
            f"{index_date_variable}",
            returning="pseudo_id",
            return_expectations={
                "int": {"distribution": "normal", "mean": 1000, "stddev": 100},
                "incidence": 1,
            },
        ),
        region=patients.registered_practice_as_of(
            f"{index_date_variable}",
            returning="nuts1_region_name",
            return_expectations={
                "rate": "universal",
                "category": {
                    "ratios": {
                        "North East": 0.1,
                        "North West": 0.1,
                        "Yorkshire and The Humber": 0.1,
                        "East Midlands": 0.1,
                        "West Midlands": 0.1,
                        "East": 0.1,
                        "London": 0.2,
                        "South East": 0.1,
                        "South West": 0.1,
                    },
                },
            },
        ),
        # Diabetes
        # Date of first (any diabetes diagnosis) in primary care
        diabetes_diagnosis=patients.with_these_clinical_events(
            combine_codelists(
                diabetes_t1_codes, diabetes_t2_codes, diabetes_unknown_codes
            ),
            on_or_before="today",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"incidence": 0.05},
        ),

        # For stratifying on type of diabetes (at discharge)
        # And for identifying 'new onset' diabetes 
        t1dm_gp_first=patients.with_these_clinical_events(
            diabetes_t1_codes,
            on_or_before=f"{index_date_variable} + 30 days",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.01
            },
        ),
        t1dm_gp_last=patients.with_these_clinical_events(
            diabetes_t1_codes,
            on_or_before=f"{index_date_variable} + 30 days",
            return_last_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.01
            },
        ),
        t2dm_gp_first=patients.with_these_clinical_events(
            diabetes_t2_codes,
            on_or_before=f"{index_date_variable} + 30 days",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.01
            },
        ),
        t2dm_gp_last=patients.with_these_clinical_events(
            diabetes_t2_codes,
            on_or_before=f"{index_date_variable} + 30 days",
            return_last_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.01
            },
        ),
        unknown_diabetes_gp_first=patients.with_these_clinical_events(
            diabetes_unknown_codes,
            on_or_before=f"{index_date_variable} + 30 days",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.01
            },
        ),
        unknown_diabetes_gp_last=patients.with_these_clinical_events(
            diabetes_unknown_codes,
            on_or_before=f"{index_date_variable} + 30 days",
            return_last_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.01
            },
        ),
        
        #### covid_diagnosis=
        
        #### pneum_diagnosis=

        deregistered=patients.date_deregistered_from_all_supported_practices(
            date_format="YYYY-MM-DD"
        ),
        dod=patients.died_from_any_cause(
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2020-02-01"},
                "incidence": 0.1,
            },
        ),
    )
    return study_variables
