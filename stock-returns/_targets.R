# Set up -----------------------------------------------------------------------
## Load packages ---------------------------------------------------------------
library(targets)
library(tarchetypes)

library(tidyverse)
library(lubridate)
#library(gt)

library(rstan)
library(tidybayes)
#library(posterior)

## Source auxiliar R files -----------------------------------------------------
source("R/constants.R")
source("R/auxiliary_functions.R")
source("R/workflow_functions.R")

## Set options -----------------------------------------------------------------
options(mc.cores = parallel::detectCores())
#rstan_options(auto_write = TRUE)
set.seed(SEED)

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
        stock_count,
        STOCK_COUNT
    ),
    tar_target(
        returns,
        slice_returns(cleaned_returns, stock_count)
    )
)

predictive_prior_targets <- list(
    tar_target(
        predictive_prior_data,
        list(
            time_count = 252,  # One year
            stock_count = stock_count
        )
    ),
    tar_file(
        predictive_prior_file,
        "stan/complete-pooling/predictive_prior.stan"
    ),
    tar_target(
        predictive_prior_model,
        compile_model(predictive_prior_file)
    ),
    tar_target(
        predictive_prior_sample,
        sample_model(
            predictive_prior_model,
            predictive_prior_data,
            chains = 1,
            iter = 1,
            warmup = 0,
            algorithm = "Fixed_param"
        )
    ),
    tar_target(
        predictive_prior_return_plot,
        plot_returns(predictive_prior_sample)
    ),
    tar_target(
        predictive_prior_price_plot,
        plot_prices(predictive_prior_sample)
    )
)

model_targets <- list(
    tar_target(
        model_data,
        list(
            time_count = dim(returns)[1],
            stock_count = dim(returns)[2],
            returns = t(returns)
        )
    ),
    tar_file(
        model_file,
        "stan/complete-pooling/model.stan"
    ),
    tar_target(
        model,
        compile_model(model_file)
    ),
    tar_target(
        sample_count,
        SAMPLE_COUNT
    ),
    tar_target(
        posterior_sample,
        sample_model(
            model,
            model_data,
            iter = sample_count,
        )
    )
)

predictive_posterior_targets <- list(
    tar_target(
        posterior_estimates,
        estimate_posteriors(posterior_sample)
    ),
    tar_target(
        predictive_posterior_data,
        list(
            time_count = 252,  # One year
            stock_count = stock_count,
            mean_return = posterior_estimates["mean_return"],
            volatility = posterior_estimates["volatility"]
        )
    ),
    tar_file(
        predictive_posterior_file,
        "stan/complete-pooling/predictive_posterior.stan"
    ),
    tar_target(
        predictive_posterior_model,
        compile_model(predictive_posterior_file)
    ),
    tar_target(
        predictive_posterior_sample,
        sample_model(
            predictive_posterior_model,
            predictive_posterior_data,
            chains = 1,
            iter = 1,
            warmup = 0,
            algorithm = "Fixed_param"
        )
    ),
    tar_target(
        predictive_posterior_return_plot,
        plot_returns(predictive_posterior_sample)
    ),
    tar_target(
        predictive_posterior_price_plot,
        plot_prices(predictive_posterior_sample)
    )
)

diagnostic_targets <- list(
)

summary_targets <- list(
    tar_target(
        parameters_summary_table,
        tabularize_parameters(posterior_sample)
    ),
    tar_target(
        parameters_summary_plot,
        plot_parameters(posterior_sample)
    )
)

report_targets <- list(
    tar_render(
        report,
        "Rmd/report.Rmd",
        output_dir = "output/"
    )
)

list(
    data_targets,
    predictive_prior_targets,
    model_targets,
    predictive_posterior_targets,
    diagnostic_targets,
    summary_targets,
    report_targets
)
