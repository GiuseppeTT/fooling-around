# Define constants -------------------------------------------------------------
SEED <- 42
VERBOSE <- TRUE

SPLIT_PROPORTION <- 3/4
PARTITION_COUNT <- 10
HYPERPARAMETER_LEVELS <- 10

METRICS <- yardstick::metric_set(yardstick::roc_auc)
