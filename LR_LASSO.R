#########################################################################
##
##  LR_LASSO.R: Performing Logistic Regression with Least Absolute 
##  Shrinkage and Selection Operator regularization (LR-LASSO) for the 
##  co-normalized microarray data
##  
#########################################################################


## 1. Start from the results generated from COCONUT.R

## 2. Generation of normalized expression matrix for Stanford82
tid <- which(is.element(row.names(GSEs.COCO.combined$genes), stanford82.genes) == 1)
normData <- GSEs.COCO.combined$genes[tid, ]
sampleinfo <- GSEs.COCO.combined$pheno

## 3. LASSO penalized logistic regression
library(glmnet)
X <- t(normData)
y <- sampleinfo$cond
fit <- glmnet(X, y, family = "binomial", alpha = 1)
plot(fit)

nFeatures <- nrow(normData)
nTimes <- 100
nFolds <- 5
Freqs <- matrix(0, nFeatures, nFolds)

for ( i in 1:nTimes ) {
  cvfit <- cv.glmnet(X, y, family = "binomial", nfolds = nFolds, type.measure = "class", alpha = 1, standardize = T)
  coeff <- coef(cvfit, s = "lambda.min")
  tid <- which(as.matrix(coeff) != 0)
  tid <- tid[2:length(tid)] - 1
  Freqs[tid, i] <- 1
}

Freqs <- rowSums(Freqs)
genesOrder82 <- row.names(normData)
LASSOgenes <- genesOrder82[which(Freqs == 100)]