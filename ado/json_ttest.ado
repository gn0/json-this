*! version 1.0 3sep2018

capture program drop json_ttest
program define json_ttest
    syntax anything [using/] [if], [TABPARAMS(string asis)] [REPLACE] [BY(varname)] [*]
    marksample to_use

    if (~missing(`"`tabparams'"') & mod(`: word count `tabparams'', 2) == 1) {
        display as error "option tabparams() requires an even number of values"
        exit 111
    }

    local by_exp ""
    if ("`by'" != "") {
        local by_exp "by(`by')"
    }

    ttest `anything' if `to_use', `by_exp' `options'

    if (~missing("`using'")) {
        local output `"{"spec": "`anything'","'

        foreach p_type in "" "_l" "_u" {
            if (r(p`p_type') <= .01) {
                local output `"`output' "stars`p_type'": "***","'
            }
            else if (r(p`p_type') <= .05) {
                local output `"`output' "stars`p_type'": "**","'
            }
            else if (r(p`p_type') <= .1) {
                local output `"`output' "stars`p_type'": "*","'
            }
            else {
                local output `"`output' "stars`p_type'": "","'
            }
        }

        foreach s in N_1 N_2 p_l p_u p se t sd_1 sd_2 sd mu_1 mu_2 df_t {
            if (~missing(r(`s'))) {
                local number : di r(`s')
                local output `"`output' "`s'": `= regexr("`= regexr("`number'", "^[.]", "0.")'", "^-[.]", "-0.")',"'
            }
            else {
                local output `"`output' "`s'": null,"'
            }
        }

        local output `"`output' "if_cond": "`if'","'
        local output `"`output' "by_var": "`by'","'

        if (~missing(r(mu_1) - r(mu_2))) {
            local number : di r(mu_1) - r(mu_2)
            local output `"`output' "diff": `= regexr("`= regexr("`number'", "^[.]", "0.")'", "^-[.]", "-0.")'}"'
        }
        else {
            local output `"`output' "diff": null}"'
        }

        file open fh using "`using'", write `replace'
        file write fh `"`output'"'
        file close fh
    }
end

