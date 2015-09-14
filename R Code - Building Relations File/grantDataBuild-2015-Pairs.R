#Read into R as matrix the original data file 
grantsData <- as.matrix(read.table("grants-2015.txt",sep="\t",header=FALSE))
#Set dimensions of original file
numCols<-19
#numRows<-5
numRows<-20520
lastNamePos<-7
firstNamePos<-8
deptPos<-9

#start new text file for storing network data
data <- file("grantsNew-2015.txt", "w")  #create new output file
cat(grantsData[1,],file = data, sep = "\t")  #save first line - header names with TAB (comma) separator
#add three columns: last name, first name and dpt for Co-PI-2, perhaps at the end of each row
cat("",file = data, sep = "\n") #write change line
newRowCount <- 0 #simply used to count the rows of the new file created
for (row in 2:numRows)  #for each row in the orginal file
#Calculate number of team members and make sure the last, first, and dept lists 
#have the same number of elements separated by ~
{
  print("row:")
  print(row)
  lastList <- as.vector(unlist(strsplit(grantsData[row,lastNamePos],"~")),mode="list")
  firstList <- as.vector(unlist(strsplit(grantsData[row,firstNamePos],"~")),mode="list")
  deptList <- as.vector(unlist(strsplit(grantsData[row,deptPos],"~")),mode="list")
  numMembers <- length(lastList)
  firstNameNum <- length(firstList)
  deptNum <- length(deptList)
  if ((numMembers != firstNameNum) | (numMembers != deptNum))
  {
    print("error at original file row:")
	print(row)
  }
  else  #process current row of original file
  {
    print("number of members:")
    print(numMembers)
    for (i in 1:numMembers)  #add new row to output file for each team member
    {
      newRowCount <- newRowCount+1 #keep count of new rows in output file
      print("new row num:")
      print(newRowCount)
      
#Store all elements from column 1 to column 6 (up to list of last names) 
# create a connection only if the list of collaborators contains more than just the PI
  if (numMembers = 1)  #if only PI, store PI last name, etc. for both CoI-1 and CoI-2
  {
    
  }
  else
  {
  pos <- 1
  while (pos < numMembers)
  {
  }
  }
    cat(grantsData[row,1],grantsData[row,2],grantsData[row,3],grantsData[row,4], grantsData[row,5],grantsData[row,6], file = data, sep = "\t")
      cat("\t", file = data, sep = "")
	  # for current team member, set last, first, and dept names from corresponding lists
      lastName <- toString(lastList[i])
      print("last name:")
      print(lastName)
      firstName <- toString(firstList[i])
      print("first name:")
      print(firstName)
      deptName <- toString(deptList[i])
      print("dept name:")
      print(deptName)
      #Write last, first, and dept names to the output file
	  cat(lastName,firstName,deptName,file = data, sep = "\t")
      cat("\t", file = data, sep = "")
      #Now write the data for the remaining columns into the output file      
      cat(grantsData[row,10],grantsData[row,11],grantsData[row,12], grantsData[row,13],grantsData[row,14],grantsData[row,15],grantsData[row,16],grantsData[row,17],grantsData[row,18],grantsData[row,19],file = data, sep = "\t")
	  #create new line in output file for the data of next team member
	  cat("",file = data, sep = "\n")
    } #end for all team members
  }   #add new rows for each team member
}  #for each row in the orginal file
#Now close the output file
close(data)