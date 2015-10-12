library(RMySQL)
library(igraph)
library(dplyr)
library(tidyr)
library(ggplot2)

#### load TwoMode table from SQL -----------------------------------------------

con <- dbConnect(MySQL(), user='root', password ='password', 
                 dbname='GrantsProject')
data <- dbSendQuery(con, "SELECT * FROM TwoMode")
TwoMode <- fetch(data,n=-1)
TwoMode <- tbl_df(TwoMode)
dbClearResult(data)
dbDisconnect(con)

con <- dbConnect(MySQL(), user='root', password ='password', 
                 dbname='GrantsProject')
data <- dbSendQuery(con, "SELECT * FROM YearlyStatistics")
YearlyStatistics <- fetch(data,n=-1)
YearlyStats <- tbl_df(YearlyStatistics)
dbClearResult(data)
dbDisconnect(con)


#### function: generate data.frame of vertex metrics of a graph ----------------

vertMetrics <- function(graph, verts)
{
        metrics <- data.frame(
                Vertices = as.matrix(verts),
                Degree = degree(graph),
                BetCent = betweenness(graph),
                EigCent = evcent(graph)$vector,
                Closeness = closeness(graph),
                Coreness = graph.coreness(graph),
                ClustCoeff = transitivity(graph, type="local"),
                PageRank = page.rank(graph, directed = FALSE)$vector,
                
                stringsAsFactors = FALSE
        )
        metrics <- tbl_df(metrics)
        return(metrics)
}



#### EDGE functions: generate edge pairs from TwoMode table by year -----------

edges.Invest2Invest <-function(endyear, beginyear = 2004)
{
        # we pair investigators that have worked on the same grant for proposals
        # submitted before the input year.
        dataset <- TwoMode
        tm <- filter(dataset, GrantYear <= endyear, GrantYear >=beginyear) %>%
                select(InvestigatorID, InstitutionNumber)
        
        # pair investigators that have the same InstitutionNumber:
        IJ <- inner_join(tm, tm, "InstitutionNumber")
        
        # Currently each pair has a duplicate, so the following process is to
        # eliminate these duplicates where 
        #      (InvestA, InvestB, Instit#) = (InvestB, InvestA, Instit#).
        # We do this by making, for each pair, InvestigatorID1 the larger of the
        # two IDs under the dictionary metric, and InvestigatorID2 the smaller.
        # Then we can specify that we want only distinct rows.
        compare_cols <- select(IJ,
                               InvestigatorID.x,
                               InvestigatorID.y)
        mutate(IJ,
               InvestigatorID1 = apply(compare_cols, 1, max),
               InvestigatorID2 = apply(compare_cols, 1, min)) %>%
        select(InvestigatorID1,
               InvestigatorID2,
               InstitutionNumber) %>%
        distinct()
}



edges.Grant2Grant <-function(endyear, beginyear = 2004)
{
        # we pair grants that share investigators for proposals submitted before
        # the input year.
        dataset <- TwoMode
        tm <- filter(dataset, GrantYear <= endyear, GrantYear >=beginyear) %>%
                select(InstitutionNumber, InvestigatorID)
        
        IJ <- inner_join(tm, tm, "InvestigatorID")
                
        compare_cols <- select(IJ,
                               InstitutionNumber.x,
                               InstitutionNumber.y)
        
        mutate(IJ, 
               InstitutionNumber1 = apply(compare_cols, 1, max),
               InstitutionNumber2 = apply(compare_cols, 1, min)) %>%
        select(InstitutionNumber1,
               InstitutionNumber2,
               InvestigatorID) %>%
        distinct()
}


edges.Dept2Dept <-function(endyear, beginyear = 2004)
{
        # we pair departments if they share a grant for proposals submitted
        # before the input year.
        dataset <- TwoMode
        tm <- filter(dataset, GrantYear <= endyear, GrantYear >=beginyear) %>%
                select(InstitutionNumber,InvestigatorDept) %>%
                distinct()
        
        
        IJ <- inner_join(tm, tm, "InstitutionNumber")
        
        
        compare_cols <- select(IJ, InvestigatorDept.x, InvestigatorDept.y)
        mutate(IJ,
               Department1 = apply(compare_cols, 1, max),
               Department2 = apply(compare_cols, 1, min)) %>%
        select(Department1, Department2, InstitutionNumber) %>%
        distinct()
}




