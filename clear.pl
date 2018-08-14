#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

my $isth = $dbh->prepare("delete from ages");
$isth->execute();
my $isth = $dbh->prepare("delete from batters");
$isth->execute();
my $isth = $dbh->prepare("delete from leagues");
$isth->execute();
my $isth = $dbh->prepare("delete from pitcherages");
$isth->execute();
my $isth = $dbh->prepare("delete from pitchers");
$isth->execute();
my $isth = $dbh->prepare("delete from pitcherstats");
$isth->execute();
my $isth = $dbh->prepare("delete from stats");
$isth->execute();

system("./baseballreference.pl > log 2>&1");
system("./averageage.pl");
system("./averageleague.pl");
system("./stats.pl");
system("./combkrate.pl > prospects.html");
system("./prospectpage.pl > prospectpage.html");
system("./prospectpagekrate.pl > prospectpagekrate.html");


system("./baseballreferencepitchers.pl");
system("./pitcheraverageage.pl");
system("./pitcherstats.pl");
system("./combpitchers.pl > pitchers.html");
system("./pitcherpage.pl > pitcherpage.html");

exit 0;
