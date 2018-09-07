data {
    int<lower=2> Ngauss;
    int<lower=1> n;
    vector[n] x;
    vector[n] y;
    matrix[2,2] M[n];
}
transformed data{
    int p = 1; // number of covariates
    real pi_conc = 1.0;
    matrix[2,2] M_inv[n];
    for(i in 1:n)
      M_inv[i] = inverse(M[i]);
}
parameters {
    vector[n] xi;
    vector[n] eta;
    real alpha;
    real beta;
    real<lower=0> Sigma;
    simplex[Ngauss] pi;
    real mu[Ngauss];
    real<lower=0> Tau[Ngauss];
    real mu0;
    real<lower=0> U;
    real<lower=0> W;
}
model {
    target += (pi_conc - 1) * sum(log(pi));  
    target += -log(Sigma);
    for (i in 1:n) {
        real lps[Ngauss];
        for (k in 1:Ngauss) {
          lps[k] = log(pi[k]) + normal_lpdf(xi[i] | mu[k], sqrt(Tau[k]));
        }
        target += log_sum_exp(lps);
    }
    eta ~ normal(alpha+beta*x, sqrt(Sigma));
    mu ~ normal(mu0, sqrt(U));  
    Tau ~ gamma((Ngauss + p)/2.0,1/(2*W));
    U ~ gamma((Ngauss + p)/2.0 ,1/(2*W));
    for (i in 1:n) {
        vector[2] xy;
        vector[2] xieta;
        xy[1] = x[i];
        xy[2] = y[i];
        xieta[1] = xi[i];
        xieta[2] = eta[i];
        xy ~ multi_normal_prec(xieta, M_inv[i]);
     }
}
