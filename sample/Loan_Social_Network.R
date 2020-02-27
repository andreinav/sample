#Load library
library(igraph)
library(qgraph)

#Set working directory
setwd('/Users/nectaryyo/Desktop/GW/Topics/Network_Analysis/igraph') 

SN <- read.csv('SocialNetwork-LON.csv', stringsAsFactors = FALSE)

# Includes OpNum and all Team Members - 9:13 for team members 9:27 for all
SN2 <- SN[, c(1, 9:27)] 

# Creates a blank list to store the dataframes created in the loop
ls <- list() 

# The loop takes each line of data (a single project) an creates a data frame with 2 columns
        # The project number, just created by repeating it the length of the data - 1 (to remove the project column)
        # The team member, transposing the data exluding the porject number
# All NAs and missing empty rows are deleted
# Then the team leader column is created by taking the first element of the team members and repeating it
# A data frame is created for each project and stored as an element of the ls list

for(i in 1:nrow(SN2)){
        Proj = rep(SN2[i,1], ncol(SN2) - 1)
        TM = as.character(as.vector(SN2[i,-1]))
        df <- data.frame(Proj, TM)
        df1 <- df[df$TM != 'NA' & df$TM != '',] 
        df1$TL <- rep(df1[1, 2], nrow(df1))
        ls[[i]] <- df1
}

# Collapse list into single data frame
collapsed <- as.data.frame(do.call('rbind', ls)) 

# Remove repeated rows
collapsed <- unique(collapsed) 

# Remove rows where TL is the same as TM
collapsed <- collapsed[collapsed$TM != collapsed$TL, ] 

# Converts all columns from factors to string
collapsed[, c('Proj', 'TL', 'TM')] <- sapply(collapsed[, c('Proj', 'TL', 'TM')], as.character) 


######## Create a clean data frame that to be converted to a graph object #########

# Drops project number
clean <- collapsed[2:3] 

# Drops repeated links (is a team leader worked multiple times with a same team member)
clean <- unique(test) 

# Names columns for graph element
names(clean) <- c('from', 'to') 

# Converst from factor to string
clean[, c('from', 'to')] <- sapply(clean[, c('from', 'to')], as.character) 

### Graph with all connections

# Graph elemente needs a matrix
m <- as.matrix(clean) 

# Creates a graph element
g <- graph.edgelist(m, directed = FALSE) 

# Plots graph element
plot.igraph(g, vertex.size = 1,
            layout = layout.fruchterman.reingold(g,niter=300,
                                                 area = vcount(g)^1.5,
                                                 repulserad=vcount(g)^15),
                                                  edge.width = 1) 

### Graph with selection

# Counts the number of links per team leader through a table that is converted to a data frame
counts <- as.data.frame(table(clean$from), stringsAsFactors = FALSE) 

# Names columns for join
names(counts) <- c('from', 'freq') 

# Joins the counts df to the main data frame by 'from'
clean_wc <- merge(x = clean, y = counts, by = "from", all.x=TRUE) 

## Select break
# Drops team leaders that have less than x amount of links
clean_wc2 <- clean_wc[clean_wc$freq > 35, ] 

# Create Matrix
m <- as.matrix(clean_wc2[1:2])
g <- graph.edgelist(m, directed = FALSE)
plot.igraph(g, vertex.size = 1, vertex.label = NA, layout = layout.fruchterman.reingold(g,niter=300,area = vcount(g)^1.5,repulserad=vcount(g)^15), edge.width = .3)
plot.igraph(g, vertex.size = 1, layout = layout.fruchterman.reingold(g,niter=300,area = vcount(g)^1.5,repulserad=vcount(g)^15), edge.width = .3)

#graph
qgraph(g, edge.labels = TRUE)
