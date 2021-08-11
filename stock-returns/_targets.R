# Set up -----------------------------------------------------------------------
## Load packages ---------------------------------------------------------------
library(targets)
library(tarchetypes)
library(stantargets)

library(tidyverse)
library(lubridate)

library(posterior)
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
        sliced_returns,
        slice_returns(cleaned_returns, time_count, stock_count)
    ),
    tar_target(
        returns,
        anonymize_returns(sliced_returns)
    )
)

exploratory_analysis <- list(
    tar_target(
        data_draws_returns,
        convert_data_to_draws(returns)
    ),
    tar_target(
        data_summary_returns,
        convert_data_to_summary(returns)
    ),
    tar_target(
        data_observed_plot_returns,
        plot_observed(data_draws_returns)
    )
)

stan_targets <- list(
    tar_stan_mcmc(
        predictive_prior,
        stan_files = c(
            complete_pooling = "stan/complete-pooling/predictive-prior.stan"
        ),
        data = list(
            stock_count = dim(returns)[2]
        ),
        quiet = FALSE,
        pedantic = TRUE,
        include_paths = "stan/",
        chains = 1,
        iter_warmup = 0,
        iter_sampling = SAMPLE_COUNT,
        fixed_param = TRUE,
        diagnostics = FALSE
    ),
    tar_stan_vb(
        model,
        stan_files = c(
            complete_pooling = "stan/complete-pooling/model.stan"
        ),
        data = list(
            time_count = dim(returns)[1],
            stock_count = dim(returns)[2],
            returns = returns
        ),
        quiet = FALSE,
        pedantic = TRUE,
        include_paths = "stan/",
        iter = MAX_ITER_COUNT,
        adapt_iter = ADAPT_ITER_COUNT,
        tol_rel_obj = TOLERANCE,
        output_samples = SAMPLE_COUNT
    ),
    tar_stan_gq(
        predictive_posterior,
        stan_files = c(
            complete_pooling = "stan/complete-pooling/predictive-posterior.stan"
        ),
        data = list(
            stock_count = dim(returns)[2]
        ),
        fitted_params = model_vb_complete_pooling,
        quiet = FALSE,
        pedantic = TRUE,
        include_paths = "stan/"
    ),
    tar_target(
        predictive_prior_observed_plot_complete_pooling,
        plot_observed(predictive_prior_draws_complete_pooling)
    ),
    tar_target(
        model_parameter_table_complete_pooling,
        tidy_stan_summary(model_summary_complete_pooling)
    ),
    tar_target(
        model_parameter_plots_complete_pooling,
        plot_parameters(tidy_stan_draws(model_draws_complete_pooling))
    ),
    tar_target(
        predictive_posterior_observed_plot_complete_pooling,
        plot_observed(predictive_posterior_draws_complete_pooling)
    )
)

report_targets <- list(
    tar_target(
        decimal_count,
        DECIMAL_COUNT
    ),
    tar_render(
        report_complete_pooling,
        "Rmd/report.Rmd",
        params = list(
            predictive_prior_observed_table = predictive_prior_summary_complete_pooling,
            predictive_prior_observed_plot = predictive_prior_observed_plot_complete_pooling,
            observed_table = data_summary_returns,
            observed_plot = data_observed_plot_returns,
            predictive_posterior_observed_table = predictive_posterior_summary_complete_pooling,
            predictive_posterior_observed_plot = predictive_posterior_observed_plot_complete_pooling,
            parameter_table = model_parameter_table_complete_pooling,
            parameter_plots = model_parameter_plots_complete_pooling
        ),
        output_file = "../output/report/complete-pooling-report.html"
    )
)

list(
    data_targets,
    exploratory_analysis,
    stan_targets,
    report_targets
)
