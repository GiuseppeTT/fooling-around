# Set up -----------------------------------------------------------------------
library(tidyverse)


# Script -----------------------------------------------------------------------
raw_returns <- read_rds("data/raw_returns.rds")

clean_returns <-
    raw_returns %>%
    mutate(return = log1p(return))

clean_returns <-
    clean_returns %>%
    pivot_wider(date, names_from = ticker, values_from = return) %>%
    select(-date) %>%
    drop_na() %>%
    as.matrix()

write_rds(clean_returns, "data/clean_returns.rds")
