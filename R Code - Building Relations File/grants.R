
#Read into R as matrix the original data file 
grantsData <- as.matrix(read.csv("grants.csv",sep=",",header=FALSE))
#Set dimensions of original file
numCols <- 16
numRows <- 3
lastNamePos <- 5
firstNamePos <- 6
deptPos <- 7


newNumRows <- 100

#Create new matrix
newMatrix<-matrix(data = NA, nrow = newNumRows, ncol = numCols, byrow = FALSE,
       dimnames = NULL)
newRowCount <- 0
#for each row in the orginal file
for (row in 1:numRows)
#Calculate number of team members
{
  print("row:", row)
  print(row)
  lastList <- as.vector(unlist(strsplit(grantsData[row,lastNamePos],"~")),mode="list")
  firstList <- as.vector(unlist(strsplit(grantsData[row,firstNamePos],"~")),mode="list")
  deptList <- as.vector(unlist(strsplit(grantsData[row,deptPos],"~")),mode="list")
  numMembers <- length(lastList)
  firstNameNum <- length(firstList)
  deptNum <- length(deptList)
  if ((numMembers != firstNameNum) | (numMembers != deptNum))
  {
    print("error at:",row)
  }
  else
  {
    print("number of members:")
    print(numMembers)
    for (i in 1:numMembers)
    {
      newRowCount <- newRowCount+1
      print("new row num:")
      print(newRowCount)
      for (j in 1:(lastNamePos-1)) 
      {
        newMatrix[newRowCount,j]<- grantsData[row,j]
        print("in for")
        print(newMatrix[newRowCount,j])
      }
      lastName <- lastList[i]
      print("last name:")
      print(lastName)
      firstName <- firstList[i]
      print("first name:")
      print(firstName)
      deptName <- deptList[i]
      print("dept name:")
      print(deptName)
      print("newrowcount:")
      print(newRowCount)
      print("lastNamePos:")
      print(lastNamePos)
      print("lastName:")
      print(lastName)
      print("last name in matrix:") 
print(newMatrix);
      print(newMatrix[newRowCount,lastNamePos]<-lastList[i])
      print("first name in matrix:")
print(newMatrix);
      print(newMatrix[newRowCount,firstNamePos]<-firstList[i])
      print(newMatrix[newRowCount,firstNamePos]<-firstList[i])
      newMatrix[newRowCount,deptPos]<-deptName
      print("dept name:")
      print(newMatrix[newRowCount,deptNamePos])

      for (j in (deptPos+1):numCols) 
      {
        newMatrix[newRowCount,j]<- grantsData[row,j]
      }
    }
  }
}
