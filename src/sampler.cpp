#include "sampler.h"

// [[Rcpp::depends(RcppArmadillo)]]
Rcpp::List Sampler::write_data() {
  return(dat.write_data());
}

Rcpp::List Sampler::write_control() {
  return(Rcpp::List::create(
      Rcpp::Named("iterations", dat.iter),
      Rcpp::Named("thin", dat.thin),
      Rcpp::Named("burnin", dat.burnin)
  ));
}

SamplerPartial::SamplerPartial(Data& dat_, Rcpp::Nullable<Rcpp::List> init_) {
  dat = dat_;
  pars = ParametersPartial(dat, init_);
  transf = TransformationsPartial(dat, pars);
}

SamplerWeak::SamplerWeak(Data& dat_, Rcpp::Nullable<Rcpp::List> init_) {
  dat = dat_;
  pars = ParametersWeak(dat, init_);
  transf = TransformationsWeak(dat, pars);
}
void SamplerPartial::sample() {
  Progress progress_bar(dat.iter, true);
  for (arma::uword i = 0; i < dat.iter; i++) {
    for (arma::uword j = 0; j < dat.thin; j++) {
      if (Progress::check_abort()) {
        Rcpp::Rcout << "MCMC terminated by user\n";
        goto stop;
      }
      transf.complete_response(dat, pars);
      pars.update_lambda(dat, transf);
      pars.update_zeta(dat, transf);
      pars.update_phi(dat, transf);
      pars.update_eta(dat, transf);
      pars.update_xi_eta(dat, transf);
      pars.update_delta_eta(dat, transf);
      pars.update_beta(dat, transf);
      pars.update_delta_beta(dat, transf);
      pars.update_omega(dat, transf);
      pars.update_nu(dat, transf);
      pars.update_a123(dat);
    }
    progress_bar.increment();
    write_samples();
  }
  stop:
    NULL;
}

void SamplerPartial::write_samples() {
  pars.lambda_container.slice(current_iter) = pars.lambda;
  pars.beta_container.slice(current_iter) = pars.beta;
  pars.delta_beta_container.slice(current_iter) = pars.delta_beta;
  pars.delta_eta_container.slice(current_iter) = pars.delta_eta;
  pars.omega_container.col(current_iter) = pars.omega;
  pars.xi_eta_container.slice(current_iter) = pars.xi_eta;
  pars.zeta_container.col(current_iter) = pars.zeta;
  pars.eta_container.slice(current_iter) = pars.eta;
  pars.phi_container(current_iter) = pars.phi;
  pars.sigmasqetai_container.slice(current_iter) = pars.sigmasqetai;
  pars.delta_eta_container.slice(current_iter) = pars.delta_eta;
  pars.nu_container(current_iter) = pars.nu;
  pars.a1_container(current_iter) = pars.a1;
  pars.a2_container(current_iter) = pars.a2;
  pars.a3_container(current_iter) = pars.a3;
  current_iter++;
}

Rcpp::List SamplerPartial::get_samples() {
  return Rcpp::List::create(Rcpp::Named("lambda", pars.lambda_container),
                            Rcpp::Named("beta", pars.beta_container),
                            Rcpp::Named("delta_beta", pars.delta_beta_container),
                            Rcpp::Named("delta_eta", pars.delta_eta_container),
                            Rcpp::Named("eta", pars.eta_container),
                            Rcpp::Named("omega", pars.omega_container),
                            Rcpp::Named("xi_eta", pars.xi_eta_container),
                            Rcpp::Named("zeta", pars.zeta_container),
                            Rcpp::Named("phi", pars.phi_container),
                            Rcpp::Named("sigmasqetai", pars.sigmasqetai_container),
                            Rcpp::Named("delta_eta", pars.delta_eta_container),
                            Rcpp::Named("nu", pars.nu_container),
                            Rcpp::Named("a1", pars.a1_container),
                            Rcpp::Named("a2", pars.a2_container),
                            Rcpp::Named("a3", pars.a3_container),
                            Rcpp::Named("fit", transf.fit));
}

void SamplerWeak::sample() {
  Progress progress_bar(dat.iter, true);
  for (arma::uword i = 0; i < dat.iter; i++) {
    for (arma::uword j = 0; j < dat.thin; j++) {
      if (Progress::check_abort()) {
        Rcpp::Rcout << "MCMC terminated by user\n";
        goto stop;
      }
      transf.complete_response(dat, pars);
      pars.update_lambda(dat, transf);
      pars.update_zeta(dat, transf);
      pars.update_phi(dat, transf);
      pars.update_eta(dat, transf);
      pars.update_xi_eta(dat, transf);
      // pars.update_delta_eta(dat, transf);
      pars.update_beta(dat, transf);
      pars.update_delta_beta(dat, transf);
      pars.update_omega(dat, transf);
      pars.update_nu(dat, transf);
      // pars.update_a12(dat);
    }
    progress_bar.increment();
    write_samples();
  }
  stop:
    NULL;
}

void SamplerWeak::write_samples() {
  pars.lambda_container.slice(current_iter) = pars.lambda;
  pars.beta_container.slice(current_iter) = pars.beta;
  pars.delta_beta_container.slice(current_iter) = pars.delta_beta;
  pars.delta_eta11(current_iter) = pars.delta_eta11;
  pars.delta_eta1.col(current_iter) = pars.delta_eta1;
  pars.delta_eta2.col(current_iter) = pars.delta_eta2;
  pars.omega_container.col(current_iter) = pars.omega;
  pars.xi_eta_container.slice(current_iter) = pars.xi_eta;
  pars.zeta_container.col(current_iter) = pars.zeta;
  pars.eta_container.slice(current_iter) = pars.eta;
  pars.phi_container.slice(current_iter) = pars.phi;
  pars.sigmasqetai_container.slice(current_iter) = pars.sigmasqetai;
  pars.delta_eta_container.slice(current_iter) = pars.delta_eta;
  pars.nu_container(current_iter) = pars.nu;
  pars.a1_container(current_iter) = pars.a1;
  pars.a2_container(current_iter) = pars.a2;
  current_iter++;
}

Rcpp::List SamplerWeak::get_samples() {
  return Rcpp::List::create(Rcpp::Named("lambda", pars.lambda_container),
                            Rcpp::Named("beta", pars.beta_container),
                            Rcpp::Named("delta_beta", pars.delta_beta_container),
                            Rcpp::Named("delta_eta11", pars.delta_eta11_container),
                            Rcpp::Named("delta_eta1", pars.delta_eta1_container),
                            Rcpp::Named("delta_eta2", pars.delta_eta2_container),
                            Rcpp::Named("eta", pars.eta_container),
                            Rcpp::Named("omega", pars.omega_container),
                            Rcpp::Named("xi_eta", pars.xi_eta_container),
                            Rcpp::Named("zeta", pars.zeta_container),
                            Rcpp::Named("phi", pars.phi_container),
                            Rcpp::Named("sigmasqetai", pars.sigmasqetai_container),
                            Rcpp::Named("delta_eta", pars.delta_eta_container),
                            Rcpp::Named("nu", pars.nu_container),
                            Rcpp::Named("a1", pars.a1_container),
                            Rcpp::Named("a2", pars.a2_container),
                            Rcpp::Named("fit", transf.fit));
}