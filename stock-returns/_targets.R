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
    tar_stan_vb(
        stan,
        stan_files = c(
            complete_pooling = "stan/complete-pooling.stan",
            partial_pooling = "stan/partial-pooling.stan"#,
            #correlated_partial_pooling = "stan/correlated-partial-pooling.stan"
        ),
        data = list(
            time_count = dim(returns)[1],
            stock_count = dim(returns)[2],
            returns = returns
        ),
        quiet = FALSE,
        pedantic = TRUE,
        iter = ITER_COUNT,
        tol_rel_obj = TOLERANCE,
        output_samples = SAMPLE_COUNT
    ),
    complement_stan_mcmc(
        stan,
        complete_pooling
    ),
    complement_stan_mcmc(
        stan,
        partial_pooling
    )
)

report_targets <- list(
    tar_render(
        complete_pooling_report,
        "Rmd/report.Rmd",
        params = list(
            parameter_table = stan_parameter_table_complete_pooling,
            parameter_plots = stan_parameter_plots_complete_pooling
        ),
        output_file = "../output/complete_pooling_report.html"
    ),
    tar_render(
        partial_pooling_report,
        "Rmd/report.Rmd",
        params = list(
            parameter_table = stan_parameter_table_partial_pooling,
            parameter_plots = stan_parameter_plots_partial_pooling
        ),
        output_file = "../output/partial_pooling_report.html"
    )
)

list(
    data_targets,
    stan_targets,
    report_targets
)
