#!/usr/local/Cellar/perl/5.26.0/bin/perl

use Date::Calc qw/Delta_Days/;
use LWP::Simple;
use HTML::TableExtract qw(tree);;
use DBI;
use DBD::mysql;
use Data::Dumper;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

my $year = defined($ARGV[0]) ? shift(@ARGV) : "2018";

my $leaguesquery = "select league, level, leaguehash, year from brleagues where year = ?";
my $leaguesth = $dbh->prepare($leaguesquery);

my $query = "insert into pitchers(name, age, team, league, g, bf, ip, h, r, er, bb, so, hbp, hr) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
my $isth = $dbh->prepare($query);

my $birthdatequery = "select birthdate from birthdate where nameurl = ?";
my $birthsth = $dbh->prepare($birthdatequery);

my $birthinsertquery = "insert into birthdate(nameurl, name, birthdate) VALUES (?, ?, ?)";
my $birthinsertsth = $dbh->prepare($birthinsertquery);

my $urltemplate = "http://www.baseball-reference.com/minors/leader.cgi?type=pitch&id=%arg%&sort_by=so";

$leaguesth->execute($year);
while (@row = $leaguesth->fetchrow_array()) {
   my ($league, $level, $leaguehash, $year) = @row;
   my $url = $urltemplate;
   $url =~ s|%arg%|$leaguehash|;

   print "$league ... fetching data ...\n";
   insertBatters($url);
}

sub findAge {
    my ($url, $name) = @_;
    
    $nameurl = $url;
    $nameurl =~ s|.*id=||;
    
    $birthsth->execute($nameurl);
    $resultsflag = false;
    if (@data = $birthsth->fetchrow_array()) {
        $resultsflag = true;
        my @date = split("-", $data[0]);
        $date[2] =~ s|^([0-9]+) .*|$1|;
        
        my($day, $month, $year)=(localtime)[3,4,5];
        my @today = (1900 + $year, 1 + $month, $day);
        
        my $dd = Delta_Days(@date, @today);
        return ($dd / 365 ) ;
    }
    
    # We can't find the birthdate in the db, need to query it from B-R.com
    $page = get("http://www.baseball-reference.com/". $url);
    if ($page =~ m|data-birth=\"([^\"]+)\"|g) {
        $age = $1;
        my @date = split("-", $age);
        print "DATE @date \n";

        # Insert the ID/birthdate into the database
        if ($resultsflag == false) {
            $birthinsertsth->execute($nameurl, $name, $age);
        }
        
        my($day, $month, $year)=(localtime)[3,4,5];
        my @today = (1900 + $year, 1 + $month, $day);

        my $dd = Delta_Days(@date, @today);
        
        return ($dd / 365 ) ;
    }
}

sub insertBatters {
	my ($url) = @_;
    print "URL $url\n";
	$page = get($url);
    
	my $te = new HTML::TableExtract(count => 0);
	$te->parse($page);
	foreach my $ts ($te->tables) {
       my $tree = $ts->tree();
       my $rowcount = 1;
       print "TS $ts\n";
	   foreach my $row ($ts->rows) {
        $maxrow = $#{$ts->rows};
        next if ($rowcount > $maxrow);
        next if ($rowcount > 100);
        
        #print "TREE " . Dumper(\$tree) . "\n";
        my $cell = $tree->cell($rowcount,1)->as_HTML;
           
           
        print "ROW " . $cell . "\n";
        $cell =~ s|.*href=\"||;
        $cell =~ s|\".*||;
        $age = findAge($cell, $tree->cell($rowcount,1)->as_text);
           
		my $player = {
			name=>$tree->cell($rowcount,1)->as_text,
			age=>$age,
			team=>$tree->cell($rowcount,3)->as_text,
			league=>$tree->cell($rowcount,4)->as_text,
            games=>$tree->cell($rowcount,11)->as_text,
            bf=>$tree->cell($rowcount,28)->as_text,
			ip=>$tree->cell($rowcount,17)->as_text,
			h=>$tree->cell($rowcount,18)->as_text,
			r=>$tree->cell($rowcount,19)->as_text,
			er=>$tree->cell($rowcount,20)->as_text,
            hr=>$tree->cell($rowcount,21)->as_text,
            bb=>$tree->cell($rowcount,22)->as_text,
			so=>$tree->cell($rowcount,24)->as_text,
			hbp=>$tree->cell($rowcount,25)->as_text
			};
        print Dumper(\$player) . "\n";
		#print "@$row[1] age[@$row[2]] team[@$row[3]] league[@$row[4]] g @$row[5] bf @$row[6] ip @$row[12] h @$row[13] r @$row[14] er @$row[15] bb @$row[17] so @$row[19] hbp @$row[20]\n";	
         
           $isth->execute($tree->cell($rowcount,1)->as_text, #name
           $age, #age
           $tree->cell($rowcount,3)->as_text, #team
           $tree->cell($rowcount,4)->as_text, #league
           $tree->cell($rowcount,11)->as_text, #g
           $tree->cell($rowcount,28)->as_text, #bf
           $tree->cell($rowcount,17)->as_text, #ip
           $tree->cell($rowcount,18)->as_text, #h
           $tree->cell($rowcount,19)->as_text, #r
           $tree->cell($rowcount,20)->as_text, #er
           $tree->cell($rowcount,22)->as_text, #bb
           $tree->cell($rowcount,24)->as_text, #so
           $tree->cell($rowcount,25)->as_text, #hbp
           $tree->cell($rowcount,21)->as_text); #hr
           $rowcount++;
	   }
	} 
}
