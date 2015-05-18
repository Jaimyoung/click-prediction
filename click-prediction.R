#---------------------
# 0. Necessary libraries

source("click-prediction-functions.R")

library(glmnet)
library(caret)
library(ROCR)
library(ggplot2)
library(dplyr)
library(logging)
library(data.table)
basicConfig()



#---------------------
# 1. Read data and cleanup

data = fread("data/train_train_sample",
             header = TRUE, sep = ',',
             data.table = FALSE)

# Remove the ID column
data$id = NULL

# Data structure
head(data)
str(data)


#---------------------
# 2. Feature selection and engineering

# Don't run. R crashes with memory error. (Why?)
lm(click ~ ., data=data)

# Number of levels in each variable
n_var_levels = apply(data, 2, function(x) length(unique(x)))
sum(n_var_levels)
sort(n_var_levels, decreasing = TRUE)

# Add time variables
data =
  mutate(data,
         datetime = as.POSIXct(strptime(hour, "%y%m%d%H")),
         dat = strftime(datetime, "%Y-%m-%d"),
         tod = strftime(datetime, "%H"),
         click = factor(click))


data2 = data
names(data2)

for(nm in names(data2)){
  # nm = names(data2)[2] # test
  loginfo("Collapsing column %s", nm)
  x = data2[[nm]]
  data2[[nm]] = collapse_levels(x)
}

lm_fit = lm(as.numeric(click) ~ ., data=sample_frac(data2, 0.1))
summary(lm_fit)


#------------------------
# glmnet model fitting (LASSO) on the training set

X = sparse.model.matrix(click ~ ., data2)
y = data$click
cvfit = cv.glmnet(X, y, family="binomial")

save(cvfit, file="full_csvfit.RData")

cvfit
coef(cvfit)
plot(cvfit)
plot(cvfit$glmnet.fit)
coef(cvfit, s="lambda.min")

coef(cvfit, s="lambda.1se")



#----------------------
# Scoring the glmnet model using the test data
#
test = fread("data/train_test_sample", header = TRUE, sep = ',',
             data.table = FALSE)
test$id = NULL
test = mutate(test,
              datetime = as.POSIXct(strptime(hour, "%y%m%d%H")),
              dat = strftime(datetime, "%Y-%m-%d"),
              tod = strftime(datetime, "%H"),
              click = factor(click))

test2 = test
# Make test set's factor variables have the same level as training set's
for(nm in names(test2)){
  # (nm = names(data2)[2]) # test
  loginfo("Collapsing column %s", nm)
  x = factor(test2[[nm]])
  x_train = data2[[nm]]
  levels(x)[!(levels(x) %in% levels(x_train))] = "Other"
  test2[[nm]] = x
}
str(test2)

newX = sparse.model.matrix(click ~ ., test2)
# newX has an extra variable due to the value in test set not in training set.
setdiff(colnames(X), colnames(newX))
setdiff(colnames(newX), colnames(X))
# Without this, the newX has an extra variable compared to X
newX = newX[, -which(colnames(newX) == 'device_typeOther')]
dim(X)
dim(newX)

lasso_predictions = predict(cvfit, newx = newX, s = "lambda.min", type="response")
lasso_predictions = predict(cvfit, newx = newX, s = "lambda.1se", type="response")

summary(lasso_predictions)
hist(lasso_predictions)

#----------------------
# Evaluation of the VW
#
vw_predictions = fread("data/predictions", data.table=FALSE)[[1]]
summary(vw_predictions)
hist(vw_predictions)


#---------------------
# Comparison of the Lasso and VW
lasso_pred <- prediction(lasso_predictions, test$click)
lasso_perf <- performance(lasso_pred, measure = "tpr", x.measure = "fpr")
vw_pred <- prediction(vw_predictions, test$click)
vw_perf <- performance(vw_pred, measure = "tpr", x.measure = "fpr")

(vw_auc <- performance(pred, "auc")@y.values[[1]])
(vw_auc_01 <- performance(pred, "auc", fpr.stop=0.1)@y.values[[1]])
(lasso_auc <- performance(lasso_pred, "auc")@y.values[[1]])
(lasso_auc_01 <- performance(lasso_pred, "auc", fpr.stop=0.1)@y.values[[1]])


boxplot(split(vw_pred, test$click))
boxplot(split(lasso_predictions, test$click))




plot(vw_perf, col="blue")
plot(lasso_perf, col="red", add=TRUE)
abline(0,1)
legend('bottomright', legend = c("VW", "glmnet"), col=c('blue', 'red'), lty=1,
       inset=0.1)

