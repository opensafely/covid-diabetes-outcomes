from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_study_variables(index_date_variable):
    study_variables = dict(
        date_of_birth=patients.date_of_birth(
            "YYYY-MM",
            return_expectations={
                "date": {"earliest": "1911-01-01", "latest": "today"},
                "incidence": 1
            },
        ),
        sex=patients.sex(
            return_expectations={
                "rate": "universal",
                "category": {"ratios": {"M": 0.49, "F": 0.51}},
            },
        ),
        ethnicity=patients.with_these_clinical_events(
	        ethnicity_codes,	
	        returning="category",
	        find_last_match_in_period=True,
	        on_or_before="today",
	        return_expectations={
		        "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
		        "incidence": 0.8,
	        },
        ),
        practice_id=patients.registered_practice_as_of(
            f"{index_date_variable}",
            returning="pseudo_id",
            return_expectations={
                "int": {"distribution": "normal", "mean": 50, "stddev": 5},
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
        imd=patients.address_as_of(
            f"{index_date_variable}",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
            return_expectations={
                "rate": "universal",
                "category": {
                    "ratios": {
                        "100": 0.1,
                        "200": 0.1,
                        "300": 0.1,
                        "400": 0.1,
                        "500": 0.1,
                        "600": 0.1,
                        "700": 0.1,
                        "800": 0.1,
                        "900": 0.1,
                        "1000": 0.1,
                    }
                },
            },
        ),
        # Diabetes dates
        # Date of first (any diabetes diagnosis) in primary care
        date_diabetes_diagnosis=patients.with_these_clinical_events(
            combine_codelists(
                diabetes_t1_codes, diabetes_t2_codes, diabetes_unknown_codes
            ),
            on_or_before="today",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.05
            },
        ),
        # For stratifying on type of diabetes (at discharge) and identifying 'new onset' diabetes 
        date_t1dm_gp_first=patients.with_these_clinical_events(
            diabetes_t1_codes,
            on_or_before=f"{index_date_variable} + 30 days",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.0075
            },
        ),
        date_t1dm_gp_last=patients.with_these_clinical_events(
            diabetes_t1_codes,
            on_or_before=f"{index_date_variable} + 30 days",
            return_last_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.0075
            },
        ),
        date_t2dm_gp_first=patients.with_these_clinical_events(
            diabetes_t2_codes,
            on_or_before=f"{index_date_variable} + 30 days",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.0425
            },
        ),
        date_t2dm_gp_last=patients.with_these_clinical_events(
            diabetes_t2_codes,
            on_or_before=f"{index_date_variable} + 30 days",
            return_last_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.0425
            },
        ),
        date_unknown_diabetes_gp_first=patients.with_these_clinical_events(
            diabetes_unknown_codes,
            on_or_before=f"{index_date_variable} + 30 days",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.005
            },
        ),
        date_unknown_diabetes_gp_last=patients.with_these_clinical_events(
            diabetes_unknown_codes,
            on_or_before=f"{index_date_variable} + 30 days",
            return_last_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.005
            },
        ),
        date_t1dm_hospital_first=patients.admitted_to_hospital(
            with_these_diagnoses=diabetes_t1_codes_hospital,
            on_or_before=f"{index_date_variable}",
            find_first_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.005
            },
        ),
        date_t1dm_hospital_last=patients.admitted_to_hospital(
            with_these_diagnoses=diabetes_t1_codes_hospital,
            on_or_before=f"{index_date_variable}",
            find_last_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.005
            },
        ),
        date_t2dm_hospital_first=patients.admitted_to_hospital(
            with_these_diagnoses=diabetes_t2_codes_hospital,
            on_or_before=f"{index_date_variable}",
            find_first_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.02
            },
        ),
        date_t2dm_hospital_last=patients.admitted_to_hospital(
            with_these_diagnoses=diabetes_t2_codes_hospital,
            on_or_before=f"{index_date_variable}",
            find_last_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2015-01-01"},
                "incidence": 0.02
            },
        ),
        # COVID dates
        date_covid_test=patients.with_test_result_in_sgss(
	        pathogen="SARS-CoV-2",
	        test_result="positive",
	        find_first_match_in_period=True,
	        returning="date",
	        date_format="YYYY-MM-DD",
	        return_expectations={"date": {"earliest": "2020-02-01"}},
        ),
        date_covid_hospital=patients.admitted_to_hospital(
	        with_these_diagnoses=covid_codelist,
	        find_first_match_in_period=True,
	        returning="date_admitted",
	        date_format="YYYY-MM-DD",
	        return_expectations={"date": {"earliest": "2020-02-01"}},
        ),
        date_covid_icu=patients.admitted_to_icu(
	        find_first_match_in_period=True,
	        returning="date_admitted",
	        date_format="YYYY-MM-DD",
	        return_expectations={"date": {"earliest": "2020-02-01"}},
        ),
        # Censoring dates
        date_deregistered=patients.date_deregistered_from_all_supported_practices(
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2020-02-01"},
                "incidence": 0.05,
            },
        ),
        date_of_death=patients.died_from_any_cause(
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {"earliest": "2020-02-01"},
                "incidence": 0.1,
            },
        ),
    )
    return study_variables
