import numpy as np
from matplotlib import pyplot as plt
import dynesty
import corner

# check if variables were previously defined
try:  # if so, keep them the same
    anisotropic
    nlive
    dlogz
    min_eff
    fname
    logn
    fpath
    fout
    n
    ntot
    idxs
    x, y, z, vx, vy, vz
    nparams
except NameError:  # if not, define them for the first time
    print("Initializing parameters...")

    # do you wish to include anisotropic models?
    anisotropic = False

    # NS parameters
    nlive = 500  # number of "live points"
    dlogz = 0.01  # termination criterion
    min_eff = 20.  # minimum efficiency for first update

    # data to be loaded in
    fname = 'm5r3g1.5phi5.0'  # data file
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

    # define utility functions
    exec(open('PyScripts/utils.py').read())

# initialize Static Nested Sampling sampler
sampler = dynesty.NestedSampler(loglike, prior_transform, nparams,
                                nlive=nlive, first_update={'min_eff': min_eff})

# run nested sampling
sampler.run_nested(dlogz=dlogz)
results = sampler.results

# get samples
samples = results.samples
logwt = results.logwt
logz, logzerr = results.logz, results.logzerr
wts = np.exp(logwt - np.nanmax(logwt))

# save samples
if anisotropic:
    fsamps = fpath + fout + fname + '_NS_{}_a.npy'.format(logn)
else:
    fsamps = fpath + fout + fname + '_NS_{}.npy'.format(logn)
with open(fsamps, 'wb') as f:
    np.save(f, samples)
    np.save(f, logwt)
    np.save(f, logz)
    np.save(f, logzerr)

# define labels for cornerplots
if anisotropic:
    labels = [r'$\log M$', r'$r_h$', r'$g$', r'$\Phi_0$', r'$\log r_a$']
else:
    labels = [r'$\log M$', r'$r_h$', r'$g$', r'$\Phi_0$']

# save NS cornerplot
corner.corner(dynesty.utils.resample_equal(samples, wts),  # resampled points
              levels=[0.68, 0.95, 0.997],  # 1, 2, 3-sigma contours
              labels=labels,  # axis labels
              show_titles=True)
if anisotropic:
    plt.savefig(fpath + fout + fname + '_NS_{}_a.png'.format(logn))
else:
    plt.savefig(fpath + fout + fname + '_NS_{}.png'.format(logn))
plt.close()
