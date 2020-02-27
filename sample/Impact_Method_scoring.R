install.packages("stringr")
install.packages("dplyr")
install.packages("readr")
install.packages("readxl")
install.packages("tidyr")
#
#
library(dplyr)
library(readr)
library(tidyr)
library(readxl)
library(stringr)

source("J:/CSU & CSDR/01_CSDRs/CSDR_code/CSDRs/2019/code/function.R")

##set working directory
setwd("J:/CSU & CSDR/01_CSDRs/CSDR 2020/2. data")


####################
# Load data
####################

#load TC and PO scores

TC_PO_Scoring <- read_excel("qualitative/TC Mapping/TC_PO_Scoring.xlsx") %>%
  select (ISO3,
          `GLOBAL ID`,
          `CS Start Year`,
          yeartoyear_score,
          cummulative_score,
          source) %>%
  mutate (`CS Start Year`= as.character(`CS Start Year`))


CS_MASTER <- read_excel("J:/Results Framework (5-6)/Data Reference Files/CS_Pri_Obj_Ind_COI_TIGenOBJ_Sep232019.xlsm",  skip = 1) %>%
  filter (Status == "active") %>%
  select (ID,
          ISO3,
          TYPE,
          `Description of level`,
          `CSDR Indicator Name`,
          Priority,
          `Objective ID`,
          `GLOBAL ID`,
          Type_indicator,
          `CS Start Year`) %>%
  #rename (`GLOBAL ID` = `Global ID`) %>%
  filter (TYPE == "Indicator") 


CS_year <- read_excel("J:/Results Framework (5-6)/Data Reference Files/CS_Pri_Obj_Ind_COI_TIGenOBJ_Sep232019.xlsm",  skip = 1) %>%
  filter (Status == "active") %>%
  select (ISO3,
          `CS Start Year`) %>%
  unique()


REG_sample2020 <- read_excel("J:/CSU & CSDR/01_CSDRs/CSDR_code/CSDRs/2019/data_in/REG_sample2020.xlsx") %>%
  
  mutate (`Op Id` = as.character(`Op Id`)) %>%
  
  unique()


TIMS_rating <- read_excel("J:/CSU & CSDR/01_CSDRs/CSDR_code/CSDRs/2019/data_in/CSDR Rating.xlsx") %>%
  
  rename (`Op Id` = `Operation ID`) %>%
  
  mutate (`Op Id` = as.character(`Op Id`)) %>%
  
  mutate (`Benchmark ID` = as.character(`Benchmark ID`)) %>%
  
  mutate (ID_OP = paste (`Op Id`,`Benchmark ID`, sep = "_")) %>%
  
  select (-`Meeting Date Current`) %>%
  
  group_by (`Op Id`, `Benchmark ID`, Year) %>%
  
  mutate (i = paste (`Op Id`, `Benchmark ID`, Year, sep ="/")) %>%
  
  #mutate (check = duplicated(i, incomparables = FALSE))
  
  distinct (i, .keep_all = TRUE) %>%
  
  ungroup(`Op Id`, `Benchmark ID`, year) %>%
  
  #group_by ()
  #group_by(i) %>%
  
  spread(Year, `Benchmark Rating`, sep = "_") %>%
  
  select (-i) %>%
  
  rename_at (.vars = vars(contains("Year")), 
             .funs = str_replace, pattern = "Year", replacement = "rating") %>%
  
  ungroup() 
  



#load DF TIMS
TIMS_mapping <- read_csv("J:/CSU & CSDR/01_CSDRs/Historical Data/TIMS mapping/TIMSMAPPING_2017_2019.csv") %>%
  
  mutate (`Op Id` = as.character(`Op Id`))  %>%
  
  mutate (`Benchmark ID` = as.character (`Benchmark ID`)) %>%
  
  mutate (ID_OP = paste (`Op Id`,`Benchmark ID`, sep = "_")) %>%
  
  distinct(ID_OP, .keep_all = TRUE)


sample<- read_csv("J:/CSU & CSDR/01_CSDRs/CSDR_code/CSDRs/2019/data_out/sample2020.csv") %>%
  
  mutate (`Op Id` = as.character(`Op Id`)) %>%
  
  select (`Op Id`,
          `Op Signing Date`,
          #ID,
          #Type,
          Country,
          ISO3,
          #`CS start year`,
          #`Description of level`,
          #sampleCSDR,
          `Current Impact`,
          year_meeting_date,
          ABI_tranch,
          ReviewQ4)


####################
# Create a single database with: 
# TIMS mapping and TIMS rating
####################


