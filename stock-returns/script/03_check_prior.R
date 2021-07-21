# TODO: remove warmup, not necessary
# Set up -----------------------------------------------------------------------
library(tidyverse)
library(gt)
library(tidybayes)
library(rstan)

source("R/functions.R")

STOCK_COUNT <- 100

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)


# Script -----------------------------------------------------------------------
data <- list(
    stock_count = STOCK_COUNT
)

model <- stan_model("stan/prior_model.stan")

fit <- sampling(
    model,
    data,
    chains = 1,
    iter = 2 * 252,  # One year after warmup
    algorithm = "Fixed_param"
)

prior_return_summary_table <-
    fit %>%
    gather_draws(prior_returns[stock]) %>%
    median_qi() %>%
    select(
        Stock = stock,
        Median = .value,
        `2.5% quantile` = .lower,
        `97.5% quantile` = .upper
    ) %>%
    gt() %>%
    fmt_percent(!Stock, decimals = 3) %>%
    tab_header("Prior return summaries")

gtsave(prior_return_summary_table, "output/prior_return_summary_table.html")

prior_return_distributions_plot <-
    fit %>%
    gather_draws(prior_returns[stock]) %>%
    mutate(.value = expm1(.value)) %>%
    ggplot(aes(x = .value, group = stock)) +
    geom_density(color = alpha("black", 0.1)) +
    scale_x_log10() +
    theme_bw(18) +
    labs(
        title = "Prior return distributions",
        x = "Return",
        y = "Density"
    )

ggsave(
    "output/prior_return_distributions_plot.png",
    prior_return_distributions_plot,
    width = 12,
    height = 8
)

prior_prices_plot <-
    fit %>%
    gather_draws(prior_returns[stock]) %>%
    group_by(stock) %>%
    arrange(.draw) %>%
    mutate(.value = one_first(exp(cumsum(.value)))) %>%
    ggplot(aes(x = .draw, y = .value, group = stock)) +
    geom_line(alpha = 0.1) +
    scale_y_log10() +
    theme_bw(18) +
    labs(
        title = "Prior prices",
        x = "Time (in trading days)",
        y = "Price"
    )

ggsave(
    "output/prior_prices_plot.png",
    prior_prices_plot,
    width = 12,
    height = 8
)
