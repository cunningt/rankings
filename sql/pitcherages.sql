# WARNING: Cannot generate character set or collation names without the --server option.
# CAUTION: The diagnostic mode is a best-effort parse of the .frm file. As such, it may not identify all of the components of the table correctly. This is especially true for damaged files. It will also not read the default values for the columns and the resulting statement may not be syntactically correct.
# Reading .frm file for pitcherages.frm:
# The .frm file is a TABLE.
# CREATE TABLE Statement:

CREATE TABLE `pitcherages` (
  `age` float NOT NULL, 
  `stddev` float NOT NULL, 
  `league` varchar(96) NOT NULL 
) ENGINE=InnoDB;

#...done.
