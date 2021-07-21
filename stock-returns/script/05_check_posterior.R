# Set up -----------------------------------------------------------------------
library(tidyverse)
library(gt)
library(tidybayes)

source("R/functions.R")


# Script -----------------------------------------------------------------------
returns <- read_rds("data/clean_returns.rds")
fit <- read_rds("output/fit.rds")

posterior_return_summary_table <-
    fit %>%
    gather_draws(posterior_returns[stock]) %>%
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

gtsave(posterior_return_summary_table, "output/posterior_return_summary_table.html")

posterior_return_distributions_plot <-
    fit %>%
    gather_draws(posterior_returns[stock]) %>%
    mutate(.value = expm1(.value)) %>%
    ggplot(aes(x = .value, group = stock)) +
    geom_density(color = alpha("black", 0.1)) +
    theme_bw(18) +
    labs(
        title = "Posterior return distributions",
        x = "Return",
        y = "Density"
    )

ggsave(
    "output/posterior_return_distributions_plot.png",
    posterior_return_distributions_plot,
    width = 12,
    height = 8
)

posterior_prices_plot <-
    fit %>%
    gather_draws(posterior_returns[stock]) %>%
    group_by(stock) %>%
    arrange(.draw) %>%
    mutate(.value = one_first(exp(cumsum(.value)))) %>%
    ggplot(aes(x = .draw, y = .value, group = stock)) +
    geom_line(alpha = 0.1) +
    scale_y_log10() +
    theme_bw(18) +
    labs(
        title = "Posterior prices",
        x = "Time (in trading days)",
        y = "Price"
    )

ggsave(
    "output/posterior_prices_plot.png",
    posterior_prices_plot,
    width = 12,
    height = 8
)
