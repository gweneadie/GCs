import sys

from limepy import limepy, sample, spes
import numpy as np
from scipy.optimize import minimize, differential_evolution

# do you wish to include anisotropic models?
anisotropic = True

# scale factor to inflate the Normal proposal
inflate = 2.5  # inflate std dev by this factor

# number of samples to save
nsamps = 2500

# data to be loaded in
fpath = 'mockdata/m5r3g1.5phi3.0'  # data file
logn = 5  # log of number of stars to read in

# load data
fpath += '.dat'  # file suffix
n = int(10**logn)  # number of stars to read in
x, y, z, vx, vy, vz = np.loadtxt(fpath)[:n].T

# load optimized results
if anisotropic:
    fopt = fpath + '_optim_{}_a.npy'.format(logn)
else:
    fopt = fpath + '_optim_{}.npy'.format(logn)
with open(fopt, 'rb') as f:
    theta_map = np.load(f)
    theta_logp = np.load(f)
    theta_H = np.load(f)

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

# clean up Hessian
H = np.copy(theta_H)
try:
    # check if matrix is semi-positive definite
    np.linalg.cholesky(H)
    spd = True
except:
    spd = False
    pass
# if not, culprit is either we hit the edge or bad values
if not spd:
    # check 1: edge
    if not np.all(np.isfinite(H)):
        # shift each parameter by 2 * delta and repeat Hessian
        for i in range(len(theta_map)):
            for j in range(len(theta_map)):
                theta_temp = np.copy(theta_map)
                theta_map[i, j] += 2 * 1e-3
                H = hessian(theta_map, theta_logp)
                if np.all(np.isfinite(H)):
                    break
                theta_map[i, j] -= 4 * 1e-3
                H = hessian(theta_map, theta_logp)
                if np.all(np.isfinite(H)):
                    break
            if np.all(np.isfinite(H)):
                break
        try:
            # check if matrix is semi-positive definite
            np.linalg.cholesky(H)
            spd = True
        except:
            pass
if not spd:
    # check 2: diagonals
    H = np.copy(theta_H)
    for i in range(len(theta_map)):
        H[i, i] = np.abs(H[i, i])
    try:
        # check if matrix is semi-positive definite
        np.linalg.cholesky(H)
        spd = True
    except:
        pass
if not spd:
    # final solution: just get rid of final covariances (logra)
    width = 1. / 20.  # normalized width relative to bounds
    H2 = np.zeros_like(H)
    H2[:-1, :-1] = np.linalg.inv(H[:-1, :-1])
    H2[-1, -1] = ((6. - (-1.)) / 2. * width / inflate)**2
    H = np.linalg.inv(H2)
try:
    # check if matrix is semi-positive definite
    np.linalg.cholesky(H)
    spd = True
except:
    pass

# generate samples from normal proposal distribution
Cinv = H / inflate**2
C = np.linalg.inv(H)
samples = np.random.multivariate_normal(theta_map, C, size=nsamps)

# compute proposal log-probability
const = np.linalg.slogdet(2. * np.pi * H)[1]
logq = -0.5 * np.array([(np.dot(np.dot((s - theta_map), Cinv), s - theta_map)
                         + const)
                        for s in samples])

# compute posterior log-probability
logp = np.zeros(nsamps)
for i, s in enumerate(samples):
    if (i + 1) % 100 == 0:
        print(i+1)
    logp[i] = logpost(s)

# compute importance weight
logwt = logp - logq

# save samples
if anisotropic:
    fsamps = fpath + '_IS_{}_a.npy'.format(logn)
else:
    fsamps = fpath + '_IS_{}.npy'.format(logn)
with open(fsamps, 'wb') as f:
    np.save(f, theta_map)
    np.save(f, C)
    np.save(f, samples)
    np.save(f, logq)
    np.save(f, logp)