temp <- sample %>%
  
  #filter (ISO3 == "POL") %>%
  
  left_join (REG_sample2020) %>%
  mutate (ISO3 = ifelse (ISO3 == "REG", 
                         ISO32, ISO3)) %>%
  left_join (TIMS_rating) %>%
  left_join (TIMS_mapping) %>%
  
  mutate (year_meeting_date = ifelse (Country == "Regional", 
                                      "not applicable", year_meeting_date)) %>%

  mutate (SOURCE = "TIMS") %>%
  distinct(`Op Id`, `GLOBAL ID`, .keep_all = TRUE) %>%
  
  select (`Op Id`,
          `Op Signing Date`,
          #ID,
          #Type,
          Country,
          ISO3,
          #`CS start year`,
          #`Description of level`,
          ID_OP,
          `GLOBAL ID`,
          `Benchmark ID`,
          contains("rating"),
          `Current Impact`,
          SOURCE) %>%
  
  ##remove the wrong GLOBAL IDs
  
  filter(`GLOBAL ID` != "CO2") %>%
  filter(`GLOBAL ID` != "ASBPROD") %>%
  filter(`GLOBAL ID` != "EELOANSVOL") %>%
  filter(`GLOBAL ID` != "ENERGYRENEW") %>%
  filter(`GLOBAL ID` != "ENERGYSAV") %>%
  filter(`GLOBAL ID` != "PPLMCPINFRA") %>%
  filter(`GLOBAL ID` != "SMEALL") %>%
  filter(`GLOBAL ID` != "SMEFIN") %>%
  filter(`GLOBAL ID` != "TFP") 


#####################################
# Generate a database with the OPS
# that have missing GLOBAL ID
#####################################

df_missing_mappingOPS <- temp %>%
  
  filter(is.na(`GLOBAL ID`)) %>%
  
  distinct(`Op Id`,
           ISO3) 

temp2 <- temp %>%
  group_by(`GLOBAL ID`, ISO3) %>%
  unique() 

#CSDR_IDs_OPS <-  CS_MASTER %>%
# left_join (temp2)

#####################################
# Generate a database for TIMS
#####################################

df <- temp %>% 
  
  filter(!is.na(`GLOBAL ID`)) %>%

  
  #filter (ISO3 == "BGR") %>%
  #filter (`GLOBAL ID` == "PFIFINRATIO") %>% #
  #filter (`Benchmark ID` == 34894) %>%
  
  ##convert vars to numeric categorical variables to numeric
  mutate (bench_2013_num = transf(rating_2013, 2013)) %>%
  mutate (bench_2014_num = transf(rating_2014, 2014)) %>%
  mutate (bench_2015_num = transf(rating_2015, 2015)) %>%
  mutate (bench_2016_num = transf(rating_2016, 2016)) %>%
  mutate (bench_2017_num = transf(rating_2017, 2017)) %>%
  mutate (bench_2018_num = transf(rating_2018, 2018)) %>%
  mutate (bench_2019_num = transf(rating_2019, 2019)) %>%
  
  
  ##if 2019 has NA but there is a value in previous years, keep NA
  mutate (test =  ifelse (is.na(bench_2018_num) 
                          &  is.na (bench_2019_num) , NA , "ignore" )) %>%
  
  #filter (is.na(test)) %>%
  
  mutate (status_TIMS = ifelse (is.na(test) &
                            !is.na(bench_2016_num),
                          "completed operation", 
                          ifelse(is.na(test) &
                                   !is.na(bench_2015_num),
                                 "completed operation",
                                 ifelse(is.na(test) &
                                          !is.na(bench_2014_num),
                                        "completed operation",
                                        ifelse(is.na(test) &
                                                 !is.na(bench_2013_num),
                                               "completed operation",
                                               ifelse(is.na(test) &
!is.na(bench_2017_num),
"completed operation",
"active operation")))))) %>%
  
  
#####Condition 1 :   
##if both 2018 and 2019 have NA replace with 2 if it is an active operation
##if it is a completed operation, then keep NA as per instruction to receive not relevant

#for active operations
mutate (bench_2018_num =  ifelse (is.na(bench_2018_num) & 
is.na(bench_2019_num) &
status_TIMS == "active operation",
2,
bench_2018_num)) %>%
  
mutate (bench_2019_num =  ifelse (is.na(bench_2018_num) & 
is.na(bench_2019_num)&
status_TIMS == "active operation",
2, 
bench_2019_num)) %>%
 
###ignore code   
#    #for completed operations
#mutate (bench_2018_num =  
#ifelse (is.na(bench_2018_num) & 
#is.na(bench_2019_num) &
#status_TIMS == "completed operation", 
#2,
#bench_2018_num )) %>%
#  
#mutate (bench_2019_num =  
#ifelse (is.na(bench_2018_num) & 
#is.na(bench_2019_num) &
#status_TIMS == "completed operation", 
#2,
#bench_2019_num)) %>%
  
  
#########################################################################
#####Condition 2: 
##if there is a value for 2019 but NA in 2018, replace 2018 with 2
  
