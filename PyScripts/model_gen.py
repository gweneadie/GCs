import sys
sys.path.append('/home/Gwenny/Documents/Work/Research/GCs/limepy/')

from limepy import limepy, sample
import numpy as np

#Do you wish to randomize the dataset?
random_seed=True 

#Specfify values for mass, rh, h, and phi you wish to generate models for
mparam=[1.e4,1.e5,1.e6]
rparam=[1.,3.,9.]
gparam=[0.5,1.5,2.5]
phi0param=[3.0,5.0,7.0]

for m in mparam:
    for r in rparam:
        for g in gparam:
            for phi0 in phi0param:
                model=limepy(g=g,phi0=phi0,M=m,rh=r)
                
                if random_seed:
                    data=sample(model,N=int(m),seed=np.random.randint(0,1000))
                else:
                    data=sample(model,N=int(m))
                filename='../mockdata/paper1data/m%sr%sg%sphi%s.dat' % (str(int(np.log10(m))),str(int(r)),str(g),str(phi0))
                print(filename)
                np.savetxt(filename,np.column_stack([data.x,data.y,data.z,data.vx,data.vy,data.vz]))
