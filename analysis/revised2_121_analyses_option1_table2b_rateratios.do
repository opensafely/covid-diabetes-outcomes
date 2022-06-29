local mypath="`c(pwd)'/analysis/"

do `mypath'/000_filepaths.do


**// Outcome rates and rate ratios
**//////////////////////////////////////////////

use $outdir/input_part1_clean.dta, clear

drop if group==4

gen adj_ethnic=(cat_ethnic==1)

local grouplabel1="COVID-19 with diabetes"
local grouplabel2="COVID-19 without diabetes"
local grouplabel3="Pneumonia with diabetes"

gen expos=(group==1)

set more off

tempname rates
	postfile `rates' outindex groupindex str30(outcome) str30(group) person_time numevents rate rate_lo rate_hi adj_rateratio adj_rateratio_lo adj_rateratio_hi ///
	using $revisedresultsdir/revised2_option1_table2b_rateratios.dta, replace
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
			post `rates' (`outindex') (1) ("`outcome'") ("`grouplabel1'") (`r(ptime)') (`r(failures)') (`r(rate)') (`r(lb)') (`r(ub)') (.) (.) (.)
		}
		if _rc!=0 {
			post `rates' (`outindex') (1) ("`outcome'") ("`grouplabel1'") (.) (.) (.) (.) (.) (.) (.) (.)
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
				**// Adjusted rate ratio
				if `m'==1 {
					capture nbreg delta expos i.cat_sex i.cat_age i.adj_ethnic i.cat_imd if (group==1 | group==`k') & myselect==1, offset(ln_myend) vce(robust)
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
			post `rates' (`outindex') (`k') ("`outcome'") ("`grouplabel`k''") (`person_time') (`numevents') (`rate') (`rate_lo') (`rate_hi') (`rateratio1') (`rateratio1_lo') (`rateratio1_hi') 
		}
		foreach myvar in myselect myend ln_myend delta _st _d _t _t0 {
			capture drop `myvar'
		}
	}
postclose `rates'

use $revisedresultsdir/revised2_option1_table2b_rateratios.dta, clear

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
foreach myvar in "adj_rateratio" {
	format `myvar' `myvar'_lo `myvar'_hi %12.2fc
	tostring `myvar',    gen(temp1) force usedisplayformat
	tostring `myvar'_lo, gen(temp2) force usedisplayformat
	tostring `myvar'_hi, gen(temp3) force usedisplayformat
	gen `myvar'_ci=temp1+" ("+temp2+", "+temp3+")"
	drop `myvar' `myvar'_lo `myvar'_hi temp*
	rename `myvar'_ci `myvar'
}

do `mypath'/005_table_edit.do

save $revisedresultsdir/revised2_option1_table2b_rateratios.dta, replace
