# Determinants of GDP Growth in Asian Economies
### Panel Data Analysis — 15 Emerging Economies, 1995–2023

<p align="left">
  <img src="https://img.shields.io/badge/Language-R%204.5%2B-276DC3?style=flat-square&logo=r&logoColor=white" />
  <img src="https://img.shields.io/badge/Data-World%20Bank%20WDI-003087?style=flat-square" />
  <img src="https://img.shields.io/badge/Method-Advanced%20Panel%20Econometrics-2E86AB?style=flat-square" />
  <img src="https://img.shields.io/badge/Status-Complete-28a745?style=flat-square" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" />
</p>

> **A methodologically rigorous investigation into how inflation, FDI, trade openness, and capital formation drive GDP growth — and how ignoring non-stationarity manufactures economically compelling but statistically meaningless results.**

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
2. [Research Question & Empirical Strategy](#2-research-question--empirical-strategy)
3. [Data & Variable Transformations](#3-data--variable-transformations)
4. [Methodological Pipeline](#4-methodological-pipeline)
5. [Key Results](#5-key-results-escaping-the-spurious-regression-trap)
6. [Methodological Caveats & Limitations](#6-methodological-caveats--limitations)
7. [How to Run](#7-how-to-run)
8. [References](#8-references)

---

## 1. Project Overview

This project investigates the macroeconomic determinants of annual GDP growth across **15 developing Asian economies** from **1995 to 2023**.

The core contribution is **methodological rigor**. Rather than defaulting to naive fixed-effects estimators, this pipeline systematically tests for and corrects the severe panel data pathologies endemic to macro-econometric work:

| Pathology | Test Deployed | Treatment Applied |
|---|---|---|
| Cross-Sectional Dependence (CSD) | Pesaran CD Test | Driscoll-Kraay Standard Errors |
| Non-Stationarity / Unit Roots | CIPS (2nd Generation) | First-Differencing of I(1) variables |
| Serial Correlation | Wooldridge Test | Newey-West bandwidth in DK SEs |
| Endogeneity | Control Function + Block Bootstrap | TWFE permitted — exogeneity not rejected |

By deploying second-generation panel unit-root tests (Pesaran's CIPS) and block-bootstrapped Control Functions, the analysis demonstrates precisely how ignoring time-series properties in panel data can manufacture economically compelling but statistically meaningless results.

---

## 2. Research Question & Empirical Strategy

### Research Question

> *How do structural macroeconomic variables — Inflation, FDI, Trade Openness, and Gross Fixed Capital Formation — impact contemporaneous GDP growth when fully accounting for cross-country spatial contagion and non-stationary trending behaviours?*

### Empirical Model (Strictly Stationary Specification)

Following the identification of I(1) variables via the CIPS test, the final preferred model transforms all non-stationary regressors into first-differences. This ensures a mathematically valid, strictly stationary I(0) estimation framework and guards against spurious inference.

The estimated equation is:

```
GDP_growth[i,t] = α
                + β₁ · Inflation[i,t]
                + β₂ · ΔFDI[i,t-1]
                + β₃ · ΔTrade[i,t]
                + β₄ · ΔGFCF[i,t-1]
                + μ[i]
                + γ[t]
                + ε[i,t]
```

where `Δ` denotes the first-difference operator, `μ[i]` are country fixed effects, `γ[t]` are year fixed effects, and `ε[i,t]` is the idiosyncratic error term estimated with Driscoll-Kraay standard errors.

| Component | Description | Integration Order |
|---|---|---|
| `GDP_growth[i,t]` | Real GDP Growth Rate (%) | I(0) — stationary in levels |
| `Inflation[i,t]` | CPI Inflation (%) | I(0) — stationary in levels |
| `ΔFDI[i,t-1]` | First-Difference of FDI Inflows (% of GDP), lagged 1 period | Transformed to I(0) |
| `ΔTrade[i,t]` | First-Difference of Trade Openness (Exports + Imports, % of GDP) | Transformed to I(0) |
| `ΔGFCF[i,t-1]` | First-Difference of Gross Fixed Capital Formation (% of GDP), lagged 1 period | Transformed to I(0) |
| `μ[i]` | Country Fixed Effects — absorbs time-invariant country heterogeneity | — |
| `γ[t]` | Year Fixed Effects — absorbs common global shocks (GFC, COVID-19, etc.) | — |

**On the lag structure:** FDI and GFCF enter with a one-period lag (t−1) to reflect the real-world gestation period between capital commitment and output materialisation, and to provide a conservative buffer against reverse causality from contemporaneous growth shocks.

---

## 3. Data & Variable Transformations

**Source:** World Bank World Development Indicators (WDI, 2025) — fetched dynamically via the `WDI` R package.

**Sample:** 15 Asian economies across a nearly three-decade panel.

| ISO | Country | ISO | Country |
|---|---|---|---|
| BD | Bangladesh | PK | Pakistan |
| CN | China | PH | Philippines |
| IN | India | LK | Sri Lanka |
| ID | Indonesia | TH | Thailand |
| KH | Cambodia | VN | Vietnam |
| LA | Laos | MN | Mongolia |
| MM | Myanmar | MY | Malaysia |
| NP | Nepal | | |

**Panel Structure:** N = 15, Max T = 29. The unbalanced panel geometry is natively preserved to avoid unnecessary data loss from listwise deletion.

> **Note on Year Truncation:** The panel terminates at 2023 to avoid severe right-edge missingness present in 2024 WDI releases.

---

## 4. Methodological Pipeline

The script executes a strict, **sequential diagnostic pipeline** — each stage gates the decisions made in the next.

```
┌─────────────────────────────────────────────────────────────────┐
│  STAGE 1 │ Poolability & Model Selection                        │
│           Honda Test → Mundlak Device                           │
│           → Reject Pooled OLS & Random Effects → Use TWFE       │
├─────────────────────────────────────────────────────────────────┤
│  STAGE 2 │ Cross-Sectional Dependence                           │
│           Pesaran CD Test (p = 0.0011)                          │
│           → CSD Detected → Mandate DK Errors                    │
│           → Invalidate 1st-Generation Unit Root Tests           │
├─────────────────────────────────────────────────────────────────┤
│  STAGE 3 │ 2nd Generation Unit Root Testing                     │
│           Pesaran CIPS Test (on max balanced sub-panel)         │
│           → FDI, GFCF, Trade are I(1) → First-difference        │
│           → GDP Growth, Inflation are I(0) → Keep in levels     │
├─────────────────────────────────────────────────────────────────┤
│  STAGE 4 │ Endogeneity Testing                                  │
│           Control Function (Instrument: d_lag2_fdi)             │
│           First-Stage F = 34.29 (strong instrument)             │
│           Block Bootstrap (500 iter.) → CF p-value = 0.494      │
│           → Fail to Reject Exogeneity → Standard TWFE permitted │
├─────────────────────────────────────────────────────────────────┤
│  STAGE 5 │ Robust Final Estimation                              │
│           Two-Way FE + Driscoll-Kraay SEs (NW lag = 2)          │
│           Simultaneously handles: CSD, Autocorrelation, Hetsk.  │
└─────────────────────────────────────────────────────────────────┘
```

**Stage 1 — Poolability & Mundlak Device**
The Honda (1985) test strongly rejects the Pooled OLS restriction (p < 0.001). The Mundlak (1978) device — augmenting the RE model with group means of all time-varying regressors — yields a jointly significant Wald statistic (p = 0.0171), rejecting Random Effects in favour of Fixed Effects. This confirms that unobserved country heterogeneity is systematically correlated with the regressors, violating the RE orthogonality assumption.

**Stage 2 — Cross-Sectional Dependence**
The Pesaran (2004) CD test detects substantial spatial contagion across panel units (p = 0.0011). This is expected in a sample of economically integrated Asian economies subject to common regional shocks (Asian Financial Crisis, GFC, COVID-19). Critically, CSD renders first-generation panel unit-root tests (IPS, LLC) invalid — mandating the use of second-generation alternatives in Stage 3.

**Stage 3 — Second-Generation Unit Roots**
The Pesaran (2007) CIPS test — which accommodates cross-sectional dependence via a common factor structure — is applied to the maximum balanced sub-panel. `FDI`, `GFCF`, and `Trade Openness` are confirmed non-stationary I(1). `GDP Growth` and `Inflation` are I(0). All I(1) variables are first-differenced to prevent spurious regression.

**Stage 4 — Endogeneity**
A Control Function (CF) approach employs the second lag of differenced FDI (`d_lag2_fdi`) as an instrument, on the premise that two-period lagged capital flows are sufficiently distant from current growth shocks to satisfy exclusion. The cluster-robust first-stage F-statistic (34.29) clears Stock-Yogo (2005) weak instrument thresholds. A 500-iteration country-clustered block bootstrap yields an empirical CF residual p-value of 0.494 — exogeneity is not rejected; standard TWFE estimation is permitted.

**Stage 5 — Robust Inference**
Serial correlation is detected (Wooldridge test, p = 0.013). The final model is estimated using Driscoll-Kraay (1998) standard errors with a Newey-West lag bandwidth of 2, simultaneously correcting for cross-sectional dependence, heteroskedasticity, and autocorrelation.

---

## 5. Key Results: Escaping the Spurious Regression Trap

The most critical finding is the stark contrast between the naive levels specification and the strictly stationary model.

| Variable | (1) TWFE — Spurious Levels | (2) Pooled OLS — Stationary | (3) TWFE — Stationary ✓ |
|---|:---:|:---:|:---:|
| **Inflation** *(I(0))* | −0.164 *** | −0.159 ** | **−0.176 \*\*\*** |
| **FDI (t−1)** *(I(1) in levels)* | 0.145 ** | — | — |
| **Trade** *(I(1) in levels)* | 0.007 | — | — |
| **GFCF (t−1)** *(I(1) in levels)* | −0.046 | — | — |
| **Δ FDI (t−1)** *(I(0))* | — | 0.032 | **0.043** |
| **Δ Trade** *(I(0))* | — | 0.055 ** | **−0.001** |
| **Δ GFCF (t−1)** *(I(0))* | — | 0.172 *** | **0.075** |
| Country FE | Yes | No | **Yes** |
| Year FE | Yes | No | **Yes** |
| Standard Errors | Driscoll-Kraay | Robust HC1 | **Driscoll-Kraay** |

*\*\*\* p<0.01, \*\* p<0.05, \* p<0.10. Column (3) is the preferred specification.*

### Interpretation

**① The Spurious FDI Premium**

Column (1) regresses GDP growth on FDI, Trade, and GFCF in raw levels. The result appears economically meaningful: FDI carries a positive, statistically significant coefficient of 0.145 (p < 0.05). A researcher relying on this specification would conclude that FDI inflows robustly stimulate growth. However, this conclusion is entirely spurious. The CIPS test establishes that FDI is I(1) while GDP Growth is I(0). Regressing a stationary series on a non-stationary one produces t-statistics that follow non-standard limiting distributions — the apparent significance is a mechanical consequence of coincident trends, not genuine causation. This is the Granger-Newbold (1974) spurious regression problem transposed to a panel setting.

**② Collapse of Capital and Trade Effects**

Once I(1) regressors are correctly first-differenced (Column 3), the estimated coefficients on ΔFDI, ΔTrade, and ΔGFCF become statistically indistinguishable from zero. This carries a clear economic interpretation: short-run year-on-year fluctuations in FDI flows, trade volumes, and investment rates carry no robust contemporaneous signal for growth, conditional on country fixed effects, year fixed effects, and fully corrected standard errors. Long-run cointegrating dynamics — which are discarded by differencing — may still exist and warrant separate investigation.

**③ The Inflation Drag — The Sole Robust Structural Finding**

The one variable that survives the complete econometric correction is **Inflation**. Its coefficient is stable in sign, magnitude, and significance across all three columns:

> A **1 percentage point increase in CPI inflation** is associated with approximately a **0.18 percentage point reduction in real GDP growth** (p < 0.01), robust to country fixed effects, year fixed effects, CSD-corrected standard errors, and stationarity transformations.

This is consistent with the menu-cost and Tobin-Mundell literature: elevated inflation erodes real purchasing power, distorts relative price signals, increases macroeconomic uncertainty, and compresses investment horizons. The stability of this coefficient across all three specifications is precisely what confers credibility — it is not an artifact of any single methodological choice.

---

## 6. Methodological Caveats & Limitations

Column (3) constitutes the preferred specification under the diagnostic results obtained. Nevertheless, the following limitations are intrinsic to the identification strategy and should govern interpretation of all reported estimates.

---

### 6.1 Attenuation Bias Induced by First-Differencing

The first-difference transformation is the canonical remedy for I(1) non-stationarity, but it carries a well-documented econometric cost: it amplifies the contribution of classical measurement error relative to the true signal in the regressor, biasing coefficient estimates toward zero (Griliches & Hausman, 1986).

If a variable `x[i,t]` is measured with error `v[i,t]` such that the observed variable is `x_obs[i,t] = x*[i,t] + v[i,t]`, the probability limit of the OLS estimator on the differenced variable is attenuated by the factor:

```
plim(β_hat_FD) = β · [1 - (2·σ²_v) / Var(Δx*[i,t])]
```

This attenuation factor is more severe than in the levels regression whenever the true signal `x*` is highly persistent — which is precisely the case for FDI, trade openness, and capital formation, all of which exhibit slow structural adjustment. Differencing shrinks the signal variance while leaving measurement error variance approximately unchanged, driving the ratio `2·σ²_v / Var(Δx*)` toward one in the limit.

The implication is that the near-zero estimates for ΔFDI and ΔTrade in Column (3) may represent a **lower bound on the true short-run elasticities**, with attenuation bias suppressing coefficients that are genuinely non-zero. IV estimation of the differenced equation — using further lags as instruments — would provide an attenuation-corrected alternative via the Arellano-Bond (1991) moment conditions, at the cost of efficiency losses in a panel of this dimension.

---

### 6.2 Loss of Long-Run Cointegrating Information

First-differencing eliminates the permanent, low-frequency components of each series — components that, under cointegration, carry the most economically informative long-run relationships. If GDP growth, FDI, and capital formation share a common stochastic trend (i.e., are cointegrated), the first-differenced model systematically discards the error-correction mechanism governing mean reversion toward the long-run equilibrium.

The appropriate framework for jointly estimating short-run dynamics and long-run equilibria in a heterogeneous panel is the **Pooled Mean Group (PMG) estimator** of Pesaran, Shin & Smith (1999), which imposes a common long-run cointegrating vector while permitting heterogeneous short-run adjustment speeds. The underlying panel ARDL(p, q) specification for each country i is:

```
ΔGDP_growth[i,t] = φ[i] · [GDP_growth[i,t-1] - θ'·X[i,t-1]]
                 + Σ λ[i,j] · ΔGDP_growth[i,t-j]
                 + Σ δ[i,j] · ΔX[i,t-j]
                 + μ[i] + ε[i,t]
```

where `φ[i] < 0` is the error-correction speed of adjustment and `θ` is the long-run coefficient vector (constrained equal across countries under PMG). A Hausman-type test against the Mean Group (MG) estimator — which allows both short- and long-run heterogeneity — then determines whether the pooling restriction is supported by the data. This analysis is the most important natural extension of the present work, as it would directly test whether the null long-run effects of FDI and capital accumulation survive or dissolve under a theoretically richer dynamic specification.

---

### 6.3 Dynamic Panel Bias and the Case for System GMM

The Wooldridge (2010) serial correlation test (p = 0.013) suggests AR(1) dynamics in the residuals of the preferred model, consistent with dynamic misspecification arising from the exclusion of the lagged dependent variable `GDP_growth[i,t-1]`.

Including this term in a within-group Fixed Effects estimator introduces the **Nickell (1981) bias**: the demeaned lagged outcome is correlated with the demeaned error by construction, yielding a downward-biased autoregressive coefficient. The order of the bias can be approximated as:

```
Bias(ρ_hat) ≈ -(1 + ρ) / (T - 1)
```

With T ≈ 29 and a plausible autoregressive coefficient of ρ ≈ 0.3, this gives a bias of approximately −0.045 — arguably negligible in magnitude. Nevertheless, the theoretically correct framework is **Blundell-Bond System GMM** (1998), which instruments the differenced equation with lagged levels and the levels equation with lagged differences. System GMM would additionally address any residual endogeneity imperfectly captured by the Control Function, and provides natural specification tests via the Arellano-Bond AR(2) test for second-order serial correlation and the Hansen J-statistic for instrument validity. The proliferation of instruments is the primary practical concern in a panel of this size; applying the Roodman (2009) `collapse` option to limit instrument count is strongly recommended.

---

### 6.4 Finite-Sample Distortions in Cluster Bootstrap Inference

The endogeneity test in Stage 4 relies on a country-clustered block bootstrap (B = 500). Asymptotic validity of cluster-robust bootstrap inference requires a sufficiently large number of clusters — Cameron, Gelbach & Miller (2008) suggest N ≥ 30 as a practical threshold below which empirical rejection rates can deviate meaningfully from nominal levels. With N = 15, the bootstrap test statistic may exhibit finite-sample size distortions.

A more reliable alternative in small-cluster settings is the **Wild Cluster Bootstrap** (Cameron, Gelbach & Miller, 2008; Webb, 2014), which randomises the sign of residuals within clusters using auxiliary weight distributions rather than resampling entire clusters. For N between 10 and 30, the Rademacher weight distribution is standard; for N < 10, Webb's (2014) 6-point distribution achieves superior size control. Critically, the CF residual p-value of 0.494 is sufficiently far from conventional significance thresholds that the exogeneity conclusion is unlikely to be overturned even under refined inference — but this should be confirmed formally in future work.

---

### 6.5 Sample Composition and External Validity

The inclusion of China — an economy of exceptional scale whose growth dynamics are substantially shaped by state-directed capital allocation and exchange rate management — raises the question of whether pooling across all 15 countries is appropriate. The Two-Way Fixed Effects estimator identifies coefficients from within-country variation over time; China's unusual combination of persistent high growth, controlled inflation, and state-mediated FDI flows may exert disproportionate leverage on the pooled estimates. A natural robustness check is to re-estimate Column (3) on the sample excluding China and examine whether the inflation coefficient and the null results for capital and trade are preserved. More formally, Pesaran & Yamagata's (2008) slope homogeneity test (`Δ` test) should be applied to verify that the TWFE pooling restriction is not rejected by the data — if it is, the Mean Group estimator of Pesaran & Smith (1995) provides consistent inference under slope heterogeneity.

---

## 7. How to Run

### Requirements

- R version ≥ 4.5.0
- Active internet connection (required to query the World Bank WDI API)

### Execution

The script is entirely **self-contained**. All dependencies are detected and installed automatically on first run.

```r
source("gdp_panel_analysis.R")
```

The script will automatically:

1. Detect and install any missing R packages
2. Fetch panel data dynamically via the World Bank WDI API
3. Execute all five diagnostic stages sequentially
4. Run the block-bootstrap endogeneity procedure (500 iterations)
5. Print formatted Stargazer regression tables to the console

> **Runtime note:** The 500-iteration block bootstrap may take several minutes depending on hardware. Set `B = 100` in the script for a faster test run.

---

## 8. References

- **Arellano, M., & Bond, S. (1991).** Some tests of specification for panel data. *The Review of Economic Studies*, 58(2), 277–297.

- **Blundell, R., & Bond, S. (1998).** Initial conditions and moment restrictions in dynamic panel data models. *Journal of Econometrics*, 87(1), 115–143.

- **Cameron, A.C., Gelbach, J.B., & Miller, D.L. (2008).** Bootstrap-based improvements for inference with clustered errors. *The Review of Economics and Statistics*, 90(3), 414–427.

- **Driscoll, J.C., & Kraay, A.C. (1998).** Consistent covariance matrix estimation with spatially dependent panel data. *The Review of Economics and Statistics*, 80(4), 549–560.

- **Granger, C.W.J., & Newbold, P. (1974).** Spurious regressions in econometrics. *Journal of Econometrics*, 2(2), 111–120.

- **Greene, W.H. (2012).** *Econometric Analysis* (7th ed.). Pearson.

- **Griliches, Z., & Hausman, J.A. (1986).** Errors in variables in panel data. *Journal of Econometrics*, 31(1), 93–118.

- **Judson, R.A., & Owen, A.L. (1999).** Estimating dynamic panel data models: a guide for macroeconomists. *Economics Letters*, 65(1), 9–15.

- **Kao, C., & Chiang, M.H. (2000).** On the estimation and inference of a cointegrated regression in panel data. *Advances in Econometrics*, 15, 179–222.

- **Mundlak, Y. (1978).** On the pooling of time series and cross section data. *Econometrica*, 46(1), 69–85.

- **Nickell, S. (1981).** Biases in dynamic models with fixed effects. *Econometrica*, 49(6), 1417–1426.

- **Olea, J.L.M., & Pflueger, C. (2013).** A robust test for weak instruments. *Journal of Business & Economic Statistics*, 95(3), 358–369.

- **Pesaran, M.H. (2004).** General diagnostic tests for cross section dependence in panels. *University of Cambridge, Cambridge Working Papers in Economics*.

- **Pesaran, M.H. (2007).** A simple panel unit root test in the presence of cross-section dependence. *Journal of Applied Econometrics*, 22(2), 265–312.

- **Pesaran, M.H., Shin, Y., & Smith, R.P. (1999).** Pooled mean group estimation of dynamic heterogeneous panels. *Journal of the American Statistical Association*, 94(446), 621–634.

- **Pesaran, M.H., & Smith, R. (1995).** Estimating long-run relationships from dynamic heterogeneous panels. *Journal of Econometrics*, 68(1), 79–113.

- **Pesaran, M.H., & Yamagata, T. (2008).** Testing slope homogeneity in large panels. *Journal of Econometrics*, 142(1), 50–93.

- **Roodman, D. (2009).** How to do xtabond2: An introduction to difference and system GMM in Stata. *The Stata Journal*, 9(1), 86–136.

- **Stock, J.H., & Yogo, M. (2005).** Testing for weak instruments in linear IV regression. In D.W.K. Andrews & J.H. Stock (Eds.), *Identification and Inference for Econometric Models*. Cambridge University Press.

- **Webb, M.D. (2014).** Reworking wild bootstrap based inference for clustered errors. *Queen's Economics Department Working Paper*, No. 1315.

- **Wooldridge, J.M. (2010).** *Econometric Analysis of Cross Section and Panel Data* (2nd ed.). MIT Press.

---

<p align="center">
  <sub>MSc Economics · Gokhale Institute of Politics and Economics · Pune, India</sub>
</p>
