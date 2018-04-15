CREATE TABLE `fgbatters` (
  `nameurl` varchar(26) NOT NULL, 
  `name` varchar(192) NOT NULL, 
  `age` float NOT NULL, 
  `team` varchar(96) NOT NULL, 
  `league` varchar(96) NOT NULL, 
  `level` varchar(96) NOT NULL, 
  `games` smallint(6) NOT NULL, 
  `pa` smallint(6) NOT NULL, 
  `ab` smallint(6) NOT NULL, 
  `r` smallint(6) NOT NULL, 
  `h` smallint(6) NOT NULL, 
  `doubles` smallint(6) NOT NULL, 
  `triples` smallint(6) NOT NULL, 
  `hr` smallint(6) NOT NULL, 
  `rbi` smallint(6) NOT NULL, 
  `bb` smallint(6) NOT NULL, 
  `so` smallint(6) NOT NULL, 
PRIMARY KEY `PRIMARY` (`nameurl`)
) ENGINE=InnoDB;

#...done.
