########################### MAIN TABLE ------

CREATE TABLE Main
(
PIEmployeeId varchar(255),
InstitutionNumber varchar(255),
SubmittedDate date,
PILastName varchar(255),
PIFirstName varchar(255),
PIDepartmentName varchar(255),
InvestigatorALLLastName varchar(255),
InvestigatorALLFirstName varchar(255),
InvestigatorALLDept varchar(255),
SponsorName varchar(255),
ProjectTitle varchar(255),
RequestedProjectPeriodStartDate date,
RequestedProjectPeriodEndDate date,
ProjectTotalRequestedSponsorCosts varchar(255),
CurrentProposalStatus varchar(255),
CurrentProposalStatusDate date,
ARRAFunding varchar(255),
SponsorAwardNumber varchar(255),
TotalGranted varchar(255),
TeamSize int,
Awarded int,
NIHGrant int,
AwardedNIH int
);


LOAD DATA LOCAL INFILE '/Users/elenapalesis/dropbox/grant collaborations 2015/data files/MAIN_table.txt' 
INTO TABLE Main 
FIELDS TERMINATED BY '\t' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';



# remove column line from csv import
DELETE FROM MAIN
WHERE PIEmployeeID = "PI Employee ID";

# add GrantYear column to streamline future yearly calculations
ALTER TABLE Main ADD GrantYear int(4);
UPDATE Main SET GrantYear = Year(SubmittedDate);


# FlagBad column flags rows where investigator names are empty or placeholders.
ALTER TABLE Main ADD FlagBad int(4);

# this flags a long list of investigator names that are only placeholders
UPDATE Main SET FlagBad = 1
WHERE 	(InvestigatorALLLastName LIKE '%MATR %') OR
(InvestigatorALLLastName LIKE '%To Be hired%') OR
(InvestigatorALLLastName LIKE '%Postdoc%') OR
(InvestigatorALLLastName LIKE '%Research%') OR
(InvestigatorALLLastName LIKE '%TBH%') OR
(InvestigatorALLLastName LIKE '%TBD%') OR
(InvestigatorALLLastName LIKE '%TBA%') OR
(InvestigatorALLLastName LIKE '%TBN%') OR
(InvestigatorALLLastName LIKE '%Technician%') OR
(InvestigatorALLLastName LIKE '%Lab%') OR
(InvestigatorALLLastName LIKE '%Specialist%') OR
(InvestigatorALLLastName LIKE '%Coordinator%') OR
(InvestigatorALLLastName LIKE '%To be determined%') OR
(InvestigatorALLLastName LIKE '%To be named%') OR
(InvestigatorALLLastName LIKE '%determined%') OR
(InvestigatorALLLastName LIKE '%To be hired%') OR
(InvestigatorALLLastName LIKE '%Project%') OR
(InvestigatorALLLastName LIKE '%Intern%') OR
(InvestigatorALLLastName LIKE '%Assistant%') OR
(InvestigatorALLLastName LIKE '%Counselor%') OR
(InvestigatorALLLastName LIKE '%PhD%') OR
(InvestigatorALLLastName LIKE '%student%') OR
(InvestigatorALLLastName LIKE '%worker%') OR
(InvestigatorALLLastName LIKE '%Program%') OR
(InvestigatorALLLastName LIKE '%Coordinator%') OR
(InvestigatorALLLastName LIKE '%~~%') OR
(InvestigatorALLLastName LIKE '~%') OR
(InvestigatorALLFirstName LIKE '%MATR %') OR
(InvestigatorALLFirstName LIKE '%To Be hired%') OR
(InvestigatorALLFirstName LIKE '%Postdoc%') OR
(InvestigatorALLFirstName LIKE '%Research%') OR
(InvestigatorALLFirstName LIKE '%TBH%') OR
(InvestigatorALLFirstName LIKE '%TBD%') OR
(InvestigatorALLFirstName LIKE '%TBA%') OR
(InvestigatorALLFirstName LIKE '%TBN%') OR
(InvestigatorALLFirstName LIKE '%Technician%') OR
(InvestigatorALLFirstName LIKE '%Lab%') OR
(InvestigatorALLFirstName LIKE '%Specialist%') OR
(InvestigatorALLFirstName LIKE '%Coordinator%') OR
(InvestigatorALLFirstName LIKE '%To be determined%') OR
(InvestigatorALLFirstName LIKE '%To be named%') OR
(InvestigatorALLFirstName LIKE '%determined%') OR
(InvestigatorALLFirstName LIKE '%To be hired%') OR
(InvestigatorALLFirstName LIKE '%Project%') OR
(InvestigatorALLFirstName LIKE '%Intern%') OR
(InvestigatorALLFirstName LIKE '%Assistant%') OR
(InvestigatorALLFirstName LIKE '%Counselor%') OR
(InvestigatorALLFirstName LIKE '%PhD%') OR
(InvestigatorALLFirstName LIKE '%student%') OR
(InvestigatorALLFirstName LIKE '%worker%') OR
(InvestigatorALLFirstName LIKE '%Program%') OR
(InvestigatorALLFirstName LIKE '%Coordinator%') OR
(InvestigatorALLFirstName LIKE '%~~%') OR
(InvestigatorALLFirstName LIKE '~%');


