#### Modernized Beta-Binomial Reliability Visualization ####
# Purpose: Alternative figure generation with ggplot2 and advanced diagnostics
# Path: Documents/GitHub/BetaBinomialPaperMaterials/Code_for_figures_v2.R

# 1. Load Libraries
# Note: install.packages(c("VGAM", "ggplot2", "dplyr", "tidyr", "patchwork", "ggrepel")) if not installed
library(VGAM)      # For Beta-Binomial fitting
library(ggplot2)   # For high-quality graphics
library(dplyr)     # For data manipulation
library(tidyr)     # For data tidying
library(patchwork) # For combining plots
library(ggrepel)   # For non-overlapping labels

# 2. Core Functions
# ------------------------------------------------------------------------------

# Function to fit model and return parameters/reliability
get_bb_results <- function(data, y_col, n_col, id_col) {
  df <- data %>% filter(!!sym(n_col) > 0)
  y <- df[[y_col]]
  n <- df[[n_col]]
  
  # Fit Model
  fit <- vglm(cbind(y, n - y) ~ 1, betabinomial)
  mu <- exp(coef(fit)[1]) / (1 + exp(coef(fit)[1]))
  gamma <- exp(coef(fit)[2]) / (1 + exp(coef(fit)[2]))
  theta <- gamma / (1 - gamma)
  M <- 1/gamma - 1
  
  # Derive Beta Parameters
  alpha <- mu / theta
  beta_param <- (1 - mu) / theta
  
  # Calculate EB Estimates and Reliability
  df <- df %>%
    mutate(
      obs_rate = y / n,
      eb_est = (y + alpha) / (n + alpha + beta_param),
      reliability = n / (n + alpha + beta_param),
      shrinkage = obs_rate - eb_est
    )
  
  return(list(data = df, params = list(alpha=alpha, beta=beta_param, mu=mu, M=M)))
}

# 3. Data Setup (Example/Simulated Data)
# ------------------------------------------------------------------------------
# In a real run, you would use:
# contraceptive <- readxl::read_excel("path/to/data.xlsx")
# sim_data <- contraceptive 

set.seed(123)
n_obs <- 100
sim_data <- data.frame(
  ClinicID = 1:n_obs,
  total = round(runif(n_obs, 5, 200)),
  yes_mostmod = rbinom(n_obs, round(runif(n_obs, 5, 200)), 0.35),
  yes_larc = rbinom(n_obs, round(runif(n_obs, 5, 200)), 0.10)
)

# Process both measures
results_mm <- get_bb_results(sim_data, "yes_mostmod", "total", "ClinicID")
results_larc <- get_bb_results(sim_data, "yes_larc", "total", "ClinicID")

# 4. Figure Alternatives
# ------------------------------------------------------------------------------

#### ALT FIGURE 1: Integrated Density + Histogram ####
plot_density_hist <- function(res, title) {
  p_text <- paste0("α: ", round(res$params$alpha, 2), " | β: ", round(res$params$beta, 2))
  
  ggplot(res$data, aes(x = obs_rate)) +
    geom_histogram(aes(y = ..density..), fill = "grey80", color = "white", bins = 20) +
    stat_function(fun = dbeta, args = list(shape1 = res$params$alpha, shape2 = res$params$beta), 
                  color = "firebrick", size = 1.2, linetype = "dashed") +
    labs(title = title, subtitle = p_text, x = "Observed Rate", y = "Density") +
    theme_minimal()
}

p1 <- plot_density_hist(results_mm, "Most-Mod Service Quality")
p2 <- plot_density_hist(results_larc, "LARC Measure Quality")

# Display combined (requires patchwork)
# (p1 / p2) 

#### ALT FIGURE 3: Shrinkage Visualization (Slope Plot style) ####
# Shows how observed rates move toward the mean after reliability adjustment
shrink_data <- results_mm$data %>%
  arrange(total) %>%
  slice(c(1:5, (n()-5):n())) %>% # Pick smallest and largest for clarity
  select(ClinicID, obs_rate, eb_est, total) %>%
  pivot_longer(cols = c(obs_rate, eb_est), names_to = "Type", values_to = "Value")

p3 <- ggplot(shrink_data, aes(x = Type, y = Value, group = ClinicID)) +
  geom_line(aes(color = log(total)), alpha = 0.6, size = 1) +
  geom_point() +
  scale_color_viridis_c(name = "Log(Sample Size)") +
  scale_x_discrete(labels = c("eb_est" = "Adjusted (EB)", "obs_rate" = "Observed")) +
  labs(title = "Shrinkage Effect by Sample Size", y = "Measure Rate") +
  theme_light()

#### NEW FIGURE: Caterpillar Plot ####
# Visualizes reliability scores across the population
p4 <- ggplot(results_mm$data %>% arrange(reliability), aes(x = reorder(ClinicID, reliability), y = reliability)) +
  geom_point(aes(size = total), alpha = 0.5, color = "steelblue") +
  geom_hline(y_intercept = 0.7, linetype = "dotted", color = "red") + # Common threshold
  annotate("text", x = 10, y = 0.73, label = "Reliability Threshold (0.7)", color = "red", size = 3) +
  labs(title = "Reliability by Clinic (Caterpillar Plot)", x = "Clinic Rank", y = "Reliability (n / n+M)") +
  theme_minimal() +
  theme(axis.text.x = element_blank())

#### NEW FIGURE: Funnel Plot ####
# Performance rate vs sample size with BB-derived confidence bands
mu <- results_mm$params$mu
p5 <- ggplot(results_mm$data, aes(x = total, y = obs_rate)) +
  geom_point(aes(alpha = reliability), color = "darkslategrey") +
  geom_hline(y_intercept = mu, color = "blue") +
  # Adding simple 95% binomial bands for comparison
  stat_function(fun = function(x) mu + 1.96*sqrt(mu*(1-mu)/x), linetype = "dashed", alpha = 0.5) +
  stat_function(fun = function(x) mu - 1.96*sqrt(mu*(1-mu)/x), linetype = "dashed", alpha = 0.5) +
  labs(title = "Funnel Plot: Observed Rate vs. Sample Size",
       subtitle = "Blue line = Population Mean | Dashed = 95% Binomial limits",
       x = "Sample Size (n)", y = "Observed Rate") +
  theme_minimal()

# 5. Save Exports
# ------------------------------------------------------------------------------
# Example of how to save:
# ggsave("Figure_Shrinkage.png", p3, width = 8, height = 6)
# ggsave("Figure_Funnel.png", p5, width = 8, height = 6)
