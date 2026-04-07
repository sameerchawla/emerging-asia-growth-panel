# ==============================================================================
# DETERMINANTS OF GDP GROWTH IN DEVELOPING ASIA (1995–2023)
# MSc Econometrics Research Script
#
# Author: Sameer Chawla
# Institution: Gokhale Institute of Politics and Economics (GIPE)
#
# Core Theoretical Foundations:
# 1. Wooldridge (2010): Panel Data, Chamberlain's Device, Serial Correlation
# 2. Greene (2012): Endogeneity, Control Functions, Block Bootstrapping
# 3. Gujarati (2009): Classical Diagnostics (Koenker-Bassett / BP Tests)
# 4. Pesaran (2007): CIPS Unit Root Testing under Cross-Sectional Dependence
# ==============================================================================

options(scipen = 999, digits = 4)
pkgs <- c("WDI", "plm", "lmtest", "sandwich", "dplyr", "stargazer", "car", "boot")
for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) install.packages(p)
  suppressPackageStartupMessages(library(p, character.only = TRUE))
}

cat("\n=== STEP 1: DATA DOWNLOAD & PREPARATION ===\n")
# End year 2023 avoids extreme missingness in current-year WDI data
raw <- WDI(
  country = c("BD","CN","IN","ID","MY","PK","PH","LK","TH","VN","KH","NP","MN","MM","LA"),
  indicator = c(
    "NY.GDP.MKTP.KD.ZG",    # GDP growth (%)
    "FP.CPI.TOTL.ZG",       # Inflation, CPI (%)
    "BX.KLT.DINV.WD.GD.ZS", # FDI net inflows (% GDP)
    "NE.TRD.GNFS.ZS",       # Trade openness (% GDP)
    "NE.GDI.TOTL.ZS"        # Gross fixed capital formation (% GDP)
  ),
  start = 1995, end = 2023
)

df <- raw %>%
  rename(
    gdp_growth = NY.GDP.MKTP.KD.ZG,
    inflation  = FP.CPI.TOTL.ZG,
    fdi        = BX.KLT.DINV.WD.GD.ZS,
    trade      = NE.TRD.GNFS.ZS,
    gfcf       = NE.GDI.TOTL.ZS
  ) %>%
  arrange(country, year) %>%
  group_by(country) %>%
  mutate(
    # One-period lags to mitigate contemporaneous reverse causality
    lag_fdi   = dplyr::lag(fdi, 1),
    lag_gfcf  = dplyr::lag(gfcf, 1),
    lag2_fdi  = dplyr::lag(fdi, 2), # Instrument for Control Function
    
    # Manual first-differences to prevent plm double-differencing bugs in the FD model
    d_gdp_growth = gdp_growth - dplyr::lag(gdp_growth, 1),
    d_inflation  = inflation - dplyr::lag(inflation, 1),
    d_lag_fdi    = lag_fdi - dplyr::lag(lag_fdi, 1),
    d_trade      = trade - dplyr::lag(trade, 1),
    d_lag_gfcf   = lag_gfcf - dplyr::lag(lag_gfcf, 1),
    
    # Mundlak means (Chamberlain's Device - Wooldridge 2010)
    inf_bar   = mean(inflation, na.rm = TRUE),
    fdi_bar   = mean(fdi, na.rm = TRUE),
    gfcf_bar  = mean(gfcf, na.rm = TRUE),
    trade_bar = mean(trade, na.rm = TRUE)
  ) %>%
  ungroup()

pdata <- pdata.frame(df, index = c("country", "year"))
T_max <- length(unique(df$year))
N <- length(unique(df$country))
cat(sprintf("Panel: N = %d, Max T = %d (Unbalanced panel natively preserved for Estimation)\n\n", N, T_max))

f_base <- gdp_growth ~ inflation + lag_fdi + trade + lag_gfcf

# ----------------------------------------------------------------------
# STEP 2: POOLABILITY TEST (Gujarati Ch. 16)
# ----------------------------------------------------------------------
cat("=== STEP 2: POOLABILITY TEST ===\n")
pool_test <- plmtest(plm(f_base, data = pdata, model = "pooling"), effect = "individual", type = "honda")
cat(sprintf("Honda statistic = %.3f, p-value = %.4f -> %s\n\n", 
            pool_test$statistic, pool_test$p.value, 
            ifelse(pool_test$p.value < 0.05, "Panel methods needed (Reject OLS)", "Pooled OLS OK")))

