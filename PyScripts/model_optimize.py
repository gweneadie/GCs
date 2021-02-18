import sys

from limepy import limepy, sample, spes
import numpy as np
from scipy.optimize import minimize, differential_evolution
import corner

# do you wish to include anisotropic models?
anisotropic = True

# do you want to use slower but more robust optimization?
diff_evol = True

# data to be loaded in
fname = 'm5r3g1.5phi3.0a0.8'  # data file
logn = 2.7  # log of number of stars to read in

# file paths
fpath = 'mockdata/'  # location of data to be read in
fout = 'fits/'  # location where fits will be stored

# load data
n = int(10**logn)  # number of stars to read in
x, y, z, vx, vy, vz = np.loadtxt(fpath + fname + '.dat')[:n].T
nparams = 4 + anisotropic

# define utility functions
exec(open('utils.py').read())

# optimization
if anisotropic:
    theta0 = np.array([np.log10(n), 3.4, 1.6, 5.1, 0.5])
    bounds = [(3, 7), (0, 30), (1e-3, 3.5), (1.5, 14.), (-1., 6.)]
else:
    theta0 = np.array([np.log10(n), 3.4, 1.6, 5.1])
    bounds = [(3, 7), (0, 30), (1e-3, 3.5), (1.5, 14.)]
if diff_evol:
    # use differential evolution
    res = differential_evolution(neglogp, bounds, popsize=50)
else:
    # use nelder-mead
    res = minimize(neglogp, theta0, method='nelder-mead')

# compute Hessian
t, logp = np.copy(res['x']), -res['fun']
theta_H = hessian(t, logp)

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
                theta_map[i] += 2 * 1e-3
                theta_map[j] += 2 * 1e-3
                H = hessian(theta_map, theta_logp)
                if np.all(np.isfinite(H)):
                    break
                theta_map[i] -= 4 * 1e-3
                theta_map[j] -= 4 * 1e-3
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

# regularize dimensions so we don't overshoot bounds like crazy
C = np.linalg.inv(H)
for i in range(nparams):
    stddev = np.sqrt(C[i, i])  # marginal width of Gaussian
    if stddev > 2. * (bounds[i][1] - bounds[i][0]):
        # compute rescaling factor
        ratio = 2. * (bounds[i][1] - bounds[i][0]) / stddev
        # rescale covariance
        C[i, :] *= ratio
        C[:, i] *= ratio
H = np.linalg.inv(C)

# print final Hessian
print(t, H, logp)

# write out results
if anisotropic:
    fout = fpath + fout + fname + '_optim_{}_a.npy'.format(logn)
else:
    fout = fpath + fout + fname + '_optim_{}.npy'.format(logn)
with open(fout, 'wb') as f:
    np.save(f, t)
    np.save(f, logp)
    np.save(f, H)
