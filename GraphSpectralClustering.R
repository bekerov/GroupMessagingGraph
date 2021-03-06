library('igraph');
#install.packages("expm", repos="http://R-Forge.R-project.org")
library('expm');
library('MASS');
#adjacency matrix given:
M <- matrix(c(0, 10, 0, 0, 0,
              10, 0, 8, 0, 0,
              0, 8, 0, 1, 0,
              0, 0, 1, 0, 3,
              0, 0, 0, 3, 0), nrow=5, ncol=5)
n <- dim(M)[1]
names <- 'noname'
Mraw <- M
rownames(Mraw) <- NULL
colnames(Mraw) <- NULL
Mraw
data.frame(names, Mraw)

Sym=M+t(M) #symmetric matrix for in+out replies
Sym
###invert replies to get some kind of 'distance'
#S <- 1/(1+Sym)
#S <- exp(-Sym*n^2/sum(Sym))
m <- (sum(Sym)-sum(diag(Sym)))/(n^2-n)
#S <- Sym/(Sym+m) #similarity function to [0,1]
S <- m/(m+Sym)
#s <- exp(-m/(m+Sym))
#S
#S <- Sym #remove -comment- this line in case of setting the inverse weights
D=diag(S)*diag(n) 
W <- S-D
W
D <- colSums(S)*diag(n)-D
D
L <- D-W
L
Lraw <- L
rownames(Lraw) <- NULL
colnames(Lraw) <- NULL
Lraw
L%*%matrix(1,n,1) #just a test, must be a vector of zeroes

#Normalized spectral clustering according to Ng, Jordan, and Weiss (2002):
Lsym = ginv(sqrt(D)) %*% L %*% ginv(sqrt(D)) #symmetric normalized laplacian
#Lrw = ginv(D) %*% L  #normalized laplacian for random walks
Lsym
rk <- n
L_dec=svd(Lsym,rk,rk)
data.frame(names, L_dec$u)

######
Lsym
L_dec$u %*% (L_dec$d[1:rk]*diag(rk)) %*% t(L_dec$v)
error <- matrix(0,1,n)
for (i in 1:n){
  L_dec=svd(Lsym,i,i)
  error[i] <- sum((Lsym - L_dec$u %*% (L_dec$d[1:i]*diag(i)) %*% t(L_dec$v))^2)
}
error
plot(1:n, error/sum((Lsym^2))) #decreasing sequence of errors by rank of svd
#error plot shows I must use every eigenvector but the last

#rk <- 12 #with 12 eigenvectors we get all the information
#automatize rk with a formula!!!!!
rk <- n-1 ##check this!!!
#rk <- 3
L_dec=svd(Lsym,rk,rk)
data.frame(names, L_dec$u)
#normalize rows of U to norm 1
#Unorm <- L_dec$u/(rowSums(L_dec$u^2)^(1/2))
#rowSums(Unorm^2)^(1/2) #test: must be a vector of ones
rownames(L_dec$u) <-names
L_dec$u
#plot(data.frame(Unorm))
#text(data.frame(Unorm),row.names(Unorm), pos=4, cex=0.6, col="red")
plot(data.frame(L_dec$u))
text(data.frame(L_dec$u),row.names(Unorm), pos=4, cex=0.6, col="red")
pair=c(1,2)
plot(data.frame(Unorm[,pair]))
text(data.frame(Unorm[,pair]),row.names(Unorm[,pair]), pos=4, cex=0.6, col="red")
pair=c(1,3)
plot(data.frame(Unorm[,pair]))
text(data.frame(Unorm[,pair]),row.names(Unorm[,pair]), pos=4, cex=0.6, col="red")
pair=c(2,3)
plot(data.frame(Unorm[,pair]))
text(data.frame(Unorm[,pair]),row.names(Unorm[,pair]), pos=4, cex=0.6, col="red")

#normalized Lsym
km.out=kmeans(L_dec$u,4,nstart=15)
km.out$cluster
pair=c(2,3)
plot(L_dec$u[,pair],col=km.out$cluster,cex=0.6,pch=1,lwd=3)
text(data.frame(L_dec$u[,pair]),row.names(L_dec$u[,pair]), pos=4, cex=0.6, col=km.out$cluster)

plot(data.frame(L_dec$u),col=km.out$cluster,cex=0.6,pch=1,lwd=3)
text(data.frame(L_dec$u),row.names(L_dec$u), pos=4, cex=0.6, col=km.out$cluster)

hc.complete=hclust(dist(L_dec$u),method="complete")
plot(hc.complete)
#hc.single=hclust(dist(Unorm),method="single")
#plot(hc.single)
#hc.average=hclust(dist(Unorm),method="average")
#plot(hc.average)

