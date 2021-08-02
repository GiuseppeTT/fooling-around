data {
    int<lower=0> time_count;
    int<lower=0> stock_count;
}
generated quantities {
    real mean_return;
    real<lower=0> volatility;

    matrix[stock_count, time_count] returns;

    mean_return = normal_rng(0, 0.1 / 100.0);
    volatility = fabs(normal_rng(0, 10.0 / 100.0));

    for (stock in 1:stock_count)
        for (time in 1:time_count)
            returns[stock, time] = normal_rng(mean_return, volatility);
}
