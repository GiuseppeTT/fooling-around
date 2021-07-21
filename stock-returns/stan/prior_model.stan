data {
    int<lower=0> stock_count;
}
generated quantities {
    real mean_returns_mean;
    real<lower=0> mean_returns_standard_deviation;
    vector[stock_count] mean_returns;

    real<lower=0> volatilities_standard_deviation;
    vector<lower=0>[stock_count] volatilities;

    vector[stock_count] prior_returns;

    mean_returns_mean = normal_rng(0, 0.1 / 100.0);
    mean_returns_standard_deviation = fabs(normal_rng(0, 0.1 / 100.0));
    for (stock in 1:stock_count)
        mean_returns[stock] = normal_rng(mean_returns_mean, mean_returns_standard_deviation);

    volatilities_standard_deviation = fabs(normal_rng(0, 10.0 / 100.0));
    for (stock in 1:stock_count)
        volatilities[stock] = fabs(normal_rng(0, volatilities_standard_deviation));

    for (stock in 1:stock_count)
        prior_returns[stock] = normal_rng(mean_returns[stock], volatilities[stock]);
}
