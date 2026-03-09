# Sameer Chawla
# MSc Economics, GIPE | IBEF
# Macroeconomic Determinants of GDP Growth — Emerging Asia (1995-2024)
# Data: World Bank WDI

# This project looks at what drives GDP growth across 10 emerging Asian
# economies over 30 years. I use panel data methods (pooled OLS, FE, RE)
# and follow it up with the standard set of diagnostic tests.
# Final inference is based on Driscoll-Kraay SEs given cross-sectional
# dependence across these economies.


# ---- packages ----------------------------------------------------------------

# install.packages(c("WDI","dplyr","tidyr","ggplot2","corrplot",
#                    "plm","lmtest","sandwich","car","stargazer"))

library(WDI)
library(dplyr)
library(tidyr)
library(ggplot2)
library(corrplot)
library(plm)
library(lmtest)
library(sandwich)
library(car)
library(stargazer)


# ---- data --------------------------------------------------------------------

codes <- c(
  gdp_growth = "NY.GDP.MKTP.KD.ZG",
  inflation  = "FP.CPI.TOTL.ZG",
  fdi        = "BX.KLT.DINV.WD.GD.ZS",
  trade      = "NE.TRD.GNFS.ZS",
  investment = "NE.GDI.TOTL.ZS"
)

countries <- c("BD","CN","IN","ID","MY","PK","PH","LK","TH","VN")

df <- WDI(country = countries, indicator = codes,
          start = 1995, end = 2024, extra = FALSE)

df <- df %>%
  rename(country_code = iso2c, country_name = country) %>%
  drop_na() %>%
  mutate(year_num = as.numeric(as.character(year)))

# quick check
cat("obs:", nrow(df), "| countries:", length(unique(df$country_name)),
    "| years:", min(df$year), "-", max(df$year), "\n")


# ---- descriptive stats -------------------------------------------------------

summary(df[c("gdp_growth","inflation","fdi","trade","investment")])

# country averages — useful for the results table in the paper
country_avg <- df %>%
  group_by(country_name) %>%
  summarise(
    growth     = round(mean(gdp_growth), 2),
    inflation  = round(mean(inflation),  2),
    fdi        = round(mean(fdi),        2),
    trade      = round(mean(trade),      2),
    investment = round(mean(investment), 2)
  ) %>%
  arrange(desc(growth))

print(country_avg)


# ---- correlation matrix ------------------------------------------------------

corr_matrix <- cor(df[c("gdp_growth","inflation","fdi","trade","investment")],
                   use = "pairwise.complete.obs")

corrplot(corr_matrix, method = "number", type = "upper",
         title = "Correlation Matrix", mar = c(0,0,1,0))


# ---- panel data frame --------------------------------------------------------

# keeping df as a normal data frame for dplyr operations
# pdf is only used for plm functions
pdf <- pdata.frame(df, index = c("country_name","year"))


# ---- unit root tests (IPS) ---------------------------------------------------
# Im-Pesaran-Shin test — pools ADF tests across countries
# H0: unit root present (non-stationary)
# reject H0 if p < 0.05, i.e. variable is stationary
# always set lags=2, otherwise you get NA output

purtest(pdf$gdp_growth, test = "ips", exo = "intercept", lags = 2)
purtest(pdf$inflation,  test = "ips", exo = "trend",     lags = 2)
purtest(pdf$fdi,        test = "ips", exo = "intercept", lags = 2)
purtest(pdf$trade,      test = "ips", exo = "intercept", lags = 2)
purtest(pdf$investment, test = "ips", exo = "intercept", lags = 2)

# trade fails (p = 0.28) — non-stationary
# fix: add year_num as a linear time trend in the regression
# can't first-difference trade inside FE — it causes double-differencing


# ---- regression models -------------------------------------------------------
# year_num included to control for the time trend in trade

form <- gdp_growth ~ inflation + fdi + log(trade + 1) + investment + year_num

pooled <- plm(form, data = pdf, model = "pooling")
fe     <- plm(form, data = pdf, model = "within")
re     <- plm(form, data = pdf, model = "random")

summary(pooled)
summary(fe)
summary(re)


# ---- model selection tests ---------------------------------------------------

# do we even need panel models? (BP LM test)
# H0: no individual effects, pooled OLS is fine
plmtest(pooled, type = "bp")

# FE or RE? (Hausman test)
# H0: RE is consistent
# reject => use FE
phtest(fe, re)


# ---- diagnostic tests --------------------------------------------------------

# heteroskedasticity
# running on lm version with country dummies
# NOT using car::vif here because aliased coefficients error appears with dummies
lm_fe <- lm(gdp_growth ~ inflation + fdi + log(trade+1) + investment + year_num
            + factor(country_name), data = df)
