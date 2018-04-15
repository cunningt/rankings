CREATE TABLE fgbirthdate (
  `nameurl` varchar(26) NOT NULL,
  `name` varchar(192) NOT NULL, 
  `birthdate` datetime NOT NULL, 
   unique key `nameurl` (`nameurl`)
) ENGINE=InnoDB;

