##master dataset


#run packages
#install.packages ("WDI")
#install.packages ("dplyr")
#install.packages ("tidyr")
#install.packages ("stringi")
#install.packages ("readr")
#install.packages ("ggplot2")
#
##load libraries
#library(dplyr)
#library(tidyr)
#library(stringi)
#library(readr)
#library(WDI)

options( warn = -1 )
#set working directory
setwd("C:/Users/andreinav/OneDrive - Inter-American Development Bank Group/strategic selectivity/strategic selectivity")

#run scripts
source("code/TSP/list_TSP.R")
source("code/WDI_names.R")
source("code/wb_data_download.R")
source ("code/TSP/clean_data_TSP.R")
source("code/TSP/merging_data_TSP.R")
source("code/TSP/neg_indicators_TSP.R")
source("code/normalize.R")
source ("code/ranking_meth.R")
source("code/combined_methods.R")
source ("code/clean.R")


#save final dataset
write.csv(final_df, "data_out/TSP/final.csv", row.names = FALSE)
