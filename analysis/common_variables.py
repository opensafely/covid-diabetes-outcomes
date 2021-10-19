from cohortextractor import filter_codes_by_category, patients, combine_codelists
from codelists import *
from datetime import datetime, timedelta

def generate_common_variables(index_date_variable):
    common_variables = dict(
        age=patients.age_as_of(
            f"{index_date_variable}",
            return_expectations={
                "rate": "universal",
                "int": {"distribution": "population_ages"},
            },
        ),
        sex=patients.sex(
            return_expectations={
                "rate": "universal",
                "category": {"ratios": {"M": 0.49, "F": 0.51}},
            }
        ),
        practice_id=patients.registered_practice_as_of(
            "index_date",
            returning="pseudo_id",
            return_expectations={
                "int": {"distribution": "normal", "mean": 1000, "stddev": 100},
                "incidence": 1,
            },
        ),
    )
    return common_variables
