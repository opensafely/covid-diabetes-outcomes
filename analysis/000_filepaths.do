**// Set filepaths and create results directory
global projectdir `c(pwd)'
global outdir $projectdir/output 
global resultsdir $projectdir/output/part1
capture mkdir "$resultsdir"