# How many grants submitted have missing members or placeholder names?
SELECT COUNT(FlagBad)FROM Main;



########################### Investigators --------------
DROP TABLE Investigators;

CREATE TABLE Investigators
SELECT
	InvestigatorID, 
	InvestigatorLastName,
	InvestigatorFirstName,
	InvestigatorDept,
	COUNT(InvestigatorID) as NumberProposals,
	SUM(Awarded) as NumberAwarded
FROM TwoMode
GROUP BY InvestigatorID;

ALTER TABLE Investigators



########################### Grants -------------------------

DROP TABLE GrantTable;

# create GrantTable to calculate initial information about each grant proposal
CREATE TABLE GrantTable
SELECT
	InstitutionNumber,
	SubmittedDate,
	YEAR(SubmittedDate) as GrantYear,
	Awarded,
	COUNT(InvestigatorID) as NumberInvestigators
FROM TwoMode
GROUP BY InstitutionNumber;


# SumTeamSuccessful is the number of grants funded per investigator
# summed over all investigators participating in the project
ALTER TABLE GrantTable
ADD SumTeamSuccessful int(11);


# SumTeamProposed is the number of grant projects each investigator
# has participated in, summed over all investigators of the grant
ALTER TABLE GrantTable
ADD SumTeamProposed int(11);


# calulating SumTeamSuccessful and SumTeamProposed columns
UPDATE GrantTable as GT
INNER JOIN (
	SELECT 
		TM.InstitutionNumber,
		SUM(I.NumberProposals) as SumTeamProposed,
		SUM(I.NumberAwarded) as SumTeamSuccessful
	FROM TwoMode as TM
	INNER JOIN Investigators as I on TM.InvestigatorID = I.InvestigatorID
	GROUP BY TM.InstitutionNumber) as N on GT.InstitutionNumber = N.InstitutionNumber
SET GT.SumTeamProposed = N.SumTeamProposed,
	GT.SumTeamSuccessful = N.SumTeamSuccessful;


# TeamSuccessRate is the ratio of Successful/Proposed columns:
ALTER TABLE GrantTable
ADD TeamSuccessRate FLOAT;

UPDATE GrantTable
SET TeamSuccessRate = SumTeamSuccessful/SumTeamProposed;



########################### TwoMode -------------------------

# This TwoMode table pairs Grants to Investigators. To generate it,
# we run the source/build_TwoMode.R file, and then import the resultant
# csv file into the database.

CREATE TABLE TwoMode
(
PIEmployeeId varchar(255),
InstitutionNumber varchar(255),
SubmittedDate date,
PILastName varchar(255),
PIFirstName varchar(255),
PIDepartmentName varchar(255),
InvestigatorLastName varchar(255),
InvestigatorFirstName varchar(255),
InvestigatorDept varchar(255),
SponsorName varchar(255),
ProjectTitle varchar(255),
RequestedProjectPeriodStartDate date,
RequestedProjectPeriodEndDate date,
ProjectTotalRequestedSponsorCosts varchar(255),
CurrentProposalStatus varchar(255),
CurrentProposalStatusDate date,
ARRAFunding varchar(255),
SponsorAwardNumber varchar(255),
TotalGranted varchar(255),
TeamSize int,
Awarded int,
NIHGrant int,
AwardedNIH int
);

#DELETE FROM TwoMode;

LOAD DATA LOCAL INFILE '/Users/elenapalesis/dropbox/grant collaborations 2015/data files/TwoMode_table.txt' 
INTO TABLE TwoMode 
FIELDS TERMINATED BY '\t' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

# delete the column headings generated when importing the csv file
DELETE FROM TwoMode
WHERE PIEmployeeID = "PI Employee ID";

# Create a unique ID for each investigator by concatenating First,Last names
ALTER TABLE TwoMode
ADD InvestigatorID varchar(255) FIRST;

