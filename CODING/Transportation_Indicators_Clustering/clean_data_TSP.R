
message("Running script that cleans the dataframes...")

#load datasets
#load data with region information

region <- read.csv("data_in/region_data.csv",
                   stringsAsFactors = FALSE) %>%
   
   rename (iso3c = country.code) 

#####################################################
#####################################################
#####################################################

#load data with cluster information
cluster <- read.csv("data_in/cluster_data.csv",
                    stringsAsFactors = FALSE) %>%
   rename (year_cluster = year)

#####################################################
#####################################################
#####################################################

#country strategy information

CS <- read.csv("data_in/TSP/CS.csv",
               stringsAsFactors = FALSE) %>%
   
   gather("series.code",
          "CS_priority",
          2:8)


#country strategy description of objectives
CS_objectives <- read.csv ("data_in/TSP/CS_text_objectives.csv", 
                           stringsAsFactors = FALSE) %>%
   
   gather("objective_number",
          "description",
          objective.1: objective.3)





#####################################################
#####################################################
#####################################################

#load indicator names
#indicators_names <- read.csv('data_in/wb_indicators_names.csv', stringsAsFactors = FALSE)

#conver from wide to long form and add names of indicators
wb_long <- 
   
   wb_indicators %>%
   
   select (iso2c : iso3c) %>%
   
   gather ("series.code", "value", EN.CO2.TRAN.ZS: SH.STA.TRAF.P5) %>%
   
   mutate (source = "WDI") %>%
   
   select(-iso2c) %>%
   
   left_join(indicators_names, by = c("series.code")) %>%
   
   filter(!is.na(value)) %>%
   
   rename (source = sourceOrg) %>%
   
   rename (series.name = indicator) %>%
   
   rename(series.description = indicatorDesc) %>%
   
   #select variables of interest
   select(country,
          iso3c,
          year,
          series.code,
          series.name,
          value,
          source,
          series.description)


#####################################################
#####################################################
#####################################################
#load motorized data

moto <- read.csv ("data_in/TSP/motorization rate.csv", 
                  stringsAsFactors = FALSE) %>%
   
   gather ("year", "value",3:4) %>%
   
   mutate (year = as.numeric (gsub ("X","", year))) %>%
   select (-country) %>%
   
   rename (iso3c = country.code) %>%
   
   mutate (source = "OICA") %>%
   
   mutate(series.name = "Motorization rate (/1000 inh.)") %>%
   
   mutate (series.code = "NA_motorization.rate") %>%
   
   mutate(series.description = "Vehicles in use are composed of all registered vehicles on the road. To calculate the motorization rate, population data published by the United Nations. Estimations created by OICA")

#####################################################
#####################################################
#####################################################
#wb_indicators <- read.csv("data_in/wb_indicators.csv", stringsAsFactors = FALSE)

#urban_motorization_rate<- 
#   wb_indicators %>%
#   select( iso3c, year, SP.URB.TOTL.IN.ZS) %>%
#   group_by (year, iso3c) %>%
#   left_join (moto, by = c("year", "iso3c")) %>%
#   mutate( urban_motorization_rate =  value/SP.URB.TOTL.IN.ZS) %>%
#   mutate (categories = "urban motorization rate") %>%
#   mutate (series.code = "Motorization/ SP.URB.TOTL.IN.ZS") %>%
#   mutate (series.name = "Motorization rate of urban population, constructed") %>%
#   mutate (source = "IIC/DSP") %>%
#   filter (!is.na (urban_motorization_rate) ) %>%
#   ungroup() %>%
#   select (iso3c, year, categories, source, urban_motorization_rate, series.code)


#####################################################
#####################################################
#####################################################

##load data infrastructure vulnerability
#infra_vul <- read.csv ("data_in/infra_vulnerability.csv", stringsAsFactors = FALSE) %>%
#   rename (iso3c = ISO3) %>%
#   select(-Name) %>%
#   gather ("year", "value", 2:22) %>%
#   mutate (year = as.numeric (gsub ("X","", year))) %>%
#   filter (year >=2010) %>%
#   mutate (categories = "sustainability_adaptation") %>%
#   mutate (source = "ND-GAIN") %>%
#   mutate (series.name = "Infrastructure Vulnerability (0-1)")


#####################################################
#####################################################
#####################################################

