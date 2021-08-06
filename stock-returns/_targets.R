# Set up -----------------------------------------------------------------------
## Load packages ---------------------------------------------------------------
library(targets)
library(tarchetypes)
library(stantargets)

library(tidyverse)
library(lubridate)

library(tidybayes)

## Source auxiliary R files ----------------------------------------------------
source("R/constants.R")
source("R/auxiliary_functions.R")
source("R/workflow_functions.R")
source("R/factory_functions.R")

## Set options -----------------------------------------------------------------
set.seed(SEED)

options(mc.cores = parallel::detectCores())


# Targets ----------------------------------------------------------------------
data_targets <- list(
    tar_target(
        year_count,
        YEAR_COUNT
    ),
    tar_target(
        raw_returns,
        download_returns(year_count)
    ),
    tar_target(
        cleaned_returns,
        clean_returns(raw_returns)
    ),
    tar_target(
        time_count,
        TIME_COUNT
    ),
    tar_target(
        stock_count,
        STOCK_COUNT
    ),
    tar_target(
        returns,
        slice_returns(cleaned_returns, time_count, stock_count)
    )
)

stan_targets <- list(
    tar_stan_mcmc(
        stan,
        stan_files = c(
            complete_pooling = "stan/complete-pooling.stan",
            partial_pooling = "stan/partial-pooling.stan",
            correlated_partial_pooling = "stan/correlated-partial-pooling.stan"
        ),
        data = list(
            time_count = dim(returns)[1],
            stock_count = dim(returns)[2],
            returns = returns
        ),
        quiet = FALSE,
        pedantic = TRUE,
        iter_warmup = SAMPLE_COUNT,
        iter_sampling = SAMPLE_COUNT
    ),
    complement_stan_mcmc(
        stan,
        complete_pooling
    ),
    complement_stan_mcmc(
        stan,
        partial_pooling
    ),
    complement_stan_mcmc(
        stan,
        correlated_partial_pooling
    )
)

list(
    data_targets,
    stan_targets
)
