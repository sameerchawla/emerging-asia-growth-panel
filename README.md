# emerging-asia-growth-panel

**Macroeconomic Determinants of GDP Growth in Emerging Asia (1995–2024)**  
Sameer Chawla | MSc Economics, GIPE | IBEF

Panel data analysis of what drives GDP growth across ten emerging Asian economies over thirty years, using World Bank data.

---

## Countries

Bangladesh · China · India · Indonesia · Malaysia · Pakistan · Philippines · Sri Lanka · Thailand · Viet Nam

---

## Data

Source: [World Bank Development Indicators](https://data.worldbank.org)  
Period: 1995–2024 | Observations: 294

| Variable | WDI Code | Description |
|---|---|---|
| `gdp_growth` | NY.GDP.MKTP.KD.ZG | GDP growth, annual % |
| `inflation` | FP.CPI.TOTL.ZG | CPI inflation, annual % |
| `fdi` | BX.KLT.DINV.WD.GD.ZS | FDI net inflows, % of GDP |
| `trade` | NE.TRD.GNFS.ZS | Trade openness (X+M), % of GDP |
| `investment` | NE.GDI.TOTL.ZS | Gross capital formation, % of GDP |

---

### Fixed Effects Model (Preferred Specification)

GDP_Growth_it = α_i + β₁ Inflation_it + β₂ FDI_it + β₃ log(Trade_it + 1) + β₄ Investment_it + β₅ Year_t + ε_it

Where:

- **α_i** = country-specific fixed effect  
- **ε_it** = error term  
- **i** indexes countries  
- **t** indexes time (years)

A **linear time trend (Year_t)** is included to control for potential non-stationarity in the trade variable (IPS test p = 0.28).

The **Fixed Effects estimator** is preferred over the **Random Effects estimator** based on the **Hausman test**, indicating that country-specific effects are correlated with the regressors.



---

## Results

| | Pooled OLS | Fixed Effects | Random Effects |
|---|---|---|---|
| Inflation | −0.168\*\*\* | −0.210\*\*\* | −0.175\*\*\* |
| FDI | 0.541\*\*\* | 0.568\*\*\* | 0.478\*\*\* |
| log(Trade) | −1.560\*\*\* | 2.340\*\* | −0.659 |
| Investment | 0.123\*\*\* | 0.128\*\*\* | 0.132\*\*\* |
| Year Trend | −0.063\*\*\* | −0.056\*\* | −0.064\*\*\* |
| R² | 0.321 | 0.261 | 0.243 |
| N | 294 | 294 | 294 |

HC1 SEs for Pooled/RE. Driscoll–Kraay (HC3, maxlag = 2) for Fixed Effects.  
\* p<0.1 · \*\* p<0.05 · \*\*\* p<0.01

---

## Diagnostic Tests

| Test | Statistic | p-value | Result |
|---|---|---|---|
| IPS — GDP growth | Wtbar = −5.09 | < 0.001 | Stationary |
| IPS — Inflation | Wtbar = −2.50 | 0.006 | Stationary |
| IPS — FDI | Wtbar = −3.44 | < 0.001 | Stationary |
| IPS — Trade | Wtbar = −0.58 | 0.280 | Non-stationary → time trend added |
| IPS — Investment | Wtbar = −5.91 | < 0.001 | Stationary |
| Breusch-Pagan LM | χ²(1) = 4.51 | 0.034 | Panel model required |
| Hausman Test | χ²(5) = 27.10 | < 0.001 | Fixed Effects preferred |
| Heteroskedasticity (BP) | BP = 84.08 | < 0.001 | Detected |
| Serial Correlation (Wooldridge) | F = 24.95 | < 0.001 | Detected |
| Cross-Sectional Dependence (Pesaran CD) | z = 13.70 | < 0.001 | Detected |
| Multicollinearity (VIF) | All < 2 | — | Not present |

---

## How to Run

```r
# install once
install.packages(c("WDI","dplyr","tidyr","ggplot2","corrplot",
                   "plm","lmtest","sandwich","car","stargazer"))

# run
source("AsianGrowthRate.R")
```

---

## Repository Structure

```
emerging-asia-growth-panel/
├── AsianGrowthRate.R
└── README.md
```

---

*MSc Economics · Gokhale Institute of Politics and Economics (GIPE) · 2025*
