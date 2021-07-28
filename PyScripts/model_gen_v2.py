from limepy import limepy, sample
import numpy as np

# do you wish to randomize the dataset?
random_seed = True

# do you wish to include anisotropic models?
anisotropic = False

# specfify values for mass, rh, h, and phi you wish to generate models for
mparam = [1.e4, 1.e5, 1.e6]
rparam = [1., 3., 9.]
gparam = [0.5, 1.5, 2.5]
phi0param = [3.0, 5.0, 7.0]
aparam = [0.8, 0.5, 0.2]

# loop through parameter grid
for m in mparam:
    for r in rparam:
        for g in gparam:
            for phi0 in phi0param:

                # initialize seed
                if random_seed:
                    seed = np.random.randint(0, 2**32)
                else:
                    seed = None

                # generate data
                if anisotropic:
                    # loop over anisotropic models
                    for beta in aparam:
                        model = limepy(g=g, phi0=phi0, M=m, rh=r)
                        ra = model.rh
                        while True:
                            model = limepy(g=g, phi0=phi0, M=m, rh=r, ra=ra)
                            err = model.beta.max() - beta
                            ra *= 1. + (model.beta.max() - beta)
                            if abs(err) < 1e-5:
                                break
                        data = sample(model, N=int(1e4), seed=seed)
                        filename = ('mockdata/m%sr%sg%sphi%sa%s.dat'
                                    % (str(int(np.log10(m))), str(int(r)),
                                       str(g), str(phi0), str(beta)))
                        print(filename, round(ra, 2))
                        np.savetxt(filename,
                                   np.column_stack([data.x, data.y, data.z,
                                                    data.vx, data.vy,
                                                    data.vz]),
                                   fmt='%.8e')
                else:
                    # use isotropic model
                    model = limepy(g=g, phi0=phi0, M=m, rh=r)
                    data = sample(model, N=int(1e4), seed=seed)
                    filename = ('mockdata/m%sr%sg%sphi%s.dat'
                                % (str(int(np.log10(m))), str(int(r)),
                                   str(g), str(phi0)))
                    print(filename)
                    np.savetxt(filename,
                               np.column_stack([data.x, data.y, data.z,
                                                data.vx, data.vy, data.vz]),
                               fmt='%.8e')
