#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

my $leaguequery = "select distinct league from fgbatters";
my $playerquery = "select ab, pa, h, bb, doubles, triples, hr, league, so from fgbatters where league = ? and age < 28";
my $isopquery = "select sum(ab) as ab, sum(doubles) as doubles, sum(triples) as triples, sum(hr) as hr, sum(pa) as pa, sum(so) as so from fgbatters where league=? and age < 28 group by league";
my $wobaquery = "select sum(pa) as pa, sum(h) as h, sum(bb) as bb, sum(doubles) as doubles, sum(triples) as triples, sum(hr) as hr from fgbatters where league=? and age < 28 group by league";
my $agequery = "insert into leagues (league, isop, isopstddev, woba, wobastddev, krate, kratestddev) VALUES (?,?,?,?,?,?,?)";

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
        my $pa = $data[4];
        my $so = $data[5];

        if ($ab != 0) {
            my $isop = ($doubles + ($triples * 2) + ($hr * 3)) / $ab;
            $isophash{$lg} = $isop;
            $kratehash{$lg} = ($so / $pa);
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
   $isopcount = 0;
   $wobacount = 0;
   $kratecount = 0;

   $playersth->execute($leagues[$i]);
   while (@data = $playersth->fetchrow_array()) {
       my $st = 0;
       my $ab = $data[$st++];
       my $pa = $data[$st++];
       my $h = $data[$st++];
       my $bb = $data[$st++];
       my $doubles = $data[$st++];
       my $triples = $data[$st++];
       my $hr = $data[$st++];
       my $league = $data[$st++];
       my $k = $data[$st++];
       my $singles = $h - $doubles - $triples - $hr;

       next if ($ab == 0);

       my $isop = ($doubles + ($triples * 2) + ($hr * 3)) / $ab;
       my $woba = ((0.72 * $bb) + (0.9 * $singles) + (1.24 * $doubles)
                + (1.56 * $triples) + (1.95 * $hr)) / $pa;
       my $krate = ($k / $pa);
       
       $isopvariance = ($isop - $isophash{$league}) * ($isop - $isophash{$league});
       $wobavariance = ($woba - $wobahash{$league}) * ($woba - $wobahash{$league});
       $kratevariance = ($krate - $kratehash{$league}) * ($krate - $kratehash{$league});
       
       $isopcount = $isopcount + $isopvariance;
       $wobacount = $wobacount + $wobavariance;
       $kratecount = $kratecount + $kratevariance;
 
       $playercount++;
   }

       my $wobastddev = sqrt($wobacount / $playercount);
       my $isopstddev = sqrt($isopcount / $playercount);
       my $kratestddev = sqrt($kratecount / $playercount);
       my $lg = $leagues[$i];
       print "$leagues[$i] wobastddev[$wobastddev] isopsttdev[$isopstddev] kratestddev[$kratestddev]\n";
       $agesth->execute($leagues[$i], $isophash{$leagues[$i]}, $isopstddev,
            $wobahash{$leagues[$i]}, $wobastddev, $kratehash{$leagues[$i]}, $kratestddev);
}
