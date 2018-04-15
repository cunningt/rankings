# WARNING: Cannot generate character set or collation names without the --server option.
# CAUTION: The diagnostic mode is a best-effort parse of the .frm file. As such, it may not identify all of the components of the table correctly. This is especially true for damaged files. It will also not read the default values for the columns and the resulting statement may not be syntactically correct.
# Reading .frm file for pitcherstats.frm:
# The .frm file is a TABLE.
# CREATE TABLE Statement:

CREATE TABLE `pitcherstats` (
  `uid` int(11) NOT NULL, 
  `bfpergame` float NOT NULL, 
  `adjustedbfpergame` float NOT NULL, 
  `kminusbb` float NOT NULL, 
  `adjustedkminusbb` float NOT NULL, 
  `kminusbbip` float NOT NULL, 
  `adjustedkminusbbip` float NOT NULL, 
  `fip` float NOT NULL, 
  `adjustedfip` float NOT NULL, 
PRIMARY KEY `PRIMARY` (`uid`)
) ENGINE=InnoDB;

#...done.