# ----------------------------------------------------------------------
# STEP 3: ROBUST MUNDLAK TEST (FE vs RE)
# ----------------------------------------------------------------------
cat("=== STEP 3: MUNDLAK TEST (FE vs RE with Clustered SEs) ===\n")
# Isolate complete cases specifically for lm() to ensure cluster vectors align perfectly
df_mundlak <- df %>% 
  select(country, year, gdp_growth, inflation, lag_fdi, trade, lag_gfcf, inf_bar, fdi_bar, trade_bar, gfcf_bar) %>% 
  na.omit()

mundlak_lm <- lm(gdp_growth ~ inflation + lag_fdi + trade + lag_gfcf + inf_bar + fdi_bar + trade_bar + gfcf_bar, data = df_mundlak)

# Pre-compute cluster-robust VCV matrix, then pass to linearHypothesis
vcov_mundlak <- vcovCL(mundlak_lm, cluster = df_mundlak$country)
mundlak_test <- linearHypothesis(mundlak_lm, c("inf_bar=0", "fdi_bar=0", "trade_bar=0", "gfcf_bar=0"), vcov. = vcov_mundlak)

mundlak_pval <- mundlak_test$`Pr(>F)`[2]
cat(sprintf("Robust Mundlak F-test p-value = %.4f -> %s\n\n", mundlak_pval, 
            ifelse(mundlak_pval < 0.05, "Reject RE (Fixed Effects required)", "RE is efficient")))

# ----------------------------------------------------------------------
# STEP 4: CROSS-SECTIONAL DEPENDENCE (CSD)
# ----------------------------------------------------------------------
cat("=== STEP 4: CROSS-SECTIONAL DEPENDENCE (Pesaran 2004) ===\n")
twfe_prelim <- plm(f_base, data = pdata, model = "within", effect = "twoways")
cd_test <- pcdtest(twfe_prelim, test = "cd")
csd_flag <- cd_test$p.value < 0.05
cat(sprintf("Pesaran CD statistic = %.2f, p-value = %.4f -> %s\n\n", 
            cd_test$statistic, cd_test$p.value, 
            ifelse(csd_flag, "CSD Present (Mandates CIPS & Driscoll-Kraay SEs)", "No CSD")))

# ----------------------------------------------------------------------
# STEP 5: PESARAN CIPS PANEL UNIT ROOT TEST (2nd Generation)
# ----------------------------------------------------------------------
cat("=== STEP 5: 2nd GEN UNIT ROOTS (Pesaran CIPS) ===\n")
# CIPS strictly requires a balanced panel. We dynamically extract the largest 
# balanced subset from our data specifically for this test.
vars_to_test <- c("gdp_growth", "inflation", "fdi", "gfcf", "trade")
df_ur <- df %>% select(country, year, all_of(vars_to_test)) %>% na.omit()
max_t_ur <- max(table(df_ur$country))

df_bal <- df_ur %>% group_by(country) %>% filter(n() == max_t_ur) %>% ungroup()
pdata_bal <- pdata.frame(df_bal, index = c("country", "year"))

cat(sprintf("CIPS strictly requires balanced data. Extracted %d fully balanced countries (T=%d).\n", 
            length(unique(df_bal$country)), max_t_ur))

vars_drift <- c("gdp_growth", "inflation") # Non-trending macroeconomic flows
vars_trend <- c("fdi", "gfcf", "trade")    # Historically trending ratios

for (v in c(vars_drift, vars_trend)) {
  trend_type <- ifelse(v %in% vars_trend, "trend", "drift") 
  test <- tryCatch(cipstest(pdata_bal[[v]], type = trend_type), error = function(e) NULL)
  
  if (!is.null(test)) {
    pv <- test$p.value
    cat(sprintf("CIPS Test for %-12s (type=%-5s): p-value = %.4f -> %s\n", 
                v, trend_type, pv, ifelse(pv < 0.05, "I(0) [Stationary]", "I(1) [Non-Stationary]")))
  } else {
    cat(sprintf("CIPS Test for %-12s failed to converge.\n", v))
  }
}

