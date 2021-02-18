import numpy as np
# save data

with open('m5r3g1.5phi3.0a0.8_MCMC_2.7_a.npy', 'rb') as f:
    theta_map = np.load(f)
    theta_C = np.load(f)
    theta_samps = np.load(f)
    theta_logq = np.load(f)
    theta_logp = np.load(f)


np.savetxt('logq.txt', theta_logq)
np.savetxt('logp.txt', theta_logp)
#np.savetxt('samples.txt',theta_samps)

