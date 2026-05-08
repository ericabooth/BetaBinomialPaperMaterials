
# Beta Binomial Materials (pre-print manuscript)
_forked from @farharboratx_

This repository contains the pre-print manuscript and accompanying R code for our methodological paper **"Rethinking 'Signal-To-Noise': A Coherent Beta-Binomial Reliability Formulation for Assessing Quality Measures"**. 

in this paper, we derive and advocate for an an alternative beta-binomial reliability formulation that aligns with classical test theory (CTT). This formulation provides a more mathematically coherent and stable alternative to the widely used Adams (2009) "signal-to-noise" approach. The methodology is particularly relevant for assessing health care quality measures used in provider profiling and pay-for-performance programs. 

The repository includes real-world comparative examples using contraceptive care measures (the moderate-rate "Most-Mod" measure and the low-rate "LARC" measure) aggregated across 99 Iowa counties using Medicaid data. 

---

## Authors
* **Samuel Field** 
* **Fei Dong** 
* **Eric Booth** [github](www.github.com/ericabooth)
* **Philip Hastings**
* Pat Malone

**Affiliation**: Far Harbor, LLC, Austin, TX, United States of America.

---

## Repository Contents

### Manuscript
* **`Round 2_Revise_Resubmit_A Coherent Beta-Binomial Reliability Formulation for Assessing Quality Measures_05062026.pdf`**: The full pre-print manuscript. It outlines the mathematical derivations equating the proposed reliability formulation to the Empirical Bayes (EB) shrinkage factor and provides empirical comparisons against the Adams (2009) approach.

### R Code & Tools
* **`beta_rel_method.R`**: An R script containing the `beta_rel` function. This function estimates the beta-binomial model and calculates the proposed reliability statistic for cluster-level data (e.g., clinics, counties, or providers). It outputs a merged dataset containing the original data and the calculated reliability.
* **`beta_rel_threshold_tool.R`**: An R script containing the `beta.rel.threshold` function. This tool estimates the probability that a provider's performance rate falls below a user-specified quality threshold. It outputs the reliability statistic alongside the threshold classification probability.
* **`Code for figures.R`**: The complete R code required to reproduce all visualizations from the manuscript, including Figures 1 through 5 and Supplemental Figures 1 and 2. This includes density plots of the fitted beta distributions, prior/posterior distribution overlays, and comparative scatterplots of the two reliability methods.

---

## Dependencies

The R scripts provided in this repository require several standard packages. If you are running the code for the first time, you will need to install the following:

* `openxlsx`
* `plyr`
* `dplyr`
* `lme4`
* `haven`
* `gsubfn`
* `VGAM` (specifically required for the `vglm` function to estimate the beta-binomial model)

---

## Usage

To use the tools provided in this repository:
1. Load the required R libraries listed above.
2. Read your quality measure dataset into R (the examples use `.xlsx` files via the `openxlsx` package).
3. Ensure your dataset contains variables for the **cluster ID**, the **count of service incidents** (numerator), and the **total count of eligible patients** (denominator).
4. Run the desired function (`beta_rel` or `beta.rel.threshold`) by passing your dataset's specific variables as arguments. 
5. Merge the function's output data frame back with your original dataset to append the reliability statistics.
```
