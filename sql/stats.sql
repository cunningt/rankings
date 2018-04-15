# WARNING: Cannot generate character set or collation names without the --server option.
# CAUTION: The diagnostic mode is a best-effort parse of the .frm file. As such, it may not identify all of the components of the table correctly. This is especially true for damaged files. It will also not read the default values for the columns and the resulting statement may not be syntactically correct.
# Reading .frm file for stats.frm:
# The .frm file is a TABLE.
# CREATE TABLE Statement:

CREATE TABLE `stats` (
  `uid` int(11) NOT NULL, 
  `isop` float NOT NULL, 
  `age_adjusted_isop` float NOT NULL, 
  `lg_adjusted_isop` float NOT NULL, 
  `both_adjusted_isop` float NOT NULL, 
  `bbrate` float NOT NULL, 
  `adjusted_bbrate` float NOT NULL, 
  `woba` float NOT NULL, 
  `age_adjusted_woba` float NOT NULL, 
  `lg_adjusted_woba` float NOT NULL, 
  `both_adjusted_woba` float NOT NULL, 
  `krate` float NOT NULL, 
  `adjusted_krate` float NOT NULL, 
PRIMARY KEY `PRIMARY` (`uid`)
) ENGINE=InnoDB;

#...done.
