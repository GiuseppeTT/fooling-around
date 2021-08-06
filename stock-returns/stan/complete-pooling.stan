data {
    int<lower=0> time_count;
    int<lower=0> stock_count;
    matrix[time_count, stock_count] returns;
}
transformed data {
    // Make log returns closer to the unitary scale.
    matrix[time_count, stock_count] std_returns;

    std_returns = 100.0 * returns;
}
parameters {
    real std_mean_return;
    real<lower=0> std_volatility;
}
model {
    std_mean_return ~ normal(0.0, 0.2);
    std_volatility ~ normal(0.0, 10.0);

    for (stock in 1:stock_count)
        std_returns[:, stock] ~ normal(std_mean_return, std_volatility);
}
generated quantities {
    real mean_return;
    real<lower=0> volatility;

    // Recover unescaled parameters.
    mean_return = std_mean_return / 100.0;
    volatility = std_volatility / 100.0;
}
