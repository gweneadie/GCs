
# transformation function for model parameters
# for transforming parameters back to regular space
transform.func = function(x){
  c( exp(x[1:4]) )
}


# parametrization for sampling
inv.transform = function(x){
  c( log(x[1:4]) )
}

# inverse transform chains
transform.chains = function(x){
 exp(x[, 1:4])
}
