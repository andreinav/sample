

message("Standarizing the variables of interest using the mean and the standard deviation of each cluster...")

#function
ntile_na <- function(x,n)
{
   notna <- !is.na(x)
   out <- rep(NA_real_,length(x))
   out[notna] <- ntile(x[notna],n)
   return(out)
}

###########################################################################
#STEP 1: apply multiplier to negative indicators

df1 <- df %>%
   mutate (neg_ind = ifelse (series.code %in% negative_ind, 1, 0) ) %>%
   mutate (value = ifelse (neg_ind == 1, value * -1, value)) %>%
   select(-neg_ind,
          -year_cluster)


###########################################################################
#STEP 2: create a distribution for each indicator, last year available


df2 <- df1 %>%
   
   #filter (value != is.na(value)) %>%
   
   distinct() %>%
   group_by (iso3c, series.code) %>%
   arrange (desc(year)) %>%
   slice(1) %>%
   
   #mutate (max_year = max(year)) %>%
   ungroup() %>%
   
   group_by(series.code, cluster) %>%
   mutate (value_norm6 = (value - mean (value, na.rm = TRUE)) / 
              (sd (value, na.rm = TRUE))) %>%
   mutate(mean_ind6 = mean (value_norm6, na.rm = TRUE)) %>%
   ungroup() #%>%

# mutate (value_norm6 = ifelse (is.nan(value_norm6), 0, value_norm6))



   
###########################################################################
#STEP 3: convert to long form

df3 <- df2 %>%
  gather ("norm_type", "value_norm", starts_with ("value_")) %>%
  
  gather ("mean_type", "value_mean", starts_with ("mean_")) %>%

  unique() 




###########################################################################
#STEP 4: construct a priority variable that measures standard deviations from mean

df4 <-  df3 %>%
   
   #create a priority variable that measures standard deviations from mean
   group_by(norm_type, series.code, cluster) %>%
   
   mutate(quartile = ntile_na (value_norm, 5)) %>% #
 
   mutate (priority_25th = ifelse (quartile == 1,  1, 0)) %>%
   
   ungroup() %>%
   
   gather ("type_of_priority", "priority_value", starts_with ("priority_")) #%>%
   

df5 <- df4 

###########################################################################   
#STEP 5: construct a varible that indicates if the indicator value is above the 90th percentile


#calculate a binary = TRUE if its above the 90th percentile
   #mutate (above_90th = ifelse (value_norm > 1.282,  TRUE, FALSE)) %>%
   
   
   #calculate the mean of each cluster by type of normalization
   #group_by (norm_type, cluster, series.code) %>%
   #mutate (mean_cluster = mean (value_norm, na.rm = TRUE)) %>%
   #ungroup() %>%
   
   
###########################################################################   
#STEP 6: construct priority relative to cluster above

#calculate the means by each cluster that are in wide format
   #arrange (cluster) %>%
   #mutate (mean_cluster1 = ifelse (cluster == 1, mean_cluster, NA)) %>%
   #mutate (mean_cluster2 = ifelse (cluster == 2, mean_cluster, NA)) %>%
   #mutate (mean_cluster3 = ifelse (cluster == 3, mean_cluster, NA)) %>%
   #mutate (mean_cluster4 = ifelse (cluster == 4, mean_cluster, NA)) 


#calculate variable that are relative to clusters based on the 90th percentile rule




#%>%mutate (prio_rel_next = ifelse (above_90th == TRUE & cluster == 1,  
#                                   na.omit (value_norm - mean_cluster2), 
#                                   
#                                   ifelse (above_90th == TRUE & cluster == 2, 
#                                           na.omit (value_norm - mean_cluster3), 
#                                           
#                                           ifelse (above_90th == TRUE & cluster == 3,
#                                                   na.omit (value_norm - mean_cluster4), 
#                                                   
#                                                   ifelse (above_90th == FALSE,
#                                                           diff_SD, NA))))) %>%
#   
#   
#   
#   #reshape data
#   gather ("priority_relative_cluster", "diff_SD2", starts_with ("prio_rel")) %>%
#   
#   filter (!is.na (value)) %>%
#   select( -mean_cluster1,
#           -mean_cluster2,
#           -mean_cluster3,
#           -mean_cluster4) 
#

#save dataframe
#write.csv (df5,"data_out/FI_normalize2.csv", row.names = FALSE)





#####################################################
#####################################################
#####################################################
#####################################################

#