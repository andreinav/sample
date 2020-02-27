

message("Creating a dataframe that combined the two methods: absolute values and cluster analysis...")

###create a single databased with combined methods

final_df <- df5 %>%
   
   #only keep normalization 6: last year available
   filter (norm_type == "value_norm6") %>%
   
   #only keep priority type of below 25th
   filter(type_of_priority == "priority_25th") %>%
   
   rename (priority_cluster_25 = priority_value) %>%
   
   #join bottom 20 dataframe
   left_join (df_bottom %>%
                 select (iso3c,series.code,year,bottom20),
              by = c("iso3c", 
                     "year",
                     "series.code")) %>%
   
   #construct priority variable that combines ranking and cluster method
   mutate (priority_comb = ifelse (bottom20 == 1 | priority_cluster_25 == 1,
                                   1, 0) )  %>%
   
   mutate (priority_comb = ifelse (is.na (priority_comb), 
                                   99,
                                   priority_comb)) %>%
   
   
   group_by (categories, iso3c) %>%
   mutate(category_sum = mean (priority_comb)) %>%
   ungroup() %>%
   
   #construct priority variable by categories
   mutate (priority_at_categories_level = ifelse (category_sum >= 0.5 ,
                                                  1,
                                                  0)) %>%
   
   #join dataframe with corporate targets
   left_join(corp_targets, by = c ("iso3c")) %>%


   #create additional corporate target 2 that combines C&D and S&I
   mutate (corporate_target2 = ifelse (corporate_targets == 1, 
                                    "Corporate Target (C&D or S&I)","")) 

