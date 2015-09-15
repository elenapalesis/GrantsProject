LOAD DATA LOCAL INFILE '/Users/elenapalesis/dropbox/grant collaborations 2015/R Code - building relations file/grants2015copy.txt' 
INTO TABLE Main 
FIELDS TERMINATED BY '\t' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';