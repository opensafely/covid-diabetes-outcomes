**// Total
replace category=""									if strpos(lower(demographic),"total")!=0		&	category=="."

**// Sex
replace category="Female"							if	strpos(lower(demographic),"sex")!=0			&	category=="1"
replace category="Male"								if	strpos(lower(demographic),"sex")!=0			&	category=="2"

**// Age
replace category="18-49"							if	strpos(lower(demographic),"age")!=0			&	category=="1"
replace category="50-59"							if	strpos(lower(demographic),"age")!=0			&	category=="2"
replace category="60-69"							if	strpos(lower(demographic),"age")!=0			&	category=="3"
replace category="70-79"							if	strpos(lower(demographic),"age")!=0			&	category=="4"
replace category="80+"								if	strpos(lower(demographic),"age")!=0			&	category=="5"

**// Ethnicity
replace category="White"							if	strpos(lower(demographic),"ethnic")!=0		&	category=="1"
replace category="Mixed"							if	strpos(lower(demographic),"ethnic")!=0		&	category=="2"
replace category="Asian/Asian British"				if	strpos(lower(demographic),"ethnic")!=0		&	category=="3"
replace category="Black"							if	strpos(lower(demographic),"ethnic")!=0		&	category=="4"
replace category="Other"							if	strpos(lower(demographic),"ethnic")!=0		&	category=="5"
replace category="Unknown"							if	strpos(lower(demographic),"ethnic")!=0		&	(category=="6" | category==".")

**// IMD
replace category="1 (least deprived)"				if	strpos(lower(demographic),"imd")!=0			&	category=="1"
replace category="2"								if	strpos(lower(demographic),"imd")!=0			&	category=="2"
replace category="3"								if	strpos(lower(demographic),"imd")!=0			&	category=="3"
replace category="4"								if	strpos(lower(demographic),"imd")!=0			&	category=="4"
replace category="5 (most deprived)"				if	strpos(lower(demographic),"imd")!=0			&	category=="5"
replace category="Unknown"							if	strpos(lower(demographic),"imd")!=0			&	(category=="6" | category==".")

**// Type of diabetes
replace category="None"								if 	strpos(lower(demographic),"diabetes")!=0	&	category=="3"

**// History of CVD
replace category="No"								if	strpos(lower(demographic),"cvd")!=0			&	category=="1"
replace category="Yes"								if	strpos(lower(demographic),"cvd")!=0			&	category=="2"
replace category="Unknown"							if	strpos(lower(demographic),"cvd")!=0			&	category=="3"

**// History of renal disease
replace category="No"								if	strpos(lower(demographic),"renal")!=0		&	category=="1"
replace category="Yes"								if	strpos(lower(demographic),"renal")!=0		&	category=="2"
replace category="Unknown"							if	strpos(lower(demographic),"renal")!=0		&	category=="3"

**// Required critical care
replace category="No"								if	strpos(lower(demographic),"critical")!=0	&	category=="1"
replace category="Yes"								if	strpos(lower(demographic),"critical")!=0	&	category=="2"

**// COVID-19 vaccination status (at baseline)
replace category="None" 							if strpos(lower(demographic),"vaccin")!=0 		& 	category=="1"
replace category="One dose" 						if strpos(lower(demographic),"vaccin")!=0 		& 	category=="2"
replace category="Two doses" 						if strpos(lower(demographic),"vaccin")!=0 		& 	category=="3"

**// Smoking status
replace category="Never" 							if strpos(lower(demographic),"smok")!=0 		& 	category=="1"
replace category="Ex" 								if strpos(lower(demographic),"smok")!=0			& 	category=="2"
replace category="Current" 							if strpos(lower(demographic),"smok")!=0 		& 	category=="3"
replace category="Unknown" 							if strpos(lower(demographic),"smok")!=0 		& 	category=="4"

**// Hazardous alcohol comsumption (in the year prior to baseline)
replace category="No" 								if strpos(lower(demographic),"alcohol")!=0 		& 	category=="1"
replace category="Yes" 								if strpos(lower(demographic),"alcohol")!=0 		& 	category=="2"
replace category="Unknown" 							if strpos(lower(demographic),"alcohol")!=0 		& 	category=="3"

**// BMI
replace category="Underweight" 						if	strpos(lower(demographic),"bmi")!=0			&	 category=="1"
replace category="Healthy" 							if	strpos(lower(demographic),"bmi")!=0			&	 category=="2"
replace category="Overweight" 						if	strpos(lower(demographic),"bmi")!=0			&	 category=="3"
replace category="Obese" 							if	strpos(lower(demographic),"bmi")!=0			&	 category=="4"
replace category="Unknown" 							if	strpos(lower(demographic),"bmi")!=0			&	(category=="5" | category==".")

**// HbA1c
replace category="Normal" 							if	strpos(lower(demographic),"hba1c")!=0		&	 category=="1"
replace category="Prediabetes" 						if	strpos(lower(demographic),"hba1c")!=0		&	 category=="2"
replace category="Diabetes" 						if	strpos(lower(demographic),"hba1c")!=0		&	 category=="3"
replace category="Unknown" 							if	strpos(lower(demographic),"hba1c")!=0		&	(category=="4" | category==".")
