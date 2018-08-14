CREATE TABLE `fgstats` (
  `nameurl` varchar(96) NOT NULL,
  `level` varchar(96) NOT NULL, 
  `isop` float NOT NULL, 
  `age_adjusted_isop` float NOT NULL, 
  `lg_adjusted_isop` float NOT NULL, 
  `both_adjusted_isop` float NOT NULL, 
  `xiso` float NOT NULL,
  `age_adjusted_xiso` float NOT NULL,
  `lg_adjusted_xiso` float NOT NULL,
  `both_adjusted_xiso` float NOT NULL,
  `bbrate` float NOT NULL, 
  `adjusted_bbrate` float NOT NULL, 
  `woba` float NOT NULL, 
  `age_adjusted_woba` float NOT NULL, 
  `lg_adjusted_woba` float NOT NULL, 
  `both_adjusted_woba` float NOT NULL, 
  `krate` float NOT NULL, 
  `adjusted_krate` float NOT NULL 
) ENGINE=InnoDB;

