*! version 1.2 24feb2019

capture program drop json_reg
program define json_reg
    syntax anything using/ [if] [aweight fweight pweight/], [TABPARAMS(string asis)] [REPLACE] [*]
    marksample to_use

    if (~missing(`"`tabparams'"') & mod(`: word count `tabparams'', 2) == 1) {
        display as error "option tabparams() requires an even number of values"
        exit 111
    }

    local weight_exp ""
    if ("`weight'" != "") {
        local weight_exp "[`weight'=`exp']"
    }

    reg `anything' if `to_use' `weight_exp', `options'

    local outcome : word 1 of `anything'
    matrix beta = e(b)
    matrix V = e(V)
    local df_m = e(df_m)
    local df_r = e(df_r)
    local F = e(F)
    local F_p = Ftail(`df_m', `df_r', `F')
    local t_cv = invttail(`df_r', .025)

    local output `"{"outcome": "`outcome'","'
    local output `"`output' "N": `e(N)',"'

    if (~missing("`e(N_clust)'")) {
        local output `"`output' "N_clust": `e(N_clust)',"'
    }
    else {
        local output `"`output' "N_clust": null,"'
    }

    local output `"`output' "clustvar": "`e(clustvar)'","'
    local output `"`output' "df_m": `df_m',"'
    local output `"`output' "df_r": `df_r',"'
    local output `"`output' "F": `F',"'
    local output `"`output' "F_p": `F_p',"'
    local output `"`output' "r2": `e(r2)',"'
    local output `"`output' "r2_a": `e(r2_a)',"'

    if (~missing(`"`tabparams'"')) {
        forval i = 1(2)`: word count `tabparams'' {
            local key : word `i' of `tabparams'
            local value : word `= `i' + 1' of `tabparams'

            if (~missing(real("`value'"))) {
                local output `"`output' "`key'": `value',"'
            }
            else {
                local output `"`output' "`key'": "`value'","'
            }
        }
    }

    quietly summ `outcome' if e(sample)
    local output `"`output' "mean_outcome": `r(mean)',"'

    local output `"`output' "coef": {"'

    forval i = 1/`= colsof(beta)' {
        local coef_name : word `i' of `: colfullnames(beta)'
        local est = beta[1, `i']
        local se = sqrt(V[`i', `i'])
        local ci_l = `est' - `t_cv' * `se'
        local ci_u = `est' + `t_cv' * `se'
        local t = `est' / `se'

        local p = 1
        if (`se' > 0) {
            local p = 2 * ttail(`df_r', abs(`t'))
        }

        local stars ""
        if (`p' <= .01) {
            local stars "***"
        }
        else if (`p' <= .05) {
            local stars "**"
        }
        else if (`p' <= .1) {
            local stars "*"
        }

        local output `"`output' "`coef_name'": {"'
        local output `"`output' "est": `est',"'
        local output `"`output' "se": `se',"'
        local output `"`output' "t": `t',"'
        local output `"`output' "p": `p',"'
        local output `"`output' "stars": "`stars'","'
        local output `"`output' "ci_l": `ci_l',"'
        local output `"`output' "ci_u": `ci_u'"'
        local output `"`output'},"'
    }

    local output `"`output'}}"'

    local output : subinstr local output "{ " "{", all
    local output : subinstr local output ",}" "}", all
    local output : subinstr local output " ." " 0.", all
    local output : subinstr local output "-." "-0.", all
    local output : subinstr local output "0.," "0.0,", all

    file open fh using "`using'", write `replace'
    file write fh `"`output'"'
    file close fh
end

