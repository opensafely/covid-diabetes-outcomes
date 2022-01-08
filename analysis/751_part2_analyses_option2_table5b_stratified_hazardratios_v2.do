local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Stratified hazard ratios - comparing groups 1 and 2
**///////////////////////////////////////////////////////////////////

set more off
		
use $outdir/matched_part2_groups_1_and_2.dta, clear

local refgroup2="COVID-19 without diabetes"

**// Loop over each outcome
foreach outcome in "stroke_thrombotic" "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {	
	use $outdir/matched_part2_groups_1_and_2.dta, clear
	gen expos=(group==1)
	gen myend=(min(date_`outcome', date_censor)-date_patient_index)/(365.25/12)
	gen myselect=(myend>0)
	gen delta=(date_`outcome'==min(date_`outcome', date_censor))
	local demogindex=0
	**// Loop over each demographic/characteristic
	foreach demog in "sex" "age" "ethnic" "imd" "hist_cvd" "hist_renal" "vaccin" "smoking" "alcohol" "bmi" "hba1c" {
		local demogindex=`demogindex'+1
		summ cat_`demog'
		local numcat_`demog'=r(max)
		if `numcat_`demog''==. {
			local numcat_`demog'=1
		}
		**// Loop over categories of the demographic/characteristic
		forvalues catindex=1(1)`numcat_`demog'' {
			capture erase $resultsdir/hr_`outcome'_`demog'_`catindex'.dta
			**// Estimate hazard ratios and post
			tempname hazardratios
				postfile `hazardratios' demogindex catindex groupindex str20(demographic) str25(refgroup) ///
				`outcome'_hr1 `outcome'_hr1_lo `outcome'_hr1_hi ///
				`outcome'_hr2 `outcome'_hr2_lo `outcome'_hr2_hi ///
				`outcome'_hr3 `outcome'_hr3_lo `outcome'_hr3_hi ///
				`outcome'_hr4 `outcome'_hr4_lo `outcome'_hr4_hi ///
				using $resultsdir/hr_`outcome'_`demog'_`catindex'.dta, replace
				forvalues k=2(1)2 {
					count if group==1 & delta==1 & myselect==1 & cat_`demog'==`catindex'
					local mycounta=r(N)
					count if group==`k' & delta==1 & myselect==1 & cat_`demog'==`catindex'
					local mycountb=r(N)
					if `mycounta'>=8 & `mycountb'>=8 {
						forvalues m=1(1)4 {

						
							if `m'==1 {
								**// Using propensity scores as inverse probability weights
								**//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
								preserve
								**// Estimate propensity scores
								keep if (group==1 | group==`k') & myselect==1 & cat_`demog'==`catindex'
								foreach mytype in "vaccin" "hba1c" {
									rename cat_`mytype' excl_`mytype'
								}
								capture logistic expos i.cat_*
								if _rc==0 {
									predict propensity
									**// IP weights
									gen ipw=(expos/propensity)+((1-expos)/(1-propensity))
									**// Set as weighted survival data
									capture drop _st _d _t _t0
									capture stset myend [pweight=ipw], f(delta) id(patient_id)
									**// Estimate hazard ratio
									capture stcox expos, vce(robust)
									if _rc==0 {
										matrix M1=e(b)
										matrix M2=e(V)
										local hr`m'   =exp(M1[1,1])
										local hr`m'_lo=exp(M1[1,1]-1.96*(M2[1,1]^0.5))
										local hr`m'_hi=exp(M1[1,1]+1.96*(M2[1,1]^0.5))										
									}
									if _rc!=0 {
										local hr`m'   =999999
										local hr`m'_lo=999999
										local hr`m'_hi=999999					
									}
								}
								if _rc!=0 {
									local hr`m'   =999999
									local hr`m'_lo=999999
									local hr`m'_hi=999999								
								}
								restore
							}

							
							if `m'==2 {
								**// Using propensity scores as inverse probability weights - with trimming
								**//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
								preserve
								**// Estimate propensity scores
								keep if (group==1 | group==`k') & myselect==1 & cat_`demog'==`catindex'
								foreach mytype in "vaccin" "hba1c" {
									rename cat_`mytype' excl_`mytype'
								}
								capture logistic expos i.cat_*
								if _rc==0 {
									predict propensity
									**// Trimming (replaces common support restriction)
									drop if (propensity<0.1 | propensity>0.9)
									**// IP weights
									gen ipw=(expos/propensity)+((1-expos)/(1-propensity))
									**// Set as weighted survival data
									capture drop _st _d _t _t0
									capture stset myend [pweight=ipw], f(delta) id(patient_id)
									**// Estimate hazard ratio
									capture stcox expos, vce(robust)
									if _rc==0 {
										matrix M1=e(b)
										matrix M2=e(V)
										local hr`m'   =exp(M1[1,1])
										local hr`m'_lo=exp(M1[1,1]-1.96*(M2[1,1]^0.5))
										local hr`m'_hi=exp(M1[1,1]+1.96*(M2[1,1]^0.5))										
									}
									if _rc!=0 {
										local hr`m'   =999999
										local hr`m'_lo=999999
										local hr`m'_hi=999999					
									}
								}
								if _rc!=0 {
									local hr`m'   =999999
									local hr`m'_lo=999999
									local hr`m'_hi=999999								
								}
								restore
							}

							
							if `m'==3 {
								**// Using propensity scores as inverse probability weights - with trimming and stabilisation
								**//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
								preserve
								**// Estimate propensity scores
								keep if (group==1 | group==`k') & myselect==1 & cat_`demog'==`catindex'
								foreach mytype in "vaccin" "hba1c" {
									rename cat_`mytype' excl_`mytype'
								}
								capture logistic expos i.cat_*
								if _rc==0 {
									predict propensity
									**// Trimming (replaces common support restriction)
									drop if (propensity<0.1 | propensity>0.9)
									**// Stabilised IP weights (replaces IP weights)
									count if expos==1
									local count_expos=r(N)
									local myp=`count_expos'/_N
									gen sipw=(expos*`myp'/propensity)+(((1-expos)*(1-`myp'))/(1-propensity))
									**// Set as weighted survival data
									capture drop _st _d _t _t0
									capture stset myend [pweight=sipw], f(delta) id(patient_id)
									**// Estimate hazard ratio
									capture stcox expos, vce(robust)
									if _rc==0 {
										matrix M1=e(b)
										matrix M2=e(V)
										local hr`m'   =exp(M1[1,1])
										local hr`m'_lo=exp(M1[1,1]-1.96*(M2[1,1]^0.5))
										local hr`m'_hi=exp(M1[1,1]+1.96*(M2[1,1]^0.5))										
									}
									if _rc!=0 {
										local hr`m'   =999999
										local hr`m'_lo=999999
										local hr`m'_hi=999999					
									}
								}
								if _rc!=0 {
									local hr`m'   =999999
									local hr`m'_lo=999999
									local hr`m'_hi=999999								
								}
								restore
							}

							
*							if `m'==4 {
*								**// Using propensity scores as inverse probability weights - with trimming and stabilisation - incorporating all two-way interactions
*								**//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*								preserve
*								**// Estimate propensity scores (incorporating all two-way interactions)
*								keep if (group==1 | group==`k') & myselect==1 & cat_`demog'==`catindex'
*								foreach mytype in "vaccin" "hba1c" {
*									rename cat_`mytype' excl_`mytype'
*								}
*								describe cat_*, varlist
*								local mylist=""
*								foreach myvarA in `r(varlist)' {
*									foreach myvarB in `r(varlist)' {
*										local mylist="`mylist'"+" "+"`myvarA'##`myvarB'"
*									}			
*								}
*								capture logistic expos `mylist'
*								if _rc==0 {
*									predict propensity
*									**// Trimming (replaces common support restriction)
*									drop if (propensity<0.1 | propensity>0.9)
*									**// Stabilised IP weights (replaces IP weights)
*									count if expos==1
*									local count_expos=r(N)
*									local myp=`count_expos'/_N
*									gen sipw=(expos*`myp'/propensity)+(((1-expos)*(1-`myp'))/(1-propensity))
*									**// Set as weighted survival data
*									capture drop _st _d _t _t0
*									capture stset myend [pweight=sipw], f(delta) id(patient_id)
*									**// Estimate hazard ratio
*									capture stcox expos, vce(robust)
*									if _rc==0 {
*										matrix M1=e(b)
*										matrix M2=e(V)
*										local hr`m'   =exp(M1[1,1])
*										local hr`m'_lo=exp(M1[1,1]-1.96*(M2[1,1]^0.5))
*										local hr`m'_hi=exp(M1[1,1]+1.96*(M2[1,1]^0.5))										
*									}
*									if _rc!=0 {
*										local hr`m'   =999999
*										local hr`m'_lo=999999
*										local hr`m'_hi=999999					
*									}
*								}
*								if _rc!=0 {
*									local hr`m'   =999999
*									local hr`m'_lo=999999
*									local hr`m'_hi=999999								
*								}
*								restore
*							}
							
							
							if `m'==4 {
									local hr`m'   =888888
									local hr`m'_lo=888888
									local hr`m'_hi=888888
							}

							
						}
						post `hazardratios' (`demogindex') (`catindex') (`k') ("`demog'") ("`refgroup`k''") ///
						(`hr1') (`hr1_lo') (`hr1_hi') (`hr2') (`hr2_lo') (`hr2_hi') (`hr3') (`hr3_lo') (`hr3_hi') (`hr4') (`hr4_lo') (`hr4_hi')
					}
					else {
						post `hazardratios' (`demogindex') (`catindex') (`k') ("`demog'") ("`refgroup`k''") (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.)
					}
				}							
			postclose `hazardratios' 	
		}
	}
}

**// Append categories within each demographic for each outcome
foreach outcome in "stroke_thrombotic" "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {		
	foreach demog in "sex" "age" "ethnic" "imd" "hist_cvd" "hist_renal" "vaccin" "smoking" "alcohol" "bmi" "hba1c" {
		clear
		set obs 0
		forvalues catindex=1(1)`numcat_`demog'' {
			append using $resultsdir/hr_`outcome'_`demog'_`catindex'.dta
			erase $resultsdir/hr_`outcome'_`demog'_`catindex'.dta
		}
		tostring catindex, gen(category) force
		order category, after(demographic)
		do `mypath'/002_catlab.do
		save $resultsdir/hr_`outcome'_`demog'.dta, replace
	}
}

