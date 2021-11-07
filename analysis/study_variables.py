from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from local_codelists import *
from datetime import datetime, timedelta

def generate_study_variables(index_date_variable):
    study_variables = dict(
        ### DEMOGRAPHICS
        date_birth=patients.date_of_birth(
            "YYYY-MM",
            return_expectations={"date": {"earliest": "1911-01-01", "latest": "today"}, "incidence": 1},
        ),
        sex=patients.sex(
            return_expectations={"rate": "universal", "category": {"ratios": {"M": 0.49, "F": 0.51}}},
        ),
        ethnicity_clinical=patients.with_these_clinical_events(
	        ethnicity_codes,	
	        returning="category",
	        find_last_match_in_period=True,
	        on_or_before="today",
	        return_expectations={"category": {"ratios": {"1": 0.8, "3": 0.1, "5": 0.1}}, "incidence": 0.8},
        ),
        ethnicity_sus=patients.with_ethnicity_from_sus(
            returning="group_6",
            use_most_frequent_code=True,
 	        return_expectations={"category": {"ratios": {"1": 0.8, "3": 0.1, "5": 0.1}}, "incidence": 0.8},
        ),
        practice_id=patients.registered_practice_as_of(
            f"{index_date_variable}",
            returning="pseudo_id",
            return_expectations={"int": {"distribution": "normal", "mean": 50, "stddev": 5}, "incidence": 1},
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
                    },
                },
                "incidence": 0.9
            },
        ),
        ### EXPOSURE
        ## Diabetes dates
        # Date of first (any diabetes diagnosis) in primary care
        date_diabetes_diagnosis=patients.with_these_clinical_events(
            combine_codelists(
                diabetes_t1_codes, diabetes_t2_codes, diabetes_unknown_codes
            ),
            on_or_before="today",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2015-01-01"}, "incidence": 0.05},
        ),
        # For stratifying on type of diabetes (at discharge) and identifying 'new onset' diabetes 
        date_t1dm_gp_first=patients.with_these_clinical_events(
            diabetes_t1_codes,
            on_or_before=f"{index_date_variable}",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2015-01-01"}, "incidence": 0.0075},
        ),
        date_t1dm_gp_last=patients.with_these_clinical_events(
            diabetes_t1_codes,
            on_or_before=f"{index_date_variable}",
            return_last_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2015-01-01"}, "incidence": 0.0075},
        ),
        date_t2dm_gp_first=patients.with_these_clinical_events(
            diabetes_t2_codes,
            on_or_before=f"{index_date_variable}",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2015-01-01"}, "incidence": 0.0425},
        ),
        date_t2dm_gp_last=patients.with_these_clinical_events(
            diabetes_t2_codes,
            on_or_before=f"{index_date_variable}",
            return_last_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2015-01-01"}, "incidence": 0.0425},
        ),
        date_unknown_diabetes_gp_first=patients.with_these_clinical_events(
            diabetes_unknown_codes,
            on_or_before=f"{index_date_variable}",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2015-01-01"}, "incidence": 0.005},
        ),
        date_unknown_diabetes_gp_last=patients.with_these_clinical_events(
            diabetes_unknown_codes,
            on_or_before=f"{index_date_variable}",
            return_last_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2015-01-01"}, "incidence": 0.005},
        ),
        date_t1dm_hospital_first=patients.admitted_to_hospital(
            with_these_diagnoses=diabetes_t1_codes_hospital,
            on_or_before=f"{index_date_variable}",
            find_first_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2015-01-01"}, "incidence": 0.005},
        ),
        date_t1dm_hospital_last=patients.admitted_to_hospital(
            with_these_diagnoses=diabetes_t1_codes_hospital,
            on_or_before=f"{index_date_variable}",
            find_last_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2015-01-01"}, "incidence": 0.005},
        ),
        date_t2dm_hospital_first=patients.admitted_to_hospital(
            with_these_diagnoses=diabetes_t2_codes_hospital,
            on_or_before=f"{index_date_variable}",
            find_first_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2015-01-01"}, "incidence": 0.02},
        ),
        date_t2dm_hospital_last=patients.admitted_to_hospital(
            with_these_diagnoses=diabetes_t2_codes_hospital,
            on_or_before=f"{index_date_variable}",
            find_last_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2015-01-01"}, "incidence": 0.02},
        ),
        ## COVID dates
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
        ### COVARIATES
        # Smoking status
        latest_smoking=patients.with_these_clinical_events(
            smoking_codes,
            on_or_before=f"{index_date_variable}",
            find_last_match_in_period=True,
            returning="category",
            return_expectations={
                "category": {"ratios": {"S": 0.5, "E": 0.3, "N": 0.2}},
                "incidence": 0.9
            },
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(smoking_codes, include=["S", "E"]),
            on_or_before=f"{index_date_variable}",
        ),
        # Hazardous alcohol consumption (in the previous year)
        haz_alcohol_lastyear=patients.with_these_clinical_events(
            hazardous_alcohol_codes,
            between=[f"{index_date_variable} - 1 year", f"{index_date_variable}"],
        ),
        # HbA1c
        hba1c=patients.with_these_clinical_events(
            hba1c_new_codes,
            on_or_before=f"{index_date_variable}",
            find_last_match_in_period=True,
            returning="numeric_value",
            include_date_of_match=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
                "incidence": 0.95
            },
        ),
        hba1c_percentage=patients.with_these_clinical_events(
            hba1c_old_codes,
            on_or_before=f"{index_date_variable}",
            find_last_match_in_period=True,
            returning="numeric_value",
            include_date_of_match=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "float": {"distribution": "normal", "mean": 5, "stddev": 2},
                "incidence": 0.95
            },
        ),
        # BMI
        bmi=patients.most_recent_bmi(
            on_or_before=f"{index_date_variable}",
            minimum_age_at_measurement=16,
            include_measurement_date=True,
            date_format="YYYY-MM-DD",
            return_expectations={
                "float": {"distribution": "normal", "mean": 35, "stddev": 10},
                "incidence": 0.95
            },
        ),
        # History of CVD
        hist_cvd=patients.with_these_clinical_events(
            hist_cvd_codes,
            on_or_before=f"{index_date_variable}",
            return_expectations={"incidence": 0.2},
        ),
        #hist_cvd_opcs=patients.admitted_to_hospital(
            #with_these_procedures=hist_cvd_codes_OPCS4,
            #on_or_before=f"{index_date_variable}",
            #return_expectations={"incidence": 0.2},
        #),
        hist_cvd_opcs2=patients.admitted_to_hospital(
            with_these_procedures=hist_cvd_codes_OPCS4_2,
            on_or_before=f"{index_date_variable}",
            return_expectations={"incidence": 0.2},
        ),
        # History of renal disease 
        # Creatinine measurement; RRT-dialysis/transplant; CKD stage (no CTV3, SNOMED available)
        creatinine=patients.with_these_clinical_events(
            creatinine_codes,
            find_last_match_in_period=True,
            on_or_before=f"{index_date_variable}",
            returning="numeric_value",
            return_expectations={
                "float": {"distribution": "normal", "mean": 60.0, "stddev": 15},
                "incidence": 0.95
            },
        ),
        ckd_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=ckd3_5_codes_hospital,
            on_or_before=f"{index_date_variable}",
            return_expectations={"incidence": 0.1},
        ),
        hist_rrt=patients.with_these_clinical_events(
            rrt_codes, 
            on_or_before=f"{index_date_variable}",
            return_expectations={"incidence": 0.1},
        ),
        ### CENSORING
        date_deregistered=patients.date_deregistered_from_all_supported_practices(
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2020-02-01"}, "incidence": 0.05}, 
        ),
        date_pneum_hospital=patients.admitted_to_hospital(
	        with_these_diagnoses=pneumonia_codelist,
	        find_first_match_in_period=True,
	        returning="date_admitted",
	        date_format="YYYY-MM-DD",
	        return_expectations={"date": {"earliest": "2019-02-01"}, "incidence": 0.02},            
        ),
        date_death=patients.died_from_any_cause(
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2020-02-01"}, "incidence": 0.1},
        ),
        ### OUTCOMES
        ## Cardiovascular
        # Stroke
        stroke_gp=patients.with_these_clinical_events(
            stroke_codes,
            on_or_after=f"{index_date_variable} - 3 months",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2019-11-01"}},
        ),
        stroke_gp_2=patients.with_these_clinical_events(
            stroke_codes_2,
            on_or_after=f"{index_date_variable} - 3 months",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2019-11-01"}},
        ),
        stroke_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=stroke_codes_hospital,
            on_or_after=f"{index_date_variable} - 3 months",
            find_first_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2019-11-01"}},
        ),
        stroke_ons=patients.with_these_codes_on_death_certificate(
            stroke_codes_hospital,
            on_or_after=f"{index_date_variable}",
            match_only_underlying_cause=False,
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2020-02-01"}},
        ),
        # Myocardial Infarction (MI)
        mi_gp=patients.with_these_clinical_events(
            mi_codes,
            on_or_after=f"{index_date_variable} - 3 months",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2019-11-01"}},
        ),
        mi_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=mi_codes_hospital,
            on_or_after=f"{index_date_variable} - 3 months",
            find_first_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2019-11-01"}},
        ),
        mi_ons=patients.with_these_codes_on_death_certificate(
            mi_codes_hospital,
            on_or_after=f"{index_date_variable}",
            match_only_underlying_cause=False,
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2020-02-01"}},
        ),
        # Deep Vein Thrombosis (DVT)
        dvt_gp=patients.with_these_clinical_events(
            dvt_codes,
            on_or_after=f"{index_date_variable} - 3 months",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2019-11-01"}},
        ),
        dvt_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=dvt_codes_hospital,
            on_or_after=f"{index_date_variable} - 3 months",
            find_first_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2019-11-01"}},
        ),
        dvt_ons=patients.with_these_codes_on_death_certificate(
            dvt_codes_hospital,
            on_or_after=f"{index_date_variable}",
            match_only_underlying_cause=False,
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2020-02-01"}},
        ),
        # Pulmonary Embolism (PE)
        pe_gp=patients.with_these_clinical_events(
            pe_codes,
            on_or_after=f"{index_date_variable} - 3 months",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2019-11-01"}},
        ),
        pe_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=pe_codes_hospital,
            on_or_after=f"{index_date_variable} - 3 months",
            find_first_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2019-11-01"}},
        ),
        pe_ons=patients.with_these_codes_on_death_certificate(
            pe_codes_hospital,
            on_or_after=f"{index_date_variable}",
            match_only_underlying_cause=False,
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2020-02-01"}},
        ),
        # Heart Failure (HF)
        hf_gp=patients.with_these_clinical_events(
            hf_codes,
            on_or_after=f"{index_date_variable} - 3 months",
            return_first_date_in_period=True,
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2019-11-01"}},
        ),
        hf_hospital=patients.admitted_to_hospital(
            with_these_diagnoses=hf_codes_hospital,
            on_or_after=f"{index_date_variable} - 3 months",
            find_first_match_in_period=True,
            returning="date_admitted",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2019-11-01"}},
        ),
        hf_ons=patients.with_these_codes_on_death_certificate(
            hf_codes_hospital,
            on_or_after=f"{index_date_variable}",
            match_only_underlying_cause=False,
            returning="date_of_death",
            date_format="YYYY-MM-DD",
            return_expectations={"date": {"earliest": "2020-02-01"}},
        ),
        ## Renal
        ## Hepatic
        ## Mental Illness
        ## Symptoms of post-COVID syndrome outcome        
    )
    return study_variables
