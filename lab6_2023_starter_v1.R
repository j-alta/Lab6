#  Gregory A. Bruich, Ph.D.
#  Economics 50, Harvard University
#  Send corrections and suggestions to gbruich@fas.harvard.edu
#
#  File: 	lab6_2023_starter_v1.R
#
#  Description:
#  
#  The following program reads in the data set and splits the data at random
#  into training and test subsamples. Then it estimates a multivariate regression,
#  predicts kfr_pooled_pooled_p25 in both the training and test samples,
#  and computes the RMSPE in each of these samples.  It then estimates a small
#  decision tree followed by a large decision tree and similarly predicts 
#  kfr_pooled_pooled_p25 and computes the RMSPE in both the test and training
#  subsamples.  It also creates a visualizations of the estimated decision trees.  
#
#  The code may have some typos -- please be on the look out for them -- and to 
#  receive credit for the lab you have to make edits to estimate your own 
#  regressions and decision trees.  These are simply examples of what you might
#  what to  do in your analysis, but you are expected to make an effort to 
#  understand what you are doing with the code.
#
#  Inputs:  mobility.dta (download from canvas)
#           rpart library for decision trees
#           haven library to load stata data sets into R
#
#  Outputs: figure1.png, figure2.png

rm(list=ls()) # removes all objects from the environment
cat('\014') # clears the console

###Load packages
if (!require(haven)) install.packages("haven"); library(haven)
if (!require(rpart)) install.packages("rpart"); library(rpart)

## Read in data 
mobility <- read_dta("mobility.dta")
summary(mobility)

#Question 2 example code
HUID <- 50505050 #Replace with your HUID
set.seed(HUID)

#Uniformly distributed random number between 0 and 1
mobility$random_number <- runif(length(mobility$cz))

## Generate a training flag for 50% of the sample
mobility$train_flag <- ifelse(mobility$random_number>= 0.5, 1, 0) 

#Report number of observations in training and test samples
sum(mobility$train_flag)
sum(1-mobility$train_flag)

## Create some data frames that just contain the training and test data
test <- subset(mobility, train_flag == 0)
train <- subset(mobility, train_flag == 1)

#Question 4 example code

### Regression example: modify this code to complete the coding exercise
mobilityreg <- lm(kfr_pooled_pooled_p25 ~ bowl_per_capita + singleparent_share1990, data=train) 
summary(mobilityreg)

### Display data for Milwaukee, WI
summary(subset(mobility, cz == 24100))

#Generate predictions for all observations in the test data
y_test_predictions_ols <- predict(mobilityreg, newdata=test)

#Generate predictions for all observations in the training data
y_train_predictions_ols <- predict(mobilityreg, newdata=train)

#Generate squared prediction errors
OLS_performance_testset <- (test$kfr_pooled_pooled_p25 - y_test_predictions_ols)^2
OLS_performance_trainset <- (train$kfr_pooled_pooled_p25 - y_train_predictions_ols)^2

#Report the root mean squared prediction error
rmspe_test_ols <- sqrt(mean(OLS_performance_testset, na.rm=TRUE))
rmspe_train_ols <- sqrt(mean(OLS_performance_trainset, na.rm=TRUE))

rmspe_test_ols
rmspe_train_ols

#Question 5.	Prediction using decision tree

#### Trees example: modify this code to complete the coding exercise
## Method is rpart()
## Depth 3
mobilitytree <- rpart(kfr_pooled_pooled_p25 ~ bowl_per_capita + singleparent_share1990, 
                      data=train, 
                      maxdepth = 3, 
                      cp=0) 

#Options for rpart
#cp = complexity parameter, which controls the complexity of the tree. 0 is most complex.
#If cp>0 the tree will only grown if the increase in tree size improve the performance of the tree by at least cp.
#maxdepth = maximum depth of any node of the final tree, with the root node counted as depth 0
#Other tuning parameters that can be changed
help("rpart.control")

#Visualize the fitted decision tree
plot(mobilitytree, margin = 0.2) # plot tree
text(mobilitytree, cex = 0.5) # add labels to tree

#Save figure
dev.copy(png,'figure1.png')
dev.off()

#Apply tree to predict Milwaukee, WI
summary(subset(mobility, cz == 24100))

#Calculate predictions for all rows in test and training samples
y_test_predictions_tree <- predict(mobilitytree, newdata=test)
y_train_predictions_tree <- predict(mobilitytree, newdata=train)

#Generate squared prediction errors
tree_performance_testset <- (test$kfr_pooled_pooled_p25 - y_test_predictions_tree)^2
tree_performance_trainset <- (train$kfr_pooled_pooled_p25 - y_train_predictions_tree)^2

#Report the root mean squared prediction error
rmspe_test_tree <- sqrt(mean(tree_performance_testset, na.rm=TRUE))
rmspe_train_tree <- sqrt(mean(tree_performance_trainset, na.rm=TRUE))

#Report the root mean squared prediction error
rmspe_test_tree
rmspe_train_tree

#Question 6 example code
#Estimate large tree
big_tree <-rpart(kfr_pooled_pooled_p25 ~ bowl_per_capita + singleparent_share1990, 
             data=train, 
             maxdepth = 30, 
             cp=0,  
             minsplit = 1, 
             minbucket = 1)

#Visualize the fitted decision tree
plot(big_tree, margin = 0.2) # plot tree
text(big_tree, cex = 0.5) # add labels to tree

#Save figure
dev.copy(png,'figure2.png')
dev.off()

#Calculate predictions for all rows in test and training samples
y_test_predictions_big_tree <- predict(big_tree, newdata=test)
y_train_predictions_big_tree <- predict(big_tree, newdata=train)

#Generate squared prediction errors
big_tree_performance_testset <- (test$kfr_pooled_pooled_p25 - y_test_predictions_big_tree)^2
big_tree_performance_trainset <- (train$kfr_pooled_pooled_p25 - y_train_predictions_big_tree)^2

#Report the root mean squared prediction error
rmspe_test_big_tree <- sqrt(mean(big_tree_performance_testset, na.rm=TRUE))
rmspe_train_big_tree <- sqrt(mean(big_tree_performance_trainset, na.rm=TRUE))

#Report the root mean squared prediction error
rmspe_test_big_tree
rmspe_train_big_tree

#Question 7
#Compare RMSPE for the three models in-sample
#Compare RMSPE for the three models in the pseudo out-of-sample