edges.Grant2Dept <-function(endyear, beginyear = 2004)
{
        # we pair departments if they share a grant for proposals submitted
        # before the input year.
        dataset <- TwoMode
        beginyear <- endyear
        filter(dataset, GrantYear <= endyear, GrantYear >=beginyear) %>%
                select(Grant = InstitutionNumber,
                       Department = InvestigatorDept) %>%
                distinct()
}



#### VERTEX functions: generate list of vertices from edges --------------------


vertices.Dept2Dept <- function(edges)
{
        verts <- edges %>%
                gather(Type, Departments, Department1:Department2) %>%
                select(Departments) %>%
                distinct() %>%
                arrange(Departments)
        
        return(verts)
}



vertices.Invest2Invest <- function(edges)
{
        verts <- edges %>%
                gather(Type, Investigators, InvestigatorID1:InvestigatorID2) %>%
                select(Investigators) %>%
                distinct() %>%
                arrange(Investigators)
        
        return(verts)
}


vertices.Grant2Grant <- function(edges)
{
        verts <- edges %>%
                gather(Type, Grants, InstitutionNumber1:InstitutionNumber2) %>%
                select(Grants) %>%
                distinct() %>%
                arrange(Grants)
        
        return(verts)
}




vertices.Grant2Dept <- function(edges)
{
        verts <- edges %>%
                gather(Type, Verts, Grant:Department) %>%
                select(Verts, Type) %>%
                distinct() %>%
                arrange(Verts)
        
        return(verts)
}



#### METRIC functions: generate data.frame of vertex metrics for input year-----

metrics.Dept2Dept <- function(endyear, beginyear = 2004)
{
        edges <- edges.Dept2Dept(endyear, beginyear)
        
        verts <- vertices.Dept2Dept(edges)
        
        g <- graph.data.frame(edges, vertices = verts, directed = FALSE)
        
        return(vertMetrics(g,verts))
}


metrics.Invest2Invest <- function(endyear, beginyear = 2004)
{
        edges <- edges.Invest2Invest(endyear, beginyear)
        
        verts <- vertices.Invest2Invest(edges)
        
        g <- graph.data.frame(edges, vertices = verts, directed = FALSE)
        
        return(vertMetrics(g,verts))
}


metrics.Grant2Grant <- function(endyear, beginyear = 2004)
{
        edges <- edges.Grant2Grant(endyear, beginyear)
        
        verts <- vertices.Grant2Grant(edges)
        
        g <- graph.data.frame(edges, vertices = verts, directed = FALSE)
        
        return(vertMetrics(g,verts))
}



metrics.Grant2Dept <- function(endyear, beginyear = 2004)
{
        edges <- edges.Grant2Dept(endyear, beginyear)
        
        verts <- vertices.Grant2Dept(edges)
        
        g <- graph.data.frame(edges, vertices = verts, directed = FALSE)
        
        vertMetrics(g,verts) %>%
                rename(Vertices = Vertices.Verts,
                       Type = Vertices.Type)

}



#### create master dataframe of yearly metric tables ---------------------------

years <- data.frame(year = 2004:2015, stringsAsFactors = FALSE)


master_df <- tbl_df(mutate(years,
                           g2g = lapply(2004:2015, metrics.Grant2Grant),
                           d2d = lapply(2004:2015, metrics.Dept2Dept),
                           i2i = lapply(2004:2015, metrics.Invest2Invest),
                           g2d = lapply(2004:2015, metrics.Grant2Dept)))


#detach("package:igraph", unload=TRUE)

