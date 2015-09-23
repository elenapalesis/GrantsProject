library(RMySQL)
library(ggplot2)


# write histogram function ----
#  Function to generate histograms of Team Size for each year
histify <-function(year)
        # establish database connection
        con <- dbConnect(MySQL(), user='root', password ='password', 
                         dbname='GrantsProject')
        # establish query for TeamSize column from Main table for specified year
        data <- dbSendQuery(con,
                            paste0(
                                    "SELECT TeamSize ",
                                    "FROM Main ",
                                    "WHERE SubmittedDate LIKE '",
                                    year,
                                    "%'")
        )
        # store query result into tableYear as data.frame
        tableYear <-fetch(data,n=-1)
        print(tableYear)
        # 
        dbClearResult(data)
        dbDisconnect(con)
        title <- paste0('Histogram of Team Size of Year ', year)
        return(
                ggplot(tableYear, aes(x=TeamSize)) + 
                        geom_histogram(aes(y=..density..),binwidth=1) +
                        ggtitle(title)
        )
}



# write mean function ----
meanify <-function(year)
{
        con <- dbConnect(MySQL(), user='root', password ='password', 
                         dbname='GrantsProject')
        data <- dbSendQuery(con, paste0(
                "SELECT TeamSize FROM Main WHERE SubmittedDate LIKE '",year,"%'"))
        tableYear <-fetch(data,n=-1)
        dbClearResult(data)
        dbDisconnect(con)
        
        values <-as.vector(tableYear[,1])
        return(mean(values))
}



percentSingle <-function(year)
{
        con <- dbConnect(MySQL(), user='root', password ='password', 
                         dbname='GrantsProject')
        data <- dbSendQuery(con, paste0(
                "SELECT TeamSize ",
                "FROM Main ",
                "WHERE SubmittedDate LIKE '",
                year,
                "%'"))
        tableYear <-fetch(data,n=-1)
        dbClearResult(data)
        dbDisconnect(con)
        
        values <-as.vector(tableYear[,1])
        length <- length(values)
        a <- table(values)
        singletons <- as.numeric(a['1'])
        return(singletons/length)
}

lapply(2004:2015, percentSingle)

#lapply(2004:2015, histify)

percentSingle(2004)


# average money request per year ----
avgMoneyReq <-function(year)
{
        con <- dbConnect(MySQL(), user='root', password ='password', 
                         dbname='GrantsProject')
        data <- dbSendQuery(con, paste0(
                "SELECT ProjectTotalRequestedSponsorCosts ",
                "FROM Main ",
                "WHERE SubmittedDate LIKE '"
                ,year,"%'"))
        tableYear <-fetch(data,n=-1)
        dbClearResult(data)
        dbDisconnect(con)
        
        values <-as.vector(tableYear[,1])
        return(mean(values))
}

# writing to mysql ----


con <- dbConnect(MySQL(), user='root', password ='password', 
                 dbname='GrantsProject')
dbWriteTable(con,'YearlyData')

YearlyData <-data.frame(Year = 2004:2015, 
                        MeanTeamSize = sapply(2004:2015,meanify),
                        PercentSingleInv = sapply(2004:2015,percentSingle))
YearlyData











con <- dbConnect(MySQL(), user='root', password ='password', 
                 dbname='GrantsProject')
data <- dbSendQuery(con, paste0(
        "SELECT TeamSize ",
        "FROM Main ",
        "WHERE SubmittedDate LIKE '",
        year,
        "%'"))
tableYear <-fetch(data,n=-1)
dbClearResult(data)
dbDisconnect(con)

values <-as.vector(tableYear[,1])
length <- length(values)
a <- table(values)
singletons <- as.numeric(a['1'])
return(singletons/length)




