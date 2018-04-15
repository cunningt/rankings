# WARNING: Cannot generate character set or collation names without the --server option.
# CAUTION: The diagnostic mode is a best-effort parse of the .frm file. As such, it may not identify all of the components of the table correctly. This is especially true for damaged files. It will also not read the default values for the columns and the resulting statement may not be syntactically correct.
# Reading .frm file for ages.frm:
# The .frm file is a TABLE.
# CREATE TABLE Statement:

CREATE TABLE `ages` (
  `age` float NOT NULL, 
  `stddev` float NOT NULL, 
  `isop` float NOT NULL, 
  `woba` float NOT NULL, 
  `krate` float NOT NULL, 
  `level` varchar(96) NOT NULL 
) ENGINE=InnoDB;

#...done.
