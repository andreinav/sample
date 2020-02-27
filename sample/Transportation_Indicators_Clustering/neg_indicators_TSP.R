message("Defining a list of indicators that are negative for development...")


##option 1: apply multiplier before normalization

##TSP
##SH.STA.TRAF.P5: Mortality caused by road traffic injury (per 100,000 people)	
##NA_motorization rate Motorization rate (/1000 inh.)
##EN.CO2.TRAN.ZS: CO2 emissions from transport (% of total fuel combustion)

negative_ind <- c("SH.STA.TRAF.P5",
                  "NA_motorization.rate",
                  "EN.CO2.TRAN.ZS")