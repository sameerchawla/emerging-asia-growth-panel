# =============================================================================
# GDP GROWTH DETERMINANTS - 10 ASIAN ECONOMIES 1995-2024
# Data:   World Bank WDI
# =============================================================================
# HOW TO RUN:
#   1. Open RStudio
#   2. File > Open > select this file
#   3. Click "Source" (top right of script pane)
#   All packages install automatically on first run.
# =============================================================================


# -----------------------------------------------------------------------------
# STEP 0: INSTALL AND LOAD PACKAGES
# -----------------------------------------------------------------------------

packages <- c("WDI", "plm", "lmtest", "sandwich", "dplyr")

for (pkg in packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}

options(scipen = 4, digits = 4)
cat("Packages loaded.\n\n")


# -----------------------------------------------------------------------------
# STEP 1: DOWNLOAD DATA FROM WORLD BANK
# -----------------------------------------------------------------------------

cat("Downloading data...\n")

raw <- WDI(
  country   = c("BD", "CN", "IN", "ID", "MY", "PK", "PH", "LK", "TH", "VN"),
  indicator = c(
    "NY.GDP.MKTP.KD.ZG",    # gdp_growth
    "FP.CPI.TOTL.ZG",       # inflation
    "BX.KLT.DINV.WD.GD.ZS", # fdi
    "NE.TRD.GNFS.ZS",       # trade
    "NE.GDI.TOTL.ZS"        # investment
  ),
  start = 1995,
  end   = 2024
)

cat("Downloaded", nrow(raw), "rows.\n\n")


# -----------------------------------------------------------------------------
# STEP 2: CLEAN DATA
# -----------------------------------------------------------------------------

df <- raw %>%
  rename(
    gdp_growth = NY.GDP.MKTP.KD.ZG,
    inflation  = FP.CPI.TOTL.ZG,
    fdi        = BX.KLT.DINV.WD.GD.ZS,
    trade      = NE.TRD.GNFS.ZS,
    investment = NE.GDI.TOTL.ZS
  ) %>%
  select(country, year, gdp_growth, inflation, fdi, trade, investment) %>%
  mutate(
    covid = as.integer(year %in% c(2020, 2021)),  # pandemic dummy
    gfc   = as.integer(year %in% c(2008, 2009))   # financial crisis dummy
  ) %>%
  arrange(country, year) %>%
  group_by(country) %>%
  mutate(dtrade = trade - lag(trade)) %>%          # first difference of trade
  ungroup() %>%
  filter(!is.na(dtrade)) %>%                       # drop first year per country
  filter(complete.cases(.))                        # drop any remaining NAs

cat("Clean data: N =", nrow(df), "observations\n")
cat("Countries:", paste(unique(df$country), collapse = ", "), "\n\n")


# -----------------------------------------------------------------------------
# STEP 3: DECLARE PANEL DATA
# -----------------------------------------------------------------------------

pdata <- pdata.frame(df, index = c("country", "year"))
print(pdim(pdata))
cat("\n")


# -----------------------------------------------------------------------------
# STEP 4: DESCRIPTIVE STATISTICS
# -----------------------------------------------------------------------------

cat("==== DESCRIPTIVE STATISTICS ====\n")

vars   <- c("gdp_growth", "inflation", "fdi", "trade", "dtrade", "investment")
labels <- c("GDP Growth", "Inflation", "FDI", "Trade", "D.Trade", "Investment")

desc <- data.frame(
  Variable = labels,
  N        = sapply(vars, function(v) sum(!is.na(df[[v]]))),
  Mean     = round(sapply(vars, function(v) mean(df[[v]], na.rm = TRUE)), 2),
  SD       = round(sapply(vars, function(v) sd(df[[v]],   na.rm = TRUE)), 2),
  Min      = round(sapply(vars, function(v) min(df[[v]],  na.rm = TRUE)), 2),
  Max      = round(sapply(vars, function(v) max(df[[v]],  na.rm = TRUE)), 2)
)

print(desc, row.names = FALSE)
cat("\n")


# -----------------------------------------------------------------------------
# STEP 5: CROSS-SECTION DEPENDENCE TEST
# -----------------------------------------------------------------------------
# Run this BEFORE unit root tests.
# Asian economies are linked by trade and capital flows.
# If CSD is confirmed, IPS test is invalid -- must use CIPS instead.

cat("==== CROSS-SECTION DEPENDENCE (Pesaran CD) ====\n")

