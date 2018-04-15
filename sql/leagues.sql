# WARNING: Cannot generate character set or collation names without the --server option.
# CAUTION: The diagnostic mode is a best-effort parse of the .frm file. As such, it may not identify all of the components of the table correctly. This is especially true for damaged files. It will also not read the default values for the columns and the resulting statement may not be syntactically correct.
# Reading .frm file for leagues.frm:
# The .frm file is a TABLE.
# CREATE TABLE Statement:

CREATE TABLE `leagues` (
  `league` varchar(96) NOT NULL, 
  `isop` float NOT NULL, 
  `isopstddev` float NOT NULL, 
  `woba` float NOT NULL, 
  `wobastddev` float NOT NULL, 
  `krate` float NOT NULL, 
  `kratestddev` float NOT NULL 
) ENGINE=InnoDB;

#...done.
