# Determinants of GDP Growth in Asian Economies
### Panel Data Analysis — 15 Emerging Economies, 1995–2023

<p align="left">
  <img src="https://img.shields.io/badge/Language-R%204.5%2B-276DC3?style=flat-square&logo=r&logoColor=white" />
  <img src="https://img.shields.io/badge/Data-World%20Bank%20WDI-003087?style=flat-square&logo=worldhealthorganization&logoColor=white" />
  <img src="https://img.shields.io/badge/Method-Advanced%20Panel%20Econometrics-2E86AB?style=flat-square" />
  <img src="https://img.shields.io/badge/Status-Complete-28a745?style=flat-square" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" />
</p>

> **A methodologically rigorous investigation into how inflation, FDI, trade openness, and capital formation drive GDP growth — and how ignoring non-stationarity leads to fundamentally spurious conclusions.**

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

| Pathology | Test Deployed | Treatment |
|---|---|---|
| Cross-Sectional Dependence (CSD) | Pesaran CD Test | Driscoll-Kraay Standard Errors |
| Non-Stationarity / Unit Roots | CIPS (2nd Generation) | First-Differencing of I(1) variables |
| Serial Correlation | Wooldridge Test | Newey-West bandwidth in DK SEs |
| Endogeneity | Control Function + Block Bootstrap | Permitted TWFE (exogeneity not rejected) |

