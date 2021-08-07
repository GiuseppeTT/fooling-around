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

    // https://stats.stackexchange.com/questions/72790/bound-for-the-correlation-of-three-random-variables
    real<lower=- 1 / (stock_count - 1), upper=1> global_correlation;
}
transformed parameters {
    corr_matrix[stock_count] correlations;
    cov_matrix[stock_count] std_covariances;

    correlations = rep_matrix(global_correlation, stock_count, stock_count) + (1 - global_correlation) * diag_matrix(rep_vector(1, stock_count));
    std_covariances = quad_form_diag(correlations, std_volatilities);
}
model {
    std_mean_returns_scale ~ normal(0.0, 0.2);
    std_mean_returns ~ normal(0.0, std_mean_returns_scale);

    std_volatilities_scale ~ normal(0.0, 10.0);
    std_volatilities ~ normal(0.0, std_volatilities_scale);

    for (time in 1:time_count)
        std_returns[time, :] ~ multi_normal(std_mean_returns, std_covariances);
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
