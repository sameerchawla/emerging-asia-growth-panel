# Determinants of GDP Growth in Asian Economies
### Panel Data Analysis — 10 Emerging Economies, 1995–2024

<p align="left">
  <img src="https://img.shields.io/badge/Language-R%204.2%2B-276DC3?style=flat-square&logo=r" />
  <img src="https://img.shields.io/badge/Data-World%20Bank%20WDI-003087?style=flat-square" />
  <img src="https://img.shields.io/badge/Method-Panel%20Data%20Econometrics-2E86AB?style=flat-square" />
  <img src="https://img.shields.io/badge/Status-Complete-28a745?style=flat-square" />
</p>

---

## Author

| | |
|---|---|
| **Name** | Sameer Chawla |
| **Programme** | MSc Economics |
| **Institution** | Gokhale Institute of Politics and Economics (GIPE), Pune |
| **Expected Graduation** | 2027 |

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Research Question and Hypotheses](#2-research-question-and-hypotheses)
3. [Data](#3-data)
4. [Methodology](#4-methodology)
5. [Results](#5-results)
6. [Limitations](#6-limitations)
7. [Robustness Checks](#7-robustness-checks)
8. [How to Run](#8-how-to-run)
9. [Repository Structure](#9-repository-structure)
10. [Education and Skills](#10-education-and-skills)
11. [Relevance to CRISIL](#11-relevance-to-crisil)
12. [References](#12-references)

---

## 1. Project Overview

This project examines the **macroeconomic determinants of annual GDP growth** across ten emerging Asian economies from 1995 to 2024 using panel data econometrics. The ten countries — Bangladesh, China, India, Indonesia, Malaysia, Pakistan, Philippines, Sri Lanka, Thailand, and Vietnam — represent a diverse cross-section of Asian development experiences, collectively accounting for a substantial share of global output and population.

The sample period deliberately captures three major global shocks: the **Asian Financial Crisis (1997–98)**, the **Global Financial Crisis (2008–09)**, and the **COVID-19 pandemic (2020–21)**. These events provide rich within-country variation and allow the analysis to control for common external shocks that would otherwise bias coefficient estimates.

The core contribution of this paper is methodological. Rather than applying standard first-generation panel tools, the analysis explicitly accounts for **cross-section dependence (CSD)** — a feature that arises naturally in tightly integrated regional economies and invalidates conventional unit-root tests and standard error estimators. The econometric pipeline moves from CSD testing through second-generation unit-root tests to Fixed Effects estimation with Driscoll-Kraay standard errors, which are consistent under both serial correlation and cross-sectional dependence.

The project is fully reproducible. A single R script downloads live data from the World Bank API and replicates all tables and test statistics reported here.

---

## 2. Research Question and Hypotheses

### Research Question

> What macroeconomic factors — specifically inflation, foreign direct investment inflows, trade openness, and gross capital formation — explain **within-country variation** in annual GDP growth across ten emerging Asian economies during 1995–2024?

The emphasis on within-country variation distinguishes this study from cross-sectional growth regressions. By exploiting panel variation, the estimates control for time-invariant country characteristics (institutional quality, geography, culture) that would otherwise confound a pure cross-section analysis.

### Empirical Model

```
GDP_growth_it = α + β₁·Inflation_it + β₂·FDI_it + β₃·ΔTrade_it
                  + β₄·Investment_it + β₅·COVID_t + β₆·GFC_t
                  + μᵢ + εᵢₜ
```

| Symbol | Description |
|--------|-------------|
| `i` | Country (N = 10) |
| `t` | Year (T = 23–29 per country) |
| `μᵢ` | Unobserved time-invariant country fixed effect |
| `ΔTrade` | First difference of trade openness — trade is I(1) in levels |
| `COVID_t` | Binary dummy: 1 in 2020–2021, 0 otherwise |
| `GFC_t` | Binary dummy: 1 in 2008–2009, 0 otherwise |

### Hypotheses

| Hypothesis | Variable | Predicted Sign | Economic Rationale |
|------------|----------|----------------|--------------------|
| H1 | Inflation | **Negative** | High inflation increases uncertainty, erodes real returns, discourages investment and distorts price signals |
| H2 | FDI | **Positive** | Foreign capital inflows promote technology transfer, productivity spillovers, and capital accumulation in host economies |
| H3 | ΔTrade | **Non-zero** (two-sided) | Trade liberalisation may raise allocative efficiency, though short-run effects on growth are theoretically ambiguous |
| H4 | Investment | **Positive** | Gross capital formation drives output expansion through the capital accumulation channel (Solow 1956) |

---

## 3. Data

**Source:** World Bank World Development Indicators (WDI, 2025). Downloaded automatically via the `WDI` R package — no manual data files required.

**Sample:** 10 Asian economies, 1995–2024. After first-differencing trade openness and removing observations with missing values, the final estimation sample is **N = 284** country-year observations (unbalanced panel: T = 23–29 per country).

### Variable Definitions

| Variable | WDI Indicator Code | Units |
|----------|--------------------|-------|
| GDP Growth | `NY.GDP.MKTP.KD.ZG` | Annual % |
| Inflation | `FP.CPI.TOTL.ZG` | Annual % (CPI) |
| FDI | `BX.KLT.DINV.WD.GD.ZS` | % of GDP |
| Trade Openness | `NE.TRD.GNFS.ZS` | (Exports + Imports) / GDP % |
| Investment | `NE.GDI.TOTL.ZS` | Gross capital formation, % of GDP |

### Country Coverage

| Country | ISO | T (obs.) | Notes |
|---------|-----|----------|-------|
| Bangladesh | BGD | 29 | Full coverage |
| China | CHN | 29 | Largest economy; sensitivity check excludes it |
| India | IND | 29 | Full coverage |
| Indonesia | IDN | 29 | Full coverage |
| Malaysia | MYS | 29 | Full coverage |
| Pakistan | PAK | 29 | Full coverage |
| Philippines | PHL | 29 | Full coverage |
| Sri Lanka | LKA | 23 | Unbalanced; sensitivity check excludes it |
| Thailand | THA | 29 | Full coverage |
| Vietnam | VNM | 29 | Full coverage |

### Descriptive Statistics

| Variable | N | Mean | Std Dev | Min | Median | Max |
|----------|---|------|---------|-----|--------|-----|
| GDP Growth (%) | 284 | 5.14 | 3.25 | −13.10 | 5.81 | 14.15 |
| Inflation (%) | 284 | 5.77 | 6.22 | −1.71 | 3.51 | 58.45 |
| FDI (% GDP) | 284 | 2.16 | 1.99 | −2.76 | 1.96 | 9.71 |
| Trade Openness (%) | 284 | 75.57 | 56.84 | 21.46 | 55.70 | 220.41 |
| ΔTrade (%) | 284 | 0.88 | 6.23 | −43.34 | 0.73 | 60.02 |
| Investment (% GDP) | 284 | 27.93 | 7.08 | 13.17 | 27.12 | 46.27 |

---

## 4. Methodology

### Step-by-Step Econometric Pipeline

The analysis follows a sequential procedure in which each step informs the next. The order matters — testing for cross-section dependence before unit-root tests is not optional; it determines which test is valid.

```
STEP 1:  Pesaran CD Test
         Test for cross-section dependence on preliminary FE residuals.
         Result: z = 13.97, p < 0.001 → CSD strongly confirmed.
         Implication: IPS test assumes cross-sectional independence
                      → IPS is now INVALID for this dataset.
              │
              ▼
STEP 2:  Panel Unit-Root Tests
         ├── IPS (Im-Pesaran-Shin 2003)
         │       Shown for reference only — invalid under CSD.
         └── CIPS (Pesaran 2007)  ← PREFERRED
                 Augments each country's ADF with cross-sectional averages,
                 making it robust to cross-section dependence.
         Result: trade openness is I(1) in levels; all other variables I(0).
              │
              ▼
STEP 3:  Variable Treatment
         ├── Enter in levels : GDP growth, inflation, FDI, investment
         └── First-difference: trade openness → ΔTrade
                 Differencing removes the unit root and prevents
                 spurious regression of I(0) on I(1).
              │
              ▼
STEP 4:  Panel Model Estimation
         ├── Pooled OLS        — baseline, no country effects
         ├── Fixed Effects     — within-group transformation, removes μᵢ
         └── Random Effects    — Wallace-Hussain method
                 (Default Swamy-Arora fails with singularity when
                  COVID + GFC dummies are both included)
              │
              ▼
STEP 5:  Model Selection
         ├── F-test            F(9, 268) = 8.29, p < 0.001 → reject Pooled OLS
         ├── Breusch-Pagan LM  χ²(1) = 89.5,    p < 0.001 → RE over Pooled OLS
         └── Hausman Test      χ²(6) = 5.54,    p = 0.480 → RE formally preferred
                 Note: Hausman result overridden by diagnostic failures below.
              │
              ▼
STEP 6:  Post-Estimation Diagnostics (on FE residuals)
         ├── Breusch-Godfrey  χ²(23) = 40.5, p = 0.013 → serial correlation PRESENT
         ├── Breusch-Pagan    BP(6)  = 38.5,  p < 0.001 → heteroskedasticity PRESENT
         └── Pesaran CD       z = 10.0,       p < 0.001 → residual CSD PRESENT
                 Default standard errors are biased — robust inference required.
              │
              ▼
STEP 7:  Robust Standard Errors
         ├── HC3 Cluster-Robust SE  (clustered by country)
         │       Valid asymptotically as number of clusters → ∞.
         │       ⚠ With only N=10 clusters, may still underestimate uncertainty.
         └── Driscoll-Kraay SCC SE  (maxlag = 2)  ← PREFERRED
                 Consistent under serial correlation AND cross-section dependence.
                 Does not require large N — valid as T → ∞.
                 Better suited to small-N, moderate-T panels like this one.
              │
              ▼
STEP 8:  Robustness Checks
         ├── Exclude Sri Lanka   (unbalanced T, unusual post-2022 dynamics)
         ├── Exclude China       (structural outlier, dominant FDI absorber)
         └── Exclude both
```

### Why Wallace-Hussain Random Effects?

The default Swamy-Arora RE estimator throws the following error when both COVID and GFC dummies are included alongside country effects:

```
Error in solve.default(crossprod(ZBeta)):
  Lapack routine dgesv: system is exactly singular: U[7,7] = 0
```

Wallace-Hussain (1969) uses a different variance-component estimator that does not require inverting the between-groups matrix — resolving the singularity.

---

## 5. Results

### 5.1 Model Selection and Diagnostics

| Test | Statistic | p-value | Conclusion |
|------|-----------|---------|------------|
| F-test (FE vs Pooled OLS) | F(9, 268) = 8.29 | < 0.001 | Reject Pooled OLS |
| Breusch-Pagan LM (RE vs Pooled) | χ²(1) = 89.5 | < 0.001 | Random effects present |
| Hausman (FE vs RE) | χ²(6) = 5.54 | = 0.480 | RE formally preferred |
| Serial Correlation (BG) | χ²(23) = 40.5 | = 0.013 | **Present — robust SE required** |
| Heteroskedasticity (BP) | BP(6) = 38.5 | < 0.001 | **Present** |
| Residual CSD (Pesaran CD) | z = 10.0 | < 0.001 | **Present — Driscoll-Kraay SE used** |

**Preferred specification:** Fixed Effects with Driscoll-Kraay standard errors. Although the Hausman test formally prefers RE, confirmed serial correlation and residual CSD invalidate RE standard errors. FE with Driscoll-Kraay SE is the most appropriate estimator for this panel.

---

### 5.2 Regression Tables

#### Table 1 — Pooled OLS

> Baseline model. Ignores country heterogeneity. Rejected by F-test (F = 8.29, p < 0.001).

| Variable | Coefficient | Std. Error | Sig. |
|----------|-------------|------------|------|
| Inflation (%) | −0.1703 | (0.0282) | *** |
| FDI (% GDP) | +0.1901 | (0.1007) | . |
| ΔTrade | +0.0104 | (0.0232) | |
| Investment (% GDP) | +0.1363 | (0.0218) | *** |
| COVID Dummy | −4.4615 | (0.6318) | *** |
| GFC Dummy | −0.6324 | (0.6572) | |
| Constant | +2.1931 | (0.6549) | *** |
| **N = 284** | **R² = 0.359** | **Adj. R² = 0.345** | F = 25.89 *** |

---

#### Table 2 — Fixed Effects (Within Transformation)

> Removes time-invariant country heterogeneity. No constant — absorbed by country dummies.

| Variable | Coefficient | Std. Error | Sig. |
|----------|-------------|------------|------|
| Inflation (%) | −0.2147 | (0.0283) | *** |
| FDI (% GDP) | +0.6252 | (0.1332) | *** |
| ΔTrade | +0.0073 | (0.0212) | |
| Investment (% GDP) | +0.0963 | (0.0370) | ** |
| COVID Dummy | −4.3719 | (0.5699) | *** |
| GFC Dummy | −0.6984 | (0.5935) | |
| **N = 284** | **Within R² = 0.356** | **Adj. R² = 0.320** | F = 24.73 *** |

---

#### Table 3 — Random Effects (Wallace-Hussain)

> Hausman test (p = 0.48) formally recommends RE. Standard errors unreliable under confirmed CSD and serial correlation.

| Variable | Coefficient | Std. Error | Sig. |
|----------|-------------|------------|------|
| Inflation (%) | −0.2059 | (0.0279) | *** |
| FDI (% GDP) | +0.5219 | (0.1251) | *** |
| ΔTrade | +0.0079 | (0.0213) | |
| Investment (% GDP) | +0.1051 | (0.0326) | ** |
| COVID Dummy | −4.3927 | (0.5718) | *** |
| GFC Dummy | −0.6757 | (0.5955) | |
| Constant | +2.5375 | (1.0076) | * |
| **N = 284** | **R² = 0.350** | **Chi-sq = 149.75 ***` | Idio. var. = 6.03 |

---

#### Table 4 — Fixed Effects + HC3 Cluster-Robust SE

> Same FE point estimates as Table 2. Standard errors corrected for heteroskedasticity and within-cluster correlation.

| Variable | Coefficient | HC3 SE | Sig. |
|----------|-------------|--------|------|
| Inflation (%) | −0.2147 | (0.0515) | *** |
| FDI (% GDP) | +0.6252 | (0.2424) | * |
| ΔTrade | +0.0073 | (0.0295) | |
| Investment (% GDP) | +0.0963 | (0.0457) | * |
| COVID Dummy | −4.3719 | (0.7629) | *** |
| GFC Dummy | −0.6984 | (0.5025) | |
| **N = 284** | **N clusters = 10** | **⚠ May be downward biased** | |

> **Note:** Cameron & Miller (2015) recommend ≥ 30 clusters for reliable inference. With N = 10 countries, HC3 SEs likely underestimate true uncertainty. Compare with Table 5.

---

#### Table 5 — Fixed Effects + Driscoll-Kraay SE *(Preferred Specification)*

> Same FE coefficients as Tables 2 and 4. Driscoll-Kraay SEs are consistent under serial correlation and cross-sectional dependence without requiring large N.

| Variable | Coefficient | DK SE | Sig. |
|----------|-------------|-------|------|
| Inflation (%) | −0.2147 | (0.0666) | ** |
| FDI (% GDP) | +0.6252 | (0.1002) | *** |
| ΔTrade | +0.0073 | (0.0585) | |
| Investment (% GDP) | +0.0963 | (0.0367) | ** |
| COVID Dummy | −4.3719 | (1.5342) | ** |
| GFC Dummy | −0.6984 | (0.4844) | |
| **N = 284** | **maxlag = 2** | **Valid under CSD + serial corr.** | ✅ Preferred |

`*** p < 0.001   ** p < 0.01   * p < 0.05   . p < 0.10`

---

### 5.3 Key Findings

**Inflation (H1 — Supported)**
Inflation is negative and highly significant across all five model specifications. The preferred FE-DK estimate of −0.215 (p < 0.01) implies that a one percentage point increase in inflation is associated with approximately a 0.22 percentage point reduction in GDP growth, holding all else constant. This is consistent with the literature: high inflation raises uncertainty, misallocates resources, and erodes real returns to capital.

**FDI (H2 — Supported)**
FDI is positive and significant across all specifications. The FE-DK estimate of +0.625 (p < 0.001) suggests that a one percentage point increase in FDI as a share of GDP is associated with roughly 0.63 percentage points of additional growth. This supports the FDI-led growth hypothesis and is consistent with the technology transfer and productivity spillover channels emphasised in the literature. The coefficient attenuates when China is excluded (to +0.458), indicating that China's large FDI absorption modestly inflates the full-sample estimate.

**Trade Openness (H3 — Not Supported)**
The first difference of trade openness is statistically insignificant in all models under all SE specifications. The coefficient is economically small and consistent with zero. Short-run fluctuations in trade intensity do not appear to translate into contemporaneous growth outcomes in this panel. This does not rule out long-run trade-growth relationships — the use of first differences limits the analysis to short-run dynamics.

**Investment (H4 — Partially Supported)**
Gross capital formation enters with a positive coefficient consistent with the Solow (1956) capital accumulation channel. Under default FE SEs the coefficient is significant at 5%; it remains significant at 5% under Driscoll-Kraay SEs (+0.096, p < 0.01) but attenuates to 5–10% under HC3 SEs. The positive direction is stable across all sub-samples in the robustness checks.

**COVID-19 and GFC Dummies**
The COVID-19 dummy is large, negative, and highly significant across all specifications (coefficient ≈ −4.37, p < 0.01 under DK SEs), consistent with the severe output contractions observed across Asian economies in 2020. The GFC dummy is consistently insignificant in the full sample, suggesting the within-country average growth drag from the GFC was muted once country fixed effects and the macroeconomic regressors are controlled for — though it becomes marginally significant when Sri Lanka is excluded.

### 5.4 Hypothesis Summary

| Hypothesis | Variable | Predicted | FE-DK Coefficient | p-value | Verdict |
|------------|----------|-----------|-------------------|---------|---------|
| H1 | Inflation | Negative | −0.2147 | 0.001 | ✅ Supported |
| H2 | FDI | Positive | +0.6252 | < 0.001 | ✅ Supported |
| H3 | ΔTrade | Non-zero | +0.0073 | 0.901 | ❌ Not Supported |
| H4 | Investment | Positive | +0.0963 | 0.009 | ⚠️ Partially Supported |

---

## 6. Limitations

This study provides useful empirical evidence on the macroeconomic determinants of growth in emerging Asian economies, but several econometric and data limitations qualify the findings and should be considered when interpreting the results.

### 6.1 Endogeneity and Reverse Causality

The most important limitation is the likely **endogeneity of FDI and investment**. Higher economic growth attracts more foreign direct investment — countries growing faster are more attractive investment destinations. Similarly, investment rates may be a response to positive growth expectations rather than an autonomous cause of growth. The static panel models used here (Pooled OLS, Fixed Effects, Random Effects) do not address this reverse causality. As a result, the FDI and investment coefficients should be interpreted as **associations**, not causal effects.

The appropriate solution — System GMM (Blundell and Bond 1998), which instruments for lagged endogenous variables — requires substantially larger cross-sections than N = 10 to produce reliable estimates. This is a binding constraint of the dataset.

### 6.2 Small Cross-Sectional Dimension (N = 10)

The panel has only ten countries. This creates two compounding problems. First, **cluster-robust HC3 standard errors** are known to be downward biased with fewer than approximately 30 clusters (Cameron and Miller 2015), meaning t-statistics from Table 4 are likely inflated and should be treated with caution. Second, many advanced panel estimators (System GMM, CCE-Mean Group, pooled CCEMG) are designed for panels with large N and perform poorly when N is small. The Driscoll-Kraay estimator is used precisely because it does not require large N, but it comes with its own caveat — it is asymptotically valid as T grows, not N, which holds reasonably well here (T ≈ 25–29) but is not guaranteed to deliver adequate finite-sample performance.

### 6.3 CIPS Non-Significance for Several Variables

The preferred CIPS unit-root test returns p-values above 0.10 for inflation, FDI, and investment — meaning CIPS does not conclusively confirm stationarity for these variables. The analysis treats them as I(0) based on the IPS test (which is invalid under CSD) and economic reasoning (stationary macro rates are theoretically expected). A more rigorous approach would apply Moon-Perron (2004) or panel KPSS tests as additional confirmation. If these variables are in fact near-integrated, coefficient estimates may be imprecise even in first-differenced specifications.

### 6.4 No Long-Run Analysis

Because trade openness is I(1) and enters the model in first differences, the analysis is confined to **short-run associations**. Potential long-run equilibrium relationships between trade integration and economic growth — which are arguably more policy-relevant for assessing the cumulative effects of trade liberalisation — are not captured. Panel cointegration tests (Pedroni 1999; Westerlund 2007) followed by a panel error correction model or panel ARDL framework would be needed to investigate long-run dynamics.

### 6.5 Omitted Variable Bias

Economic growth is influenced by many variables not included in this model: human capital accumulation, institutional quality, financial sector development, government expenditure and fiscal policy, technological progress, demographic structure, and political stability. Country fixed effects absorb time-invariant omitted variables, but **time-varying omissions** remain. For example, if institutional quality deteriorated in Pakistan during years of high inflation, the inflation coefficient may partially capture an institutional quality effect rather than a pure inflation effect. The direction of this bias is difficult to sign without additional data.

### 6.6 Unbalanced Panel and Sri Lanka

Sri Lanka has only 23 observations compared to 29 for most other countries. The missing years correspond partly to the 2022 sovereign debt crisis — a period of extreme macroeconomic instability that is absent from the sample but relevant for characterising Sri Lanka's growth dynamics. This creates a **non-random attrition** problem: the years for which Sri Lanka data is missing are precisely the years when its behaviour would diverge most sharply from the rest of the panel. The robustness check excluding Sri Lanka addresses this partially.

### 6.7 Interpretation as Associations, Not Causal Effects

Given the endogeneity concerns in limitation 6.1 and the absence of instrumental variables or a natural experiment, all coefficients should be interpreted as **conditional associations** — the estimated partial correlation between each variable and GDP growth after controlling for the others and for country fixed effects. Claims of causality are not warranted by this analysis.

---

## 7. Robustness Checks

To verify that the core findings are not driven by individual influential observations, the Fixed Effects model is re-estimated on three sub-samples.

### Results (FE + HC3 Cluster-Robust SE)

| Variable | Full Sample | Excl. Sri Lanka | Excl. China | Excl. Both |
|----------|-------------|-----------------|-------------|------------|
| Inflation | −0.215 *** | −0.216 * | −0.218 *** | Negative *** |
| FDI | +0.625 * | +0.580 * | +0.458 . | Positive |
| ΔTrade | +0.007 | +0.002 | +0.008 | Insignificant |
| Investment | +0.096 * | +0.119 * | +0.110 * | Positive * |
| COVID | −4.372 *** | −4.311 *** | −4.620 *** | Negative *** |
| GFC | −0.698 | −0.991 * | −0.780 | Mixed |

`*** p<0.001  ** p<0.01  * p<0.05  . p<0.10`

**Interpretation:**
- The **inflation** result is the most robust — it is negative and significant in every sub-sample under both HC3 and Driscoll-Kraay SEs.
- **FDI** remains positive and significant when Sri Lanka is excluded but attenuates when China is excluded, confirming that China's large FDI flows modestly inflate the full-sample coefficient. The direction is stable.
- **Investment** recovers stronger significance when Sri Lanka is excluded, consistent with the hypothesis that Sri Lanka's unbalanced and atypical observations add noise to the estimate.
- The **GFC dummy** becomes significant when Sri Lanka is excluded, suggesting Sri Lanka's post-GFC trajectory is unusual enough to dampen the GFC coefficient in the full sample.
- **ΔTrade** is insignificant in all sub-samples without exception.

---

## 8. How to Run

### Requirements
- R version ≥ 4.2.0
- Internet connection on first run (for World Bank API download)

### In RStudio
```r
# Open the script and click Source, or run:
source("gdp_panel_simple.R")
```

### In Terminal
```bash
Rscript gdp_panel_simple.R
```

### Packages
The script automatically installs any missing packages on first run:
```
WDI   plm   lmtest   sandwich   dplyr
```
No manual installation is needed.

---

## 9. Repository Structure

```
gdp-growth-asian-panel/
│
├── gdp_panel_simple.R            Main analysis script — fully reproducible
├── README.md                     This file
│
└── outputs/                      Generated automatically on first run
    ├── five_regression_tables.docx    Five formatted regression tables (Word)
    └── table_main_results.txt         Plain-text summary table
```


### Relevant Coursework

`Advanced Econometrics` `Macroeconomics` `Time Series Analysis` `Mathematical Economics`
`Development Economics` `Financial Economics` `Statistics and Probability` `Panel Data Methods`

### Technical Skills

| Area | Details |
|------|---------|
| Econometric Methods | Panel Data, Fixed/Random Effects, GMM, Cointegration, Unit Root Testing, Robust Inference, Time Series |
| R Packages | `plm` `lmtest` `sandwich` `WDI` `dplyr` `knitr` `ggplot2` |
| Soft Skills | Research writing, data storytelling, peer collaboration |

---

## 12. References

| Author(s) | Year | Work |
|-----------|------|------|
| Baltagi, B.H. | 2005 | *Econometric Analysis of Panel Data*, 3rd ed. Wiley |
| Blundell, R. and Bond, S. | 1998 | Initial conditions and moment restrictions in dynamic panel data models. *Journal of Econometrics*, 87(1) |
| Cameron, A.C. and Miller, D.L. | 2015 | A practitioner's guide to cluster-robust inference. *Journal of Human Resources*, 50(2) |
| Driscoll, J.C. and Kraay, A.C. | 1998 | Consistent covariance matrix estimation with spatially dependent panel data. *Review of Economics and Statistics*, 80(4) |
| Gujarati, D.N. and Porter, D.C. | 2009 | *Basic Econometrics*, 5th ed. McGraw-Hill |
| Hausman, J.A. | 1978 | Specification tests in econometrics. *Econometrica*, 46(6) |
| Im, K.S., Pesaran, M.H. and Shin, Y. | 2003 | Testing for unit roots in heterogeneous panels. *Journal of Econometrics*, 115(1) |
| Moon, H.R. and Perron, B. | 2004 | Testing for a unit root in panels with dynamic factors. *Journal of Econometrics*, 122(1) |
| Pedroni, P. | 1999 | Critical values for cointegration tests in heterogeneous panels. *Oxford Bulletin of Economics and Statistics*, 61(S1) |
| Pesaran, M.H. | 2004 | General diagnostic tests for cross-section dependence in panels. *CESifo Working Paper No. 1229* |
| Pesaran, M.H. | 2007 | A simple panel unit root test in the presence of cross-section dependence. *Journal of Applied Econometrics*, 22(2) |
| Solow, R.M. | 1956 | A contribution to the theory of economic growth. *Quarterly Journal of Economics*, 70(1) |
| Wallace, T.D. and Hussain, A. | 1969 | The use of error components models in combining cross-section and time-series data. *Econometrica*, 37(1) |
| Westerlund, J. | 2007 | Testing for error correction in panel data. *Oxford Bulletin of Economics and Statistics*, 69(6) |
| World Bank | 2025 | *World Development Indicators*. Washington D.C. |

---

*Last updated: March 2026 · Sameer Chawla · MSc Economics, GIPE Pune*