# function to extract vertex df from master df
ex <- function(yr, pair)
{
        if (pair == "g2g")
        {
                pair <- 2
        }
        if (pair == "d2d")
        {
                pair <- 3
        }
        if (pair == "i2i")
        {
                pair <- 4
        }
        if (pair == "g2d")
        {
                pair <- 5
        }
        
        obj <- master_df %>%
                filter(year == yr) %>%
                select(pair)
        
        
        suppressWarnings(obj[[1, drop = TRUE]])
        
}

#### function to generate mean metric tables for each pair ---------------------



mean_row <- function(year,pair)
{
        ex(year, pair) %>%
                summarise( year = year,
                           deg = mean(Degree, na.rm = TRUE),
                           BetCent = mean(BetCent, na.rm = TRUE),
                           EigCent = mean(EigCent, na.rm = TRUE),
                           Closeness = mean(Closeness, na.rm = TRUE),
                           Coreness = mean(Coreness, na.rm = TRUE),
                           ClustCoeff = mean(ClustCoeff, na.rm = TRUE),
                           PageRank = mean(PageRank, na.rm = TRUE)
                )   
}


yearly_mean_metrics <- function(pair)
{
        rbind_all(lapply(cbind(2004:2015),mean_row, pair = pair))
}




mean_row_g2d <- function(year, pair, type)
{
        ex(year, pair) %>%
                filter(Type == type) %>%
                summarise( year = year,
                           deg = mean(Degree, na.rm = TRUE),
                           BetCent = mean(BetCent, na.rm = TRUE),
                           EigCent = mean(EigCent, na.rm = TRUE),
                           Closeness = mean(Closeness, na.rm = TRUE),
                           Coreness = mean(Coreness, na.rm = TRUE),
                           ClustCoeff = mean(ClustCoeff, na.rm = TRUE),
                           PageRank = mean(PageRank, na.rm = TRUE)
                )   
}



yearly_mean_metrics_g2d <- function(pair, type)
{
        rbind_all(lapply(2004:2015,mean_row_g2d, pair = pair, type = type))
}

mean_row_g2d(2004, 'g2d', 'Department')

yearly_mean_metrics_g2d('g2d', 'Grant')




# input 'g2g' - grants2grants, 'd2d' - dept2dept, 'i2i' - invest2invest

yearly_mean_metrics('g2d','Department')



write.csv(yearly_mean_metrics('g2g'), file = "data files/mean_metrics_g2g.csv")
write.csv(yearly_mean_metrics('i2i'), file = "data files/mean_metrics_i2i.csv")
write.csv(yearly_mean_metrics('d2d'), file = "data files/mean_metrics_d2d.csv")
write.csv(yearly_mean_metrics_g2d('g2d','Department'),
          file = "data files/mean_metrics_g2d_DEPT.csv")
write.csv(yearly_mean_metrics_g2d('g2d','Grant'),
          file = "data files/mean_metrics_g2d_GRANT.csv")



#### metric functions ----------------------------------------------------------
assign_input_data <-function(type)
{
        type <- type
        if (type == 'Invest2Invest')
        {
                edgeFunction <- edges.Invest2Invest
        }
        if (type == 'Grant2Grant')
        {
                edgeFunction <- edges.Grant2Grant
        }
        if (type == 'Dept2Dept')
        {
                edgeFunction <- edges.Dept2Dept
        }
                
                
        mean_dist <- function(year = 2004:2015)
        {
                edges <- edgeFunction(year)
                g <- graph.data.frame(edges, directed = FALSE)
                mean_distance(g)
        }
        #.......................................................
        connected_cpts <- function(year = 2004:2015)
        {
                edges <- edgeFunction(year)
                g <- graph.data.frame(edges, directed = FALSE)
                count_components(g)
        }
        #.......................................................
        number_edges <- function(year = 2004:2015)
        {
                edges <- edgeFunction(year)
                g <- graph.data.frame(edges, directed = FALSE)
                ecount(g)
        }
        #.......................................................
        cpt_dist <- function(year = 2004:2015)
        {
                edges <- edgeFunction(year)
                g <- graph.data.frame(edges, directed = FALSE)
                component_distribution(g)
        }
        #.......................................................
        modular <- function(year = 2004:2015)
        {
                edges <- edgeFunction(year)
                g <- graph.data.frame(edges, directed = FALSE)
                E(g)$weight <-count.multiple(g)
                g <- simplify(g)
                clust <- fastgreedy.community(g)
                modularity(clust)
        }
        
        
        
        return(list(mean_dist,
                    connected_cpts,
                    number_edges,
                    cpt_dist,
                    modular))
}





