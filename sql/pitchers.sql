# WARNING: Cannot generate character set or collation names without the --server option.
# CAUTION: The diagnostic mode is a best-effort parse of the .frm file. As such, it may not identify all of the components of the table correctly. This is especially true for damaged files. It will also not read the default values for the columns and the resulting statement may not be syntactically correct.
# Reading .frm file for pitchers.frm:
# The .frm file is a TABLE.
# CREATE TABLE Statement:

CREATE TABLE `pitchers` (
  `uid` int(11) NOT NULL AUTO_INCREMENT, 
  `name` varchar(192) NOT NULL, 
  `age` float NOT NULL, 
  `team` varchar(96) NOT NULL, 
  `league` varchar(96) NOT NULL, 
  `g` smallint(6) NOT NULL, 
  `bf` smallint(6) NOT NULL, 
  `ip` float NOT NULL, 
  `h` smallint(6) NOT NULL, 
  `r` smallint(6) NOT NULL, 
  `er` smallint(6) NOT NULL, 
  `bb` smallint(6) NOT NULL, 
  `so` smallint(6) NOT NULL, 
  `hbp` smallint(6) NOT NULL, 
  `hr` smallint(6) NOT NULL, 
PRIMARY KEY `PRIMARY` (`uid`)
) ENGINE=InnoDB;

#...done.
