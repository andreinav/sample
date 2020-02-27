

message("Creating a list of indicators and countries required for API download...")

#create lists with indicator names and countries for TSP and ENE

countries <- c("AU",
               "AT",
               "BE",
               "CA",
               "DK",
               "FI",
               "FR",
               "DE",
               "IS",
               "IL",
               "IT",
               "JP",
               "KR",
               "NL",
               "NO",
               "SI",
               "ES",
               "SE",
               "CH",
               "GB",
               "US",
               "PT",
               "CZ",
               "EE",
               "GR",
               "PL",
               "PT",
               "HU",
               "SK",
               "TR",
               'AR', 
               'BB', 
               "BS",
               'BZ', 
               'BO', 
               'BR', 
               'CL', 
               'CO',
               'CR', 
               'DO', 
               'EC', 
               'SV', 
               'GT', 
               'GY', 
               'HT', 
               'HN', 
               'JM', 
               'MX', 
               'NI', 
               'PE', 
               'PA', 
               'PY', 
               'UY',
               'VE',
               'SR')

ind <- c(#world bank data
   "EN.CO2.TRAN.ZS",
   #"IS.SHP.GCNW.XQ", shipping connectivity was removed due to sector specialists advice
   "SH.STA.TRAF.P5")
   #"SP.URB.TOTL.IN.ZS", urb. pop was removed due to sector specialists advice

