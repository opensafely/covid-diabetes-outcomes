**// Set filepaths and create output directory
global projectdir `c(pwd)'
global outdir $projectdir/output 
global resultsdir $projectdir/output/part1
capture mkdir "$resultsdir"
