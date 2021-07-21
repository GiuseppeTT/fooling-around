# Set up -----------------------------------------------------------------------
library(tidyverse)
library(lubridate)
library(BatchGetSymbols)
library(future)

YEAR_COUNT <- 20
THRESH.BAD.DATA <- 0.95
DO.COMPLETE.DATA <- TRUE
DO.FILL.MISSING.PRICES <- FALSE
DO.PARALLEL <- TRUE


# Script -----------------------------------------------------------------------
sp500 <-
    GetSP500Stocks()

tickers <-
    sp500 %>%
    pull(Tickers) %>%
    str_replace(r"(\.)", r"(-)") %>%
    sort()

if (DO.PARALLEL)
    plan(multicore)
stocks <-
    tickers %>%
    BatchGetSymbols(
        first.date = now() - years(YEAR_COUNT),
        last.date = now(),
        thresh.bad.data = THRESH.BAD.DATA,
        do.complete.data = DO.COMPLETE.DATA,
        do.fill.missing.prices = DO.FILL.MISSING.PRICES,
        do.parallel = DO.PARALLEL
    )
if (DO.PARALLEL)
    plan(sequential)

returns <-
    stocks %>%
    pluck("df.tickers") %>%
    dplyr::select(date = ref.date, ticker, return = ret.adjusted.prices)

write_rds(returns, "data/raw_returns.rds")