mutate (bench_2018_num =  ifelse (!is.na(bench_2019_num) &
                                  is.na(bench_2018_num), 2,
                                  bench_2018_num)) %>%

#####Condition 3: 
##if 2019 has a value but 2018 is NA and all before is NA then replace 2018 with 2

mutate (bench_2018_num =  ifelse (!is.na(bench_2019_num) 
                                    &  is.na(bench_2017_num) 
                                    &  is.na(bench_2016_num) 
                                    &  is.na(bench_2015_num) 
                                    &  is.na(bench_2014_num)
                                    &  is.na(bench_2013_num) 
                                    &  is.na(bench_2018_num), 2,
                                    bench_2018_num )) %>%

##Condition 4:
##if 2018 has a value different that 2 AND 2019 is NA, there is a mistake in the data. replace 2019 with value of 2018
  mutate (bench_2019_num =  ifelse (bench_2018_num != 2 
                                    &  is.na(bench_2019_num),
                                    bench_2018_num , bench_2019_num )) %>%


  #convert Board Impact to Numeric variable
  mutate (`TI potential` = transTI(`Current Impact`)) %>%
  
  #create average of each year by project ID and GLOBAL ID
  group_by (`Op Id`, `GLOBAL ID`) %>%
  
  
  #create simple averages at the operation ID level and GLOBAL ID
  

  mutate (bench_2013_ave = round (mean (bench_2013_num, na.rm=TRUE), 2)) %>%
  mutate (bench_2014_ave = round (mean (bench_2014_num, na.rm=TRUE), 2)) %>%
  mutate (bench_2015_ave = round (mean (bench_2015_num, na.rm=TRUE), 2)) %>%
  mutate (bench_2016_ave = round (mean (bench_2016_num, na.rm=TRUE), 2)) %>%
  mutate (bench_2017_ave = round (mean (bench_2017_num, na.rm=TRUE), 2)) %>%
  mutate (bench_2018_ave = round (mean (bench_2018_num, na.rm=TRUE), 2)) %>%
  mutate (bench_2019_ave = round (mean (bench_2019_num, na.rm=TRUE), 2)) %>%
  
  
  #create cummulative assessment that uses the respective weights (TI potential 5 level score)
  
  mutate (value_2019 = (bench_2019_ave* `TI potential`)) %>%
  mutate (value_2013 = (bench_2013_ave* `TI potential`)) %>%
  mutate (value_2014 = (bench_2014_ave* `TI potential`)) %>%
  mutate (value_2015 = (bench_2015_ave* `TI potential`)) %>%
  mutate (value_2016 = (bench_2016_ave * `TI potential`)) %>%
  mutate (value_2017 =  (bench_2017_ave * `TI potential`))  %>%
  mutate (value_2018 = (bench_2018_ave * `TI potential`))  %>%
  ungroup() %>%
  
  #select only variables of interest
  select (ISO3,
          `Op Id`,
          `Benchmark ID`,
          `GLOBAL ID`,
          value_2019,
          value_2013,
          value_2014,
          value_2015,
          value_2016,
          value_2017,
          value_2018,
          `TI potential`,
          #`CS start year`,
          `TI potential`,
          SOURCE) %>%
  
  #remove duplicables.
  #distinct(`GLOBAL ID`, `Operation ID`, `Benchmark ID`, `ISO3`, .keep_all = T) %>%
  
  #group by Operation ID and GLOBAL ID
  group_by (`GLOBAL ID`, `Op Id`) %>%
  
  #create the differences by year (T)- (T-1)
  mutate (temp_diff= as.numeric(value_2019 - value_2018)) %>%
  ungroup() %>%
  
  ##replace NA with 0
  mutate (temp_diff = ifelse (is.na(value_2019), 0, temp_diff )) %>%
  
  #group by GLOBAL ID and ISO3 to create simple averages
  group_by (`GLOBAL ID`, ISO3) %>%
  
  #keep unique values
  distinct(`GLOBAL ID`, `Op Id`, `ISO3`, .keep_all = T)  %>%
  
  #calculate the mean of year-to-year within a country
  mutate (score_diff = round (mean (temp_diff, na.omit = TRUE),2)) %>%
  
  ungroup()



#####################################
# Generate a database with 
# the cummulative score
#####################################