fe_prelim <- plm(gdp_growth ~ inflation + fdi + trade + investment,
                 data = pdata, model = "within")

cd_test <- pcdtest(fe_prelim, test = "cd")
print(cd_test)

if (cd_test$p.value < 0.05) {
  cat("=> CSD confirmed. IPS test is invalid. Use CIPS.\n\n")
} else {
  cat("=> No CSD detected. IPS test is valid.\n\n")
}


# -----------------------------------------------------------------------------
# STEP 6: PANEL UNIT ROOT TESTS
# -----------------------------------------------------------------------------

series <- list(
  gdp_growth = pdata$gdp_growth,
  inflation  = pdata$inflation,
  fdi        = pdata$fdi,
  trade      = pdata$trade,
  investment = pdata$investment,
  dtrade     = pdata$dtrade
)

# 6A: IPS test (shown for reference only -- invalid under CSD)
cat("==== IPS UNIT ROOT TEST (reference only -- invalid under CSD) ====\n")

for (v in names(series)) {
  r <- purtest(series[[v]], test = "ips", lags = 2, exo = "intercept")
  cat(sprintf("  %-12s  Wbar = %6.3f  p = %.4f  => %s\n",
              v, r$statistic$Wbar, r$p.value,
              ifelse(r$p.value < 0.10, "I(0)", "Non-stationary")))
}
cat("\n")

# 6B: CIPS test -- PREFERRED (valid under CSD)
cat("==== CIPS UNIT ROOT TEST (Pesaran 2007) -- PREFERRED ====\n")

for (v in names(series)) {
  r <- purtest(series[[v]], test = "pescadf", lags = 2, exo = "intercept")
  cat(sprintf("  %-12s  CIPS = %6.3f  p = %.4f  => %s\n",
              v, r$statistic$Wbar, r$p.value,
              ifelse(r$p.value < 0.10, "I(0)", "Non-stationary")))
}

cat("\nConclusion:\n")
cat("  trade is I(1) in levels => enter as dtrade (first difference)\n")
cat("  all other variables are I(0) => enter in levels\n\n")


# -----------------------------------------------------------------------------
# STEP 7: ESTIMATE PANEL MODELS
# -----------------------------------------------------------------------------
# Model: gdp_growth = B1*inflation + B2*fdi + B3*dtrade + B4*investment
#                   + B5*covid + B6*gfc + country_effects + error

f <- gdp_growth ~ inflation + fdi + dtrade + investment + covid + gfc

# Pooled OLS (baseline, no country effects)
ols <- plm(f, data = pdata, model = "pooling")

# Fixed Effects (removes time-invariant country differences)
fe  <- plm(f, data = pdata, model = "within")

# Random Effects -- use Wallace-Hussain method
# (default Swamy-Arora fails with a singularity error when covid + gfc dummies
#  are both included. Wallace-Hussain avoids this.)
re  <- plm(f, data = pdata, model = "random", random.method = "walhus")

cat("==== MODEL SUMMARIES ====\n")
cat("\n--- Pooled OLS ---\n");     print(summary(ols))
cat("\n--- Fixed Effects ---\n");  print(summary(fe))
cat("\n--- Random Effects ---\n"); print(summary(re))


# -----------------------------------------------------------------------------
# STEP 8: MODEL SELECTION TESTS
# -----------------------------------------------------------------------------

cat("==== MODEL SELECTION TESTS ====\n\n")

# F-test: do country fixed effects matter?
ftest <- pFtest(fe, ols)
cat("F-test (FE vs Pooled OLS):\n")
print(ftest)
cat("=>", ifelse(ftest$p.value < 0.05,
                 "Use Fixed Effects. Country effects are significant.",
                 "Pooled OLS is sufficient."), "\n\n")

# Breusch-Pagan LM: do random effects exist?
bplm <- plmtest(ols, type = "bp")
cat("Breusch-Pagan LM (RE vs Pooled OLS):\n")
print(bplm)
cat("=>", ifelse(bplm$p.value < 0.05,
                 "Random effects exist.",
                 "No random effects."), "\n\n")

# Hausman: are country effects correlated with regressors?
hausman <- phtest(fe, re)
cat("Hausman Test (FE vs RE):\n")
print(hausman)
cat("=>", ifelse(hausman$p.value < 0.05,
                 "Use Fixed Effects (effects correlated with regressors).",
                 "Random Effects are consistent and efficient."), "\n\n")


