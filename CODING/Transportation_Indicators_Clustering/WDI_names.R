message("Please be patient.Downloading all the indicators available in the WDI databases...")
message("Please find below the 7 dataframes available from the WDI...")

##download indicator names from the WB
#detach("package: wbstats", unload=TRUE)

#indicator names
str(wb_cachelist, max.level = 1)

indicators_names <- wb_cachelist$indicators %>%
   rename (series.code = indicatorID)

write.csv (indicators_names, "data_in/wb_indicators_names.csv", row.names = FALSE)
