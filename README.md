
# JSON This

This package provides wrappers around two Stata commands to save their results in JSON files:

- [`reghdfe`](http://scorreia.com/software/reghdfe/)
- `ttest`

The resulting JSON files can be used, for example, to generate arbitrarily formatted regression tables using the [coeftable](https://github.com/gn0/coeftable) Python package.

## Installation

```Stata
capture ado uninstall json_this
net install json_this, from("https://raw.githubusercontent.com/gn0/json-this/master/ado/")
```

## Usage

### `json_reghdfe`

Save the results of `reghdfe y x, absorb(z)` in a file called `foo.json`:

```Stata
json_reghdfe y x using foo.json, absorb(z)
```

`foo.json` looks something like this (broken up here into multiple lines for legibility):

```JSON
{"outcome": "y",
 "N": 300,
 "N_clust": null,
 "clustvar": "",
 "absvars": "a",
 "df_m": 1,
 "df_r": 249,
 "F": 40.68007172613321,
 "F_p": 8.66178084844e-10,
 "r2": 0.2923736048196345,
 "r2_within": 0.1404310330487373,
 "r2_a": 0.1502799511689586,
 "r2_a_within": 0.1369789488441137,
 "mean_outcome": 0.2714693066834782,
 "coef": {"x": {
            "est": 0.4606558396069469,
            "se": 0.0722246965709874,
            "t": 6.378093110494174,
            "p": 8.66178084844e-10,
            "stars": "***",
            "ci_l": 0.3184066369562497,
            "ci_u": 0.6029050422576441}}}
```

The `replace` option allows Stata to overwrite `foo.json` if it already exists:

```Stata
json_reghdfe y x using foo.json, absorb(z) replace
```

`if` conditions, weights, and other options can also be passed on to `reghdfe`:

```Stata
json_reghdfe y x using foo.json if a == 1, absorb(z) replace
json_reghdfe y x using foo.json [aweight=w], absorb(z) replace
json_reghdfe y x using foo.json, absorb(z) vce(robust) replace
```

### `json_ttest`

Save the results of `ttest x == z` in a file called `foo.json`:

```Stata
json_ttest x == z using foo.json
```

`foo.json` looks similar to the following (again, broken up here into multiple lines for legibility):

```JSON
{"spec": "x == z",
 "stars": "",
 "stars_l": "",
 "stars_u": "",
 "N_1": 300,
 "N_2": 300,
 "p_l": 0.77231319,
 "p_u": 0.22768681,
 "p": 0.45537361,
 "se": 0.08032392,
 "t": 0.74745958,
 "sd_1": 1.0311098,
 "sd_2": 1.012639,
 "sd": null,
 "mu_1": 0.01498158,
 "mu_2": -0.0450573,
 "df_t": 299,
 "if_cond": "",
 "by_var": "",
 "diff": 0.06003889}
```

The `replace` option can be used again to allow Stata to overwrite `foo.json`:

```Stata
json_ttest x == z using foo.json, replace
```

`if` conditions and other options can also be passed on to `ttest`:

```Stata
json_ttest x == z if a == 1 using foo.json, replace
json_ttest x using foo.json, by(a) replace
json_ttest x == z using foo.json, unpaired replace
```

## Author

Gabor Nyeki.  Contact information is on http://www.gabornyeki.com/.

## License

This package is licensed under the Creative Commons Attribution 4.0 International License: http://creativecommons.org/licenses/by/4.0/.

