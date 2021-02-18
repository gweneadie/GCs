import sys

from limepy import limepy, sample, spes
import numpy as np
from scipy.optimize import minimize, differential_evolution
import corner
import dynesty
from matplotlib import pyplot as plt

# do you wish to include anisotropic models?
anisotropic = True

# scale factor to inflate the Normal proposal
inflate = 2.5  # inflate std dev by this factor

# number of samples to save
nsamps = 5000

# data to be loaded in
fname = 'm5r3g1.5phi5.0'  # data file
logn = 2.7  # log of number of stars to read in

# file paths
fpath = 'mockdata/'  # location of data to be read in
fout = 'fits/'  # location where fits will be stored

# load data
n = int(10**logn)  # number of stars to read in
x, y, z, vx, vy, vz = np.loadtxt(fpath + fname + '.dat')[:n].T
nparams = 4 + anisotropic

# load optimized results
if anisotropic:
    fopt = fpath + fout + fname + '_optim_{}_a.npy'.format(logn)
else:
    fopt = fpath + fout + fname + '_optim_{}.npy'.format(logn)
with open(fopt, 'rb') as f:
    theta_map = np.load(f)
    theta_logp = np.load(f)
    theta_H = np.load(f)

# define utility functions
exec(open('utils.py').read())

# generate precision/covariance matrix
Cinv = theta_H / inflate**2
C = np.linalg.inv(Cinv)

# generate samples from normal proposal distribution
samples = np.random.multivariate_normal(theta_map, C, size=nsamps)

# in some cases, the priors are significantly more restrictive
# regenerate the samples to match this truncated normal distribution
check = np.where(~np.isfinite(np.array([logprior(s) for s in samples])))[0]
while len(check) > 0:
    new_samps = np.random.multivariate_normal(theta_map, C, size=nsamps)
    new_check = np.where(np.isfinite(np.array([logprior(s)
                                               for s in new_samps])))[0]
    L = min(len(new_check), len(check))
    samples[check[:L]] = new_samps[new_check[:L]]
    check = check[L:]

# estimate scaling to account for difference in log-density
scale = -np.log(np.sum([np.isfinite(logprior(s))
                        for s in np.random.multivariate_normal(theta_map, C,
                                                               size=int(1e7))])
                / 1e7)

# compute proposal log-probability
const = np.linalg.slogdet(2. * np.pi * C)[1] + scale
logq = -0.5 * np.array([(np.dot(np.dot((s - theta_map), Cinv), s - theta_map)
                         + const)
                        for s in samples])

# compute posterior log-probability
logp = np.zeros(nsamps)
for i, s in enumerate(samples):
    if (i + 1) % 250 == 0:
        print(i + 1)
    logp[i] = logpost(s)

# compute importance weight
logwt = logp - logq
wts = np.exp(logwt - np.nanmax(logwt))

# save samples
if anisotropic:
    fsamps = fpath + fout + fname + '_IS_{}_a.npy'.format(logn)
else:
    fsamps = fpath + fout + fname + '_IS_{}.npy'.format(logn)
with open(fsamps, 'wb') as f:
    np.save(f, theta_map)
    np.save(f, C)
    np.save(f, samples)
    np.save(f, logq)
    np.save(f, logp)

# define labels for cornerplots
if anisotropic:
    labels = [r'$\log M$', r'$r_h$', r'$g$', r'$\Phi_0$', r'$\log r_a$']
else:
    labels = [r'$\log M$', r'$r_h$', r'$g$', r'$\Phi_0$']

# save proposal cornerplot (no weights)
corner.corner(samples,  # generated samples
              levels=[0.68, 0.95, 0.997],  # 1, 2, 3-sigma contours
              labels=labels,  # axis labels
              show_titles=True)
if anisotropic:
    plt.savefig(fpath + fout + fname + '_IS_nowt_{}_a.png'.format(logn))
else:
    plt.savefig(fpath + fout + fname + '_IS_nowt_{}.png'.format(logn))
plt.close()

# save posterior cornerplot (with weights)
corner.corner(dynesty.utils.resample_equal(samples, wts),  # resampled points
              levels=[0.68, 0.95, 0.997],  # 1, 2, 3-sigma contours
              labels=labels,  # axis labels
              show_titles=True)
if anisotropic:
    plt.savefig(fpath + fout + fname + '_IS_wt_{}_a.png'.format(logn))
else:
    plt.savefig(fpath + fout + fname + '_IS_wt_{}.png'.format(logn))
plt.close()
