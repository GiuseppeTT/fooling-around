data {
    int<lower=0> time_count;
    int<lower=0> stock_count;
    matrix[time_count, stock_count] returns;
}
parameters {
    real<lower=0> mean_returns_standard_deviation;
    vector[stock_count] mean_returns;

    real<lower=0> volatilities_standard_deviation;
    vector<lower=0>[stock_count] volatilities;

    matrix[stock_count, stock_count] correlations;
}
transformed parameters {
    matrix[asset_count, asset_count] covariances = quad_form_diag(correlations, volatilities);
}
model {
    mean_returns_standard_deviation ~ normal(0, 0.2 / 100.0);
    mean_returns ~ normal(0, mean_returns_standard_deviation);

    volatilities_standard_deviation ~ normal(0, 10.0 / 100.0);
    volatilities ~ normal(0, volatilities_standard_deviation);

    correlations ~ lkj_corr(1);

    for (time in 1:time_count)
        returns[time] ~ multi_normal(mean_returns, covariances);
}
