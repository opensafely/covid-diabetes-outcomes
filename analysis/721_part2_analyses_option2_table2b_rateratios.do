local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Outcome rates and rate ratios
**//////////////////////////////////////////////

use $outdir/matched_part2_groups_1_and_2.dta, clear

drop if group==4

local grouplabel1="COVID-19 with diabetes"
local grouplabel2="COVID-19 without diabetes"
local grouplabel3="Pneumonia with diabetes"

gen expos=(group==1)

set more off

tempname rates
	postfile `rates' outindex groupindex str30(outcome) str30(group) person_time numevents rate rate_lo rate_hi ///
	rateratio rateratio_lo rateratio_hi ///
	adj_rateratio adj_rateratio_lo adj_rateratio_hi ///
	fulladj_rateratio fulladj_rateratio_lo fulladj_rateratio_hi ///
	ipw_rateratio ipw_rateratio_lo ipw_rateratio_hi ///
	sipw_rateratio sipw_rateratio_lo sipw_rateratio_hi ///
	using $resultsdir/part2_option2_table2b_rateratios.dta, replace
	**// Loop over outcomes
	local outindex=0
	foreach outcome in "stroke_thrombotic" "stroke_haemorrhagic" "stroke_tia" "stroke_any" "mi" "dvt_any" "pe_any" "hf" "any_cvd" "aki_any" "liver" ///
	"anxiety" "depression" "psychosis" "antidepressant" "anxiolytic" "antipsychotic"  "mood_stabiliser" "sleep_insomnia" "sleep_hypersomnia" "sleep_apnoea" "fatigue" "death" {	
		local outindex=`outindex'+1
		gen myend=(min(date_`outcome', date_censor)-date_patient_index)/(365.25/12)
		gen ln_myend=ln(myend)
		gen myselect=(myend>0)
		gen delta=(date_`outcome'==min(date_`outcome', date_censor))
		capture stset myend, f(delta) id(patient_id)
		**// Loop over exposure groups
		capture stptime if group==1 & myselect==1, title(person-months) per(10000)		
		if _rc==0 {
			post `rates' (`outindex') (1) ("`outcome'") ("`grouplabel1'") (`r(ptime)') (`r(failures)') (`r(rate)') (`r(lb)') (`r(ub)') (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.)
		}
		if _rc!=0 {
			post `rates' (`outindex') (1) ("`outcome'") ("`grouplabel1'") (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.)
		}
		forvalues k=2(1)2 {
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
			forvalues m=1(1)5 {
				**// Rate ratio
				if `m'==1 {		
					capture nbreg delta expos if (group==1 | group==`k') & myselect==1, offset(ln_myend) nonrtolerance
				}
				**// Age/sex adjusted rate ratio
				if `m'==2 {
					capture nbreg delta expos i.cat_sex i.cat_age if (group==1 | group==`k') & myselect==1, offset(ln_myend) vce(robust) nonrtolerance			
				}
				**// Fully adjusted rate ratio
				if `m'==3 {
					capture nbreg delta expos i.cat_sex i.cat_age i.cat_ethnic i.cat_imd i.cat_hist_cvd i.cat_hist_renal i.cat_smoking i.cat_alcohol i.cat_bmi ///
					if (group==1 | group==`k') & myselect==1, offset(ln_myend) vce(robust) nonrtolerance			
				}
				**// IPW rate ratio
				if `m'==4 {
					capture logit expos i.cat_sex i.cat_age i.cat_ethnic i.cat_imd i.cat_hist_cvd i.cat_hist_renal i.cat_smoking i.cat_alcohol i.cat_bmi if (group==1 | group==`k') & myselect==1
					if _rc==0 {
						predict propensity
						gen ipw=(expos/propensity)+((1-expos)/(1-propensity))
					}
					capture nbreg delta expos if (group==1 | group==`k') & myselect==1 [pweight=ipw], offset(ln_myend) vce(robust) nonrtolerance
				}
				**// Trimmed and standardised IPW rate ratios
				if `m'==5 {
					capture describe propensity
					if _rc==0 {
						replace myselect=0 if propensity<0.1 | propensity>0.9
						count if group==1 & myselect==1
						local count_expos=r(N)				
						count if (group==1 | group==`k') & myselect==1
						local count_denom=r(N)
						local myp=`count_expos'/`count_denom'
						gen sipw=(expos*`myp'/propensity)+(((1-expos)*(1-`myp'))/(1-propensity))
					}
					capture nbreg delta expos if (group==1 | group==`k') & myselect==1 [pweight=sipw], offset(ln_myend) vce(robust) nonrtolerance
				}
				if _rc==0 {
					matrix M1=e(b)
					matrix M2=e(V)
					local rateratio`m'=exp(M1[1,1])
					local rateratio`m'_lo=exp(M1[1,1]-1.96*M2[1,1]^0.5)
					local rateratio`m'_hi=exp(M1[1,1]+1.96*M2[1,1]^0.5)
				}
				if _rc!=0 {
					local rateratio`m'=.
					local rateratio`m'_lo=.
					local rateratio`m'_hi=.
				}
			}
			post `rates' (`outindex') (`k') ("`outcome'") ("`grouplabel`k''") (`person_time') (`numevents') (`rate') (`rate_lo') (`rate_hi') ///
			(`rateratio1') (`rateratio1_lo') (`rateratio1_hi') ///
			(`rateratio2') (`rateratio2_lo') (`rateratio2_hi') ///
			(`rateratio3') (`rateratio3_lo') (`rateratio3_hi') ///
			(`rateratio4') (`rateratio4_lo') (`rateratio4_hi') ///
			(`rateratio5') (`rateratio5_lo') (`rateratio5_hi')
			foreach myvar in propensity ipw sipw {
				capture drop `myvar'
			}
		}
		foreach myvar in myselect myend ln_myend delta _st _d _t _t0 {
			capture drop `myvar'
		}
	}
postclose `rates'

use $resultsdir/part2_option2_table2b_rateratios.dta, clear

**// Labelling
gen type=""
order type, before(outcome)
do `mypath'/003_outlab.do
do `mypath'/004_typelab.do

**// Tidy
sort outindex groupindex
gen temp1=1 if type==type[_n-1]
replace type="" if temp1==1
gen temp2=1 if outcome==outcome[_n-1]
replace outcome="" if (temp2==1 | lower(outcome)=="death")
drop outindex groupindex temp1 temp2

describe type-group, varlist
foreach myvar in `r(varlist)' {
	gen str=strlen(`myvar')
	summ str
	format `myvar' %-`r(max)'s
	drop str
}

format person_time %12.1fc
format numevents %12.0fc

**// Format rates
format rate rate_lo rate_hi %12.1fc
tostring rate,    gen(temp1) force usedisplayformat
tostring rate_lo, gen(temp2) force usedisplayformat
tostring rate_hi, gen(temp3) force usedisplayformat
gen rate_ci=temp1+" ("+temp2+", "+temp3+")"
drop rate rate_lo rate_hi temp*
rename rate_ci rate

**// Format rate ratios 
foreach myvar in "rateratio" "adj_rateratio" "fulladj_rateratio" "ipw_rateratio" "sipw_rateratio" {
	format `myvar' `myvar'_lo `myvar'_hi %12.2fc
	tostring `myvar',    gen(temp1) force usedisplayformat
	tostring `myvar'_lo, gen(temp2) force usedisplayformat
	tostring `myvar'_hi, gen(temp3) force usedisplayformat
	gen `myvar'_ci=temp1+" ("+temp2+", "+temp3+")"
	drop `myvar' `myvar'_lo `myvar'_hi temp*
	rename `myvar'_ci `myvar'
}

do `mypath'/005_table_edit.do

save $resultsdir/part2_option2_table2b_rateratios.dta, replace
