
growth_accounting <- function(file, base_year, steady_state, fixed_capital, depreciation, income_share, output_name){
  
  # Read the stata file and filter by base year
  df <-
    read.dta13(file) %>%
    filter(year >= base_year)
  
  # Calculate average steady_state growth rates by country
  growth_rates <-
    df %>%
    group_by(countryname) %>%
    arrange(year) %>%
    slice(1:steady_state) %>%
    ungroup() %>%
    mutate(lgfk = log(gfk)) %>%
    mutate(dgfk = lgfk - lag(lgfk)) %>%
    group_by(countryname) %>%
    summarize(g = mean(dgfk, na.rm = TRUE))
  
  # Join growth rates to main data frame
  df <-
    df %>%
    left_join(growth_rates, by = 'countryname') %>%
    arrange(countryname, year)
  
  
  
  #### Calculate I
  
  df$I <- rep(0, nrow(df))
  
  for(i in 1:nrow(df)){
    
    # Calculate I0
    if(df$year[i] == base_year){
      df$I[i] <- mean(df$gfk[i:(i + fixed_capital - 1)], na.rm = TRUE)
    }
    
    # Calculate It
    else{
      df$I[i] <- df$gfk[i]
    }
    
  }
  
  
  
  #### Create combinations for depreciation
  
  # This creates a data frame for each value of depreciation, puts them in a list and collapses them into a single df
  
  ls <- list()
  
  for(i in 1:length(depreciation)){
    
    temp <- df
    temp$delta <- depreciation[i]
    ls[[i]] <- temp
    
  }
  
  df <- bind_rows(ls)
  
  
  
  #### Calculate K
  
  df$K <- rep(0, nrow(df))
  
  for(i in 1:nrow(df)){
    
    # Calculate K0
    if(df$year[i] == base_year){
      df$K[i] <- df$I[i] * (df$g[i] + df$delta[i])
    }
    
    # Calculate Kt
    else{
      df$K[i] <- df$K[i - 1] * (1 - df$delta[i]) + df$I[i]
    }
    
  }
  
  
  
  #### Calculate logs, growth rates and returns to education
  
  df <-
    df %>%
    
    # logs
    mutate(lgdp = log(gdp),
           lpop1564 = log(pop1564),
           lK = log(K),
           lyears_sch = log(years_sch)) %>%
    
    # growth rates
    mutate(dlgdp = lgdp - lag(lgdp),
           dlpop1564 = lpop1564 - lag(lpop1564),
           dlK = lK - lag(lK),
           dlyears_sch = lyears_sch - lag(lyears_sch)) %>%
    
    # calculate returns to education
    mutate(red = dlgdp / years_sch)
  
  
  
  #### Create combinations for alpha (same logic as for delta)
  
  ls <- list()
  
  for(i in 1:length(income_share)){
    
    temp <- df
    temp$alpha <- income_share[i]
    ls[[i]] <- temp
    
  }
  
  df <- bind_rows(ls)
  
  
  
  #### Calculate TPF and TFPH
  
  df <-
    df %>%
    mutate(TFP = dlgdp - (alpha * dlK) - ((1 - alpha) * dlpop1564),
           TFPH = dlgdp - (alpha * dlK) - ((1 - alpha) * dlpop1564) - ((1 - alpha) * red * dlyears_sch))
  
  
  
  #### Write out results
  
  write.csv(df, output_name, row.names = FALSE, na = '0')
  
}