bptest(lm_fe, studentize = FALSE)

# serial correlation
pwartest(form, data = pdf)

# cross-sectional dependence — expected given these are linked Asian economies
pcdtest(fe, test = "cd")

# multicollinearity check — run without country dummies to avoid aliasing
lm_vif <- lm(gdp_growth ~ inflation + fdi + log(trade+1) + investment + year_num,
             data = df)
car::vif(lm_vif)

# all three problems present (heterosk. + serial corr. + cross-sect. dependence)
# => Driscoll-Kraay SEs are the right call (vcovSCC handles all three)


# ---- robust standard errors --------------------------------------------------

# final model: FE with Driscoll-Kraay SEs
# maxlag=2 to account for second-order serial dependence
fe_scc <- coeftest(fe, vcov. = vcovSCC(fe, type = "HC3", maxlag = 2))
print(fe_scc)

# for comparison — Arellano cluster-robust (doesn't handle cross-sect. depend.)
fe_hc <- coeftest(fe, vcov. = vcovHC(fe, method = "arellano",
                                     type = "HC1", cluster = "group"))
print(fe_hc)


# ---- results table -----------------------------------------------------------

stargazer(
  pooled, fe, re,
  se = list(
    sqrt(diag(vcovHC(pooled, type = "HC1"))),
    sqrt(diag(vcovSCC(fe, type = "HC3", maxlag = 2))),
    sqrt(diag(vcovHC(re,  type = "HC1")))
  ),
  title            = "Determinants of GDP Growth in Emerging Asia (1995-2024)",
  dep.var.labels   = "GDP Growth (%)",
  covariate.labels = c("Inflation","FDI (% GDP)","log(Trade)",
                       "Investment (% GDP)","Year Trend"),
  column.labels    = c("Pooled OLS","Fixed Effects","Random Effects"),
  notes            = "HC1 SEs for Pooled/RE. Driscoll-Kraay (HC3, maxlag=2) for FE.",
  notes.append     = FALSE,
  type             = "text"   # change to "latex" if needed
)


# ---- figures -----------------------------------------------------------------

dir.create("figures", showWarnings = FALSE)

# GDP growth over time
ggplot(df, aes(x = year, y = gdp_growth,
               colour = country_name, group = country_name)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 0.9, alpha = 0.7) +
  labs(title   = "GDP Growth — Emerging Asia (1995-2024)",
       x = NULL, y = "GDP Growth (%)", colour = NULL,
       caption = "Source: World Bank WDI") +
  theme_minimal() +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold")) +
  guides(colour = guide_legend(nrow = 2))

ggsave("figures/gdp_trends.png", width = 10, height = 6, dpi = 150)

# average growth by country
ggplot(country_avg, aes(x = reorder(country_name, growth),
                        y = growth, fill = growth)) +
  geom_col(width = 0.65) +
  geom_text(aes(label = paste0(growth,"%")),
            hjust = -0.1, size = 3.2, colour = "grey30") +
  coord_flip() +
  scale_fill_gradient(low = "#5b92c4", high = "#c0392b") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(title = "Average GDP Growth by Country (1995-2024)",
       x = NULL, y = "Avg Growth (%)",
       caption = "Source: World Bank WDI") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold"))

ggsave("figures/avg_growth.png", width = 8, height = 5, dpi = 150)

# inflation vs growth
ggplot(df, aes(x = inflation, y = gdp_growth)) +
  geom_point(aes(colour = country_name), alpha = 0.5, size = 1.5) +
  geom_smooth(method = "lm", se = TRUE, colour = "black",
              linewidth = 0.7, linetype = "dashed") +
  labs(title = "Inflation and GDP Growth",
       x = "Inflation (%)", y = "GDP Growth (%)", colour = NULL,
       caption = "Source: World Bank WDI") +
  theme_minimal() +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold")) +
  guides(colour = guide_legend(nrow = 2))

ggsave("figures/inflation_growth.png", width = 8, height = 5, dpi = 150)

# FDI vs growth
ggplot(df, aes(x = fdi, y = gdp_growth)) +
  geom_point(aes(colour = country_name), alpha = 0.5, size = 1.5) +
  geom_smooth(method = "lm", se = TRUE, colour = "black",
              linewidth = 0.7, linetype = "dashed") +
  labs(title = "FDI and GDP Growth",
       x = "FDI Net Inflows (% GDP)", y = "GDP Growth (%)", colour = NULL,
       caption = "Source: World Bank WDI") +
  theme_minimal() +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold")) +
  guides(colour = guide_legend(nrow = 2))

ggsave("figures/fdi_growth.png", width = 8, height = 5, dpi = 150)

cat("done — figures saved to figures/\n")