UPDATE TwoMode
SET InvestigatorID = CONCAT(InvestigatorLastName,',',InvestigatorFirstName);


# Bring InstitutionNumber to the front of the table
ALTER TABLE TwoMode
MODIFY InstitutionNumber varchar(255) FIRST;

# Create GrantYear column to streamline future calculations
ALTER TABLE TwoMode
ADD GrantYear int(4);

UPDATE TwoMode
SET GrantYear = YEAR(SubmittedDate);


#Delete rows where investigator is a nameholder/blank
DELETE FROM  TwoMode
WHERE 	(InvestigatorID LIKE '%MATR %') OR
(InvestigatorID LIKE '%To Be hired%') OR
(InvestigatorID LIKE '%Postdoc%') OR
(InvestigatorID LIKE '%Research%') OR
(InvestigatorID LIKE '%TBH%') OR
(InvestigatorID LIKE '%TBD%') OR
(InvestigatorID LIKE '%TBA%') OR
(InvestigatorID LIKE '%TBN%') OR
(InvestigatorID LIKE '%Technician%') OR
(InvestigatorID LIKE '%Lab%') OR
(InvestigatorID LIKE '%Specialist%') OR
(InvestigatorID LIKE '%Coordinator%') OR
(InvestigatorID LIKE '%To be determined%') OR
(InvestigatorID LIKE '%To be named%') OR
(InvestigatorID LIKE '%determined%') OR
(InvestigatorID LIKE '%To be hired%') OR
(InvestigatorID LIKE '%Project%') OR
(InvestigatorID LIKE '%Intern%') OR
(InvestigatorID LIKE '%Assistant%') OR
(InvestigatorID LIKE '%Counselor%') OR
(InvestigatorID LIKE '%PhD%') OR
(InvestigatorID LIKE '%student%') OR
(InvestigatorID LIKE '%worker%') OR
(InvestigatorID LIKE '%Program%') OR
(InvestigatorID LIKE '%Coordinator%') OR
(InvestigatorID LIKE '%,') OR
(InvestigatorID LIKE ',%') OR
(InvestigatorID LIKE ',');









########################### PairedInvestigators --------------
DROP TABLE PairedInvestigators;


# Create a table that pairs Investigators if they have worked
# together on a grant 

CREATE TABLE PairedInvestigators
(
PIEmployeeId varchar(255),
InstitutionNumber varchar(255),
SubmittedDate date,
PILastName varchar(255),
PIFirstName varchar(255),
PIDepartmentName varchar(255),
Investigator1LastName varchar(255),
Investigator1FirstName varchar(255),
Investigator1Dept varchar(255),
Investigator2LastName varchar(255),
Investigator2FirstName varchar(255),
Investigator2Dept varchar(255),
SponsorName varchar(255),
ProjectTitle varchar(255),
RequestedProjectPeriodStartDate date,
RequestedProjectPeriodEndDate date,
ProjectTotalRequestedSponsorCosts varchar(255),
CurrentProposalStatus varchar(255),
CurrentProposalStatusDate date,
ARRAFunding varchar(255),
SponsorAwardNumber varchar(255),
TotalGranted varchar(255),
TeamSize int,
Awarded int,
NIHGrant int,
AwardedNIH int
);


LOAD DATA LOCAL INFILE '/Users/elenapalesis/dropbox/grant collaborations 2015/data files/pairedInvestigators_table.txt' 
INTO TABLE PairedInvestigators 
FIELDS TERMINATED BY '\t' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


DELETE FROM PairedInvestigators
WHERE PIEmployeeID = "PI Employee ID";











#create columns of LastName,FirstName for both Investigators:

ALTER TABLE PairedInvestigators
ADD InvestigatorID2 varchar(255) FIRST;

ALTER TABLE PairedInvestigators
ADD InvestigatorID1 varchar(255) FIRST;

UPDATE PairedInvestigators
SET InvestigatorID1 = CONCAT_WS(',',Investigator1LastName, Investigator1FirstName);

ALTER TABLE PairedInvestigators
DROP Investigator1LastName;

ALTER TABLE PairedInvestigators
DROP Investigator1FirstName;


UPDATE PairedInvestigators
SET InvestigatorID2 = CONCAT_WS(',',Investigator2LastName, Investigator2FirstName);

ALTER TABLE PairedInvestigators
DROP Investigator2LastName;

ALTER TABLE PairedInvestigators
DROP Investigator2FirstName;




#Add Year column
ALTER TABLE PairedInvestigators
ADD GrantYear int(4) AFTER Investigator2Dept;

