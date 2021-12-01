#IST707 M004
#Final_Project
#Nianyou Zhang

dev.off()# Clear the graph window
rm(list=ls())# Clear all user objects from the environment
cat('\014') # Clear the console

# packages used and their functions:
library(dplyr)# for pipeline, mutate
library(tidyverse)# for pipeline, filter(), select()
library(ggplot2)# for some plots and caret, also required by factoextra
library(arules)# for association rule mining
library(lattice)# for caret
library(caret)# for creating training/testing set, and all the algorithms
library(e1071)# for confusion matrix
library(stats)# for creating distance matrices
library(factoextra)# for k-means clustering
library(cluster)# for hierarchical clustering
library(kernlab)# for svm

data <- read.csv(file.choose())

head(data)
summary(data)

# drop irrelevant variable: time
data1 <- data[,-12]

summary(data1)

################################################################################
################################################################################
# task one: association rule mining

# numerical columns (not binary or boolean) are age, creatinine_phosphokinase, ejection_fraction, platelets, serum_creatinine, serum_sodium
# graphing box plot for these variables to visualize the distribution
# age
ggplot(data1) +
  aes(y=age) +
  geom_boxplot() +
  ggtitle("ageBoxPlot")

# categorize age base on quadrants
data1$age <- cut(data1$age, br=c(0,51,60,70,95), labels = c("1st","2nd","3rd","4th"))

# creatinine_phosphokinase
ggplot(data1) +
  aes(y=creatinine_phosphokinase) +
  geom_boxplot() +
  ggtitle("creatinine_phosphokinaseBoxPlot")

# categorize creatinine_phosphokinase base on quadrants
data1$creatinine_phosphokinase <- cut(data1$creatinine_phosphokinase, br=c(0,116.5,250,582,7861), labels = c("1st","2nd","3rd","4th"))

# ejection_fraction
ggplot(data1) +
  aes(y=ejection_fraction) +
  geom_boxplot() +
  ggtitle("ejection_fractionBoxPlot")

# categorize ejection_fraction base on quadrants
data1$ejection_fraction <- cut(data1$ejection_fraction, br=c(0,30,38,45,80), labels = c("1st","2nd","3rd","4th"))

# platelets
ggplot(data1) +
  aes(y=platelets) +
  geom_boxplot() +
  ggtitle("plateletsBoxPlot")

# categorize platelets base on quadrants
data1$platelets <- cut(data1$platelets, br=c(0,212500,262000,303500,850000), labels = c("1st","2nd","3rd","4th"))

# serum_creatinine
ggplot(data1) +
  aes(y=serum_creatinine) +
  geom_boxplot() +
  ggtitle("serum_creatinineBoxPlot")

# categorize serum_creatinine base on quadrants
data1$serum_creatinine <- cut(data1$serum_creatinine, br=c(0,0.9,1.1,1.4,9.4), labels = c("1st","2nd","3rd","4th"))

# serum_sodium
ggplot(data1) +
  aes(y=serum_sodium) +
  geom_boxplot() +
  ggtitle("serum_sodiumBoxPlot")

# categorize serum_sodium base on quadrants
data1$serum_sodium <- cut(data1$serum_sodium, br=c(0,134,137,140,148), labels = c("1st","2nd","3rd","4th"))

# turn boolean and binary columns into factors
data1 <- data1 %>%
  mutate(anaemia=as.factor(anaemia),
         diabetes=as.factor(diabetes),
         high_blood_pressure=as.factor(high_blood_pressure),
         sex=as.factor(sex),
         smoking=as.factor(smoking),
         DEATH_EVENT=as.factor(DEATH_EVENT))

# change factor columns' names
levels(data1$anaemia) <- c("No","Yes")
levels(data1$diabetes) <- c("No","Yes")
levels(data1$high_blood_pressure) <- c("No","Yes")
levels(data1$sex) <- c("Female","Male")
levels(data1$smoking) <- c("No","Yes")
levels(data1$DEATH_EVENT) <- c("No","Yes")

summary(data1)

# turn data into transactions
datatrans <- as(data1,"transactions")

inspect(datatrans) # all transactions are looking good!

itemFrequency(datatrans) # 0.1 support seems reseaonable

# apply association rules
rules <- apriori(datatrans,
                 parameter = list(support=0.05, confidence=0.7, minlen=4),
                 appearance = list(default="lhs", rhs=("DEATH_EVENT=Yes")))

inspect(rules)

# best rule:
# [3]{ejection_fraction=1st,serum_creatinine=4th,serum_sodium=1st}=>{DEATH_EVENT=Yes}
# support:0.05016722; confidence: 0.7894737; coverage: 0.06354515; lift: 2.458882; count: 15

################################################################################
################################################################################
# task two: clustering

