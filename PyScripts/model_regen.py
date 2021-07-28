import sys
sys.path.append('/home/Gwenny/Documents/Work/Research/GCs/limepy/')

from limepy import limepy, sample
import numpy as np

#Set number of models you wish to run
ngen=50

#Do you wish to randomize the dataset?
random_seed=True 

#Set mass, radius, g, and phi0 for model
m=1.e5
r=1.
g=1.5
phi0=5.

for i in range(0,ngen):
    model=limepy(g=g,phi0=phi0,M=m,rh=r)
    if random_seed:
        data=sample(model,N=int(m),seed=np.random.randint(0,1000))
    else:
        data=sample(model,N=int(m))
            
    filename='../mockdata/paper1data/CompactGC/m%sr%sg%sphi%s_%s.dat' % (str(int(np.log10(m))),str(int(r)),str(g),str(phi0),str(i))
    print(filename)
    np.savetxt(filename,np.column_stack([data.x,data.y,data.z,data.vx,data.vy,data.vz]))
