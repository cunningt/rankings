CREATE TABLE `fgbattedball` (
  `nameurl` varchar(26) NOT NULL, 
  `name` varchar(192) NOT NULL, 
  `age` float NOT NULL, 
  `team` varchar(96) NOT NULL, 
  `league` varchar(96) NOT NULL, 
  `level` varchar(96) NOT NULL, 
  `ldpercentage` float NOT NULL, 
  `gbpercentage` float NOT NULL, 
  `fbpercentage` float NOT NULL, 
  `iffbpercentage` float NOT NULL, 
  `pullpercentage` float NOT NULL, 
  `centpercentage` float NOT NULL, 
  `oppopercentage` float NOT NULL, 
  `swstr` float NOT NULL, 
  `balls` smallint(6) NOT NULL, 
  `strikes` smallint(6) NOT NULL, 
  `pitches` smallint(6) NOT NULL, 
PRIMARY KEY `PRIMARY` (`nameurl`)
) ENGINE=InnoDB;

#...done.
