#---------------------
# 0. Necessary libraries
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
data$datetime = as.POSIXct(strptime(data$hour, "%y%m%d%H"))
data$dat = strftime(data$datetime, "%Y-%m-%d")
data$tod = strftime(data$datetime, "%H")
data$click = factor(data$click)


collapse_levels = function(x, target_nlevels = 10){
  # Input: character / factor vector x,
  # Output: factor(x) with up to target_nlevels levels.
  #   Top target_nlevels-1 levels with most observations are kept and other
  #   levels are merged into "Other" level.
  x = as.factor(x)
  if (nlevels(x) <= target_nlevels) return(x)
  (top_levles = names(sort(table(x), decreasing = TRUE)[1:(target_nlevels-1)]))
  levels(x)[!(levels(x) %in% top_levles)] = "Other"
  return(x)
}


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
# glmnet

tt = 1:nrow(data)
tt = 1:50000
y = data2[tt, 'click']
x = data2[tt, c("C1", "banner_pos", "hour", "site_category", "site_domain", "site_id")]
str(x)

X = model.matrix(click ~ ., data2[tt,])

X = sparse.model.matrix(click ~ ., data2)
y = data$click

dim(X)

# See http://stackoverflow.com/questions/17032264/big-matrix-to-run-glmnet
X <- sparse.model.matrix( ~ x[,1] - 1)
dim(X)
for (i in 2:ncol(x)) {
  print(i)
  if (nlevels(x[,i]) > 1) {
    coluna <- sparse.model.matrix(~ x[,i] - 1)
    X <- cBind(X, coluna)
    print(dim(coluna))
  } else {
    coluna <- as.numeric(as.factor(x[,i]))
    X <- cBind(X, coluna)
    print(dim(coluna))
  }
}

dim(X)

cvfit = cv.glmnet(X, y, family="binomial")

cvfit
coef(cvfit)

plot(cvfit)
plot(cvfit$glmnet.fit)
coef(cvfit, s="lambda.min")


predict(cvfit)

for(i in 1:ncol(x)){
  if (is.character(x[,i])){
    x[,i] = factor(x[,i])
  }
}

#----------------------
# Evaluation of the prediction
#
test = fread("data/train_test_sample",
             header = TRUE, sep = ',',
             data.table = FALSE)

