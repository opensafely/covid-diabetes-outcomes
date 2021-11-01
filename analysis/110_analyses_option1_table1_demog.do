**// Demographics and baseline risk factors

clear
do `c(pwd)'/analysis/000_filepaths.do

use $outdir/input_part1_clean.dta

set more off

**// Declare variable names and filename (.dta) to save results to

tempname demographics
	postfile `demographics' str20(demographic) str20(category) covid_diab covid_nodiab pneum_diab using $resultsdir/option1_table1_demographics.dta, replace
						
		**// Total
		local mytype="Total"
		forvalues k=1(1)3 {
			count if group==`k'
			local group`k'=r(N)
		}
		post `demographics'  ("`mytype'") ("") (`group1') (`group2') (`group3')
		
		**// Age-groups
		capture describe cat_age
		if _rc==0 {
			local mytype="Age"
			local mylabel1="18-49"
			local mylabel2="50-59"
			local mylabel3="60-69"
			local mylabel4="70-79"
			local mylabel5="80+"
			forvalues j=1(1)5 {
				forvalues k=1(1)3 {
					count if cat_age==`j' & group==`k'
					local group`k'=r(N)
				}
				post `demographics'  ("`mytype'") ("`mylabel`j''") (`group1') (`group2') (`group3')
			}
		}
			
		**// Sex
		capture describe cat_sex
		if _rc==0 {
			local mytype="Sex"
			local mylabel0="Female"
			local mylabel1="Male"	
			forvalues mysex=0(1)1 {
				forvalues k=1(1)3 {
					count if cat_sex==`mysex' & group==`k'
					local group`k'=r(N)
				}
				post `demographics'  ("`mytype'") ("`mylabel`mysex''") (`group1') (`group2') (`group3')
			}
		}
		
		**// Ethnicity
		capture describe cat_ethnic
		if _rc==0 {
			local mytype="Ethnicity"
			local mylabel1="White"
			local mylabel2="Mixed"
			local mylabel3="Asian/Asian British"
			local mylabel4="Black"
			local mylabel5="Other"
			local mylabel6="Unknown"
			forvalues j=1(1)6 {
				forvalues k=1(1)3 {
					count if cat_ethnic==`j' & group==`k'
					local group`k'=r(N)
				}
				post `demographics'  ("`mytype'") ("`mylabel`j''") (`group1') (`group2') (`group3')
			}
		}
		
		**// IMD
		capture describe cat_imd
		if _rc==0 {
			local mytype="IMD"
			local mylabel1="1 (least deprived)"
			local mylabel2="2"
			local mylabel3="3"
			local mylabel4="4"
			local mylabel5="5 (most deprived)"
			local mylabel6="Unknown"
			recode cat_imd .=6
			forvalues j=1(1)6 {
				forvalues k=1(1)3 {
					count if cat_imd==`j' & group==`k'
					local group`k'=r(N)
				}
				post `demographics'  ("`mytype'") ("`mylabel`j''") (`group1') (`group2') (`group3')
			}
		}			
		
		**// Type of diabetes
		
		**// History of CVD

		**// History of renal disease

		**// Type of treatment for COVID-19 (during hospitalisation)

		**// Smoking status

		**// Alcohol intake

		**// BMI
		capture describe cat_bmi
		if _rc==0 {
			local mytype="BMI"
			local mylabel1="Underweight"
			local mylabel2="Healthy"
			local mylabel3="Overweight"
			local mylabel4="Obese"
			local mylabel5="Unknown"
			forvalues j=1(1)5 {
				forvalues k=1(1)3 {
					count if cat_bmi==`j' & group==`k'
					local group`k'=r(N)
				}
				post `demographics'  ("`mytype'") ("`mylabel`j''") (`group1') (`group2') (`group3')
			}
		}
		
		**// HbA1c
		capture describe cat_hba1c
		if _rc==0 {
			local mytype="HbA1c"
			local mylabel1="Normal"
			local mylabel2="Prediabetes"
			local mylabel3="Diabetes"
			local mylabel4="Unknown"
			forvalues j=1(1)4 {
				forvalues k=1(1)3 {
					count if cat_hba1c==`j' & group==`k'
					local group`k'=r(N)
				}
				post `demographics'  ("`mytype'") ("`mylabel`j''") (`group1') (`group2') (`group3')
			}
		}
			
postclose `demographics'

**// Tidy and convert to csv
use $resultsdir/option1_table1_demographics.dta, clear
gen temp=1 if demographic==demographic[_n-1]
replace demographic="" if temp==1
drop temp
save $resultsdir/option1_table1_demographics.dta, replace
export delimited using $resultsdir/option1_table1_demographics.csv, replace
