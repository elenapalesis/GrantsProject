## this code will generate a new table that pairs 
## investigators who collaborate on the same project.

## we will pull information from this table.
grantsData <- as.matrix(read.table("grants-2015-expanded.txt",sep="\t",header=FALSE))



# assign variables to manipulate the code for trial purposes
numCols<-ncol(grantsData) # actual number of columns of original table
#numRows<-20 # for trial purposes
numRows<-nrow(grantsData) # actual number of rows
lastNamePos<-7
firstNamePos<-8
deptPos<-9




## this is the table to which we write
pairTable <- file("pairedInvestigators-2015.txt", "w")





## Now we write column names for pairTable
cat(grantsData[1,1:6], # write first 6 columns of grantsData table
    'Investigator 1 Last','Investigator 1 First','Investigator 1 Department', #columns for Investigator 1
    'Investigator 2 Last', 'Investigator 2 First','Investigator 2 Department', # columns for Investigator 2
    grantsData[1,10:23], # write the remaining columns from grantsData table
    file = pairTable, sep = "\t")
cat("",file = pairTable, sep = "\n") #write change line


# the following function takes as input a string separated by ~ and outputs a
# vector of the elements that are separated by ~
splitTilde <- function(row,column)
{
  as.vector(unlist(strsplit(grantsData[row,column],"~")),mode="list")
}

#initialize empty vectors to define pairing function
lastList<-c()
firstList<-c()
deptList<-c()

pairInvestigators <- function(inv1,inv2)
{

  cat(grantsData[row,1:6],
      toString(lastList[inv1]),toString(firstList[inv1]),toString(deptList[inv1]),
      toString(lastList[inv2]),toString(firstList[inv2]),toString(deptList[inv2]),
      grantsData[row,10:23],
      file = pairTable, sep = "\t") 
  
  cat("",file = pairTable, sep = "\n")
}


for (row in 2:numRows)
{
  # we create lists for last name, first name, and dept
  lastList <- splitTilde(row,lastNamePos)
  firstList <- splitTilde(row,firstNamePos)
  deptList <- splitTilde(row,deptPos)


  numMembers <- length(lastList)

  # sanity check:
  #print('row:')
  #print(row)
  #print('number of members:')
  #print(numMembers)
  
  
  # if there is only one investigator,
  if (numMembers == 1)
  {
    # make a self loop, and denote
    pairInvestigators(1,1)
    #print('selfie!')
    #print('-----------')
  }
  else
  {
    inv1 <- 1
    while (inv1 < numMembers)
    {
      for (inv2 in  (inv1 + 1):numMembers)
      {
        pairInvestigators(inv1,inv2)
        #print('invest1:')
        #print(inv1)
        #print('invest2:')
        #print(inv2)
      }
      inv1 <- inv1 + 1
    }
    #print('-----------')
  }
  
}

close(pairTable)