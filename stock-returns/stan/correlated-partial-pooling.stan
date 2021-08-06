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
    real<lower=0> std_mean_returns_scale;
    vector[stock_count] std_mean_returns;

    real<lower=0> std_volatilities_scale;
    vector<lower=0>[stock_count] std_volatilities;

    cholesky_factor_corr[stock_count] correlations;
}
model {
    std_mean_returns_scale ~ normal(0.0, 0.2);
    std_mean_returns ~ normal(0.0, std_mean_returns_scale);

    std_volatilities_scale ~ normal(0.0, 10.0);
    std_volatilities ~ normal(0.0, std_volatilities_scale);

    correlations ~ lkj_corr_cholesky(1.0);

    for (time in 1:time_count)
        std_returns[time, :] ~ multi_normal_cholesky(std_mean_returns, diag_pre_multiply(std_volatilities, correlations));
}
generated quantities {
    real<lower=0> mean_returns_scale;
    vector[stock_count] mean_returns;

    real<lower=0> volatilities_scale;
    vector<lower=0>[stock_count] volatilities;

    // Recover unescaled parameters.
    mean_returns_scale = std_mean_returns_scale / 100.0;
    mean_returns = std_mean_returns / 100.0;

    volatilities_scale = std_volatilities_scale / 100.0;
    volatilities = std_volatilities / 100.0;
}