df_cumm <- df %>%
  
  ##convert to long form
  gather("year_bench", "value", 5:11) %>%
    
  left_join(CS_year) %>%
    
    
  ########################################################
  #test#
  #filter (ISO3 == "ARM") %>%
  #filter (`GLOBAL ID` == "INFRAQUALITY") %>%
  ########################################################
  
  mutate (year = as.numeric(str_replace(year_bench, "value_", ""))) %>%
  
  #create a marker that tells uS if the year of the benchmark is > = to the year   of the CS start
  mutate (marker_year = ifelse (year >= `CS Start Year`, 1,0)) %>%
  
  #only keep benchmarks for the years that are > = to the CS
  filter (marker_year == 1) %>%
  
  ##select only variables of interest
  #select (ISO3,
  #      `Operation ID`,
  #      `TI potential`,
  #      `CS start year`,
  #      SOURCE,
  #      year,
  #      value) %>%
  
  #unique () %>%

#group by global ID and Operation ID
group_by (`GLOBAL ID`, `Op Id`) %>%
  
  #arrange by year
  arrange(year) %>%
  
  #keep the first and last year
  slice (c(1,n())) %>%
  
  #if the value of the benchmark at the start of the CS year is NA, then  replace with 2
  mutate (value2 = ifelse (is.na (value) & `CS Start Year` == year, (2 * `TI potential`), value)) %>%
  
  mutate (value2 = ifelse (is.nan (value2), 0, value2)) %>%
  
  #create cumulative assessments : difference between the max and min
  mutate (temp_cum = (diff(value2))) %>%
  
  
  #if the value of 2019 is NA, then use the most recent value as cumulative
  mutate (temp_cum2 = 
            ifelse (is.nan(temp_cum), value2,
                              ifelse (temp_cum == 0 & `CS Start Year` == "2019",
                                      value2,
                                      temp_cum))) %>%
  #mutate (temp_cum2 = ifelse (is.nan(temp_cum), value2, temp_cum)) %>%
  
  #filter (!is.na(temp_cum2)) %>%
  
  distinct(`GLOBAL ID`, `Op Id`, .keep_all = TRUE) %>%
  
  #finally, you group by GLOBAL ID and ISO3 to create simple averages
  group_by (`GLOBAL ID`, ISO3) %>%
  
  #calculate the mean of cummulative score within a country
  mutate (score_cum = round (mean (temp_cum2,na.rm = TRUE),2)) %>%
  
  #generate variable that indicates if there was any change (hence difference from zero)
  #mutate (anychange = any_change (temp_cum)) %>%
  ungroup() 



#####################################
# Generate a a final database that 
# combines a. y-t-y and cummulative score
#####################################

df_final <- df %>%
  
  left_join (df_cumm) %>%
  
  #generate categories for final scores
  mutate (final_cum = final_score(score_cum)) %>%
  mutate (final_diff = final_score(score_diff)) %>%
  ungroup() %>%
  
  
  
  #remove all rows that have blank in GLOBAL ID
  filter (!is.na(`GLOBAL ID`)) %>%
  
  #mutate (cummulative_score = ifelse (`CS Start Year` == 2019 , 
  #                                     final_diff, final_cum )) %>%
  
  #mutate (final_cum = ifelse (score_cum == 0 & score_diff < 0,
  #                            final_diff, 
  #                            final_cum)) %>%
  
  #select variables of interest
  select (ISO3,
          `GLOBAL ID`,
          `CS Start Year`,
          score_diff,
          score_cum,
          final_diff,
          final_cum) %>%
    
  mutate (source = "TIMS") %>%
    
  rename (cummulative_score = final_cum) %>%
  rename (yeartoyear_score = final_diff) %>%
    
  ##add TC data  
  bind_rows(TC_PO_Scoring) %>%
  
  ##add quantitative data
  
  #remove any duplicates and only keep one row per country
  distinct(`GLOBAL ID`, `ISO3`, .keep_all = T) %>%
  right_join(CS_MASTER) %>%
  select (ID,
          Priority,
          `Objective ID`,
          ISO3,
          `Description of level`,
          `CSDR Indicator Name`,
          `GLOBAL ID`,
          Type_indicator,
          yeartoyear_score,
          cummulative_score,
          source) %>%
  left_join(CS_year) %>%
  filter (Type_indicator == "Qualitative") %>%
  
  unique() %>%
  
  mutate (cummulative_score = ifelse (`CS Start Year` == 2019, 
                                                         yeartoyear_score, 
                                                         cummulative_score))


df_qual <- df_final %>% filter (!is.na (yeartoyear_score)) 

df_missing <- df_final %>%
  filter (is.na (yeartoyear_score))


#save file 
write.csv(df_qual, "qualitative/CSDR_qualitative.csv", row.names = FALSE)

#save file 
write.csv(df_missing, "qualitative/CSDR_qualitative_manual2.csv", row.names = FALSE)

#message
message("TIMS Data has been processed...")

rm(list=ls())


