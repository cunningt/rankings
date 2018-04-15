#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;


my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

my $leaguequery = "select distinct league from pitchers";
my $playerquery = "select age, bf, league from pitchers where league = ? and age < 28";
my $agequery = "insert into pitcherages (age, stddev, league) VALUES (?,?,?)";

my $isth = $dbh->prepare($query);

my $leaguesth = $dbh->prepare($leaguequery);
$leaguesth->execute();

while (@data = $leaguesth->fetchrow_array()) {
    my $league = $data[0];
    push (@leagues, $league);
}

my $playersth = $dbh->prepare($playerquery);
my $agesth = $dbh->prepare($agequery);
for ($i = 0; $i<@leagues; $i++) {

   $playercount = 0;
   $pacount = 0;
   $agecount = 0;

   $playersth->execute($leagues[$i]);
   while (@data = $playersth->fetchrow_array()) {
       my $age = $data[0];
       my $pa = $data[1];
       $playercount++;
       $pacount += $pa;
       $agecount += ($pa * $age);
   }

   if ($pacount > 0 ) {
	$avgage = $agecount / $pacount;

        $playersth->execute($leagues[$i]);
	$agecount = 0;
        while (@data = $playersth->fetchrow_array()) {
           my $age = $data[0];
           my $pa = $data[1];
           
           $agecount += (($avgage-$age)*($avgage-$age));
        }

        my $stddev = sqrt($agecount / $playercount);
        print "$leagues[$i] average age[$avgage] stddev[$stddev]\n";

	$agesth->execute($avgage, $stddev, $leagues[$i]);	 
   }
}
