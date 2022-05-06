local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Stratified outcome rate comparisons - groups 1 and 2
**///////////////////////////////////////////////////////////////////

use $outdir/input_part2_clean.dta, clear

local grouplabel1="COVID-19 with diabetes"
local grouplabel2="COVID-19 without diabetes"
local grouplabel3="No COVID-19 with diabetes"

set more off

**// Loop over each outcome
foreach outcome in "stroke_thrombotic" "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {	
	use $outdir/input_part2_clean.dta, clear
	drop if group==4
	gen expos=(group==1)
	gen myend=(min(date_`outcome', date_censor)-date_patient_index)/(365.25/12)
	gen ln_myend=ln(myend)
	gen myselect=(myend>0)
	gen delta=(date_`outcome'==min(date_`outcome', date_censor))
	capture stset myend, f(delta) id(patient_id)
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
			capture erase $revisedresultsdir/rates_`outcome'_`demog'_`catindex'.dta
			**// Calculate rates and rate ratios
			preserve
			keep if cat_`demog'==`catindex'
			tempname rates
				postfile `rates' demogindex catindex groupindex str20(demographic) str25(group) `outcome'_ptime `outcome'_events `outcome'_rate `outcome'_rate_lo `outcome'_rate_hi ///
				`outcome'_ipw_rr `outcome'_ipw_rr_lo `outcome'_ipw_rr_hi ///
				using $revisedresultsdir/rates_`outcome'_`demog'_`catindex'.dta, replace		
				**// Loop over exposure groups
				capture stptime if group==1 & myselect==1, title(person-months) per(10000)
				if _rc==0 {
					post `rates' (`demogindex') (`catindex') (1) ("`demog'") ("`grouplabel1'") (`r(ptime)') (`r(failures)') (`r(rate)') (`r(lb)') (`r(ub)') (.) (.) (.)
				}
				if _rc!=0 {
					post `rates' (`demogindex') (`catindex') (1) ("`demog'") ("`grouplabel1'") (.) (.) (.) (.) (.) (.) (.) (.)
				}
				forvalues k=2(1)3 {
					replace myselect=(myend>0)
					capture stptime if group==`k' & myselect==1, title(person-months) per(10000)		
					if _rc==0 {
						local person_time=r(ptime)
						local numevents=r(failures)
						local rate=r(rate)
						local rate_lo=r(lb)
						local rate_hi=r(ub)
					}
					if _rc!=0 {
						local person_time=.
						local numevents=.
						local rate=.
						local rate_lo=.
						local rate_hi=.
					}	
					**// Loop over model specifications (comparing group 1 and group k)
					forvalues m=1(1)1 {
						**// IPW rate ratio
						if `m'==1 {
							capture logit expos i.cat_sex i.cat_age i.cat_ethnic i.cat_imd i.cat_hist_cvd i.cat_hist_renal i.cat_smoking i.cat_alcohol i.cat_bmi ///
							if (group==1 | group==`k') & myselect==1
							if _rc==0 {
								predict propensity
								gen ipw=(expos/propensity)+((1-expos)/(1-propensity))
							}
							capture nbreg delta expos if (group==1 | group==`k') & myselect==1 [pweight=ipw], offset(ln_myend) vce(robust) nonrtolerance
						}
						if _rc==0 {
							matrix M1=e(b)
							matrix M2=e(V)
							local rr`m'=exp(M1[1,1])
							local rr`m'_lo=exp(M1[1,1]-1.96*M2[1,1]^0.5)
							local rr`m'_hi=exp(M1[1,1]+1.96*M2[1,1]^0.5)
						}
						if _rc!=0 {
							local rr`m'=.
							local rr`m'_lo=.
							local rr`m'_hi=.
						}
					}
					post `rates' (`demogindex') (`catindex') (`k') ("`demog'") ("`grouplabel`k''") (`person_time') (`numevents') (`rate') (`rate_lo') (`rate_hi') (`rr1') (`rr1_lo') (`rr1_hi')
					foreach myvar in propensity ipw sipw {
						capture drop `myvar'
					}
				}		
			postclose `rates' 	
			restore
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
			append using $revisedresultsdir/rates_`outcome'_`demog'_`catindex'.dta
			erase $revisedresultsdir/rates_`outcome'_`demog'_`catindex'.dta
		}
		tostring catindex, gen(category) force
		order category, after(demographic)
		do `mypath'/002_catlab.do
		save $revisedresultsdir/rates_`outcome'_`demog'.dta, replace
	}
}

**// Append demographics within each outcome
foreach outcome in "stroke_thrombotic" "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {	
	clear
	set obs 0
	foreach demog in "sex" "age" "ethnic" "imd" "hist_cvd" "hist_renal" "vaccin" "smoking" "alcohol" "bmi" "hba1c" {
		append using $revisedresultsdir/rates_`outcome'_`demog'.dta
		erase $revisedresultsdir/rates_`outcome'_`demog'.dta
	}
	sort demogindex catindex groupindex
	**// Tidy presentation of rates
	format `outcome'_ptime `outcome'_events %12.0f
	describe `outcome'_rate*, varlist
	foreach myvar in `r(varlist)' {
		format `myvar' %12.1f
		tostring `myvar', replace force usedisplayformat
	}
	gen newvar=`outcome'_rate+" ("+`outcome'_rate_lo+", "+`outcome'_rate_hi+")"
	replace newvar="-" if newvar==". (., .)"
	drop `outcome'_rate*
	rename newvar `outcome'_rate
	**// Tidy presentation of rate ratios
	foreach mytype in "ipw_rr" {
		format `outcome'_`mytype' `outcome'_`mytype'_lo `outcome'_`mytype'_hi %12.2f
		tostring `outcome'_`mytype', replace force usedisplayformat
		tostring `outcome'_`mytype'_lo, replace force usedisplayformat
		tostring `outcome'_`mytype'_hi, replace force usedisplayformat
		gen newvar=`outcome'_`mytype'+" ("+`outcome'_`mytype'_lo+", "+`outcome'_`mytype'_hi+")"
		replace newvar="-" if newvar==". (., .)"
		drop `outcome'_`mytype' `outcome'_`mytype'_lo `outcome'_`mytype'_hi
		rename newvar `outcome'_`mytype'
	}
	save $revisedresultsdir/rates_`outcome'.dta, replace
}

**// Merge outcomes
use $revisedresultsdir/rates_stroke_thrombotic.dta, clear
foreach outcome in "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {	
	capture merge 1:1 demogindex catindex groupindex using $revisedresultsdir/rates_`outcome'.dta
	if _rc==0 {
	   drop _merge
	   erase $revisedresultsdir/rates_`outcome'.dta
	}
}
erase $revisedresultsdir/rates_stroke_thrombotic.dta	
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
save $revisedresultsdir/revised_part2_option1_table4b_stratified_rateratios.dta, replace
