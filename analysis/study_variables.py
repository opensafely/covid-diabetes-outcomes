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
        ethnicity_clinical=patients.with_these_clinical_events(
	        ethnicity_codes,	
	        returning="category",
	        find_last_match_in_period=True,
	        on_or_before="today",
	        return_expectations={
		        "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
		        "incidence": 0.8,
	        },
        ),
        ethnicity_sus=patients.with_ethnicity_from_sus(
            returning="group_6",
            use_most_frequent_code=True,
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
        ### OUTCOMES
        ## CVD outcome (stroke, MI, DVT, PE, HF)
        # stroke
        stroke_gp=patients.with_these_clinical_events(
            stroke_codes,
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            on_or_after=f"{index_date_variable}",
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        stroke_hospital=patients.admitted_to_hospital(
            returning="date_admitted",
            with_these_diagnoses=stroke_codes_hospital,
            on_or_after=f"{index_date_variable}",
            date_format="YYYY-MM-DD",
            find_first_match_in_period=True,
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        stroke_ons=patients.with_these_codes_on_death_certificate(
            stroke_codes_hospital,
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            match_only_underlying_cause=False,
            on_or_after=f"{index_date_variable}",
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        stroke_outcome=patients.satisfying(
            "stroke_gp OR stroke_hospital OR stroke_ons"
        ),
        stroke_outcome_date=patients.minimum_of(
            "stroke_gp", "stroke_hospital", "stroke_ons"
        ),  
        # MI
        mi_gp=patients.with_these_clinical_events(
            mi_codes,
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            on_or_after=f"{index_date_variable}",
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        mi_hospital=patients.admitted_to_hospital(
            returning="date_admitted",
            with_these_diagnoses=mi_codes_hospital,
            on_or_after=f"{index_date_variable}",
            date_format="YYYY-MM-DD",
            find_first_match_in_period=True,
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        mi_ons=patients.with_these_codes_on_death_certificate(
            mi_codes_hospital,
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            match_only_underlying_cause=False,
            on_or_after=f"{index_date_variable}",
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        mi_outcome=patients.satisfying(
            "mi_gp OR mi_hospital OR mi_ons"
        ),
        mi_outcome_date=patients.minimum_of(
            "mi_gp", "mi_hospital", "mi_ons"
        ),       
        # DVT
        dvt_gp=patients.with_these_clinical_events(
            dvt_codes,
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            on_or_after=f"{index_date_variable}",
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        dvt_hospital=patients.admitted_to_hospital(
            returning="date_admitted",
            with_these_diagnoses=dvt_codes_hospital,
            on_or_after=f"{index_date_variable}",
            date_format="YYYY-MM-DD",
            find_first_match_in_period=True,
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        dvt_ons=patients.with_these_codes_on_death_certificate(
            dvt_codes_hospital,
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            match_only_underlying_cause=False,
            on_or_after=f"{index_date_variable}",
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        dvt_outcome=patients.satisfying(
            "dvt_gp OR dvt_hospital OR dvt_ons"
        ),
        dvt_outcome_date=patients.minimum_of(
            "dvt_gp", "dvt_hospital", "dvt_ons"
        ),
        # PE
        pe_gp=patients.with_these_clinical_events(
            pe_codes,
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            on_or_after=f"{index_date_variable}",
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        pe_hospital=patients.admitted_to_hospital(
            returning="date_admitted",
            with_these_diagnoses=pe_codes_hospital,
            on_or_after=f"{index_date_variable}",
            date_format="YYYY-MM-DD",
            find_first_match_in_period=True,
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        pe_ons=patients.with_these_codes_on_death_certificate(
            pe_codes_hospital,
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            match_only_underlying_cause=False,
            on_or_after=f"{index_date_variable}",
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        pe_outcome=patients.satisfying(
            "pe_gp OR pe_hospital OR pe_ons"
        ),
        pe_outcome_date=patients.minimum_of(
            "pe_gp", "pe_hospital", "pe_ons"
        ),
        # HF
        hf_gp=patients.with_these_clinical_events(
            hf_codes,
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            on_or_after=f"{index_date_variable}",
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        hf_hospital=patients.admitted_to_hospital(
            returning="date_admitted",
            with_these_diagnoses=hf_codes_hospital,
            on_or_after=f"{index_date_variable}",
            date_format="YYYY-MM-DD",
            find_first_match_in_period=True,
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        hf_ons=patients.with_these_codes_on_death_certificate(
            hf_codes_hospital,
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            match_only_underlying_cause=False,
            on_or_after=f"{index_date_variable}",
            return_expectations={"date": {"earliest": "date_patient_index"}},
        ),
        hf_outcome=patients.satisfying(
            "hf_gp OR hf_hospital OR hf_ons"
        ),
        hf_outcome_date=patients.minimum_of(
            "hf_gp", "hf_hospital", "hf_ons"
        ),
        # Composite measure
        composite_cvd_outcome=patients.satisfying(
            "stroke_outcome OR mi_outcome OR dvt_outcome OR pe_outcome OR hf_outcome"
        ),
        composite_cvd_outcome_date=patients.minimum_of(
            "stroke_outcome_date", "mi_outcome_date", "dvt_outcome_date", "pe_outcome_date", "hf_outcome_date"
        ),  
        ## Pneumonia outcome

        ## Renal outcome

        ## Hepatic outcome

        ## Mental Illness

        ## Symptoms of post-covid syndrome outcome

        ## COVARIATES
        # Smoking
        smoking_status=patients.categorised_as(
            {
                "S": "most_recent_smoking_code = 'S'",
                "E": """
                    most_recent_smoking_code = 'E' OR (
                    most_recent_smoking_code = 'N' AND ever_smoked
                    )
                """,
                "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
                "M": "DEFAULT",
            },
            return_expectations={
                "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
            },
            most_recent_smoking_code=patients.with_these_clinical_events(
                clear_smoking_codes,
                find_last_match_in_period=True,
                on_or_before=f"{index_date_variable} - 1 days",
                returning="category",
            ),
            ever_smoked=patients.with_these_clinical_events(
                filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
                on_or_before=f"{index_date_variable} - 1 days",
            ),
        ),
        smoking_status_date=patients.with_these_clinical_events(
            clear_smoking_codes,
            on_or_before=f"{index_date_variable} - 1 days",
            return_last_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={
            "incidence": 0.95,
            },
        ),
        # Hazardous alcohol behaviour in the previous year
        haz_alcohol_lastyear=patients.with_these_clinical_events(
            hazardous_alcohol_codes,
            between=[
                f"{index_date_variable} - 1 year",
                f"{index_date_variable} - 1 days",
            ],
        ),        
        # HbA1c
        hba1c_mmol_per_mol=patients.with_these_clinical_events(
            hba1c_new_codes,
            find_last_match_in_period=True,
            on_or_before=f"{index_date_variable} - 1 days",
            returning="numeric_value",
            include_date_of_match=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
                "incidence": 0.95,
            },
        ),
        hba1c_percentage=patients.with_these_clinical_events(
            hba1c_old_codes,
            find_last_match_in_period=True,
            on_or_before=f"{index_date_variable} - 1 days",
            returning="numeric_value",
            include_date_of_match=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "float": {"distribution": "normal", "mean": 5, "stddev": 2},
                "incidence": 0.95,
            },
        ),
        # BMI - continuous variable
        bmi=patients.most_recent_bmi(
            on_or_before=f"{index_date_variable} - 1 days",
            minimum_age_at_measurement=16,
            include_measurement_date=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "date": {},
                "float": {"distribution": "normal", "mean": 35, "stddev": 10},
                "incidence": 0.95,
            },
        ),  
        # Alternative BMI - categorised 
        bmi=patients.categorised_as(
            {
                "Not obese": "DEFAULT",
                "Obese I (30-34.9)": """ bmi_value >= 30 AND bmi_value < 35""",
                "Obese II (35-39.9)": """ bmi_value >= 35 AND bmi_value < 40""",
                "Obese III (40+)": """ bmi_value >= 40 AND bmi_value < 100""",
                    set maximum to avoid any impossibly extreme values being classified as obese
            },
            bmi_value=patients.most_recent_bmi(
                on_or_before=f"{index_date_variable} - 1 days", 
                minimum_age_at_measurement=16
            ),
            return_expectations={
                "rate": "universal",
                "category": {
                    "ratios": {
                        "Not obese": 0.7,
                        "Obese I (30-34.9)": 0.1,
                        "Obese II (35-39.9)": 0.1,
                        "Obese III (40+)": 0.1,
                    }
                },
            },
        ),
        # History of CVD
        hist_cvd=patients.satisfying(
            "cvd OR cvd_opcs",
            cvd=patients.with_these_clinical_events(
                hist_cvd_codes, on_or_before=f"{index_date_variable} - 1 days",
            ),
            cvd_opcs=patients.admitted_to_hospital(
                with_these_procedures=hist_cvd_codes_OPCS4_2, on_or_before=f"{index_date_variable} - 1 days",
            ),           
        ),        
        # History of renal disease (creatinine measurement, RRT-dialysis/transplant, CKD stage codes?-no CTV3 codes, SNOMED available)
        creatinine=patients.with_these_clinical_events(
            creatinine_codes,
            find_last_match_in_period=True,
            on_or_before=f"{index_date_variable} - 1 days",
            returning="numeric_value",
            include_date_of_match=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "float": {"distribution": "normal", "mean": 60.0, "stddev": 15},
                "incidence": 0.95,
            },
        ),
        hist_renal=patients.satisfying(
            "ckd_hospital OR hist_rrt",
            ckd_hospital=patients.admitted_to_hospital(
                with_these_diagnoses=ckd3_5_codes_hospital, on_or_before=f"{index_date_variable} - 1 days",
            ),
            hist_rrt=patients.with_these_clinical_events(
                rrt_codes, on_or_before=f"{index_date_variable} - 1 days",
            ),
        ),
    )
    return study_variables
