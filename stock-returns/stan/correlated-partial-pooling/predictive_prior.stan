data {
    int<lower=0> time_count;
    int<lower=0> stock_count;
}
generated quantities {
    real<lower=0> mean_returns_standard_deviation;
    vector[stock_count] mean_returns;

    real<lower=0> volatilities_standard_deviation;
    vector<lower=0>[stock_count] volatilities;

    matrix[stock_count, time_count] returns;

    mean_returns_standard_deviation = fabs(normal_rng(0, 0.2 / 100.0));
    for (stock in 1:stock_count)
        mean_returns[stock] = normal_rng(0, mean_returns_standard_deviation);

    volatilities_standard_deviation = fabs(normal_rng(0, 10.0 / 100.0));
    for (stock in 1:stock_count)
        volatilities[stock] = fabs(normal_rng(0, volatilities_standard_deviation));

    for (stock in 1:stock_count)
        for (time in 1:time_count)
            returns[stock, time] = normal_rng(mean_returns[stock], volatilities[stock]);
}
