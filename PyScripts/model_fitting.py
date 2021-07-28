import numpy as np

# START OF INPUT ARGUMENTS #

# do we want to rerun past results (i.e. overwrite files)?
overwrite = True

# do you wish to include anisotropic models?
anisotropic = True

# data to be loaded in
fname = 'm5r3g1.5phi5.0'  # data file
logn = 2.7  # log of number of stars to read in

# file paths
fpath = 'mockdata/'  # location of data to be read in
fout = 'fits/'  # location where fits will be stored

# OPTIMIZATION
# do you want to use slower but more robust optimization?
diff_evol = True

# scale factor to inflate the Normal proposal
inflate = 2.0

# IMPORTANCE SAMPLING
# number of samples to save
nsamps = 5000

# MCMC
chains = 100  # number of chains to run (this should be > N^2)
nburnin = 200  # number of burn-in iterations
nsample = 500  # number of iterations to save

# NS
nlive = 500  # number of "live points"
dlogz = 0.01  # termination criterion
min_eff = 20.  # minimum efficiency for first update

# END OF INPUT ARGUMENTS #

# load data
n = int(10**logn)  # number of stars to read in
ntot = len(np.loadtxt(fpath + fname + '.dat'))
np.random.seed(2021)  # fix random seed
idxs = np.random.choice(ntot, size=n)
x, y, z, vx, vy, vz = np.loadtxt(fpath + fname + '.dat')[idxs].T

nparams = 4 + anisotropic

# define utility functions
exec(open('PyScripts/utils.py').read())

# run optimization
print("Optimization step...")
try:  # check if file exists
    if anisotropic:
        fopt = fpath + fout + fname + '_optim_{}_a.npy'.format(logn)
    else:
        fopt = fpath + fout + fname + '_optim_{}.npy'.format(logn)
    with open(fopt, 'rb') as f:
        theta_map = np.load(f)
        theta_logp = np.load(f)
        theta_H = np.load(f)
    if overwrite:
        exec(open('PyScripts/model_optimize.py').read())
except:
    exec(open('PyScripts/model_optimize.py').read())

# run IS
print("Importance Sampling...")
try:  # check if file exists
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
    if overwrite:
        exec(open('PyScripts/model_IS.py').read())
except:
    exec(open('PyScripts/model_IS.py').read())

# run MCMC
print("Markov Chain Monte Carlo (for Bridge Sampling)...")
try:  # check if file exists
    if anisotropic:
        fsamps = fpath + fout + fname + '_MCMC_{}_a.npy'.format(logn)
    else:
        fsamps = fpath + fout + fname + '_MCMC_{}.npy'.format(logn)
    with open(fsamps, 'rb') as f:
        theta_map = np.load(f)
        theta_C = np.load(f)
        samples = np.load(f)
        logq = np.load(f)
        logp = np.load(f)
        tau = np.load(f)
    if overwrite:
        exec(open('PyScripts/model_MCMC.py').read())
except:
    exec(open('PyScripts/model_MCMC.py').read())

# run NS
print("Nested Sampling...")
try:
    if anisotropic:
        fsamps = fpath + fout + fname + '_NS_{}_a.npy'.format(logn)
    else:
        fsamps = fpath + fout + fname + '_NS_{}.npy'.format(logn)
    with open(fsamps, 'rb') as f:
        samples = np.load(f)
        logwt = np.load(f)
        logz = np.load(f)
        logzerr = np.load(f)
    if overwrite:
        exec(open('PyScripts/model_NS.py').read())
except:
    exec(open('PyScripts/model_NS.py').read())
