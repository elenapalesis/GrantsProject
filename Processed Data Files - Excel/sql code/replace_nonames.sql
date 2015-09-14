 UPDATE practice_table
 SET InvestigatorAllLastName = replace(InvestigatorAllLastName, '~', 'NA~')
 WHERE InvestigatorAllLastName LIKE '~%';
 
 UPDATE practice_table
 SET InvestigatorAllLastName = replace(InvestigatorAllLastName, '~~', '~NA~')
 WHERE InvestigatorAllLastName LIKE '%~~%';