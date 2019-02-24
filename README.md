
# JSON This

This package provides wrappers around Stata commands to save their results in JSON files.
A generic wrapper, `json_this`, works with any r-class or e-class command.
In addition to this, the package also contains three specialized wrappers around:

- `reg`
- [`reghdfe`](http://scorreia.com/software/reghdfe/)
- `ttest`

The resulting JSON files can be used, for example, to generate arbitrarily formatted regression tables using the [coeftable](https://github.com/gn0/coeftable) Python package.

## Installation

```Stata
capture ado uninstall json_this
net install json_this, from("https://raw.githubusercontent.com/gn0/json-this/master/ado/")
```

## Usage

### `json_reg` and `json_reghdfe`

The usage of `json_reg` is nearly identical to that of `json_reghdfe`.
This subsection illustrates the latter.

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

### `json_this`

`json_reg`, `json_reghdfe`, and `json_ttest` are specifically designed to export results from linear regressions and hypothesis tests.
Results from other types of commands can be exported with `json_this`.
`json_this` is a generic wrapper for r-class and e-class commands.

Save the results of `summarize x, detail` in a file called `foo.json`:

```Stata
json_this summarize x using foo.json, detail
```

`foo.json` looks similar to the following (broken up into multiple lines for legibility):

```JSON
{"cmd": "summarize",
 "r_scalars": {
   "N": 15805,
   "sum_w": 15805,
   "mean": 768.3155963302752,
   "Var": 27148076.45847922,
   "sd": 5210.381603921081,
   "skewness": 55.50313309587089,
   "kurtosis": 3639.847818166637,
   "sum": 12143228,
   "min": 7,
   "max": 362289,
   "p1": 27,
   "p5": 52,
   "p10": 77,
   "p25": 137,
   "p50": 270,
   "p75": 551,
   "p90": 1138,
   "p95": 2114,
   "p99": 9671}}
```

Save the results of `lincom`, after running `reg`, in a file called `bar.json`:

```Stata
reg y x z
json_this lincom 3 * x - 10 * z using bar.json
```

`json_this` does not clear `r()` and `e()`.
If it did, it would not be able to run `lincom`.
One side effect of this is that `bar.json` contains results from both `lincom` and `reg`:

```JSON
{"cmd": "lincom",
 "r_scalars": {
   "df": 12775,
   "se": 510.7233517176288,
   "estimate": 306.5145980089461},
 "e_scalars": {
   "rank": 3,
   "ll_0": -125549.2076105619,
   "ll": -107910.0624743788,
   "r2_a": 0.9367528438844114,
   "rss": 16188712291.35621,
   "mss": 239810888673.0277,
   "rmse": 1125.707858761062,
   "r2": 0.9367627440419,
   "F": 94620.99417362853,
   "df_r": 12775,
   "df_m": 2,
   "N": 12778},
 "e_macros": {
   "cmdline": "regress y x z",
   "title": "Linear regression",
   "marginsok": "XB default",
   "vce": "ols",
   "depvar": "y",
   "cmd": "regress",
   "properties": "b V",
   "predict": "regres_p",
   "model": "ols",
   "estat_cmd": "regress_estat"}}
```

`json_this` can also be used to export results from user-written programs.
For example, the following program called `baz` saves its results in `r()` scalars:

```Stata
program define baz, rclass
    return scalar a = 2
    return scalar b = 3
    return scalar c = 5
end
```

Save these in a file called `baz.json`:

```Stata
json_this baz using baz.json
```

Then `baz.json` contains:

```JSON
{"cmd": "baz",
 "r_scalars": {
   "c": 5,
   "b": 3,
   "a": 2}}
```

`json_this` also accepts the `replace` option to allow Stata to overwrite the output file.

## Author

Gabor Nyeki.  Contact information is on http://www.gabornyeki.com/.

## License

This package is licensed under the Creative Commons Attribution 4.0 International License: http://creativecommons.org/licenses/by/4.0/.

