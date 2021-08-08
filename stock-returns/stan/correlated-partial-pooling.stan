functions {
    real homo_corr_multi_normal_lpdf(row_vector y, vector mus, vector sigmas, real rho) {
        real lpdf = 0;
        int n = size(y);
        vector[n] std_y = (y' - mus) ./ sigmas;

        lpdf += 2 * sum(log(sigmas));
        lpdf += log(1 + (n - 1) * rho);
        lpdf += (n - 1) * log(1 - rho);

        lpdf += dot_self(std_y) / (1 - rho);
        lpdf += - square(sum(std_y)) * rho / (1 + (n - 1) * rho) / (1 - rho);

        lpdf = - lpdf / 2;

        return lpdf;
    }
}
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
    real<lower=- 1.0 / (stock_count - 1.0), upper=1.0> global_correlation;
}
model {
    std_mean_returns_scale ~ normal(0.0, 0.2);
    std_mean_returns ~ normal(0.0, std_mean_returns_scale);

    std_volatilities_scale ~ normal(0.0, 10.0);
    std_volatilities ~ normal(0.0, std_volatilities_scale);

    global_correlation ~ uniform(- 1.0 / (stock_count - 1.0), 1.0);

    for (time in 1:time_count)
        std_returns[time] ~ homo_corr_multi_normal(std_mean_returns, std_volatilities, global_correlation);
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
