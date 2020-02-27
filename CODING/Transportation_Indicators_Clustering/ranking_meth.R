
message("Calculating the ranking of countries by indicators using the LAC distribution (method 2)")

#load corporate dataset 
corp_targets <- read.csv("data_in/corp_targ.csv", stringsAsFactors = FALSE)


#create a short database
df_bottom <- df %>%

   #only keep IDB countries
   filter (region != "OECD") %>%
   
   #apply multiplier to negative indicators
   mutate(neg_ind = ifelse (series.code %in% negative_ind, 1, 0) ) %>%
   mutate (value = ifelse (neg_ind == 1, value * -1, value)) %>%
   
   #remove NA in value variables
   filter (value != is.na(value)) %>%
   distinct() %>%
   
   #arrange numbers in descending order and keep only worst performer
   group_by (iso3c, series.code) %>%
   arrange (desc(year)) %>%
   slice(1) %>%
   #mutate (max_year = max(year)) %>%
   ungroup() %>%
   
   #rank countries by value of indicator
   group_by(series.code) %>%
   arrange (series.code, value) %>%
   mutate(rank = dense_rank((value))) %>%
   
   #create a variable that keeps only bottom .25 of the distribution
   mutate(bottom20 = ifelse (value <= quantile (value, 0.20), TRUE, 
                             ifelse (value > quantile (value, 0.20), FALSE, 
                                     NA))) %>%
   mutate(bottom20 = as.numeric(bottom20)) %>%
   ungroup() %>%
   
   group_by (categories, iso3c) %>%
   mutate (category_sum = sum (bottom20, na.rm = TRUE)) %>%
   mutate(priority = ifelse (category_sum >= 1 , TRUE, FALSE)) %>%
   ungroup()


#write.csv(df_short, "data_out/ranking of values.csv", row.names = FALSE)
#write.csv(df_bottom, "data_out/bottom_20_values.csv", row.names = FALSE)




####################################################################################
####################################################################################
####################################################################################
####################################################################################



