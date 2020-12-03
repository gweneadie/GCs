# log-likelihood
def loglike(theta):
    """
    Log-likelihood function of the input parameters. Will work with both
    the isotropic and anisotropic case.

    """

    # read input parameters
    if anisotropic:
        logM, rh, g, phi0, logra = theta
    else:
        logM, rh, g, phi0 = theta
        logra = 6 - 1e-5

    if np.any(theta < 0) or g >= 3.5:
        return -np.inf

    try:
        # try to generate model
        model = limepy(rh=rh, g=g, phi0=phi0, ra=10**logra, M=10**logM)

        # try to evaluate distribution function
        df = model.df(x, y, z, vx, vy, vz, 0)
    except:
        # if anything goes wrong, the model gets rejected
        return -np.inf
        pass

    # evaluate likelihood
    floor = 1e-300  # minimum floor for numerical stability
    lnls = np.log(df / 10**logM + floor)  # add floor
    lnl = np.sum(lnls)  # Poisson log-likelihood

    return lnl


# log-prior
def logprior(theta):
    """
    Log-prior function of the input parameters.

    """

    # read input parameters
    if anisotropic:
        logM, rh, g, phi0, logra = theta
    else:
        logM, rh, g, phi0 = theta
        logra = 6 - 1e-5

    # check boundaries
    if not ((3. < logM < 7.) & (0. < rh < 30.) &
            (1e-3 < g < 3.5) & (1.5 < phi0 < 14.) &
            (-1. < logra < 6.)):
        return -np.inf
    else:
        # g: uniform
        gprior = np.log(1. / (5.3 - 1e-3))

        # logM: uniform
        logMprior = np.log(1. / (7. - 3.))

        # phi0: uniform
        phi0prior = np.log(1. / (14 - 1.5))

        # rh: uniform
        rhprior = np.log(1. / (30. - 0.))

        # ra: uniform
        lograprior = np.log(1. / (6. - (-1.)))

        return gprior + logMprior + phi0prior + rhprior + lograprior


# prior transform (i.e. converts points from [0, 1] to prior distributions)
def prior_transform(u):
    """
    Prior transform.

    """

    # read input parameters
    logM, rh, g, phi0 = u[:4]

    # transform
    logM = (7. - 3.) * logM + 3  # convert from [0, 1] -> [3, 7]
    rh = (30. - 0.) * rh + 0.  # convert from [0, 1] -> [0, 30]
    g = (3.5 - 1e-3) * g + 1e-3  # convert from [0, 1] -> [1e-3, 3.5]
    phi0 = (14. - 1.5) * phi0 + 1.5  # convert from [0, 1] -> [1.5, 14]
    if anisotropic:
        logra = u[-1]
        logra = (6. + 1.) * logra - 1.  # convert from [0, 1] -> [-1, 6]
        return np.array([logM, rh, g, phi0, logra])
    else:
        return np.array([logM, rh, g, phi0])


# log-posterior
def logpost(theta):
    """
    Log-posterior function of the input parameters.

    """

    return loglike(theta) + logprior(theta)


# negative log-posterior
def neglogp(theta):
    """
    Negative of the log-posterior function of the input parameters.
    Used for optimization.

    """

    lnp = logpost(theta)
    print(theta, lnp)

    return -lnp


# Hessian
def hessian(t, logp, delta=1e-3):
    """
    Compute the Hessian expansion around `t` with corresponding log-posterior
    `logp` using finite-differencing with step-size `delta`.
    Second-order approximation (i.e. 4 function evaluations per element).

    """

    H = np.zeros((nparams, nparams))
    for i in range(nparams):
        for j in range(i, nparams):

            if j != i:
                # off-diagnoals
                t1, t2, t3, t4 = np.copy(t), np.copy(t), np.copy(t), np.copy(t)

                t1[i] += delta
                t1[j] += delta

                t2[i] += delta
                t2[j] -= delta

                t3[i] -= delta
                t3[j] += delta

                t4[i] -= delta
                t4[j] -= delta

                # compute finite-difference approxiation
                d2 = (((neglogp(t1) - neglogp(t2)) -
                       (neglogp(t3) - neglogp(t4))) /
                      (4. * delta**2))

                # assign values
                H[i, j] = d2
                H[j, i] = d2
            else:
                # diagonals
                t1, t2 = np.copy(t), np.copy(t)

                t1[i] += 2. * delta
                t2[i] -= 2. * delta

                # compute finite-difference approxiation
                d2 = ((neglogp(t1) - 2. * -logp + neglogp(t2)) /
                      (4. * delta**2))

                # assign values
                H[i, i] = d2

    return H
