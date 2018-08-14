#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

my $leaguequery = "select distinct level from fgbatters";
my $playerquery = "select age, pa, level from fgbatters where level = ? and age < 28";
my $isopquery = "select sum(ab) as ab, sum(doubles) as doubles, sum(triples) as triples, sum(hr) as hr, sum(so) as so, sum(pa) as pa from fgbatters where level=? and age < 28 group by level";
my $wobaquery = "select sum(pa) as pa, sum(h) as h, sum(bb) as bb, sum(doubles) as doubles, sum(triples) as triples, sum(hr) as hr from fgbatters where level=? and age < 28 group by level";
my $agequery = "insert into fgages (age, stddev, isop, woba, krate, level) VALUES (?,?,?,?,?,?)";

my $isth = $dbh->prepare($query);

my $leaguesth = $dbh->prepare($leaguequery);
$leaguesth->execute();

while (@data = $leaguesth->fetchrow_array()) {
    my $league = $data[0];
    push (@leagues, $league);
}

$leaguesize = @leagues;

my $isopsth = $dbh->prepare($isopquery);
for ($i = 0; $i < $leaguesize; $i++) {
    my $lg = $leagues[$i];
    
    $isopsth->execute($leagues[$i]);
    while (@data = $isopsth->fetchrow_array()) {
        my $ab = $data[0];
        my $doubles = $data[1];
        my $triples = $data[2];
        my $hr = $data[3];
        my $so = $data[4];
        my $pa = $data[5];

        if ($ab != 0) {
            my $isop = ($doubles + ($triples * 2) + ($hr * 3)) / $ab;
            $isophash{$lg} = $isop;
            $krate = $so / $pa;
            $kratehash{$lg} = $krate;
        } else {
            $isophash{$lg} = 0;
            $kratehash{$lg} = 0;
        }
    }
}
my $wobasth = $dbh->prepare($wobaquery);
for ($i = 0; $i < $leaguesize; $i++) {
    my $league = $leagues[$i];
    $wobasth->execute($leagues[$i]);

    while (@data = $wobasth->fetchrow_array()) {
        my $pa = $data[0];
        my $h = $data[1];
        my $bb = $data[2];
        my $doubles = $data[3];
        my $triples = $data[4];
        my $hr = $data[5];
        my $singles = $h - $doubles - $triples - $hr;
        
        if ($pa != 0) {
            my $woba = ((0.72 * $bb) + (0.9 * $singles) + (1.24 * $doubles)
                + (1.56 * $triples) + (1.95 * $hr)) / $pa;
            $wobahash{$league} = $woba;
        } else {
            $wobahash{$league} = 0;
        }
    }
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
       my $lg = $leagues[$i];
       print "$leagues[$i] average age[$avgage] stddev[$stddev] isop[$isophash{$lg}] woba[$wobahash{$lg}] krate[$kratehash{$lg}]\n";
       $agesth->execute($avgage, $stddev, $isophash{$leagues[$i]}, $wobahash{$leagues[$i]},
           $kratehash{$leagues[$i]}, $leagues[$i]);
   }
}