UPDATE PairedInvestigators
SET GrantYear = Year(SubmittedDate);



#Delete rows where at least one investigator is a nameholder/blank
DELETE FROM  PairedInvestigators
WHERE 	(InvestigatorID1 LIKE '%MATR %') OR
(InvestigatorID1 LIKE '%To Be hired%') OR
(InvestigatorID1 LIKE '%Postdoc%') OR
(InvestigatorID1 LIKE '%Research%') OR
(InvestigatorID1 LIKE '%TBH%') OR
(InvestigatorID1 LIKE '%TBD%') OR
(InvestigatorID1 LIKE '%TBA%') OR
(InvestigatorID1 LIKE '%TBN%') OR
(InvestigatorID1 LIKE '%Technician%') OR
(InvestigatorID1 LIKE '%Lab%') OR
(InvestigatorID1 LIKE '%Specialist%') OR
(InvestigatorID1 LIKE '%Coordinator%') OR
(InvestigatorID1 LIKE '%To be determined%') OR
(InvestigatorID1 LIKE '%To be named%') OR
(InvestigatorID1 LIKE '%determined%') OR
(InvestigatorID1 LIKE '%To be hired%') OR
(InvestigatorID1 LIKE '%Project%') OR
(InvestigatorID1 LIKE '%Intern%') OR
(InvestigatorID1 LIKE '%Assistant%') OR
(InvestigatorID1 LIKE '%Counselor%') OR
(InvestigatorID1 LIKE '%PhD%') OR
(InvestigatorID1 LIKE '%student%') OR
(InvestigatorID1 LIKE '%worker%') OR
(InvestigatorID1 LIKE '%Program%') OR
(InvestigatorID1 LIKE '%Coordinator%') OR
(InvestigatorID1 LIKE '%,') OR
(InvestigatorID1 LIKE ',%') OR
(InvestigatorID1 LIKE ',') OR
(InvestigatorID2 LIKE '%MATR %') OR
(InvestigatorID2 LIKE '%To Be hired%') OR
(InvestigatorID2 LIKE '%Postdoc%') OR
(InvestigatorID2 LIKE '%Research%') OR
(InvestigatorID2 LIKE '%TBH%') OR
(InvestigatorID2 LIKE '%TBD%') OR
(InvestigatorID2 LIKE '%TBA%') OR
(InvestigatorID2 LIKE '%TBN%') OR
(InvestigatorID2 LIKE '%Technician%') OR
(InvestigatorID2 LIKE '%Lab%') OR
(InvestigatorID2 LIKE '%Specialist%') OR
(InvestigatorID2 LIKE '%Coordinator%') OR
(InvestigatorID2 LIKE '%To be determined%') OR
(InvestigatorID2 LIKE '%To be named%') OR
(InvestigatorID2 LIKE '%determined%') OR
(InvestigatorID2 LIKE '%To be hired%') OR
(InvestigatorID2 LIKE '%Project%') OR
(InvestigatorID2 LIKE '%Intern%') OR
(InvestigatorID2 LIKE '%Assistant%') OR
(InvestigatorID2 LIKE '%Counselor%') OR
(InvestigatorID2 LIKE '%PhD%') OR
(InvestigatorID2 LIKE '%student%') OR
(InvestigatorID2 LIKE '%worker%') OR
(InvestigatorID2 LIKE '%Program%') OR
(InvestigatorID2 LIKE '%Coordinator%') OR
(InvestigatorID2 LIKE '%,') OR
(InvestigatorID2 LIKE ',%') OR
(InvestigatorID2 LIKE ',');


#bring investigator traits near beginning of table
ALTER TABLE PairedInvestigators
MODIFY Investigator1Dept varchar(255) AFTER InvestigatorID2;

ALTER TABLE PairedInvestigators
MODIFY Investigator2Dept varchar(255) AFTER Investigator1Dept;








##### Yearly Statistics --------------------


CREATE TABLE YearlyStatistics
(
GrantYear INT(4),
NumberProposals INT(11),
NumberAwarded INT(11),
RatioAwarded FLOAT,
SingleInvestigators INT(11),
RatioSingle FLOAT,
MeanTeamSize FLOAT
);



UPDATE
	YearlyStatistics as S
	INNER JOIN (
		SELECT YEAR(SubmittedDate) AS GrantYear,
		COUNT(InstitutionNumber) AS SingleInvestigators
		FROM Main
		WHERE TeamSize = 1
		GROUP BY YEAR(SubmittedDate)
	) as N on S.GrantYear = N.GrantYear
