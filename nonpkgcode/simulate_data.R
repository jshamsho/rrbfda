sim_weak <- function(nt, nsub, nreg, ldim = 4) {
  tt <- seq(from = 0, to = 1, length.out = nt)
  eta <- matrix(0, nsub * nreg, ldim)
  sqexp <- function(t, tp) {
    exp(-(t - tp)^2 / .2)
  }
  kern <- matrix(0, nrow = nt, ncol = nt)
  for (i in 1:nt) {
    for (j in 1:nt) {
      kern[i, j] <- 5 * sqexp(tt[i], tt[j])
    }
  }
  psi <- eigen(kern)$vectors
  # evals <- rev(pracma::logseq(1, nreg * ldim, nreg * ldim))
  for (l in 1:ldim) {
    for (i in 1:nsub) {
      for (j in 1:nreg) {
        # eta[(i - 1) * nreg + j, l] <- rnorm(1, sd = evals[(l - 1) * nreg + j])
        eta[(i - 1) * nreg + j, l] <- rnorm(1, sd = (ldim - l + 1) * 1 / j)
      }
    }
  }
  phi <- pracma::randortho(nreg)
  Y <- matrix(0, nsub * nt, ncol = nreg)
  for (i in 1:nsub) {
    for (l in 1:ldim) {
      for (j in 1:nreg) {
        Y[((i - 1) * nt + 1):((i) * nt), ] <- Y[((i - 1) * nt + 1):((i) * nt), ] + 
          outer(psi[,l], phi[,j], "*") * eta[(i - 1) * nreg + j, l]
      }
    }
    Y[((i - 1) * nt + 1):((i) * nt), ] <- Y[((i - 1) * nt + 1):((i) * nt), ] + 
      c(rnorm(nt * nreg, sd = .1))
  }
  est <- matrix(0, nt, nreg)
  for (l in 1:ldim) {
    for (j in 1:nreg) {
      est <- est + outer(psi[,l], phi[,j], "*") * eta[j, l]
    }
  }
  theta <- matrix(0, nrow = nsub, ncol = nreg * ldim)
  etalong <- reshape_nreg(eta, nsub, nreg)
  for (i in 1:nsub) {
    for (l in 1:ldim) {
      idx1 <- (l - 1) * nreg + 1
      idx2 <- l * nreg
      theta[i, idx1:idx2] <- phi %*% etalong[i, idx1:idx2]
    }
  }
  Sigma <- matrix(0, nreg * ldim, nreg * ldim)
  for (l in 1:ldim) {
    idx1 <- (l - 1) * nreg + 1
    idx2 <- l * nreg
    Sigma[idx1:idx2, idx1:idx2] <- phi %*% 
      diag(((ldim - l + 1) / (1:nreg))^2) %*%
      t(phi)
  }
  sim_data <- list(Y = Y, psi = psi, theta = theta, Sigma = Sigma, phi = phi,
                   eta = eta, est = est)
  return(sim_data)
}

sim_partial <- function(nt, nsub, nreg, ldim = 4) {
  tt <- seq(from = 0, to = 1, length.out = nt)
  eta <- matrix(0, nsub * nreg, ldim)
  
  sqexp <- function(t, tp) {
    exp(-(t - tp)^2 / .2)
  }
  kern <- matrix(0, nrow = nt, ncol = nt)
  for (i in 1:nt) {
    for (j in 1:nt) {
      kern[i, j] <- 5 * sqexp(tt[i], tt[j])
    }
  }
  psi <- eigen(kern)$vectors
  for (l in 1:ldim) {
    for (i in 1:nsub) {
      for (j in 1:nreg) {
        eta[(i - 1) * nreg + j, l] <- rnorm(1, sd = (ldim - l + 1) * 1 / j)
      }
    }
  }
  phi <- array(dim = c(nreg, nreg, ldim))
  for (l in 1:ldim) {
    phi[,,l] <- pracma::randortho(nreg)
  }
  Y <- matrix(0, nsub * nt, ncol = nreg)
  for (i in 1:nsub) {
    for (l in 1:ldim) {
      Y[((i - 1) * nt + 1):((i) * nt), ] <- Y[((i - 1) * nt + 1):((i) * nt), ] + 
        psi[,l] %*% t(eta[((i - 1) * nreg + 1):(i * nreg), l]) %*% t(phi[,,l])
    }
    Y[((i - 1) * nt + 1):((i) * nt), ] <- Y[((i - 1) * nt + 1):((i) * nt), ] + 
      c(rnorm(nt * nreg, sd = .1))
  }
  
  theta <- matrix(0, nrow = nsub, ncol = nreg * ldim)
  etalong <- reshape_nreg(eta, nsub, nreg)
  for (i in 1:nsub) {
    for (l in 1:ldim) {
      idx1 <- (l - 1) * nreg + 1
      idx2 <- l * nreg
      theta[i, idx1:idx2] <- phi[,,l] %*% etalong[i, idx1:idx2]
    }
  }
  Sigma <- matrix(0, nreg * ldim, nreg * ldim)
  for (l in 1:ldim) {
    idx1 <- (l - 1) * nreg + 1
    idx2 <- l * nreg
    Sigma[idx1:idx2, idx1:idx2] <- phi[,,l] %*% 
      diag(((ldim - l + 1) / (1:nreg))^2) %*%
      t(phi[,,l])
  }
  sim_data <- list(Y = Y, psi = psi, theta = theta, Sigma = Sigma)
  return(sim_data)
}

