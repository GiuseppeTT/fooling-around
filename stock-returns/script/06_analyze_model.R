# Set up -----------------------------------------------------------------------
library(tidyverse)
library(gt)
library(tidybayes)

source("R/functions.R")


# Script -----------------------------------------------------------------------
fit <- read_rds("output/fit.rds")

posterior_summary_table <-
    fit %>%
    gather_draws(mean_returns_mean, mean_returns_standard_deviation, volatilities_mean) %>%
    median_qi() %>%
    mutate(.variable = humanize_string(.variable)) %>%
    select(
        Posterior = .variable,
        Median = .value,
        `2.5% quantile` = .lower,
        `97.5% quantile` = .upper
    ) %>%
    gt() %>%
    fmt_percent(!Posterior, decimals = 3) %>%
    tab_header("Posterior summaries")

gtsave(posterior_summary_table, "output/posterior_summary_table.html")

posterior_distributions_plot <-
    fit %>%
    gather_draws(mean_returns_mean, mean_returns_standard_deviation, volatilities_mean) %>%
    mutate(.variable = humanize_string(.variable)) %>%
    ggplot(aes(x = .value)) +
    facet_wrap(~ .variable, scales = "free") +
    geom_density(size = 2) +
    theme_bw(18) +
    labs(
        title = "Posterior distributions",
        x = NULL,
        y = NULL
    )

ggsave(
    "output/posterior_distributions_plot.png",
    posterior_distributions_plot,
    width = 14,
    height = 8
)

posterior_latent_summary_table <-
    fit %>%
    gather_draws(mean_returns[stock], volatilities[stock]) %>%
    median_qi() %>%
    mutate(.variable = humanize_string(.variable)) %>%
    select(
        Stock = stock,
        Posterior = .variable,
        Median = .value,
        `2.5% quantile` = .lower,
        `97.5% quantile` = .upper
    ) %>%
    gt() %>%
    fmt_percent(!c(Stock, Posterior), decimals = 3) %>%
    tab_header("Posterior latent summaries")

gtsave(posterior_latent_summary_table, "output/posterior_latent_summary_table.html")
