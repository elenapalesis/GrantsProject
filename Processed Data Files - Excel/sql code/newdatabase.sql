LOAD DATA INFILE 'grants.csv' 
INTO TABLE FirstTable 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';