data {
    int<lower=0> time_count;
    int<lower=0> stock_count;

    real mean_return;
    real<lower=0> volatility;
}
generated quantities {
    matrix[stock_count, time_count] returns;

    for (stock in 1:stock_count)
        for (time in 1:time_count)
            returns[stock, time] = normal_rng(mean_return, volatility);
}
