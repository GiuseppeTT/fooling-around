#include utils.stan

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
    real<lower=0.0, upper=1.0> std_global_correlation;
}
transformed parameters {
    // https://stats.stackexchange.com/questions/72790/bound-for-the-correlation-of-three-random-variables
    real<lower=- 1.0 / (stock_count - 1.0), upper=1.0> global_correlation;

    global_correlation = (1.0 + 1.0 / (stock_count - 1.0)) * std_global_correlation - 1.0 / (stock_count - 1.0);
}
model {
    std_mean_return ~ normal(0.0, 0.2);
    std_volatility ~ normal(0.0, 10.0);
    std_global_correlation ~ beta(1.2, 1.2);

    std_returns ~ homo_corr_normal(std_mean_return, std_volatility, global_correlation);
}
generated quantities {
    real mean_return;
    real<lower=0> volatility;

    // Recover unescaled parameters.
    mean_return = std_mean_return / 100.0;
    volatility = std_volatility / 100.0;
}