By deploying second-generation panel unit-root tests (Pesaran's CIPS) and block-bootstrapped Control Functions, the analysis demonstrates precisely how ignoring time-series properties in panel data can manufacture economically compelling but statistically meaningless results.

---

## 2. Research Question & Empirical Strategy

### Research Question

> *How do structural macroeconomic variables — Inflation, FDI, Trade Openness, and Gross Fixed Capital Formation — impact contemporaneous GDP growth when fully accounting for cross-country spatial contagion and non-stationary trending behaviours?*

### Empirical Model (Strictly Stationary Specification)

Following the identification of $I(1)$ variables, the final preferred model transforms non-stationary regressors into first-differences, ensuring a mathematically sound, stationary $I(0)$ framework:

$$\text{GDP\_growth}_{it} = \alpha + \beta_1 \cdot \text{Inflation}_{it} + \beta_2 \cdot \Delta\text{FDI}_{i,t-1} + \beta_3 \cdot \Delta\text{Trade}_{it} + \beta_4 \cdot \Delta\text{GFCF}_{i,t-1} + \mu_i + \gamma_t + \varepsilon_{it}$$

| Component | Description | Integration Order |
|---|---|---|
| `GDP_growth` | Real GDP Growth (%) | $I(0)$ — stationary in levels |
| `Inflation` | CPI Inflation (%) | $I(0)$ — stationary in levels |
| `ΔFDI` | First-Difference of FDI (% GDP), lagged 1 period | Transformed to $I(0)$ |
| `ΔTrade` | First-Difference of Trade Openness (% GDP) | Transformed to $I(0)$ |
| `ΔGFCF` | First-Difference of Gross Fixed Capital Formation, lagged 1 period | Transformed to $I(0)$ |
| `μᵢ` | Country Fixed Effects | — |
| `γₜ` | Year Fixed Effects | — |

---

## 3. Data & Variable Transformations

**Source:** World Bank World Development Indicators (WDI, 2025) — fetched dynamically via the `WDI` R package.

**Sample:** 15 Asian economies across a nearly three-decade panel:

| ISO Code | Country |
|---|---|
| BD | Bangladesh |
| CN | China |
| IN | India |
| ID | Indonesia |
| KH | Cambodia |
| LA | Laos |
| MM | Myanmar |
| MN | Mongolia |
| MY | Malaysia |
| NP | Nepal |
| PH | Philippines |
| PK | Pakistan |
| LK | Sri Lanka |
| TH | Thailand |
| VN | Vietnam |

**Panel Structure:** $N = 15$, $\text{Max } T = 29$ (1995–2023). The unbalanced panel geometry is natively preserved to avoid unnecessary data loss.

> **Note on Year Truncation:** The panel terminates at 2023 to avoid severe right-edge missingness present in 2024 WDI releases.

---

## 4. Methodological Pipeline

The script executes a strict, **sequential diagnostic pipeline** — each stage gates the decisions made in the next.

```
┌─────────────────────────────────────────────────────────────┐
│  STAGE 1: Poolability & Model Selection                     │
│  Honda Test → Mundlak Device → Reject Pooled OLS & RE       │
├─────────────────────────────────────────────────────────────┤
│  STAGE 2: Cross-Sectional Dependence                        │
│  Pesaran CD Test → CSD Detected → Mandate DK Errors         │
│                              → Invalidate 1st-Gen Unit Roots│
├─────────────────────────────────────────────────────────────┤
│  STAGE 3: 2nd Generation Unit Root Testing                  │
│  CIPS Test → FDI, GFCF, Trade are I(1)                      │
│           → GDP Growth, Inflation are I(0)                  │
│           → First-difference I(1) variables                 │
├─────────────────────────────────────────────────────────────┤
│  STAGE 4: Endogeneity Testing                               │
│  Control Function (IV: d_lag2_fdi) + Block Bootstrap        │
│  → CF p-value = 0.494 → Fail to Reject Exogeneity           │
│  → Standard TWFE estimation permitted                       │
├─────────────────────────────────────────────────────────────┤
│  STAGE 5: Robust Final Estimation                           │
│  TWFE + Driscoll-Kraay SEs (NW lag = 2)                     │
│  Simultaneously handles: CSD, Autocorrelation, Het'sked     │
└─────────────────────────────────────────────────────────────┘
```

### Stage-by-Stage Details

**Stage 1 — Poolability & Mundlak Device**
- *Honda Test:* Strongly rejects Pooled OLS ($p < 0.001$)
- *Robust Mundlak Test:* Joint significance of group means ($p = 0.0171$) rejects Random Effects in favour of Fixed Effects

**Stage 2 — Cross-Sectional Dependence**
- *Pesaran CD Test:* Detects heavy spatial contagion ($p = 0.0011$)
- This result explicitly invalidates 1st-generation panel unit-root tests (IPS, LLC) and mandates Driscoll-Kraay standard errors throughout

**Stage 3 — 2nd Generation Unit Roots**
- *CIPS Test* (Pesaran, 2007): Evaluated on the maximum balanced sub-panel
- **I(1) variables:** `FDI`, `GFCF`, `Trade` — non-stationary, first-differenced
- **I(0) variables:** `GDP_growth`, `Inflation` — stationary in levels

**Stage 4 — Endogeneity**
- *Instrument:* 2nd lag of differenced FDI (`d_lag2_fdi`)
- *Cluster-Robust First-Stage F-statistic:* **34.29** — clears Stock-Yogo thresholds comfortably
- *Block Bootstrap:* 500 iterations, clustered by country to preserve time-series integrity
- *Empirical p-value of CF residual:* **0.494** — exogeneity not rejected; standard TWFE permitted

**Stage 5 — Robust Inference**
- Serial correlation detected (Wooldridge test, $p = 0.0130$)
- Final model estimated using **Driscoll-Kraay Standard Errors** with Newey-West bandwidth (lag = 2)

---

## 5. Key Results: Escaping the Spurious Regression Trap

The most critical finding is the stark contrast between a naive levels estimation and the strictly stationary model.

| Variable | (1) TWFE — Spurious Levels | (2) Pooled OLS — Stationary | (3) TWFE — Stationary ✓ |
|---|:---:|:---:|:---:|
| **Inflation** *(I(0))* | −0.164 *** | −0.159 ** | **−0.176 \*\*\*** |
| **FDI (t−1)** *(I(1), levels)* | 0.145 ** | — | — |
| **Trade** *(I(1), levels)* | 0.007 | — | — |
| **GFCF (t−1)** *(I(1), levels)* | −0.046 | — | — |
| **Δ FDI (t−1)** *(I(0))* | — | 0.032 | **0.043** |
| **Δ Trade** *(I(0))* | — | 0.055 ** | **−0.001** |
| **Δ GFCF (t−1)** *(I(0))* | — | 0.172 *** | **0.075** |
| Country FE | ✓ | ✗ | **✓** |
| Year FE | ✓ | ✗ | **✓** |
| Standard Errors | Driscoll-Kraay | Robust HC1 | **Driscoll-Kraay** |

*Significance: \*\*\* p<0.01, \*\* p<0.05, \* p<0.10*

### Interpretation

**① The Spurious FDI Premium**

In Column (1), running the model in raw levels implies FDI has a highly significant positive impact on growth (0.145, $p < 0.05$). This looks economically compelling. However, because the CIPS test establishes that FDI is $I(1)$ while GDP Growth is $I(0)$, **this result is a pure statistical artifact** — spurious regression driven by coincident trends, not genuine economic causation.

**② The True Stationary Dynamics**

When $I(1)$ regressors are correctly first-differenced (Column 3), the apparent effects of FDI, Trade, and Capital Formation on growth collapse entirely. Short-run fluctuations in these structural variables exhibit no robust contemporaneous relationship with growth once country heterogeneity, global shocks, and proper stationarity are accounted for.

**③ The Inflation Drag — The Sole Robust Finding**

The only structural variable that survives the full battery of corrections is **Inflation**:

> A **1 percentage point increase in CPI inflation** is associated with a **~0.18 percentage point drag on GDP growth** ($p < 0.01$), robust across all specifications.

This finding is stable under Country FE, Year FE, CSD-corrected standard errors, and stationarity transformations — making it the single credible structural result of this analysis.

---

## 6. Methodological Caveats & Limitations

Column (3) represents the mathematically sound estimation given the diagnostic test results. However, advanced interpretation requires acknowledging the inherent trade-offs:

**① Attenuation Bias via First-Differencing**

First-differencing eliminates spurious unit roots but amplifies measurement error (raises the noise-to-signal ratio). The collapse in explanatory power for $\Delta$Trade and $\Delta$FDI in Column (3) may partially reflect **attenuation bias** rather than a true economic null effect.

**② Loss of Long-Run Information**

Differencing $I(1)$ variables discards potentially vital cointegrating relationships. Future work should apply **Panel Dynamic OLS (DOLS)** or a **Panel ARDL / PMG framework** (Pesaran, Shin & Smith, 1999) to jointly capture short-run shocks and long-run steady states.

**③ Dynamic Panel Bias**

Detected AR(1) serial correlation hints at omitted dynamic convergence effects (e.g., a lagged dependent variable $\text{GDP\_Growth}_{t-1}$). While adding this to an FE model induces Nickell Bias, the large time dimension ($T \approx 29$) implies bias of order $O(1/T)$, and thus practically negligible (Judson & Owen, 1999). **System GMM** would provide a theoretically cleaner environment regardless.

**④ Small-N Cluster Bootstrapping**

The block bootstrap relies on asymptotic properties that typically require $N \geq 30$ (Cameron, Gelbach & Miller, 2008). With $N = 15$, finite-sample distortions are plausible. A **Wild Cluster Bootstrap** is recommended as a more reliable alternative in future iterations.

---

## 7. How to Run

### Requirements

- R version ≥ 4.5.0
- Active internet connection (required to query the World Bank WDI API)

### Installation

The script is entirely **self-contained**. All dependencies are detected and installed automatically on first run — no manual package installation required.

### Execution

```r
source("gdp_panel_analysis.R")
```

The script will automatically:
1. Detect and install any missing R packages
2. Fetch panel data via the World Bank WDI API
3. Execute all diagnostic tests sequentially
4. Run the block-bootstrap endogeneity procedure (500 iterations)
5. Print formatted Stargazer regression tables to the console

> **Runtime note:** The block bootstrap (500 iterations) may take several minutes depending on hardware. Progress is printed to console.

---

## 8. References

- **Cameron, A.C., Gelbach, J.B., & Miller, D.L. (2008).** Bootstrap-based improvements for inference with clustered errors. *The Review of Economics and Statistics*, 90(3), 414–427.

- **Greene, W.H. (2012).** *Econometric Analysis* (7th ed.). Pearson.

- **Gujarati, D.N. (2009).** *Basic Econometrics* (5th ed.). McGraw-Hill.

- **Judson, R.A., & Owen, A.L. (1999).** Estimating dynamic panel data models: a guide for macroeconomists. *Economics Letters*, 65(1), 9–15.

- **Olea, J.L.M., & Pflueger, C. (2013).** A robust test for weak instruments. *Journal of Business & Economic Statistics*, 95(3), 358–369.

- **Pesaran, M.H. (2004).** General diagnostic tests for cross section dependence in panels. *University of Cambridge, Cambridge Working Papers in Economics*.

- **Pesaran, M.H. (2007).** A simple panel unit root test in the presence of cross-section dependence. *Journal of Applied Econometrics*, 22(2), 265–312.

- **Wooldridge, J.M. (2010).** *Econometric Analysis of Cross Section and Panel Data* (2nd ed.). MIT Press.

---

<p align="center">
  <sub>MSc Economics · Gokhale Institute of Politics and Economics · Pune, India</sub>
</p>
