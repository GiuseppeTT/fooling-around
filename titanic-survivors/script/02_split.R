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
## Read data
data <-
    read_rds("data/clean_titanic.rds")

## Split data
data_split <- initial_split(data, prop = SPLIT_PROPORTION, strata = outcome)

train_data <- training(data_split)
test_data  <- testing(data_split)

## Write split
write_rds(train_data, "data/train_data.rds")
write_rds(train_data, "data/test_data.rds")
