*! version 1.0 24feb2019

capture program drop json_this
program define json_this
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

    return clear
    ereturn clear

    `anything' if `to_use' `weight_exp', `options'

    local r_scalars : r(scalars)
    local r_macros : r(macros)
    local e_scalars : e(scalars)
    local e_macros : e(macros)

    local output `"{"cmd": "`: word 1 of `anything''","'

    forval i = 1/4 {
        local vars : word `i' of r_scalars r_macros e_scalars e_macros
        local ret_type : word `i' of r r e e

        if (~missing("``vars''")) {
            local output `"`output' "`vars'": {"'

            foreach var of local `vars' {
                local value "``ret_type'(`var')'"

                if (~missing(real("`value'"))) {
                    local output `"`output' "`var'": `value',"'
                }
                else {
                    local output `"`output' "`var'": "`value'","'
                }
            }

            local output `"`output'},"'
        }
    }

    local output `"`output'}"'

    local output : subinstr local output `"": { "' `"": {"', all
    local output : subinstr local output `",}"' `"}"', all
    local output : subinstr local output `"},}"' `"}}"', all

    file open fh using "`using'", write `replace'
    file write fh `"`output'"'
    file close fh
end

