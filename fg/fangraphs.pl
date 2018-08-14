#!/usr/local/Cellar/perl/5.26.0/bin/perl

use Date::Calc qw/Delta_Days/;
use LWP::Simple;
use HTML::TableExtract qw(tree);
use DBI;
use DBD::mysql;
use Data::Dumper;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

my $leaguesquery = "select leagueid, league, level, year from fgleaguelist where year = ?";
my $leaguesth = $dbh->prepare($leaguesquery);

my $query = "insert into fgbatters(nameurl, name, age, team, league, level, games, pa, ab, r, h, doubles, triples, hr, rbi, bb, so) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
my $isth = $dbh->prepare($query);

my $birthdatequery = "select birthdate from fgbirthdate where nameurl = ?";
my $birthsth = $dbh->prepare($birthdatequery);

my $birthinsertquery = "insert into fgbirthdate(nameurl, name, birthdate) VALUES (?, ?, ?)";
my $birthinsertsth = $dbh->prepare($birthinsertquery);

my $urltemplate = "https://www.fangraphs.com/minorleaders.aspx?pos=all&stats=bat&lg=%arg%&qual=0&type=0&season=2018&team=0&players=0&page=1_700";
my $year = defined($ARGV[0]) ? shift(@ARGV) : "2018";

$leaguesth->execute($year);
while (@row = $leaguesth->fetchrow_array()) {
    my ($leagueid, $league, $level, $year) = @row;

    my $url = $urltemplate;
    $url =~ s|%arg%|$leagueid|;

    print "$league ... fetching data [$url]...\n";
    insertBatters($url, $league, $level);
}

sub findAge {
    my ($uid, $name) = @_;
    
    print "UID $uid NAME $name\n";   
        
    $birthsth->execute($uid);
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
    $page = get("https://www.fangraphs.com/statss.aspx?playerid=". $uid);
    if ($page =~ m|Birthdate: <[^>]+>([^\s]+) |g) {
        $age = $1;
        my @date = split(/\//, $age);
        my $dbage = $date[2] . "-" . $date[0] . "-" . $date[1];
        
        # Insert the ID/birthdate into the database
        if ($resultsflag == false) {
            $birthinsertsth->execute($uid, $name, $dbage);
        }
        
        my($day, $month, $year)=(localtime)[3,4,5];
        my @today = (1900 + $year, 1 + $month, $day);
        my @birth = ($date[2], $date[0], $date[1]);
        
        my $dd = Delta_Days(@birth, @today);
        
        return ($dd / 365 ) ;
    }
}

sub insertBatters {
	my ($url, $lg, $level) = @_;
	my $page = get($url);
	my $te = new HTML::TableExtract( count => 3 );
	$te->parse($page);

	foreach my $ts ($te->tables) {
           my $tree = $ts->tree();
	   my $rowcount = 1;
	   foreach my $row ($ts->rows) {
		$maxrow = $#{$ts->rows};
	        $rowcount++;
                next if ($rowcount <= 2);
		next if ($rowcount > $maxrow);

        my $uidcell = $tree->cell($rowcount,0)->as_HTML;
        my $uid = "";
        if ($uidcell =~ m|playerid=([^&]+)&|) {
            $uid = $1;
        }        

		my $cell = $tree->cell($rowcount,1)->as_HTML;
        $cell =~ s|.*href=\"||;
		$cell =~ s|\".*||;
		$age = findAge($uid, $tree->cell($rowcount,0)->as_text);

		my $team = $tree->cell($rowcount,1)->as_text;
                $team =~ s| \([^)]+\)||;
	
		my $player = {
			name=>$tree->cell($rowcount,0)->as_text,
            uid=>$uid,
			age=>$age,
			team=>$team,
            league=>$lg,
			level=>$level,
			games=>$tree->cell($rowcount,3)->as_text,
			pa=>$tree->cell($rowcount,5)->as_text,
			ab=>$tree->cell($rowcount,4)->as_text,
			r=>$tree->cell($rowcount,11)->as_text,
			h=>$tree->cell($rowcount,6)->as_text,
            doubles=>$tree->cell($rowcount,8)->as_text,
			triples=>$tree->cell($rowcount,9)->as_text,
			hr=>$tree->cell($rowcount,10)->as_text,
			rbi=>$tree->cell($rowcount,12)->as_text,
			bb=>$tree->cell($rowcount,13)->as_text,
			k=>$tree->cell($rowcount,15)->as_text
			};

            print "PLAYER " . Dumper(\$player) . "\n";
            
            $isth->execute($uid,
                $tree->cell($rowcount,0)->as_text,
                $age,
                $team,
                $lg,
                $level,
                $tree->cell($rowcount,3)->as_text,
                $tree->cell($rowcount,5)->as_text,
                $tree->cell($rowcount,4)->as_text,
                $tree->cell($rowcount,11)->as_text,
                $tree->cell($rowcount,6)->as_text,
                $tree->cell($rowcount,8)->as_text,
                $tree->cell($rowcount,9)->as_text,
                $tree->cell($rowcount,10)->as_text,
                $tree->cell($rowcount,12)->as_text,
                $tree->cell($rowcount,13)->as_text,
                $tree->cell($rowcount,15)->as_text);
                
	   }
	} 
}
