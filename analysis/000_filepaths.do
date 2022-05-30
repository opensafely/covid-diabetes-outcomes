**// Set filepaths and create results directory
global projectdir `c(pwd)'
global outdir $projectdir/output
global resultsdir $outdir/results
global revisedresultsdir $outdir/revised_results
global tempresultsdir $outdir/temp_results
capture mkdir "$resultsdir"
capture mkdir "$revisedresultsdir"
capture mkdir "$tempresultsdir"
