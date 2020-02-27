####################
# Install (if necessary) and load libraries
####################

# Uncomment the install functions the first time you run the code if you do not have libraries installed 
#install.packages('readstata13')
#install.packages('dplyr')
#install.packages('tidyr')

library(readstata13)
library(dplyr)
library(tidyr)


####################
# Load the growth_accounting function
####################

source('source_function.R')


####################
# Run function with changeable parameters
####################

growth_accounting(file = 'growth_accounting.dta',
                  
                  # base year
                  base_year = 1990,
                  
                  # number of years for the steady-state growth rate output
                  steady_state = 10,
                  
                  # number of years to take into account for the Gross fixed capital formation
                  fixed_capital = 2,
                  
                  # this sets the multiple values of depreciation rate of capital (delta) - can be more or less than 3
                  depreciation = c(0.03, 0.06, 0.08),
                  
                  # this sets the multiple values of income of capital (alpha) - can be more or less than 3
                  income_share = c(0.2, 0.3, 0.4),
                  
                  # this sets the name of the output csv file - good for multiple runs
                  output_name = 'growth_accounting_results.csv')
