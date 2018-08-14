#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

my $agesquery = "select age, stddev, level from fgages";
my $leaguequery = "select league, isop, woba from fgleagues";
my $playerquery = "select nameurl, age, pa, ab, h, doubles, triples, hr, bb, league, level, so from fgbatters";

my $battedballquery = "select ldpercentage, gbpercentage, fbpercentage, iffbpercentage, pullpercentage from fgbattedball where nameurl = ? and level = ?";

my $statsquery = "insert into fgstats(nameurl, level, isop, age_adjusted_isop, lg_adjusted_isop, both_adjusted_isop, xiso, age_adjusted_xiso, lg_adjusted_xiso, both_adjusted_xiso, bbrate, adjusted_bbrate, woba, age_adjusted_woba, lg_adjusted_woba, both_adjusted_woba, krate, adjusted_krate) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

my $avgquery = "select avg(isop) as isop, avg(woba) as woba from leagues";

my $agesth = $dbh->prepare($agesquery);
my $leaguesth = $dbh->prepare($leaguequery);
my $playersth = $dbh->prepare($query);
my $avgsth = $dbh->prepare($avgquery);
my $bballsth = $dbh->prepare($battedballquery);

$agesth->execute();
$leaguesth->execute();
$avgsth->execute();

my %avgagehash = ();
my %stddevhash = ();
while (@data = $agesth->fetchrow_array()) {
    my $age = $data[0];
    my $stddev = $data[1];
    my $league = $data[2];
    
    $avgagehash{$league} = $age;
    $stddevhash{$league} = $stddev; 
}

my $avgisop = 0;
my $avgwoba = 0;
if (@data = $avgsth->fetchrow_array()) {
    $avgisop = $data[0];
    $avgwoba = $data[1];
}

my %wobastddevhash = ();
my %isopstddevhash = ();
while (@data = $leaguesth->fetchrow_array()) {
    my $league = $data[0];
    my $isopstddev = $data[1];
    my $wobastddev = $data[2];
    
    $wobastddevhash{$league} = $wobastddev;
    $isopstddevhash{$league} = $isopstddev;
}

my $playersth = $dbh->prepare($playerquery);
my $statsth = $dbh->prepare($statsquery);
$playersth->execute;
while (@data = $playersth->fetchrow_array()) {
    #uid, age, pa, ab, h, doubles, triples, hr, bb, league
    my $uid = $data[0];
    my $age = $data[1];
    my $pa = $data[2];
    my $ab = $data[3];
    my $h = $data[4];
    my $doubles = $data[5];
    my $triples = $data[6];
    my $hr = $data[7];
    my $bb = $data[8];
    my $league = $data[9];
    my $level = $data[10];
    my $so = $data[11];

    my $ldpercentage = 0;
    my $gbpercentage = 0;
    my $fbpercentage = 0;
    my $iffbpercentage = 0;
    my $pullpercentage = 0;

    $bballsth->execute($uid, $level);
    while (@bdata = $bballsth->fetchrow_array()) {
      $ldpercentage = $bdata[0];
      $gbpercentage = $bdata[1];
      $fbpercentage = $bdata[2];
      $iffbpercentage = $bdata[3];
      $pullpercentage = $bdata[4];
    }
 
    if ($ab > 0) {
        my $isop = ($doubles + ($triples * 2) + ($hr * 3)) / $ab;
        my $singles = $h - $doubles - $triples - $hr;
        my $woba = ((0.72 * $bb) + (0.9 * $singles) + (1.24 * $doubles)
            + (1.56 * $triples) + (1.95 * $hr)) / $pa;
        my $bbrate = $bb / $pa;

        # http://gameofinches.blogspot.com/2010/05/xiso-by-batted-ball-type.html
        
        my $popups = ($iffbpercentage / 100) * ($fbpercentage / 100);
        my $flyballs = ($fbpercentage/100) - $popups;
        my $xiso =
          + (.004 * $popups)
          + (.023 * $gbpercentage / 100)
          + (.624 * $flyballs)
          + (.289 * $lbpercentage / 100);

          print "$uid $level FB% [$fbpercentage] IFFB% [$iffbpercentage] LD% [$ldpercentage] GB% [$gbpercentage]\n";
          print "POPUPS [$popups] FLYBALLS [$flyballs]\n";
          $total = $popups + ($gbpercentage/100) + $flyballs + ($lbpercentage/100);
          print "TOTAL is $total should be 1\n";

        my $agediff = $avgagehash{$level} - $age;
        my $stddiff = $agediff / (2 * $stddevhash{$level});
        
        my $wobadiff = ($avgwoba - $wobastddevhash{$league}) / 3;
        my $wobamult = 1 + ($wobadiff / $avgwoba);
        my $isopdiff = ($avgisop - $isopstddevhash{$league}) / 3;
        my $isopmult = 1 + ($isopdiff / $avgisop);
        
        my $krate = $so / $pa;
        
        if (($uid == 303) || ($uid == 402)) {
            print "$uid $league $avgisop - $isopstddevhash{$league} = $isopdiff $isopmult\n";
            print "$uid $league $avgwoba - $wobastddevhash{$league} = $wobadiff $wobamult\n";
        }
        
        $statsth->execute($uid, $level,
                $isop, ($isop * (1+$stddiff)),
                ($isop * $isopmult),
                ($isop * (1+$stddiff) * $isopmult),
                $xiso, ($xiso * (1+$stddiff)),
                ($xiso * $isopmult),
                ($xiso * (1+$stddiff) * $isopmult),
		$bbrate, ($bbrate * (1+$stddiff)), 
                $woba, ($woba * (1+$stddiff)),
                ($woba * $wobamult),
                ($woba * (1+$stddiff) * $wobamult),
                $krate, ($krate * (1+$stddiff))
        );
    }
}