sim_partial_cs <- function(nt, nsub, nreg, ldim, rho1 = .6) {
  tt <- seq(from = 0, to = 1, length.out = nt)
  sqexp <- function(t, tp) {
    exp(-(t - tp)^2 / .2)
  }
  kern <- matrix(0, nrow = nt, ncol = nt)
  for (i in 1:nt) {
    for (j in 1:nt) {
      kern[i, j] <- 5 * sqexp(tt[i], tt[j])
    }
  }
  psi <- eigen(kern)$vectors
  
  Sigma <- matrix(0, nreg * ldim, nreg * ldim)
  for (i in 1:ldim) {
    idx1 <- (i - 1) * nreg + 1
    idx2 <- i * nreg
    Sigma[idx1:idx2, idx1:idx2] <-  (ldim - i + 1)^2 * (rho1 * rep(1, nreg) %*% 
                                                           t(rep(1, nreg)) + 
                                                           (1 - rho1) * diag(nreg))
  }
  theta <- MASS::mvrnorm(nsub, mu = rep(0, nrow(Sigma)), Sigma = Sigma)
  Y <- matrix(0, nsub * nt, ncol = nreg)
  for (i in 1:nsub) {
    for (l in 1:ldim) {
      idx1 <- (l - 1) * nreg + 1
      idx2 <- l * nreg
      Y[((i - 1) * nt + 1):((i) * nt), ] <- Y[((i - 1) * nt + 1):((i) * nt), ] + 
        psi[, l] %*% t(theta[i, idx1:idx2])
    }
    Y[((i - 1) * nt + 1):((i) * nt), ] <- Y[((i - 1) * nt + 1):((i) * nt), ] + c(rnorm(nt * nreg, sd = .1))
  }
  sim_data <- list(Y = Y, psi = psi, theta = theta, Sigma = Sigma)
}

sim_non_partial <- function(nt, nsub, nreg, ldim = 4, rho1 = .6, rho2 = .2) {
  tt <- seq(from = 0, to = 1, length.out = nt)
  sqexp <- function(t, tp) {
    exp(-(t - tp)^2 / .2)
  }
  kern <- matrix(0, nrow = nt, ncol = nt)
  for (i in 1:nt) {
    for (j in 1:nt) {
      kern[i, j] <- 5 * sqexp(tt[i], tt[j])
    }
  }
  psi <- eigen(kern)$vectors
  
  Sigma <- matrix(0, nreg * ldim, nreg * ldim)
  for (i in 1:ldim) {
    idx1 <- (i - 1) * nreg + 1
    idx2 <- i * nreg
    Sigma[idx1:idx2, idx1:idx2] <- (ldim - i + 1)^2 * (rho1 * rep(1, nreg) %*% 
                                                             t(rep(1, nreg)) + 
                                                             (1 - rho1) * diag(nreg))
  }
  matrows <- 1:(ldim * nreg)
  for (i in 1:(ldim - 1)) {
    matrows <- matrows[-(1:nreg)]
    matcols <- ((i - 1) * nreg + 1):(i * nreg)
    for (j in matrows) {
      for (jp in matcols) {
        Sigma[j, jp] <- rho2 * sqrt(Sigma[j, j]) * sqrt(Sigma[jp, jp])
        Sigma[jp, j] <- Sigma[j, jp]
      }
    }
  }
  
  theta <- MASS::mvrnorm(nsub, mu = rep(0, nrow(Sigma)), Sigma = Sigma)
  Y <- matrix(0, nsub * nt, ncol = nreg)
  for (i in 1:nsub) {
    for (l in 1:ldim) {
      idx1 <- (l - 1) * nreg + 1
      idx2 <- l * nreg
      Y[((i - 1) * nt + 1):((i) * nt), ] <- Y[((i - 1) * nt + 1):((i) * nt), ] + 
        psi[, l] %*% t(theta[i, idx1:idx2])
    }
    Y[((i - 1) * nt + 1):((i) * nt), ] <- Y[((i - 1) * nt + 1):((i) * nt), ] + c(rnorm(nt * nreg, sd = .1))
  }
  sim_data <- list(Y = Y, psi = psi, theta = theta, Sigma = Sigma)
}

