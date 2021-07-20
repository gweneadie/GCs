import numpy as np
# save data

with open('m5r3g1.5phi3.0_IS_2.7.npy', 'rb') as f:
    theta_map = np.load(f)
    C = np.load(f)
    samples = np.load(f)
    logq = np.load(f)
    logp = np.load(f)
    # x = []
    # x.append(theta_map)
    # x.append(theta_cov)
    # x.append(theta_cov)
    # x.append(samples)
    # x.append(logq)
    # x.append(logp)

np.savetxt('samples.txt', samples)
np.savetxt('logq.txt', logq)
np.savetxt('logp.txt', logp)

