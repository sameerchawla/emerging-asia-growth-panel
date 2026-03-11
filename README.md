# Macroeconomic Determinants of GDP Growth in Emerging Asia (1995–2024)
### Fixed Effects Panel Data Analysis | 10 Countries | N = 294 | Driscoll-Kraay Standard Errors

**Sameer Chawla** | MSc Economics, Gokhale Institute of Politics and Economics (GIPE)

---

## Overview

This project estimates the macroeconomic determinants of GDP growth across ten emerging Asian economies over a 30-year period using World Bank data. The preferred specification is a one-way Fixed Effects model with Driscoll-Kraay standard errors, chosen after a full sequence of specification and diagnostic tests.

The analysis addresses three sources of panel data complications common in cross-country growth regressions: heteroskedasticity, serial correlation, and cross-sectional dependence — the last being particularly relevant for Asian economies given their deep trade and financial integration.

---

## Countries

Bangladesh · China · India · Indonesia · Malaysia · Pakistan · Philippines · Sri Lanka · Thailand · Viet Nam

---

## Data

**Source:** World Bank World Development Indicators (WDI)  
**Period:** 1995–2024 | **Observations:** 294 (unbalanced panel, T = 25–30 per country)

| Variable | WDI Code | Description |
|---|---|---|
| `gdp_growth` | NY.GDP.MKTP.KD.ZG | GDP growth, annual % (constant prices) |
| `inflation` | FP.CPI.TOTL.ZG | CPI inflation, annual % |
| `fdi` | BX.KLT.DINV.WD.GD.ZS | FDI net inflows, % of GDP |
| `trade` | NE.TRD.GNFS.ZS | Trade openness (exports + imports), % of GDP |
| `investment` | NE.GDI.TOTL.ZS | Gross capital formation, % of GDP |

---

## Empirical Model

The preferred specification is a one-way Fixed Effects model:

```
GDP_Growth_it = α_i + β₁·Inflation_it + β₂·FDI_it + β₃·ln(Trade_it + 1) + β₄·Investment_it + β₅·Year_t + ε_it
```

where `α_i` denotes country-specific fixed effects that absorb all time-invariant unobserved heterogeneity (geography, institutions, historical development path).

**Variable construction notes:**
- Trade enters in log form — `ln(Trade + 1)` — to account for the right-skewed distribution of trade-to-GDP ratios (range: 21%–220% across the sample) and allow elasticity interpretation
- A linear time trend `Year_t` is included to control for common global growth dynamics
- The Im-Pesaran-Shin unit root test fails to reject non-stationarity for raw trade levels (p = 0.280); this is acknowledged as a limitation — the log transformation and time trend are partial rather than complete solutions

**Model selection:** Fixed Effects preferred over Random Effects based on the Hausman test (χ²(5) = 27.10, p < 0.001), indicating that country-level effects are correlated with regressors. Pooled OLS rejected by the Breusch-Pagan LM test (χ²(1) = 4.51, p = 0.034).

---

## Diagnostic Tests

| Test | Statistic | p-value | Result |
|---|---|---|---|
| IPS Unit Root — GDP Growth | Wtbar = −5.09 | < 0.001 | Stationary I(0) |
| IPS Unit Root — Inflation | Wtbar = −2.50 | 0.006 | Stationary I(0) |
| IPS Unit Root — FDI | Wtbar = −3.44 | < 0.001 | Stationary I(0) |
| IPS Unit Root — Trade (raw levels) | Wtbar = −0.58 | 0.280 | Fails to reject unit root |
| IPS Unit Root — Investment | Wtbar = −5.91 | < 0.001 | Stationary I(0) |
| Breusch-Pagan LM | χ²(1) = 4.51 | 0.034 | Panel model required |
| Hausman Test | χ²(5) = 27.10 | < 0.001 | Fixed Effects preferred |
| Heteroskedasticity (Breusch-Pagan) | BP = 84.08 | < 0.001 | Detected |
| Serial Correlation (Wooldridge) | F(1,282) = 24.95 | < 0.001 | Detected |
| Cross-Sectional Dependence (Pesaran CD) | z = 13.70 | < 0.001 | Detected |
| Multicollinearity (VIF, max) | 1.76 (FDI) | — | Not present |

Heteroskedasticity, serial correlation, and cross-sectional dependence are addressed jointly via **Driscoll-Kraay (1998) standard errors** (HC3, maxlag = 2), which are consistent under all three violations. Results are also reported under Arellano cluster-robust SEs (clustered by country) for comparison.

---

## Results

| | Pooled OLS | Fixed Effects | Random Effects |
|---|---|---|---|
| Inflation | −0.168\*\*\* | −0.210\*\*\* | −0.175\*\*\* |
| FDI | 0.541\*\*\* | 0.568\*\*\* | 0.478\*\*\* |
| ln(Trade + 1) | −1.560\*\*\* | 2.340† | −0.659 |
| Investment | 0.123\*\*\* | 0.128\*\*\* | 0.132\*\*\* |
| Year Trend | −0.063\*\*\* | −0.056\*\* | −0.064\*\*\* |
| R² | 0.321 | 0.261 (within) | 0.243 |
| N | 294 | 294 | 294 |

