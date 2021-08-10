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
    real std_mean_returns_location;
    real<lower=0> std_mean_returns_scale;
    vector[stock_count] std_mean_returns;

    real<lower=0> std_volatilities_scale;
    vector<lower=0>[stock_count] std_volatilities;

    real<lower=0.0, upper=1.0> std_global_correlation;
}
transformed parameters {
    // https://stats.stackexchange.com/questions/72790/bound-for-the-correlation-of-three-random-variables
    real<lower=- 1.0 / (stock_count - 1.0), upper=1.0> global_correlation;

    global_correlation = (1.0 + 1.0 / (stock_count - 1.0)) * std_global_correlation - 1.0 / (stock_count - 1.0);
}
model {
    std_mean_returns_location ~ normal(0.0, 0.2);
    std_mean_returns_scale ~ normal(0.0, 0.2);
    std_mean_returns ~ normal(std_mean_returns_location, std_mean_returns_scale);

    std_volatilities_scale ~ normal(0.0, 10.0);
    std_volatilities ~ normal(0.0, std_volatilities_scale);

    std_global_correlation ~ beta(1.2, 1.2);

    std_returns ~ matrix_homo_corr_multi_normal(std_mean_returns, std_volatilities, global_correlation);
}
generated quantities {
    real mean_returns_location;
    real<lower=0> mean_returns_scale;
    vector[stock_count] mean_returns;

    real<lower=0> volatilities_scale;
    vector<lower=0>[stock_count] volatilities;

    // Recover unescaled parameters.
    mean_returns_location = std_mean_returns_location / 100.0;
    mean_returns_scale = std_mean_returns_scale / 100.0;
    mean_returns = std_mean_returns / 100.0;

    volatilities_scale = std_volatilities_scale / 100.0;
    volatilities = std_volatilities / 100.0;
}
