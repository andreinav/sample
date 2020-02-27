
message("Merging all cleaned datasets to a single sector dataframe...")


#create TSP dataset

#merge wb indicators data with names of tsp indicators
df <- wb_long %>%
   #mutate( iso3c = as.character(iso3c)) %>%
   
   bind_rows (moto) %>%
   
   bind_rows (WEF) %>%
   
   bind_rows (road_den) %>%
   
   bind_rows(paved_road) %>%
   
   bind_rows (shipping) %>%

   #bind_rows(infra_vul) %>%
   #bind_rows(urban_motorization_rate) %>%
   
   
   left_join (region, by = c("iso3c")) %>%
   left_join (cluster, by = c("iso3c")) %>%
   left_join (categories, by = c ("series.code")) %>%
   left_join(CS, by = c("series.code", "iso3c")) %>%
   left_join(CS_objectives, by = c("iso3c")) %>%
   
   #filter out countries outside of selectivity
   filter (cluster %in% 1:4) %>%
   select(-country) %>%
   unique()


###########################################
###########################################
#saving indicadicators

indicators <- df %>%
   select(series.name, series.code, series.description) %>%
   group_by(series.name) %>%
   unique() %>%
   ungroup()

write.csv(indicators, "data_out/TSP/indicators.csv", row.names = FALSE)



