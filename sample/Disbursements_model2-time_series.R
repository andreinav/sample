### Load libraries
library(dplyr)
library(tidyr)
library(forecast)



### Load data

ops <- read.csv('data_processed/all_ops_processed.csv')


#################################################
#
#     Forecasting Model Testing
#
#################################################


### Setup data

ops_ts <-
  ops %>%
  
  # Group by year and month
  group_by(YR, MTH) %>%
  
  # Create summaries
  summarize(Sum_Disbursed = sum(as.numeric(Monthly_Disb), na.rm = TRUE)) %>%
  
  # Calculate log of disbursement
  mutate(Sum_Disbursed_Log = log(Sum_Disbursed)) %>%
  
  # Only include transactions from 2006
  filter(YR >= 2006) %>%
  
  # Set in appropriate order in order to create data series
  arrange(YR, MTH)



### Pre-modeling processing

# Create train data
ops_ts_train <-
  ops_ts %>%
  filter(YR != 2015)

# Create test data
ops_ts_test <-
  ops_ts %>%
  filter(YR == 2015)

# Create vector with actual 2016 values for R2 calculation
ts_actual <- ops_ts_test$Sum_Disbursed

# Define time series (2006-2014)
ops_ts_obj <- ts(ops_ts_train$Sum_Disbursed, start = c(2006, 1), frequency = 12)

# Visualize time series
plot.ts(ops_ts_obj)

# Visualize time series components
ops_ts_components <- decompose(ops_ts_obj)
plot(ops_ts_components)



### Modeling and prediction - making sure the model is good

# Create time series model (auto-arima)
fit <- auto.arima(ops_ts_obj)

# Predict 2015
ts_pred <- forecast(fit, h = 12)$mean

# Calculate R2
R2(ts_pred, ts_actual)





#################################################
#
#     Forecasting Model
#
#################################################

# Define time series (2006-2015) - all data
ops_ts_obj_final <- ts(ops_ts$Sum_Disbursed, start = c(2006, 1), frequency = 12)

# Create time series model (auto-arima)
fit_final <- auto.arima(ops_ts_obj_final)

# Predict 2015
ts_pred_final <- forecast(fit, h = 12)$mean

# Create data frame
forecast_predictions <- data.frame(month = 1:12, disbursement = as.numeric(ts_pred_final))

# Export results
write.csv(forecast_predictions, 'model_predictions/model_predictions-forecast.csv', row.names = FALSE)
