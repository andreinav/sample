

message("Final cleaning of dataframe with only the variables of interest...")

#run libraries
#library(WDI)
library(dplyr)
library(tidyr)
library(stringi)
library(readr)
library(ggplot2)
library(readr)


final_df <- final_df %>%
   select (iso3c,
           region,
           cluster,
           series.code,
           series.name,
           name,
           value, 
           categories,
           year,
           series.description,
           value_norm,
           bottom20,
           priority_cluster_25,
           priority_comb,
           CS_priority) %>%
  
   #mutate variables (remove commas)
   mutate (series.description = gsub ( ',', '', series.description)) %>%
   mutate (series.name = gsub ( ',', '', series.name)) %>%

   
   #round values (for SQL)
   mutate (value = round (value, digits = 2)) %>%
   mutate  (value_norm = round (value_norm, digits = 2)) %>%
   
   #mutate variables (additional spaces)
   mutate (series.description = gsub("\n", "", series.description)) %>%
   mutate (series.name = gsub("\n", "", series.name)) 
   

rm(list = ls()[!ls() %in% c("final_df")])