**// Append demographics within each outcome
foreach outcome in "stroke_thrombotic" "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {	
	clear
	set obs 0
	foreach demog in "sex" "age" "ethnic" "imd" "hist_cvd" "hist_renal" "vaccin" "smoking" "alcohol" "bmi" "hba1c" {
		append using $resultsdir/hr_`outcome'_`demog'.dta
		erase $resultsdir/hr_`outcome'_`demog'.dta
	}
	sort demogindex catindex groupindex
	**// Tidy presentation of hazard ratios
	describe `outcome'_hr*, varlist
	foreach myvar in `r(varlist)' {
		format `myvar' %12.2f
		tostring `myvar', replace force usedisplayformat
		
	}
	forvalues m=1(1)4 {
		gen newvar`m'=`outcome'_hr`m'+" ("+`outcome'_hr`m'_lo+", "+`outcome'_hr`m'_hi+")"
		replace newvar`m'="-" if newvar`m'==". (., .)"
		drop `outcome'_hr`m'*
		rename newvar`m' `outcome'_hr`m'
	}
	save $resultsdir/hr_`outcome'.dta, replace
}

**// Merge outcomes
use $resultsdir/hr_stroke_thrombotic.dta, clear
foreach outcome in "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {	
	capture merge 1:1 demogindex catindex groupindex using $resultsdir/hr_`outcome'.dta
	if _rc==0 {
	   drop _merge
	   erase $resultsdir/hr_`outcome'.dta
	}
}
erase $resultsdir/hr_stroke_thrombotic.dta	
sort demogindex catindex groupindex

**// Labelling
do `mypath'/001_demoglab.do

**// Tidy
gen temp1=1 if demographic==demographic[_n-1]
replace demographic="" if temp1==1
gen temp2=1 if category==category[_n-1]
replace category="" if temp2==1
drop temp1 temp2

describe, varlist
foreach myvar in `r(varlist)' {
	capture gen str=strlen(`myvar')
	if _rc==0 {
		summ str
		format `myvar' %-`r(max)'s
		drop str			
	}
}
drop demogindex catindex groupindex
save $resultsdir/part2_option2_table5b_stratified_hazardratios_v2.dta, replace
