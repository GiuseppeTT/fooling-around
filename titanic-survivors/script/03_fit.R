# Set up -----------------------------------------------------------------------
## Load libraries
library(tidyverse)
library(tidymodels)

## Source auxiliary R files
source("R/constants.R")
source("R/functions.R")

## Set seed
set.seed(SEED)


# Fit --------------------------------------------------------------------------
## Read and resample data
train_data <- read_rds("data/train_data.rds")
train_resamples <- vfold_cv(train_data, v = PARTITION_COUNT, strata = outcome)

## Build workflow
# TODO: transform fare?
preprocessor <-
    recipe(outcome ~ ., data = train_data) %>%  # TODO: check data argument
    update_role(passenger, new_role = "ID") %>%
    step_zv(all_predictors()) %>%
    step_impute_median(all_numeric_predictors()) %>%
    step_impute_mode(all_nominal_predictors()) %>%
    step_dummy(all_nominal(), -all_outcomes())

logistic_model <-
    logistic_reg(penalty = tune()) %>%
    set_engine("glmnet")

random_forest_model <-
    rand_forest() %>%
    set_engine("ranger") %>%
    set_mode("classification")

workflows <-
    workflow_set(
        list(
            common_preprocessor = preprocessor
        ),
        list(
            logistic = logistic_model,
            random_forest = random_forest_model
        )
    )

## Tune workflows
tuned_workflows <-
    workflows %>%
    workflow_map(
        resamples = train_resamples,
        grid = HYPERPARAMETER_LEVELS,
        verbose = VERBOSE,
        metrics = metric_set(roc_auc)
    )

## Fit final model
best_workflow <-
    tuned_workflows %>%
    pull_best_workflow()

# TODO: maybe not use last_fit, just fit
final_workflow <-
    best_workflow %>%
    fit(data = train_data)

## Save model
write_rds(final_workflow, "output/final_workflow.rds")