#### apply global metric functions and add to table ----------------------------

inputData <- "Invest2Invest"


II_mean_dist <- assign_input_data("Invest2Invest")[[1]]
II_connected_cpts <- assign_input_data("Invest2Invest")[[2]]
II_number_edges <- assign_input_data("Invest2Invest")[[3]]
II_cpt_dist <- assign_input_data("Invest2Invest")[[4]]
II_modular <- assign_input_data("Invest2Invest")[[5]]


inputData <- "Dept2Dept"

DD_mean_dist <- assign_input_data("Dept2Dept")[[1]]
DD_connected_cpts <- assign_input_data("Dept2Dept")[[2]]
DD_number_edges <- assign_input_data("Dept2Dept")[[3]]
DD_cpt_dist <- assign_input_data("Dept2Dept")[[4]]
DD_modular <- assign_input_data("Dept2Dept")[[5]]


inputData <- "Grant2Grant"

        
GG_mean_dist <- assign_input_data("Grant2Grant")[[1]]
GG_connected_cpts <- assign_input_data("Grant2Grant")[[2]]
GG_number_edges <- assign_input_data("Grant2Grant")[[3]]
GG_cpt_dist <- assign_input_data("Grant2Grant")[[4]]
GG_modular <- assign_input_data("Grant2Grant")[[5]]



global_i2i <- mutate(YearlyStats,
               II.MeanDistance = sapply(GrantYear, II_mean_dist),
               II.ConnectedComponents = sapply(GrantYear, II_connected_cpts),
               II.NumberEdges = sapply(GrantYear, II_number_edges),
               II.Modularity = sapply(GrantYear, II_modular)) %>%
        select(
                GrantYear,
                II.MeanDistance,
                II.ConnectedComponents,
                II.NumberEdges,
                II.Modularity)


global_d2d <- mutate(YearlyStats,
                     DD.MeanDistance = sapply(GrantYear, DD_mean_dist),
                     DD.ConnectedComponents = sapply(GrantYear, DD_connected_cpts),
                     DD.NumberEdges = sapply(GrantYear, DD_number_edges),
                     DD.Modularity = sapply(GrantYear, DD_modular)) %>%
        select(
                GrantYear,
                DD.MeanDistance,
                DD.ConnectedComponents,
                DD.NumberEdges,
                DD.Modularity)

global_g2g <- mutate(YearlyStats,
                     GG.MeanDistance = sapply(GrantYear, GG_mean_dist),
                     GG.ConnectedComponents = sapply(GrantYear, GG_connected_cpts),
                     GG.NumberEdges = sapply(GrantYear, GG_number_edges),
                     GG.Modularity = sapply(GrantYear, GG_modular)) %>%
        select(
                GrantYear,
                GG.MeanDistance,
                GG.ConnectedComponents,
                GG.NumberEdges,
                GG.Modularity)



YearlyStats

write.csv(YearlyStats, file = "data files/YearlyStats.csv")
write.csv(global_i2i, file = "data files/global_metrics_yearly_i2i.csv")
write.csv(global_g2g, file = "data files/global_metrics_yearly_g2g.csv")
write.csv(global_d2d, file = "data files/global_metrics_yearly_d2d.csv")

global_d2d


write.csv(II_2004, file = "II_2004.csv")



II2004 <- edges.Invest2Invest(2004)
II_2004 <- select(II2004, source = InvestigatorID1, target = InvestigatorID2)%>%
        mutate(type = 'Undirected')
write.csv(II_2004, file = "II_2004.csv")





       
