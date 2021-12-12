gen strpos=strpos(outcome,":")
recode strpos 0=.
gen category=substr(outcome,strpos+2,.)
gen temp=substr(outcome,1,strpos-1)
replace temp=temp[_n-1] if temp==""
gen flag=1 if temp==temp[_n-1]
replace temp="" if flag==1
replace outcome=temp
order category, after(outcome)
drop strpos temp flag

replace category="" if (outcome=="DVT" | outcome=="PE" | outcome=="AKI")

foreach myvar in "type" "outcome" "category" {
   gen str=strlen(`myvar')
   summ str
   format `myvar' %-`r(max)'s
   drop str
}
