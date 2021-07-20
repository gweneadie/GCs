import sys

from limepy import limepy, sample, spes
import numpy as np
import emcee
import corner
from matplotlib import pyplot as plt

# do you wish to include anisotropic models?
anisotropic = False

# MCMC parameters
chains = 100  # number of chains to run (this should be > N^2)
nburnin = 200  # number of burn-in iterations
nsample = 500  # number of iterations to save

# data to be loaded in
fname = 'm5r3g1.5phi3.0'  # data file
logn = 2.7  # log of number of stars to read in

# file paths
fpath = 'mockdata/'  # location of data to be read in
fout = 'fits/'  # location where fits will be stored

# load data
n = int(10**logn)  # number of stars to read in
ntot = len(np.loadtxt(fpath + fname + '.dat'))
np.random.seed(2021)  # fix random seed
idxs = np.random.choice(ntot, size=n)
x, y, z, vx, vy, vz = np.loadtxt(fpath + fname + '.dat')[idxs].T

nparams = 4 + anisotropic

# load importance sampling results
if anisotropic:
    finit = fpath + fout + fname + '_IS_{}_a.npy'.format(logn)
else:
    finit = fpath + fout + fname + '_IS_{}.npy'.format(logn)
with open(finit, 'rb') as f:
    theta_map = np.load(f)
    theta_C = np.load(f)
    theta_samps = np.load(f)
    theta_logq = np.load(f)
    theta_logp = np.load(f)

# define utility functions
exec(open('PyScripts/utils.py').read())

# compute importance weights
logwt = theta_logp - theta_logq  # log(importance weight)
wt = np.exp(logwt - np.nanmax(logwt))  # importance weight
wt[~np.isfinite(wt)] = 0.  # deal with ill-defined weights
wt /= wt.sum()  # normalize to sum to 1

# get initial chain positions from the set of IS samples
try:
    # sample chains without replacement (ideal)
    idxs = np.random.choice(len(theta_samps), size=chains, p=wt, replace=False)
except:
    # sample chains with replace (should be okay)
    idxs = np.random.choice(len(theta_samps), size=chains, replace=True)
theta_init = theta_samps[idxs]

# initialize Differential Evolution MCMC (DEMCMC) sampler
sampler = emcee.EnsembleSampler(chains, nparams, logpost,
                                moves=emcee.moves.DEMove())

# run MCMC (burn-in)
print('Burning in...')
sampler.run_mcmc(theta_init, nburnin, progress=True)

# compute rough estimate of auto-correlation time
tau = sampler.get_autocorr_time(quiet=True)
print('Initial auto-correlation time estimates:', tau)

# run MCMC (sampling) starting from last position
sampler.run_mcmc(None, nsample, progress=True)
tau = sampler.get_autocorr_time(discard=nburnin, quiet=True)
print('Final auto-correlation time estimates:', tau)

# get samples
samples = sampler.get_chain(discard=nburnin)
logp = sampler.get_log_prob(discard=nburnin)

# compute IS proposal log-probability
const = np.linalg.slogdet(2. * np.pi * theta_C)[1]
Cinv = np.linalg.inv(theta_C)
logq = -0.5 * np.array([(np.dot(np.dot((s - theta_map), Cinv), s - theta_map)
                         + const)
                        for s in samples.reshape(-1, nparams)])
logq = logq.reshape(nsample, chains)

# save samples
if anisotropic:
    fsamps = fpath + fout + fname + '_MCMC_{}_a.npy'.format(logn)
else:
    fsamps = fpath + fout + fname + '_MCMC_{}.npy'.format(logn)
with open(fsamps, 'wb') as f:
    np.save(f, theta_map)
    np.save(f, theta_C)
    np.save(f, samples)
    np.save(f, logq)
    np.save(f, logp)

# define labels for cornerplots
if anisotropic:
    labels = [r'$\log M$', r'$r_h$', r'$g$', r'$\Phi_0$', r'$\log r_a$']
else:
    labels = [r'$\log M$', r'$r_h$', r'$g$', r'$\Phi_0$']

# save MCMC cornerplot
corner.corner(samples.reshape(-1, nparams),  # generated samples
              levels=[0.68, 0.95, 0.997],  # 1, 2, 3-sigma contours
              labels=labels,  # axis labels
              show_titles=True)
if anisotropic:
    plt.savefig(fpath + fout + fname + '_MCMC_{}_a.png'.format(logn))
else:
    plt.savefig(fpath + fout + fname + '_MCMC_{}.png'.format(logn))
plt.close()
