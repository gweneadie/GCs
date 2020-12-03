import sys

from limepy import limepy, sample, spes
import numpy as np

# set number of models you wish to run
ngen = 50

# do you wish to randomize the dataset?
random_seed = True

# do you want to add anisotropy?
anisotropy = False

# set mass, radius, g, phi0, and anisotropy for model
m = 1.e5
r = 3.
g = 1.5
phi0 = 5.
if anisotropy:
    ra = 8.
else:
    ra = 1.e8

for i in range(0, ngen):

    # initialize seed
    if random_seed:
        seed = np.random.randint(0, 2**32)
    else:
        seed = None

    model = limepy(g=g, phi0=phi0, M=m, rh=r, ra=ra)
    data = sample(model, N=int(1e4), seed=seed)

    if anisotropy:
        filename = ('mockdata/regen/m%sr%sg%sphi%sa%s_%s.dat'
                    % (str(int(np.log10(m))), str(int(r)),
                       str(g), str(phi0), str(int(ra)), str(i)))
    else:
        filename = ('mockdata/regen/m%sr%sg%sphi%s_%s.dat'
                    % (str(int(np.log10(m))), str(int(r)),
                       str(g), str(phi0), str(i)))
    print(filename)
    np.savetxt(filename,
               np.column_stack([data.x, data.y, data.z,
                                data.vx, data.vy, data.vz]),
               fmt='%.8e')
