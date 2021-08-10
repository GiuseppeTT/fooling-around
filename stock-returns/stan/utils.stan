functions {
    real homo_corr_normal_lpdf(matrix y, real mu, real sigma, real rho) {
        real lpdf = 0;
        real partial_lpdf = 0;
        real aux = 0;

        int n = rows(y);
        int p = cols(y);
        matrix[n, p] std_y;

        std_y = (y - mu) / sigma;

        lpdf += n * p * 2 * log(sigma);
        lpdf += n * log(1 + (p - 1) * rho);
        lpdf += n * (p - 1) * log(1 - rho);

        partial_lpdf = 0;
        for (i in 1:n)
            for (j in 1:p)
                partial_lpdf += square(std_y[i, j]);
        lpdf += partial_lpdf / (1 - rho);

        partial_lpdf = 0;
        aux = 0;
        for (i in 1:n) {
            aux = 0;
            for (j in 1:p)
                aux += std_y[i, j];

            aux = square(aux);
            partial_lpdf += aux;
        }
        lpdf += - partial_lpdf * rho / (1 + (p - 1) * rho) / (1 - rho);

        lpdf = - lpdf / 2;

        return lpdf;
    }

    real vector_homo_corr_multi_normal_lpdf(vector y, vector mus, vector sigmas, real rho) {
        real lpdf = 0;

        int p = size(y);
        vector[p] std_y;

        std_y = (y - mus) ./ sigmas;

        lpdf += 2 * sum(log(sigmas));
        lpdf += log(1 + (p - 1) * rho);
        lpdf += (p - 1) * log(1 - rho);

        lpdf += dot_self(std_y) / (1 - rho);
        lpdf += - square(sum(std_y)) * rho / (1 + (p - 1) * rho) / (1 - rho);

        lpdf = - lpdf / 2;

        return lpdf;
    }

    real row_vector_homo_corr_multi_normal_lpdf(row_vector y, vector mus, vector sigmas, real rho) {
        return vector_homo_corr_multi_normal_lpdf(y' | mus, sigmas, rho);
    }

    real matrix_homo_corr_multi_normal_lpdf(matrix y, vector mus, vector sigmas, real rho) {
        real lpdf = 0;
        real partial_lpdf = 0;
        real aux = 0;

        int n = rows(y);
        int p = cols(y);
        matrix[n, p] std_y;

        for (i in 1:n)
            for (j in 1:p)
                std_y[i, j] = (y[i, j] - mus[j]) / sigmas[j];

        lpdf += n * 2 * sum(log(sigmas));
        lpdf += n * log(1 + (p - 1) * rho);
        lpdf += n * (p - 1) * log(1 - rho);

        partial_lpdf = 0;
        for (i in 1:n)
            for (j in 1:p)
                partial_lpdf += square(std_y[i, j]);
        lpdf += partial_lpdf / (1 - rho);

        partial_lpdf = 0;
        aux = 0;
        for (i in 1:n) {
            aux = 0;
            for (j in 1:p)
                aux += std_y[i, j];

            aux = square(aux);
            partial_lpdf += aux;
        }
        lpdf += - partial_lpdf * rho / (1 + (p - 1) * rho) / (1 - rho);

        lpdf = - lpdf / 2;

        return lpdf;
    }
}