SET S.SingleInvestigators = N.SingleInvestigators;


UPDATE YearlyStatistics as S
	INNER JOIN (
		SELECT YEAR(SubmittedDate) AS GrantYear,
		COUNT(InstitutionNumber) AS NumberProposals,
		SUM(Awarded) AS NumberAwarded,
		AVG(1.0*TeamSize) AS MeanTeamSize
		FROM Main
		GROUP BY YEAR(SubmittedDate)
	) as N on S.GrantYear = N.GrantYear
SET S.NumberProposals = N.NumberProposals,
	S.NumberAwarded = N.NumberAwarded,
	S.MeanTeamSize = N.MeanTeamSize;




UPDATE YearlyStatistics
SET RatioSingle = SingleInvestigators/NumberProposals,
	RatioAwarded = NumberAwarded/NumberProposals;



#--------
SELECT InvestigatorID1, InvestigatorID2
FROM PairedInvestigators
WHERE InvestigatorID1 != InvestigatorID2;


UPDATE
	YearlyStatistics as S
	INNER JOIN (
		SELECT YEAR(SubmittedDate) AS GrantYear,
		COUNT(InstitutionNumber) AS SingleInvestigators
		FROM Main
		WHERE TeamSize = 1
		GROUP BY YEAR(SubmittedDate)
	) as N on S.GrantYear = N.GrantYear
SET S.SingleInvestigators = N.SingleInvestigators;

##### Paired Grants --------------------

CREATE TABLE temp1_PairedGrants
SELECT 
	TM1.InstitutionNumber as InstitutionNumber1, 
	TM2.InstitutionNumber as InstitutionNumber2,
	TM1.Awarded as Awarded1,
	TM2.Awarded as Awarded2,
	YEAR(TM1.SubmittedDate) as GrantYear1,
	YEAR(TM2.SubmittedDate) as GrantYear2 
FROM TwoMode as TM1
INNER JOIN 
	TwoMode as TM2
	on TM1.InvestigatorID = TM2.InvestigatorID;
	

UPDATE temp1_PairedGrants
SET InstitutionNumber1 = InstitutionNumber2,
	InstitutionNumber2 = InstitutionNumber1
WHERE InstitutionNumber1 < InstitutionNumber2;

CREATE TABLE PairedGrants
SELECT DISTINCT *
FROM temp1_PairedGrants;

DROP TABLE temp1_PairedGrants;

##### Paired Departments --------------------
DROP TABLE PairedDepartments;
CREATE TABLE temp1_PairedDepartments
SELECT
	TM1.InvestDept1 as Dept1,
	TM2.InvestDept2 as Dept2,
	TM1.Awarded1 as Awarded1,
	TM2.Awarded2 as Awarded2,
	TM1.GrantYear1 as GrantYear1,
	TM2.GrantYear2 as GrantYear2
FROM (
	SELECT 
		InvestigatorDept as InvestDept1,
		InstitutionNumber as InstitNum1,
		InvestigatorID as InvestID1,
		Awarded as Awarded1,
		YEAR(SubmittedDate) as GrantYear1
	FROM TwoMode
	) as TM1
INNER JOIN
	(
	SELECT
		InvestigatorDept as InvestDept2,
		InstitutionNumber as InstitNum2,
		InvestigatorID as InvestID2,
		Awarded as Awarded2,
		YEAR(SubmittedDate) as GrantYear2
	FROM TwoMode
	) as TM2
on TM1.InstitNum1 = TM2.InstitNum2;

SELECT
	Dept1,
	Dept2,
	SUM(Awarded1) as SumAwarded,
	COUNT(*) as Weight
FROM PairedDepartments
GROUP BY Dept1, Dept2;



SELECT * FROM
(
	SELECT 
		InvestigatorDept as InvestDept1,
		InstitutionNumber as InstitNum1,
		InvestigatorID as InvestID1,
		Awarded as Awarded1,
		YEAR(SubmittedDate) as GrantYear1
	FROM TwoMode
	) as TM1
INNER JOIN
	(
	SELECT
		InvestigatorDept as InvestDept2,
		InstitutionNumber as InstitNum2,
		InvestigatorID as InvestID2,
		Awarded as Awarded2,
		YEAR(SubmittedDate) as GrantYear2
	FROM TwoMode
	) as TM2
on TM1.InstitNum1 = TM2.InstitNum2
WHERE TM1.InvestID1 != TM2.InvestID2 AND TM1.InstitNum1 != TM2.InstitNum2;
