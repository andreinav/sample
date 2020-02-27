library(dplyr)
library(tidyr)
library(lubridate)
library(caret)
library(forecast)
library(vars)

#information on VARS Package
#https://cran.r-project.org/web/packages/vars/vars.pdf

#information on how to use the VARS package with the example of canada dataset
#http://ftp.uni-bayreuth.de/math/statlib/R/CRAN/doc/vignettes/vars/vars.pdf


##Model: Vector Autoregressive model used for financial forecasting

###########
# Example
###########

data(Canada)
head(Canada)

###########
# Testing
###########

#load data and remove private sector departments

final_dept <- read.csv('~/Downloads/Challenge/data_processed/final_dept.csv')

dept_include <- c('IFD', 'INE', 'INT', 'SCL')

#transform data
test <-
        final_dept %>%
        filter(Department %in% dept_include) %>%
        group_by(Department, YR) %>%
        summarize(sum_m1 = sum(M1),
                  sum_m2 = sum(M2),
                  sum_m3 = sum(M3),
                  sum_m4 = sum(M4),
                  sum_m5 = sum(M5),
                  sum_m6 = sum(M6),
                  sum_m7 = sum(M7),
                  sum_m8 = sum(M8),
                  sum_m9 = sum(M9),
                  sum_m10 = sum(M10),
                  sum_m11 = sum(M11),
                  sum_m12 = sum(M12)) %>%
        gather('month', 'sum_log', sum_m1:sum_m12) %>%
        mutate(month = as.numeric(gsub('sum_m', '', month))) %>%
        spread(Department, sum_log) %>%
        arrange(YR, month)
    
#separate train and test samples
train <-
        test %>%
        filter(YR != 2015)

test <-
        test %>%
        filter(YR == 2015)

train_ts <- ts(train[3:6], class = c('ts', 'mts'))

plot(train_ts)

#Select the best lag for this data
VARselect(train_ts, lag.max = 5, type = 'const')

#Run model with train sample, costant and including seasonality
var.2c <- VAR(train_ts, p = 1, type = 'const', season = 12)
summary(var.2c)
plot(var.2c)

#Predict
var.f12 <- predict(var.2c, n.ahead = 12, ci = 0.95)

pred_IFD <- var.f12$fcst$IFD[1:12]
pred_INE <- var.f12$fcst$INE[1:12]
pred_INT <- var.f12$fcst$INT[1:12]
pred_SCL <- var.f12$fcst$SCL[1:12]


#arrange final data that will be compared to the test
pred_final <- c(pred_IFD, pred_INE, pred_INT, pred_SCL)

#arrange final data that will be tested
actual_final <- c(test$IFD, test$INE, test$INT, test$SCL)

#calculate the R square
R2(pred_final, actual_final)
