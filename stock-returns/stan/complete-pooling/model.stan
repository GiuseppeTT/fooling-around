data {
    int<lower=0> time_count;
    int<lower=0> stock_count;
    matrix[stock_count, time_count] returns;
}
parameters {
    real mean_return;
    real<lower=0> volatility;
}
model {
    mean_return ~ normal(0, 0.1 / 100.0);
    volatility ~ normal(0, 10.0 / 100.0);

    for (stock in 1:stock_count)
        returns[stock] ~ normal(mean_return, volatility);
}