cat("\nPanel Cointegration Check (Residual Stationarity):\n")
twfe_resid_coint <- resid(twfe_prelim)
coint_test <- tryCatch(purtest(twfe_resid_coint, test = "ips", exo = "none"), error = function(e) NULL)
if (!is.null(coint_test)) {
  coint_pv <- coint_test$statistic$p.value
  cat(sprintf("Residual IPS p-value = %.4f -> %s\n\n", coint_pv, 
              ifelse(coint_pv < 0.05, "Residuals are I(0) -> Panel is Cointegrated (Levels are safe)", 
                     "No Cointegration -> Risk of spurious regression")))
}

# =================================================================-----
# TRANSITION TO STATIONARY MODEL (Addressing I(1) variables)
# =================================================================-----
cat("\n=== ADJUSTING MODEL FOR I(1) VARIABLES ===\n")
# Create differenced instrument for endogeneity test
df <- df %>%
  group_by(country) %>%
  mutate(d_lag2_fdi = lag2_fdi - dplyr::lag(lag2_fdi, 1)) %>%
  ungroup()

pdata <- pdata.frame(df, index = c("country", "year"))
f_stat <- gdp_growth ~ inflation + d_lag_fdi + d_trade + d_lag_gfcf
cat("New Stationary Formula: gdp_growth ~ inflation + ΔFDI(t-1) + ΔTrade + ΔGFCF(t-1)\n\n")

# ----------------------------------------------------------------------
# STEP 6: SERIAL CORRELATION & PANEL HETEROSKEDASTICITY
# ----------------------------------------------------------------------
cat("=== STEP 6: SERIAL CORRELATION & HETEROSKEDASTICITY ===\n")
twfe_stat <- plm(f_stat, data = pdata, model = "within", effect = "twoways")

# Serial Correlation (Wooldridge 2010)
war_test <- pwartest(plm(f_stat, data = pdata, model = "within", effect = "individual"))
cat(sprintf("Wooldridge AR(1) p-value = %.4f -> %s\n", war_test$p.value, 
            ifelse(war_test$p.value < 0.05, "Serial Correlation Present", "Absent")))

# Heteroskedasticity (Koenker-Bassett / Robust BP - Gujarati Ch 11)
resid_num <- as.numeric(residuals(twfe_stat))
fitted_num <- as.numeric(fitted(twfe_stat))
bp_test <- bptest(resid_num ~ fitted_num, studentize = TRUE)
cat(sprintf("Panel Breusch-Pagan p-value = %.4f -> %s\n\n", bp_test$p.value, 
            ifelse(bp_test$p.value < 0.05, "Heteroskedasticity Present", "Homoskedastic")))

# ----------------------------------------------------------------------
# STEP 7: FDI ENDOGENEITY (BLOCK-BOOTSTRAPPED CONTROL FUNCTION)
# ----------------------------------------------------------------------
cat("=== STEP 7: FDI ENDOGENEITY TEST (Greene Ch. 8) ===\n")

df_fs <- df %>% select(country, year, gdp_growth, inflation, d_trade, d_lag_gfcf, d_lag_fdi, d_lag2_fdi) %>% na.omit()
first_stage <- lm(d_lag_fdi ~ inflation + d_trade + d_lag_gfcf + d_lag2_fdi + factor(country) + factor(year), 
                  data = df_fs, na.action = na.exclude)

vcov_fs <- vcovCL(first_stage, cluster = df_fs$country)
fs_robust <- linearHypothesis(first_stage, "d_lag2_fdi = 0", vcov. = vcov_fs)
fs_fstat <- fs_robust$F[2]

countries <- unique(df$country)

boot_cf <- function(data_countries, indices) {
  sampled_countries <- data_countries[indices]
  
  d_list <- lapply(1:length(sampled_countries), function(i) {
    c_data <- df[df$country == sampled_countries[i], ]
    c_data$boot_id <- i  
    return(c_data)
  })
  d_boot <- do.call(rbind, d_list)
  
  fs_boot <- lm(d_lag_fdi ~ inflation + d_trade + d_lag_gfcf + d_lag2_fdi + factor(boot_id) + factor(year), 
                data = d_boot, na.action = na.exclude)
  d_boot$v_hat <- resid(fs_boot)
  
  pd_boot <- tryCatch(pdata.frame(d_boot, index = c("boot_id", "year")), error = function(e) NULL)
  if (is.null(pd_boot)) return(NA)
  
  ss_boot <- tryCatch(
    plm(gdp_growth ~ inflation + d_lag_fdi + d_trade + d_lag_gfcf + v_hat, data = pd_boot, model = "within", effect = "twoways"),
    error = function(e) NA
  )
  if (inherits(ss_boot, "plm")) return(coef(ss_boot)["v_hat"]) else return(NA)
}

