# This code is a demonstration of basic clustering and an example more advanced optmized methods


###########################
# 1 - Load required libraries
###########################

require(scatterplot3d)
require(rgl)
library(cluster)
library(ISLR)
library(dplyr)
library(ggplot2)
library(tidyr)


###########################
# 2 - Explore iris data
###########################


##load data

gdp <- read.csv("~/Andreina/cluster/GDP.csv", stringsAsFactors = FALSE) 

countries <- c()

gdp_long <-  GDP %>%
  gather ("year", "GDPppp", 5:length(GDP)) 


head(GDP)
table(GDP$Country.Code)




###########################
# 3 - K-Means
###########################

### Create new dataset
gdp1 <-
  GDP_long %>%
  select(Country.Name,
         GDPppp,
         year) %>%
  mutate(GDPppp = as.numeric(GDPppp)) %>%
  filter(!is.na (GDPppp)) 


### Run K-Means cluter
set.seed(100)

fit1 <- kmeans(gdp1 %>% 
                 select(GDPppp), 4)
fit1


### Add cluster numbers to dataset
gdp1$cluster <- fit1$cluster

gdp2 <- gdp1 %>%
  group_by(cluster) %>%
  summarise(val = mean (GDPppp)) %>%
  arrange(val) %>%
  mutate(order = 1: n()) %>%
  select(-val)
  
gdp1 <- gdp1 %>%
  left_join(gdp2, by ="cluster")

### Plot data coloring the data points with their cluster number
gdp1 %>%
  ggplot(aes(x = GDPppp, y = GDPppp, color = factor(order))) +
  geom_jitter(width = 1000,
              height = 1000, alpha = .2, size = 3) +
  facet_wrap(~ Country.Name)


### Let's try with 3 variables
iris2 <-
  iris %>%
  select(Sepal.Length, Sepal.Width, Petal.Length)

fit2 <- kmeans(iris2, 4)

iris2$cluster <- fit2$cluster

attach(iris2)
plot3d(Sepal.Length, Sepal.Width, Petal.Length, col = cluster, size = 8)
detach(iris2)



###########################
# 4 - Agglomerative
###########################

### Calculate distance between points - distance matrix between all points
d <- dist(gdp1, method = 'euclidean')
str(d)
head(as.matrix(d))

### Run Agglomerative cluster
fit3 <- hclust(d)
fit3

### Plot Dendrogram
plot(fit3)

# Visualize clusters
rect.hclust(fit3, k = 4, border = 'red')




###################################
# 5 - Mixed data types and optimizing cluster selection
###################################

# Example from: https://www.r-bloggers.com/clustering-mixed-data-types-in-r/
# Recomended to see the entire example with full explanation

### Get data, transform and clean
### Calculate (dissimilarity)
### Gower distance allows for mixed data types
### Here are a good explanation of different distant methods and how they compare to Gower
### https://stat.ethz.ch/education/semesters/ss2012/ams/slides/v4.2.pdf
### http://www.clustan.talktalk.net/gower_similarity.html
gower_dist <- daisy(gdp1[, -1],
                    metric = 'gower',
                    type = list(logratio = 3)) # Scales values appropriately

str(gower_dist) # How dissimilar an observation is from another
hist(gower_dist)


### Run k-medoids algorithm with pam
### http://www.math.le.ac.uk/people/ag153/homepage/KmeansKmedoids/Kmeans_Kmedoids.html
### https://en.wikipedia.org/wiki/K-medoids
### Calculate silhouette width for many k using PAM
### Silhouette width: internal validation metric which is an aggregated measure of how similar an observation is to its own cluster compared to its closest neighboring cluster. The metric can range from -1 to 1, where higher values are better.

#sil_width <- c(NA)
sil_width <- rep(NA, 9)

for(i in 2:8){
  
  pam_fit <- pam(gower_dist,
                 diss = TRUE,
                 k = i)
  
  sil_width[i - 1] <- pam_fit$silinfo$avg.width
  
}


### Plot sihouette width (higher is better)
plot(1:9, sil_width,
     xlab = 'Number of clusters',
     ylab = 'Silhouette Width')
lines(1:9, sil_width)


### Run clustering after choosing k with highest silhouette width
pam_fit <- pam(gower_dist, diss = TRUE, k = 2)

# Join data
pam_results <- gdp1 %>%
  mutate(cluster = pam_fit$clustering)



saveRDS(gdp1, 'C:/Users/Andreina/Desktop/gdp.rds')



gdp1 %>%
  ggplot(aes(x = GDPppp)) +
  geom_histogram(bins = 80)




### Calculate distance between points - distance matrix between all points
d <- dist(gdp1 %>%
            select(GDPppp), method = 'euclidean')
str(d)
head(as.matrix(d))

### Run Agglomerative cluster
fit3 <- hclust(d)
fit3

### Plot Dendrogram
plot(fit3)