Standard errors: HC1 for Pooled OLS and Random Effects. Driscoll-Kraay (HC3, maxlag = 2) for Fixed Effects.  
† p < 0.10 · \* p < 0.10 · \*\* p < 0.05 · \*\*\* p < 0.01

### Key Findings

**FDI is the strongest and most robust growth determinant.** A one percentage point increase in FDI as a share of GDP is associated with a 0.57 percentage point increase in annual GDP growth within a country (p < 0.001). This holds under both Driscoll-Kraay and cluster-robust specifications and is consistent with technology transfer and capital deepening channels (Borensztein et al., 1998). Vietnam (avg. FDI = 5.15% of GDP) and Malaysia (3.43%) lead the sample; Bangladesh (0.68%) and Pakistan (0.96%) lag significantly.

**Inflation is significantly growth-reducing.** Each additional percentage point of annual inflation is associated with a 0.21 percentage point reduction in GDP growth (p = 0.007). This is consistent with Fischer (1993). Pakistan (avg. inflation = 9.40%) and Sri Lanka (10.20%) sit at the high end; both rank in the bottom three for average GDP growth.

**Gross investment is positive and significant.** A one percentage point increase in gross capital formation raises GDP growth by approximately 0.13 percentage points (p = 0.001), consistent with standard capital accumulation theory. China's high investment ratio (avg. 40.9% of GDP) alongside its top-ranked growth performance (8.36%) illustrates this relationship within the sample.

**Trade openness shows a sign reversal across specifications.** The trade coefficient is *negative* in pooled OLS (−1.560) and random effects (−0.659) but *positive* in fixed effects (+2.340). This reversal indicates that cross-country differences in trade integration are confounded by time-invariant country characteristics in pooled estimators — characteristics that the fixed effects estimator absorbs through `α_i`. The within-country estimate is positive but only marginally significant at 10% under Driscoll-Kraay SEs (p = 0.087), indicating that while greater openness within a country tends to support growth, the estimate is sensitive to standard error choice.

---

## Limitations

This analysis has several limitations that future work should address:

1. **Endogeneity.** FDI and investment are plausibly endogenous — high-growth economies attract capital. Fixed effects control for time-invariant confounders but do not address time-varying reverse causality. A system GMM estimator (Blundell and Bond, 1998) would be the natural extension.

2. **Non-stationarity of trade.** The IPS test fails to reject a unit root for trade in raw levels (p = 0.280). The log transformation and time trend are partial mitigations. First-differencing trade as a robustness check would be advisable.

3. **Small cross-sectional dimension.** With N = 10 countries, the asymptotic properties of Driscoll-Kraay standard errors — derived under large-N assumptions — should be interpreted cautiously. Results are cross-validated using Arellano cluster-robust SEs.

4. **Omitted variables.** Human capital, institutional quality, financial development, and demographic structure are excluded. Fixed effects absorb their time-invariant components, but time-varying omitted variables may bias coefficient estimates.

5. **No two-way fixed effects.** Time fixed effects are not included. Common global shocks (1997 Asian Financial Crisis, 2008 GFC, COVID-19) are partially captured by the time trend but not fully controlled for.

6. **Sample selection.** The ten economies are not randomly selected — they are growth-oriented emerging markets with relatively complete WDI coverage. Results may not generalise beyond this regional context.

---

## Repository Structure

```
emerging-asia-growth-panel/
├── AsianGrowthRate.R       # Full analysis: data pull, diagnostics, models
└── README.md
```

---

## How to Reproduce

```r
# Install dependencies (once)
install.packages(c("WDI", "dplyr", "tidyr", "ggplot2", "corrplot",
                   "plm", "lmtest", "sandwich", "car", "stargazer"))

# Run full analysis
source("AsianGrowthRate.R")
```

Data is pulled directly from the World Bank API via the `WDI` package — no manual download required.

---

## References

- Blundell, R. and Bond, S. (1998). Initial conditions and moment restrictions in dynamic panel data models. *Journal of Econometrics*, 87(1), 115–143.
- Borensztein, E., De Gregorio, J. and Lee, J.-W. (1998). How does foreign direct investment affect economic growth? *Journal of International Economics*, 45(1), 115–135.
- Driscoll, J. C. and Kraay, A. C. (1998). Consistent covariance matrix estimation with spatially dependent panel data. *Review of Economics and Statistics*, 80(4), 549–560.
- Fischer, S. (1993). The role of macroeconomic factors in growth. *Journal of Monetary Economics*, 32(3), 485–512.
- Hausman, J. A. (1978). Specification tests in econometrics. *Econometrica*, 46(6), 1251–1271.
- Im, K. S., Pesaran, M. H. and Shin, Y. (2003). Testing for unit roots in heterogeneous panels. *Journal of Econometrics*, 115(1), 53–74.
- World Bank (2024). *World Development Indicators*. Washington, DC: World Bank Group.

---

*MSc Economics · Gokhale Institute of Politics and Economics (GIPE) · 2025*
