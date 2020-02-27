message("Please wait. Downloading indicators from the WDI using their API...")

#download indicators from World Bank Development Indicators

wb_indicators <-  WDI (indicator = ind, 
                    country = countries, 
                    extra = TRUE,
                    start=2005,
                    end=2015)






