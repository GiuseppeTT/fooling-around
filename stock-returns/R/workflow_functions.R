# Define workflow functions ----------------------------------------------------
## Data ------------------------------------------------------------------------
download_returns <- function(
    year_count,
    do_cache = FALSE,
    thresh_bad_data = 0.95,
    do_complete_data = TRUE,
    do_fill_missing_prices = FALSE
) {
    sp500 <-
        BatchGetSymbols::GetSP500Stocks(do_cache)

    tickers <-
        sp500 %>%
        pull(Tickers) %>%
        str_replace(r"(\.)", r"(-)") %>%
        sort()

    stocks <-
        tickers %>%
        BatchGetSymbols::BatchGetSymbols(
            first.date = now() - years(year_count),
            last.date = now(),
            thresh.bad.data = thresh_bad_data,
            do.complete.data = do_complete_data,
            do.fill.missing.prices = do_fill_missing_prices
        )

    returns <-
        stocks %>%
        pluck("df.tickers") %>%
        select(date = ref.date, ticker, return = ret.adjusted.prices)

    return(returns)
}

clean_returns <- function(
    raw_returns
) {
    clean_returns <-
        raw_returns %>%
        mutate(return = log1p(return))

    clean_returns <-
        clean_returns %>%
        pivot_wider(date, names_from = ticker, values_from = return) %>%
        select(-date) %>%
        drop_na() %>%
        as.matrix()

    return(clean_returns)
}

slice_returns <- function(
    returns,
    stock_count
) {
    max_stock_count <- dim(returns)[2]
    if (!is.null(stock_count) & stock_count < max_stock_count) {
        stock_indices <- sample.int(max_stock_count, stock_count)
        sliced_returns <- returns[, stock_indices]
    } else {
        sliced_returns <- returns
    }

    return(sliced_returns)
}

## Exploratory -----------------------------------------------------------------
plot_observed_returns <- function(
    returns
) {
    data <-
        returns %>%
        tidy_returns()

    plot <-
        data %>%
        plot_base_returns()

    return(plot)
}

plot_base_returns <- function(
    data
) {
    data <-
        data %>%
        mutate(return = expm1(.value))

    plot <-
        data %>%
        ggplot(aes(x = return, group = stock)) +
        geom_density() +
        base_theme() +
        labs(
            title = "Return distributions",
            x = "Return",
            y = "Density"
        )

    return(plot)
}

plot_observed_prices <- function(
    returns
) {
    data <-
        returns %>%
        tidy_returns()

    plot <-
        data %>%
        plot_base_prices()

    return(plot)
}

plot_base_prices <- function(
    data
) {
    data <-
        data %>%
        group_by(stock) %>%
        mutate(price = exp(cumsum(zero_first(.value))))

    plot <-
        data %>%
        ggplot(aes(x = time, y = price, group = stock)) +
        geom_line() +
        scale_y_log10() +
        base_theme() +
        labs(
            title = "Prices",
            x = "Time (in trading days)",
            y = "Price"
        )

    return(plot)
}

tidy_returns <- function(
    returns
) {
    returns %>%
        as_tibble() %>%
        mutate(time = row_number(), .before = everything()) %>%
        pivot_longer(!time, names_to = "stock", values_to = ".value") %>%
        return()
}

## Model -----------------------------------------------------------------------
compile_model <- function(
    file
) {
    file %>%
        stan_model() %>%
        return()
}

sample_model <- function(
    model,
    data,
    ...
) {
    model %>%
        sampling(data, ...) %>%
        return()
}

estimate_posteriors <- function(
    posterior_sample
) {
    posterior_sample %>%
        summarise_draws() %>%
        select(variable, median) %>%
        deframe() %>%
        return()
}

plot_sampled_returns <- function(
    predictive_sample
) {
    data <-
        predictive_sample %>%
        tidy_predictive_sample()

    plot <-
        data %>%
        plot_base_returns()

    return(plot)
}

plot_sampled_prices <- function(
    predictive_sample
) {
    data <-
        predictive_sample %>%
        tidy_predictive_sample()

    plot <-
        data %>%
        plot_base_prices()

    return(plot)
}

tidy_predictive_sample <- function(
    predictive_sample
) {
    data <-
        predictive_sample %>%
        tidy_draws() %>%
        gather_variables()

    data <-
        data %>%
        filter(str_detect(.variable, r"(^returns\[\d+,\d+\]$)"))

    data <-
        data %>%
        mutate(
            stock = as.numeric(str_match(.variable, r"(returns\[(\d+),(\d+)\])")[, 2]),
            time = as.numeric(str_match(.variable, r"(returns\[(\d+),(\d+)\])")[, 3])
        )

    return(data)
}

tabularize_parameters <- function(
    posterior_sample
) {
    posterior_sample %>%
        summarise_draws() %>%
        filter(str_detect(variable, "__$", negate = TRUE)) %>%
        mutate(variable = humanize_string(variable)) %>%
        return()
}

plot_parameters <- function(
    posterior_sample
) {
    data <-
        posterior_sample %>%
        tidy_draws() %>%
        gather_variables() %>%
        filter(str_detect(.variable, "__$", negate = TRUE)) %>%
        mutate(.variable = humanize_string(.variable))

    plot <-
        data %>%
        ggplot(aes(x = .value)) +
        geom_density() +
        facet_wrap(~ .variable, ncol = 1, scales = "free") +
        base_theme() +
        labs(
            title = "Posterior distributions",
            x = NULL,
            y = NULL
        )

    return(plot)
}