# drop target variable and drop irrelevant variable
data2 <- data[,1:11]

summary(data2)

# nomralize numeric columns
norm_min_max <- function(x) {
  (x-min(x))/(max(x)-min(x))
}

data3 <- data2 %>%
  mutate(age=norm_min_max(age),
         creatinine_phosphokinase=norm_min_max(creatinine_phosphokinase),
         ejection_fraction=norm_min_max(ejection_fraction),
         platelets=norm_min_max(platelets),
         serum_creatinine=norm_min_max(serum_creatinine),
         serum_sodium=norm_min_max(serum_sodium))

summary(data3)

# k-means
set.seed(1) # set seed to control the RNG

# elbow plot
elbow <- fviz_nbclust(data3, FUNcluster = kmeans, method = "wss")
elbow
# from this elbow plot, 4 means seem most reasonable

# apply k-means clustering k=4
cluster4 <- kmeans(data3, centers = 4, nstart = 20)
cluster4
cluster4$size # this shows the number of points in each cluster: 70  42 103  84
cluster4$totss # The total sum of squares: 388.5571

# four clusters and their death rate:
# put clusters label into original dataset
data4 <- data
data4$cluster <- cluster4$cluster

# cluster 1
d4c1 <- data4[which(data4$cluster==1),]
d4c1death <- count(d4c1[which(d4c1$DEATH_EVENT==1),])/count(d4c1)
d4c1death # 0.3846154

# cluster 2
d4c2 <- data4[which(data4$cluster==2),]
d4c2death <- count(d4c2[which(d4c2$DEATH_EVENT==1),])/count(d4c2)
d4c2death # 0.2962963

# cluster 3
d4c3 <- data4[which(data4$cluster==3),]
d4c3death <- count(d4c3[which(d4c3$DEATH_EVENT==1),])/count(d4c3)
d4c3death # 0.2903226

# cluster 4
d4c4 <- data4[which(data4$cluster==4),]
d4c4death <- count(d4c4[which(d4c4$DEATH_EVENT==1),])/count(d4c4)
d4c4death # 0.3376623

# summary statistics for cluster 1 and 3
summary(d4c1)
summary(d4c3)

################################################################################
################################################################################
# task three: predictive models

# predictive models with original target value
# restore original label to scaled data
data5 <- data3
data5$DEATH_EVENT <- data$DEATH_EVENT
# turn label into factor
data5 <- data5 %>%
  mutate(DEATH_EVENT=as.factor(DEATH_EVENT))
# change label name
levels(data5$DEATH_EVENT) <- c("No","Yes")

summary(data5)

# create an evaluate function to calculate other evaluation measures
evaluate <-function(m,s){
  Accuracy <- (m[1,1]+m[2,2])/(m[1,1]+m[2,2]+m[1,2]+m[2,1]) # TP+TN/(TP+TN+FP+FN)
  Specificity <- m[2,2]/(m[2,2]+m[1,2]) # TN / (TN + FP)
  Precision <- m[1,1]/(m[1,1]+m[1,2]) # TP / (TP + FP)
  Recall <- m[1,1]/(m[1,1]+m[2,2]) # TP / (TP + FN) or called Sensitivity
  F_measure <- (2*Precision*Recall)/(Precision + Recall)
  cat(s,":","\nAccuracy:",Accuracy,"\nSpecificity:",Specificity,"\nPrecision:",Precision,"\nRecall",Recall,"\nF_measure:",F_measure)
}

# subset data into training and testing sets
trainList <- createDataPartition(data5$DEATH_EVENT,p = 0.8,
                                 list = FALSE,
                                 times = 1)

# SVM
# separate label from data
training_set <- data5[trainList,] %>% select(-DEATH_EVENT)
testing_set <- data5[-trainList,] %>% select(-DEATH_EVENT)
training_labels <- data5[trainList,]$DEATH_EVENT # Extracting train labels
testing_labels <- data5[-trainList,]$DEATH_EVENT # Extracting test labels

Controls <- trainControl(method="repeatedcv",
                         number=5,
                         repeats=5)

# linear
Grid_lin <- expand.grid(C = seq(0, 2, length = 11)) # from warning messages, C=0.0 does not work

linear_SVM <- train(training_set,
                    training_labels,
                    method = 'svmLinear',
                    trControl= Controls,
                    tuneGrid = Grid_lin)

# training set accuracy
predt_linear <- predict(linear_SVM,
                        newdata = training_set)

conf_matrixtr_SVM_linear_t <- confusionMatrix(training_labels, predt_linear)
conf_matrixtr_SVM_linear_t # accuracy 0.7625

# testing set accuracy
pred_linear <- predict(linear_SVM,
                       newdata = testing_set)

conf_matrix_SVM_linear <- confusionMatrix(testing_labels, pred_linear)
conf_matrix_SVM_linear # accuracy 0.8305