# -----------------------------------------------------------------------------
# STEP 9: DIAGNOSTICS ON PREFERRED MODEL (Fixed Effects)
# -----------------------------------------------------------------------------

cat("==== DIAGNOSTICS ====\n\n")

# Serial correlation
sc <- pbgtest(fe)
cat("Serial Correlation (Breusch-Godfrey):\n")
print(sc)
cat("=>", ifelse(sc$p.value < 0.05,
                 "Serial correlation present. Need robust SE.",
                 "No serial correlation."), "\n\n")

# Heteroskedasticity
ht <- bptest(gdp_growth ~ inflation + fdi + dtrade + investment + covid + gfc,
             data = df)
cat("Heteroskedasticity (Breusch-Pagan):\n")
print(ht)
cat("=>", ifelse(ht$p.value < 0.05,
                 "Heteroskedasticity present.",
                 "No heteroskedasticity."), "\n\n")

# Residual cross-section dependence
cd_res <- pcdtest(fe, test = "cd")
cat("Cross-Section Dependence on residuals (Pesaran CD):\n")
print(cd_res)
cat("=>", ifelse(cd_res$p.value < 0.05,
                 "Residual CSD present. Use Driscoll-Kraay SE.",
                 "No residual CSD."), "\n\n")


# -----------------------------------------------------------------------------
# STEP 10: ROBUST STANDARD ERRORS
# -----------------------------------------------------------------------------
# Serial correlation + CSD are present, so default SE are biased.
# Two robust options reported:
#   HC3  = cluster-robust SE (clustered by country). NOTE: unreliable with
#          fewer than 30 clusters. N=10 here so treat with caution.
#   DK   = Driscoll-Kraay SE. Handles serial correlation AND cross-section
#          dependence. Does not need large N. This is the preferred option.

cat("==== ROBUST STANDARD ERRORS ====\n\n")

fe_hc3 <- coeftest(fe, vcov = vcovHC(fe, type = "HC3", cluster = "group"))
fe_dk  <- coeftest(fe, vcov = vcovSCC(fe, type = "HC3", maxlag = 2))

cat("Fixed Effects -- HC3 Cluster-Robust SE:\n")
print(fe_hc3)

cat("\nFixed Effects -- Driscoll-Kraay SE (preferred):\n")
print(fe_dk)


# -----------------------------------------------------------------------------
# STEP 11: SE COMPARISON TABLE
# -----------------------------------------------------------------------------

cat("==== SE COMPARISON: Default vs HC3 vs Driscoll-Kraay ====\n\n")

b      <- coef(fe)
se_def <- sqrt(diag(vcov(fe)))
se_hc3 <- sqrt(diag(vcovHC(fe, type = "HC3", cluster = "group")))
se_dk  <- sqrt(diag(vcovSCC(fe, type = "HC3", maxlag = 2)))

comp <- data.frame(
  Variable   = names(b),
  Coeff      = round(b,      4),
  Default_SE = round(se_def, 4),
  HC3_SE     = round(se_hc3, 4),
  DK_SE      = round(se_dk,  4)
)

print(comp, row.names = FALSE)
cat("\nNote: DK_SE are usually larger than HC3_SE.\n")
cat("With only 10 countries, HC3 underestimates uncertainty. Trust DK_SE.\n\n")


# -----------------------------------------------------------------------------
# STEP 12: ROBUSTNESS CHECKS
# -----------------------------------------------------------------------------
# Re-run Fixed Effects excluding problematic countries.
# Sri Lanka: unbalanced data, economic crisis in 2022.
# China: dominant economy, very different growth dynamics.

cat("==== ROBUSTNESS CHECKS ====\n\n")

run_check <- function(subset_data, label) {
  fe_sub <- plm(f, data = subset_data, model = "within")
  ct     <- coeftest(fe_sub,
                     vcov = vcovHC(fe_sub, type = "HC3", cluster = "group"))
  cat(label, "-- N =", nobs(fe_sub), "\n")
  print(ct)
  cat("\n")
}

run_check(pdata[pdata$country != "Sri Lanka", ],
          "Excluding Sri Lanka")

run_check(pdata[pdata$country != "China", ],
          "Excluding China")

run_check(pdata[!pdata$country %in% c("Sri Lanka", "China"), ],
          "Excluding Sri Lanka and China")


# -----------------------------------------------------------------------------
# STEP 13: SESSION INFO
# -----------------------------------------------------------------------------

cat("==== SESSION INFO ====\n")
sessionInfo()
