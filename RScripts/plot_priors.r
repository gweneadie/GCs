source('function_priors.r')

#### prior on M

xvals = seq(1e3, 1e7, length.out = 1e4)

log10Mpars = c(5.85, 0.6)

par(mar=c(5,5,3,2))
plot( xvals, y = normlog10M.prior(pars = xvals, ppars = log10Mpars), log="x", type = "l", lwd=2, cex.axis=2, cex.lab=2, xlab="M", ylab="density", main="Prior on M", cex.main=2)
grid()


#### prior on half-light radius
rvals = seq(0,30, length.out = 1e3)

rhpars = c(0, 30, 3.4, 0.2)

plot( rvals, y = truncnorm.prior(pars = rvals, ppars = rhpars), type="l", main=expression(Prior~on~r[h]), lwd=2, cex.axis=2, cex.lab=2, xlab=expression(r[h]), ylab="density", cex.main=2 )
grid()


