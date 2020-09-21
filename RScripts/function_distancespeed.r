# calculate the distance and speed from x,y,z and  vx, vy, vz

distancespeed <- function(dat){
  
  data.frame( r= with( dat, expr = sqrt(x^2 + y^2 + z^2) ), v = with( dat, expr = sqrt(vx^2 + vy^2 + vz^2) ) )
  
}