library(stringi)
library(dplyr)
library(tidyr)
#load WEF indicators

WEF <- read.csv ("data_in/TSP/WEF_17_18.csv", stringsAsFactors = FALSE) %>%
   select (-Series.unindented,
           -Placement,
           -Dataset,
           -Code.GCR) %>%
   
   #rename
   rename (series.code = GLOBAL.ID) %>%
   
   rename(series.name = Series) %>%
   
   #filter out source in attribute variable
   filter (Attribute != "Source") %>%
   
   filter (Attribute != "Source date") %>%
   
   filter (Attribute != "Period") %>%
   
   filter (Attribute != "Note") %>%
   
   filter (Attribute != "Rank") %>%
   
   filter (grepl("EOSQ061", series.code)) %>% 
   
   filter (Edition == "2017-2018") %>%
   
 
   
   #reshape data
   gather ("iso3c", "value", ALB:ZWE)  %>%
   
   mutate (value = as.numeric (value)) %>%
   
   mutate( year = as.numeric (stri_sub (Edition, 1,4))) %>%
   
   select(-Edition,
          -Attribute) %>%
   
   mutate (source = "WEF") %>%
   
   mutate(series.description = "World Economic Forum perseption index from the Global Competitiveness Report")


#####################################################
#####################################################
#####################################################

road_den <-  read.csv ("data_in/TSP/road_density_TSP.csv", stringsAsFactors = FALSE) 

road_den <-  road_den %>%
   
   select(iso3c:value) %>%
   
   mutate (series.code = "IFR_road_density")  %>%
   
   mutate (series.name = "Density (Km. Roads / Km2 land area)") %>%
   
   mutate (source = "IDB Transport") %>%
   
   mutate(series.description = "Density (Km. Roads / Km2 land area), varies by country according to TSP-IDB database")


#####################################################
#####################################################
#####################################################

#data from paved roads for quality

paved_road <- read.csv ("data_in/TSP/paved_road_indicator.csv", 
                        stringsAsFactors = FALSE) %>%
   select(-country) %>%
   
   mutate (series.code = "IS.ROD.PAVE.ZS") %>%
   
   mutate(series.description = " percentage of paved roads,varies by country according to TSP-IDB database")

names(paved_road) <- tolower(names(paved_road)) 

#####################################################
#####################################################
#####################################################
#####################################################

categories <- read.csv ("data_in/TSP/categories_TSP.csv", 
                        stringsAsFactors = FALSE) %>% 
   select(-series.name)

#####################################################
#####################################################
#####################################################
#####################################################
#data shipping IDB

key <- read.csv("data_in/country_key.csv", stringsAsFactors = FALSE)

shipping <- read.csv("data_in/TSP/technical_efficiency_shipping_2015.csv", 
                     stringsAsFactors = FALSE) %>% 
   
   select(port:X2010) %>%
   
   gather ("year", "value", starts_with("X"))  %>%
   
   mutate (year = as.numeric (gsub ("X","", year))) %>%
   
   mutate (value = gsub("%","", value)) %>%
   
   mutate (value = as.numeric(value)) %>%
   
   filter(!is.na(value)) %>%
   
   distinct() %>%
   
   group_by (port) %>%
   
   arrange (desc (year)) %>%
   
   mutate (max_year = max(year)) %>%
   
   filter (year == max_year) %>%
   
   ungroup() %>%
   
   group_by(country) %>%
   
   mutate(value_average = mean(value)) %>%
   
   select(-value) %>%
   
   mutate(value = value_average) %>%
   
   select(country,
          year,
          value) %>%
   
   mutate(series.name = "technical efficiency of ports (%)") %>%
   
   mutate (series.code = "NA_ports") %>%
   
   mutate (source = "IDB_TSP") %>%
   
   ungroup() %>%
   
   left_join(key, by = "country") %>%
   
   select(-country) %>%
   
   filter(!is.na(iso3c)) %>%

   mutate(series.description = " Stochastic Frontier Analysis (SFA). The model consists of an estimation of a production function for container terminals, in which cranes, berths, and terminal area are the inputs, and port container throughput is the output. As a result, time-varying technical efficiency is calculated as part of the residual term, conditional on a set of independent variables. The results provide a guideline for understanding technical efficiency's explanatory factors and trends across time, sub-regions, and countries")

#####################################################
#####################################################
#####################################################
#####################################################
