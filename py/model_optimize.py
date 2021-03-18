import sys

from limepy import limepy, sample, spes
import numpy as np
from scipy.optimize import minimize, differential_evolution

# do you wish to include anisotropic models?
anisotropic = True

# data to be loaded in
fpath = 'mockdata/m5r3g1.5phi3.0'  # data file
logn = 5 # log of number of stars to read in

# load data
fpath += '.dat'  # file suffix
n = int(10**logn)  # number of stars to read in
x, y, z, vx, vy, vz = np.loadtxt(fpath)[:n].T

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
        model = limepy(rh=rh, g=g, phi0=phi0, ra=10**logra, M=1e5)

        # try to evaluate distribution function
        df = model.df(x, y, z, vx, vy, vz, 0)
    except:
        # if anything goes wrong, the model gets rejected
        return -np.inf
        pass

    # evaluate likelihood
    floor = 1e-300  # minimum floor for numerical stability
    lnls = np.log(df * 10**(logM - 5) + floor)  # rescale and add floor
    lnl = np.sum(lnls) - 10**logM  # Poisson log-likelihood

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

        # logM: normal
        logMprior = -0.5 * ((logM - 5.85)**2 / 0.6**2 +
                            np.log(2. * np.pi * 0.6**2))

        # phi0: uniform
        phi0prior = np.log(1. / (14 - 1.5))

        # rh: normal
        rhprior = -0.5 * ((rh - 3.4)**2 / 0.2**2 +
                          np.log(2. * np.pi * 0.2**2))

        # ra: uniform
        lograprior = np.log(1. / (6. - (-1.)))

        return gprior + logMprior + phi0prior + rhprior + lograprior

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

# optimization
if anisotropic:
    theta0 = np.array([5.85, 3.4, 1.5, 5.0, 0.5])
    bounds = [(3, 7), (0, 30), (1e-3, 3.5), (1.5, 14.), (-1., 6.)]
else:
    theta0 = np.array([5.85, 3.4, 1.5, 5.0])
    bounds = [(3, 7), (0, 30), (1e-3, 3.5), (1.5, 14.)]
nparams = 4 + anisotropic
res = differential_evolution(neglogp, bounds, popsize=50)

# compute Hessian
t, logp = np.copy(res['x']), -res['fun']
H = hessian(t, logp)
print(t, H, logp)

# write out results
if anisotropic:
    fout = fpath + '_optim_{}_a.npy'.format(logn)
else:
    fout = fpath + '_optim_{}.npy'.format(logn)
with open(fout, 'wb') as f:
    np.save(f, t)
    np.save(f, logp)
    np.save(f, H)


# save data
# with open('m5r3g1.5phi3.0a0.8.dat_optim_4.npy', 'wb') as f:
#    np.save(f, np.array([1, 2]))
#    np.save(f, np.array([1, 3]))
# load data
# with open('m5r3g1.5phi3.0a0.8.dat_optim_4_a.npy', 'rb') as f:
#    a = np.load(f)
#    b = np.load(f)
#    c = np.load(f)
# print(a, b, c)
