# Set up -----------------------------------------------------------------------
library(tidyverse)
library(rstan)

STOCK_COUNT <- 20

USE_VARIATIONAL_BAYES <- FALSE
SAMPLE_COUNT <- 5e3
CHAIN_COUNT <- parallel::detectCores()

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)


# Script -----------------------------------------------------------------------
returns <- read_rds("data/clean_returns.rds")

if (!is.null(STOCK_COUNT) & STOCK_COUNT < dim(returns)[2])
    returns <- returns[, seq(STOCK_COUNT)]

data <- list(
    time_count = dim(returns)[1],
    stock_count = dim(returns)[2],
    returns = t(returns)
)

model <- stan_model("stan/model.stan")

if (USE_VARIATIONAL_BAYES) {
    fit <- vb(
        model,
        data,
        iter = 1e5,
        tol_rel_obj = 1e-8,
        output_samples = CHAIN_COUNT * SAMPLE_COUNT,
        adapt_iter = 1e3
    )
} else {
    fit <- sampling(
        model,
        data,
        chains = CHAIN_COUNT,
        iter = SAMPLE_COUNT
    )
}

write_rds(fit, "output/fit.rds")
