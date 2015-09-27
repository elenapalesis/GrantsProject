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


DELETE FROM MAIN
WHERE PIEmployeeID = "PI Employee ID";


ALTER TABLE Main ADD GrantYear int(4);
UPDATE Main SET GrantYear = Year(SubmittedDate);

ALTER TABLE Main ADD FlagBad int(4);

UPDATE Main SET FlagBad = 1
WHERE 	(InvestigatorALLLastName LIKE '%MATR %') OR
(InvestigatorALLLastName LIKE '%To Be hired%') OR
(InvestigatorALLLastName LIKE '%Postdoc%') OR
(InvestigatorALLLastName LIKE '%Research%') OR
(InvestigatorALLLastName LIKE '%TBH%') OR
(InvestigatorALLLastName LIKE '%TBD%') OR
(InvestigatorALLLastName LIKE '%TBA%') OR
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

SELECT Count(FlagBad) FROM Main;







########################### TwoMode -------------------------


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

DELETE FROM TwoMode;

LOAD DATA LOCAL INFILE '/Users/elenapalesis/dropbox/grant collaborations 2015/data files/TwoMode_table.txt' 
INTO TABLE TwoMode 
FIELDS TERMINATED BY '\t' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

DELETE FROM TwoMode
WHERE PIEmployeeID = "PI Employee ID";



########################### PairedInvestigators --------------
DROP TABLE PairedInvestigators;


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








#Delete rows where at least one investigator is a nameholder/blank
DELETE FROM  PairedInvestigators
WHERE 	(InvestigatorID1 LIKE '%MATR %') OR
(InvestigatorID1 LIKE '%To Be hired%') OR
(InvestigatorID1 LIKE '%Postdoc%') OR
(InvestigatorID1 LIKE '%Research%') OR
(InvestigatorID1 LIKE '%TBH%') OR
(InvestigatorID1 LIKE '%TBD%') OR
(InvestigatorID1 LIKE '%TBA%') OR
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





