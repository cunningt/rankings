#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
use Math::Complex;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

my $agesquery = "select age, stddev, league from pitcherages"; 
my $playerquery = "select uid, league, age, g, bf, ip, h, r, er, bb, so, hbp, hr from pitchers";
my $statsquery = "insert into pitcherstats(uid, bfpergame, adjustedbfpergame, kminusbb, adjustedkminusbb, kminusbbip, adjustedkminusbbip, fip, adjustedfip) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

my $agesth = $dbh->prepare($agesquery);
my $playersth = $dbh->prepare($query);
$agesth->execute();

my %avgagehash = ();
my %stddevhash = ();
while (@data = $agesth->fetchrow_array()) {
    my $age = $data[0];
    my $stddev = $data[1];
    my $league = $data[2];
    
    $avgagehash{$league} = $age;
    $stddevhash{$league} = $stddev; 
}

my $playersth = $dbh->prepare($playerquery);
my $statsth = $dbh->prepare($statsquery);
$playersth->execute;
while (@data = $playersth->fetchrow_array()) {
    #uid, league, age, g, bf, ip, h, r, er, bb, so, hbp
    my $uid = $data[0];
    my $league = $data[1];
    my $age = $data[2];
    my $g = $data[3];
    my $bf = $data[4];
    my $ip = $data[5];
    my $h = $data[6];
    my $r = $data[7];
    my $er = $data[8];
    my $bb = $data[9];
    my $so = $data[10];
    my $hbp = $data[11];
    my $hr = $data[12];
 
    my $agediff = $avgagehash{$league} - $age;
    my $stddiff = $agediff / (2 * $stddevhash{$league});

    if (($g > 0) && ($ip > 0)) {
	
        my $bfg = $bf / $g;
        my $kminusbb = ($so / $bf)  - ($bb / $bf);
        my $kminusbbip = ($so - $h - (.72 * $bb)) / $ip;
	    
        if ($stddevhash{$league} != 0) { 
	}

    my $agefactor = ($avgagehash{$league} - $age) / $stddevhash{$league};
	my $adjkminusbbip = 0;	
    my $adjustedfip = 0;
    my $fip = (((13 * $hr) + (3 * $bb) - (2 * $so)) / $ip) + 3.2;
    $adjkminusbbip = ($kminusbbip * (5/(1+$stddiff)));
    $adjustedfip = $fip * (5/(1 + $stddiff));

    $statsth->execute($uid, $bfg, ($bfg * $agefactor), 
				$kminusbb, ($kminusbb * $agefactor),
				$kminusbbip, $adjkminusbbip, $fip, 
                                $adjustedfip );
    }
}
