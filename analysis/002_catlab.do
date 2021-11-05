**// Sex
replace category="Female"				if	lower(demographic)=="sex"		&	category=="1"
replace category="Male"					if	lower(demographic)=="sex"		&	category=="2"

**// Age
replace category="18-49"				if	lower(demographic)=="age"		&	category=="1"
replace category="50-59"				if	lower(demographic)=="age"		&	category=="2"
replace category="60-69"				if	lower(demographic)=="age"		&	category=="3"
replace category="70-79"				if	lower(demographic)=="age"		&	category=="4"
replace category="80+"					if	lower(demographic)=="age"		&	category=="5"

**// Ethnicity
replace category="White"				if	(lower(demographic)=="ethnic" | lower(demographic)=="ethnicity")	&	category=="1"
replace category="Mixed"				if	(lower(demographic)=="ethnic" | lower(demographic)=="ethnicity")	&	category=="2"
replace category="Asian/Asian British"	if	(lower(demographic)=="ethnic" | lower(demographic)=="ethnicity")	&	category=="3"
replace category="Black"				if	(lower(demographic)=="ethnic" | lower(demographic)=="ethnicity")	&	category=="4"
replace category="Other"				if	(lower(demographic)=="ethnic" | lower(demographic)=="ethnicity")	&	category=="5"
replace category="Unknown"				if	(lower(demographic)=="ethnic" | lower(demographic)=="ethnicity")	&	category=="6"

**// IMD
replace category="1 (least deprived)"	if	lower(demographic)=="imd"		&	category=="1"
replace category="2"					if	lower(demographic)=="imd"		&	category=="2"
replace category="3"					if	lower(demographic)=="imd"		&	category=="3"
replace category="4"					if	lower(demographic)=="imd"		&	category=="4"
replace category="5 (most deprived)"	if	lower(demographic)=="imd"		&	category=="5"
replace category="Unknown"				if	lower(demographic)=="imd"		&	category=="."

**// BMI
replace category="Underweight" 			if	lower(demographic)=="bmi"		&	 category=="1"
replace category="Healthy" 				if	lower(demographic)=="bmi"		&	 category=="2"
replace category="Overweight" 			if	lower(demographic)=="bmi"		&	 category=="3"
replace category="Obese" 				if	lower(demographic)=="bmi"		&	 category=="4"
replace category="Unknown" 				if	lower(demographic)=="bmi"		&	(category=="." | category=="5")

**// HbA1c
replace category="Normal" 				if	lower(demographic)=="hba1c"		&	 category=="1"
replace category="Prediabetes" 			if	lower(demographic)=="hba1c"		&	 category=="2"
replace category="Diabetes" 			if	lower(demographic)=="hba1c"		&	 category=="3"
replace category="Unknown" 				if	lower(demographic)=="hba1c"		&	(category=="." | category=="4")