# polynomial

Grid_poly <- expand.grid(degree = 2:5, scale = 0.1, C = c(0.01,0.1,1,10,20))

poly_SVM <- train(training_set,
                  training_labels,
                  method = 'svmPoly',
                  trControl= Controls,
                  tuneGrid = Grid_poly)

# training set accuracy
predt_poly <- predict(poly_SVM,
                          newdata = training_set)

conf_matrixtr_SVM_poly_t <- confusionMatrix(training_labels, predt_poly)
conf_matrixtr_SVM_poly_t # accuracy 0.7792

# testing set accuracy
pred_poly <- predict(poly_SVM,
                         newdata = testing_set)

conf_matrix_SVM_poly <- confusionMatrix(testing_labels, pred_poly)
conf_matrix_SVM_poly # accuracy 0.7288

# radial

Grid_rad <- expand.grid(sigma = c(0.1,1,5), C = c(0.01,0.1,1,3,5,10,20))

rad_SVM <- train(training_set,
                 training_labels,
                 method = 'svmRadial',
                 trControl= Controls,
                 tuneGrid = Grid_rad)

# training set accuracy
predt_rad <- predict(rad_SVM,
                     newdata = training_set)

conf_matrixtr_SVM_rad_t <- confusionMatrix(training_labels, predt_rad)
conf_matrixtr_SVM_rad_t # accuracy 0.8292

# testing set accuracy
pred_rad <- predict(rad_SVM,
                    newdata = testing_set)

conf_matrix_SVM_rad <- confusionMatrix(testing_labels, pred_rad)
conf_matrix_SVM_rad # accuracy 0.7458

# SVM evaluation
evaluate(conf_matrix_SVM_linear$table,'SVM_linear')
evaluate(conf_matrix_SVM_poly$table,'SVM_polynomial')
evaluate(conf_matrix_SVM_rad$table,'SVM_radial')

# ANN
trainSet <- data5[trainList,]
testSet <- data5[-trainList,]

Grid <- expand.grid(size=c(2,3,4,5),decay = c(0.1, 0.5, 0.9))

ANN <- train(DEATH_EVENT~.,
             data=trainSet,
             method="nnet",
             trControl=Controls,
             tuneGrid = Grid)

# training set accuracy
predt_ANN <- predict(ANN,
                     newdata = trainSet)

conf_matrixtr_ANN_t <- confusionMatrix(trainSet$DEATH_EVENT, predt_ANN)
conf_matrixtr_ANN_t # accuracy 0.7542

# test set accuracy
pred_ANN <- predict(ANN,
                    newdata = testSet)

conf_matrix_ANN <- confusionMatrix(testSet$DEATH_EVENT, pred_ANN)
conf_matrix_ANN # accuracy 0.8136

# decision tree
#data6, new data set for DT: categorical attributes are factors; numerical attributes are unchanged
data6 <- data[,-12]

# turn boolean and binary columns into factors
data6 <- data6 %>%
  mutate(anaemia=as.factor(anaemia),
         diabetes=as.factor(diabetes),
         high_blood_pressure=as.factor(high_blood_pressure),
         sex=as.factor(sex),
         smoking=as.factor(smoking),
         DEATH_EVENT=as.factor(DEATH_EVENT))

# change factor columns' names
levels(data6$anaemia) <- c("No","Yes")
levels(data6$diabetes) <- c("No","Yes")
levels(data6$high_blood_pressure) <- c("No","Yes")
levels(data6$sex) <- c("Female","Male")
levels(data6$smoking) <- c("No","Yes")
levels(data6$DEATH_EVENT) <- c("No","Yes")

summary(data6)

# subset data6
trainListDT <- createDataPartition(data6$DEATH_EVENT,p = 0.8,
                                   list = FALSE,
                                   times = 1)
#trainSetDT, testSetDT
trainSetDT <- data6[trainListDT,]
testSetDT <- data6[-trainListDT,]


DT <- train(DEATH_EVENT~.,
            data=trainSetDT,
            method="rpart",
            trControl=Controls)

# training set accuracy
predt_DT <- predict(DT,
                    newdata = trainSetDT)

conf_matrixtr_DT_t <- confusionMatrix(trainSetDT$DEATH_EVENT, predt_DT)
conf_matrixtr_DT_t # accuracy 0.7792

# test set accuracy
pred_DT <- predict(DT,
                   newdata = testSetDT)

conf_matrix_DT <- confusionMatrix(testSetDT$DEATH_EVENT, pred_DT)
conf_matrix_DT # accuracy 0.6441


# overall evaluation
evaluate(conf_matrix_SVM_poly$table,'SVM_poly')
evaluate(conf_matrix_ANN$table,'ANN')
evaluate(conf_matrix_DT$table,'DT')

