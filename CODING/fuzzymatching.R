install.packages("fuzzyjoin")
install.packages("stringr")
install.packages("dplyr")
install.packages("tidyverse")

#Load Library
library(tidyverse)
library(stringr)
library(fuzzyjoin)
library(dplyr)



### Clean dataframe column names

clean_df_names <- function(df){
  
  # Clean names
  temp_names <-
    names(df) %>%
    str_trim() %>%
    tolower() %>%
    # Replace one or more spaces or a period with an underscore
    str_replace_all(' +|\\.+', '_') %>%
    # Remove all non-alphanumerics (except underscore)
    str_replace_all('[^a-zA-Z0-9_]', '')
  
  names(df) <-
    temp_names
  
  return(df)
  
}


### Load data

data <-
  read_csv('data.csv') %>%
  clean_df_names() %>%
  # Distance calculation are based on UTF-8 characters, so make sure string is converted
  mutate(tag = iconv(tag, 'latin1', 'UTF-8', sub = ''))

search_df <-
  read_csv('search_terms.csv') %>%
  select(-X1) %>%
  clean_df_names() %>%
  # Distance calculation are based on UTF-8 characters, so make sure string is converted
  mutate(search_term = iconv(search_term, 'latin1', 'UTF-8', sub = ''))


### Join data
data_tags <-
  taxon %>%
  select(tag) %>%
  unique() %>%
  stringdist_left_join(search_df, by = c('tag' = 'search_term'),
                       max_dist = 0.1,  method = 'jw',
                       distance_col = 'distance') %>%
  select(tag, search_term, distance, everything())

write_csv(data_tags, 'data_tagged_fuzzymatching.csv')
