# testing out the reticulate package

library("reticulate")

yoursystem <- Sys.info()["sysname"]

if(yoursystem=="Windows"){
  # if on my desktop, then use the virtual environment
  use_condaenv("/Users/Gwen/miniconda3/envs/r-reticulate-GCs/") 
  }else{ if(yoursystem=="Linux"){
      # if on my laptop, then use this version of Python
      use_python("/usr/bin/python3")
    }else{
    stop("It looks like you aren't using one of Gwen's computers. You'll need to set up your own virtual python environment with limepy installed in it, and then tell the R reticulate package where to find the environment. Good luck!")
    }
  }




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