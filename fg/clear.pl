#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

my $isth = $dbh->prepare("delete from fgages");
$isth->execute();
my $isth = $dbh->prepare("delete from fgbatters");
$isth->execute();
my $isth = $dbh->prepare("delete from fgbattedball");
$isth->execute();
my $isth = $dbh->prepare("delete from fgleagues");
$isth->execute();
my $isth = $dbh->prepare("delete from fgstats");
$isth->execute();

system("./fangraphs.pl > log 2>&1");
system("./fangraphsbattedball.pl > log 2>&1");
system("./fgaverageage.pl");
system("./fgaverageleague.pl");
system("./fgstats.pl");
system("./fgcombkrate.pl > xiso.html");

exit 0;
