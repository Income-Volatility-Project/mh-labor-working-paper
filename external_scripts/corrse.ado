program define corrse, eclass
    syntax varlist(min=2)        // Require at least 2 variables

    // Step A: Run estpost correlate on user-specified varlist
    estpost correlate `varlist'

    // Step B: Get the correlation & sample-size matrices into Stata matrices
    matrix R = e(rho)
    matrix N = e(count)

    // Step C: Enter Mata and do the elementwise arithmetic
    mata {
        R = st_matrix("R")
        N = st_matrix("N")
        // Approximate SE formula: SE = sqrt((1 - r^2) / (n - 2))
        SE = sqrt((1 :- R:^2) :/ (N :- 2))
        // Push the SE matrix back into Stata under the name "SE"
        st_matrix("SE", SE)
    }

    // Label SE matrix column correctly
    local var1 : word 1 of `varlist'
    // Grab the rest of the variables
    local varrest : list varlist - var1
    matrix colnames SE = `varrest'

    // Step D: Attach that SE matrix to the current estimation results
    estadd matrix se = SE
end