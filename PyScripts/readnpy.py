import numpy as np

readdata= np.load('mockdata/fits/m5r3g1.5phi3.0_MCMC_2.7.npy')
print(readdata)

with open('mockdata/fits/m5r3g1.5phi3.0_MCMC_2.7.npy', 'rb') as f:
    theta_map = np.load(f)
    theta_C = np.load(f)
    theta_samps = np.load(f)
    theta_logq = np.load(f)
    theta_logp = np.load(f)

print(theta_samps)
s