set.seed(123)
cat("Running Block Bootstrap (R=500, clustering by country)...\n")
boot_out <- suppressWarnings(boot(countries, boot_cf, R = 500))
valid_reps <- sum(!is.na(boot_out$t))

# Strictly empirical non-parametric p-value
boot_pval <- mean(abs(boot_out$t) > abs(boot_out$t0), na.rm = TRUE)

cat(sprintf("Valid Replicates: %d/%d\n", valid_reps, boot_out$R))
cat(sprintf("Cluster-Robust First-Stage F = %.2f\n", fs_fstat))
cat(sprintf("CF Empirical p-value = %.4f -> ΔFDI is %s\n\n", boot_pval, ifelse(boot_pval < 0.05, "ENDOGENOUS", "EXOGENOUS")))

# ----------------------------------------------------------------------
# STEP 8: ESTIMATION MODELS
# ----------------------------------------------------------------------
cat("=== STEP 8: ESTIMATING MODELS ===\n")
dk_lag <- floor(T_max^(1/4)) # Newey-West bandwidth

# 1. Spurious Levels Model (For comparison/proof of why differencing matters)
twfe_levels <- plm(gdp_growth ~ inflation + lag_fdi + trade + lag_gfcf, data = pdata, model = "within", effect = "twoways")
se_twfe_levels <- vcovSCC(twfe_levels, maxlag = dk_lag)

# 2. Pooled OLS on Stationary Model
ols_stat <- plm(f_stat, data = pdata, model = "pooling")
se_ols_stat <- vcovHC(ols_stat, method = "arellano", type = "HC1")

# 3. TWFE on Stationary Model
se_twfe_stat <- vcovSCC(twfe_stat, maxlag = dk_lag)  

# ----------------------------------------------------------------------
# STEP 9: PUBLICATION-READY TABLE
# ----------------------------------------------------------------------
cat("=== STEP 9: PUBLICATION-READY TABLE ===\n")

stargazer(
  twfe_levels, ols_stat, twfe_stat,
  type = "text",
  se = list(sqrt(diag(se_twfe_levels)), sqrt(diag(se_ols_stat)), sqrt(diag(se_twfe_stat))),
  column.labels = c("TWFE (Spurious Levels)", "Pooled OLS (Stationary)", "TWFE (Stationary)"),
  dep.var.labels = "GDP Growth (I(0))",
  covariate.labels = c("Inflation (I(0))", 
                       "FDI (t-1) [I(1)]", "Trade [I(1)]", "GFCF (t-1) [I(1)]",
                       "Δ FDI (t-1) [I(0)]", "Δ Trade [I(0)]", "Δ GFCF (t-1) [I(0)]"),
  omit = "factor\\(year\\)|factor\\(country\\)",
  add.lines = list(
    c("SE type", paste0("Driscoll-Kraay (lag=", dk_lag, ")"), "Robust HC1", paste0("Driscoll-Kraay (lag=", dk_lag, ")")),
    c("Country FE", "Yes", "No", "Yes"),
    c("Year FE", "Yes", "No", "Yes")
  ),
  title = "Determinants of GDP Growth — Developing Asia (1995–2023)",
  digits = 3,
  star.cutoffs = c(0.10, 0.05, 0.01),
  notes.align = "l",
  notes = c(
    "* p<0.10, ** p<0.05, *** p<0.01.",
    "Col 1 contains I(1) variables and is potentially spurious.",
    "Col 3 is the preferred model: all variables are transformed to I(0).",
    "DK SEs applied to TWFE models to handle Cross-Sectional Dependence.",
    paste0("Bootstrap p-value for ΔFDI endogeneity = ", round(boot_pval, 3))
  )
)

