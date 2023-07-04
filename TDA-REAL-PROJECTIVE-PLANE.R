## Library
library(TDA)

## RipsDiagram: computes persistent diagram of VR filtration
RD <- function(X, md, ms){
  X_rd <- ripsDiag(
    X = X, maxdimension = md, maxscale = ms,
    library = "Dionysus", 
    #location = TRUE, 
    printProgress = TRUE)
}
############################################################
############################################################




############################################################
############################################################
### n sample points on the unit sphere in R^3
n <- 100 # choose n
## vectors of uniformly distributed n numbers from min=0 to max
theta <- runif(n, min=0, max=2); phi <- runif(n, min=0, max=1)
# n points on the unit sphere
X <- matrix(nrow=n, ncol=4)
for (k in 1:n){
  X[k,1] = sin( pi*phi[k] )* cos( pi*theta[k])*sin( pi*phi[k] )* sin( pi*theta[k])
  X[k,2] = sin( pi*phi[k] )* cos( pi*theta[k])*cos( pi*phi[k] )
  X[k,3] = (sin( pi*phi[k] )* sin( pi*theta[k]))**2 - (cos( pi*phi[k] ))**2
  X[k,4] = 2 * sin( pi*phi[k] )* sin( pi*theta[k]) * cos( pi*phi[k] )
}
rm(n); rm(k) # delete objects n and k
#################################################






###################################################
## Rips Filtration and Persistent diagram
#  with maxdimension = md and maxscale = ms 
md <- 2
ms <- 1.7
# Rips Filtration 
#X_rf <- RF(X, md, ms)
# Persistent diagram
X_rd <- RD(X, md, ms)
#######################################################





#############################################
## Plot barcode and diagram
par(cex=0.6, mai=c(0.1, 0, 0.5, 0.2)) # margins
par(fig=c(0.15, 0.51, 0.3, 0.9)) # margin for diagram
plot(X_rd[["diagram"]], 
     #main = "Persistent Barcode" , barcode=TRUE,
     main = "Persistent Diagram", 
     panel.last = grid() )
par(fig=c(0.56, 0.93, 0.3, 0.9), new=TRUE) #margin for barcode
plot(X_rd[["diagram"]], 
     main = "Persistent Barcode" , barcode=TRUE,
     #main = "Persistent Diagram", 
     panel.last = grid() )
