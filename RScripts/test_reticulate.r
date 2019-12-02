# testing out the reticulate package

library("reticulate")

use_python("/usr/bin/python3")


# import_from_path(module = "limepy", path = "/usr/local/lib/python3.7/site-packages/")

# py_run_string(code = "from limepy import limepy", path = "/usr/local/lib/python3.7/site-packages/")


limepy <- import("limepy")

lmodel = limepy$limepy(g=1.,phi0=5.,M=10000.,rh=3.)

lmodel$df(1.,1.)



# #Setup a King model with W0=5, M=10,000 Msun, and effective radius of 3 pc
# model=limepy(g=1.,phi0=5.,M=10000.,rh=3.)

# #Evaluate distribution function for r=1pc and v=1 km/s (can accept arrays though)
# eval=model.df(1.,1.)
# print(eval)