data {
    int<lower=0> time_count;
    int<lower=0> stock_count;
    matrix[stock_count, time_count] returns;
}
parameters {
    real<lower=0> mean_returns_standard_deviation;
    vector[stock_count] mean_returns;

    real<lower=0> volatilities_standard_deviation;
    vector<lower=0>[stock_count] volatilities;
}
model {
    mean_returns_standard_deviation ~ normal(0, 0.2 / 100.0);
    mean_returns ~ normal(0, mean_returns_standard_deviation);

    volatilities_standard_deviation ~ normal(0, 10.0 / 100.0);
    volatilities ~ normal(0, volatilities_standard_deviation);

    for (stock in 1:stock_count)
        returns[stock] ~ normal(mean_returns[stock], volatilities[stock]);
}
