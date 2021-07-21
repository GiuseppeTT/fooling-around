# TODO:
# - Read test data and load fit model
# - Check it's performance
#   - Plot ROC
#   - Check AUC

# Set up -----------------------------------------------------------------------
## Load libraries
library(tidyverse)
library(tidymodels)

## Source auxiliary R files
# source("R/constants.R")
# source("R/functions.R")


# Check ------------------------------------------------------------------------
## Read test data and load workflow
test_data <-
    read_rds("data/test_data.rds")

final_workflow <-
    read_rds("output/final_workflow.rds")

## Predict
predictions <-
    final_workflow %>%
    predict(new_data = test_data, type = "prob") %>%
    bind_cols(test_data)

## Check
roc_curve_plot <-
    predictions %>%
    roc_curve(.pred_survived, truth = outcome) %>%
    autoplot()

ggsave("output/roc_curve.png")

roc_auc_value <-
    predictions %>%
    roc_auc(.pred_survived, truth = outcome) %>%
    pull(.estimate) %>%
    as.character()

write_file(roc_auc_value, "output/roc_auc.txt")
