**// Set filepaths and create results directory
global projectdir `c(pwd)'
global outdir $projectdir/output 
global resultsdir $projectdir/output/results
global revisedresultsdir $projectdir/output/revised_results
capture mkdir "$resultsdir"
capture mkdir "$revisedresultsdir"
