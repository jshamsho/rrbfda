#ifndef MODSTRING_H1
#define MODSTRING_H1

#include <RcppArmadillo.h>
#include "data.h"
class Data;

arma::uvec arma_mod(arma::uvec, arma::uword);
arma::vec bayesreg(arma::vec const &b, arma::mat const &Q);
arma::vec bayesreg_orth(arma::vec const &b,
                        arma::mat const &Q,
                        arma::mat const &lin_constr);
arma::vec dmvnrm_arma_fast(arma::mat const &x,  
                           arma::rowvec const &mean,  
                           arma::mat const &sigma, 
                           bool const logd);
double get_delta_eta_density(arma::mat& delta_eta1, arma::mat& delta_eta2,
                             arma::mat& eta, arma::mat& beta, arma::mat& xi_eta,
                             arma::mat& design);
double get_delta_eta1_density(arma::mat& delta_eta1, arma::mat& delta_eta2,
                              arma::mat& eta, arma::mat& beta, arma::mat& xi_eta,
                              arma::mat& design, arma::uword r, arma::uword c);
double get_delta_eta2_density(arma::mat& delta_eta1, arma::mat& delta_eta2,
                              arma::mat& eta, arma::mat& beta, arma::mat& xi_eta,
                              arma::mat& design, arma::uword c, arma::uword l);
double compute_delta_eta_density_c(arma::mat& delta_eta1, arma::mat& delta_eta2,
                                   arma::mat& eta, arma::mat& beta, arma::mat& xi_eta,
                                   arma::mat& design, arma::uword c, 
                                   double a1, double a2, double a3, double a4);
void compute_sigmasqeta_weak(arma::mat& delta_eta1,
                        arma::mat& delta_eta2,
                        arma::mat& sigmasqeta);
void compute_sigmasqeta_partial(arma::mat& delta_eta, arma::mat& sigmasqeta);
void compute_sigmasqetai(arma::mat& sigmasqeta,
                         arma::mat& xi_eta,
                         arma::mat& sigmasqetai);
arma::vec identify_delta1(arma::vec&);
arma::rowvec identify_delta2(arma::rowvec&);
double gam_trunc_left(double a, double b,  double cut);

#endif