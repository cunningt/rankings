#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

$pa = 75;
$limit = 50;
$league = $ARGV[0];

if ($league eq '') {
    $leaguestring = "";
} else {
    $leaguestring = "b.level = '$league' and ";
}

my $adj_bbrate_query = "select b.uid, b.name, b.league, b.age, b.pa, s.adjusted_bbrate, s.bbrate from batters b, stats s where $leaguestring b.uid=s.uid and b.pa > $pa order by adjusted_bbrate desc limit $limit";
my $adj_isop_query = "select b.uid, b.name, b.league, b.age, b.pa, s.age_adjusted_isop as age_adjusted_isop, s.isop, s.krate from batters b, stats s where $leaguestring b.uid=s.uid and b.pa > $pa order by age_adjusted_isop desc limit $limit";
my $adj_woba_query = "select b.uid, b.name, b.league, b.age, b.pa, s.age_adjusted_woba, s.woba, s.krate from batters b, stats s where $leaguestring b.uid=s.uid and b.pa > $pa order by age_adjusted_woba desc limit $limit";
my $adj_comb_query = "select b.uid, b.name, b.league, b.age, b.pa, ((s.age_adjusted_woba/2) + s.age_adjusted_isop) as comb, s.age_adjusted_isop, s.age_adjusted_woba from batters b, stats s where $leaguestring b.uid=s.uid and b.pa > $pa order by comb desc limit $limit";


my $teen_bbrate_query = "select b.uid, b.name, b.league, b.age, b.pa, s.bbrate from batters b, stats s where $leaguestring b.uid=s.uid and b.age < 20 and b.pa > $pa order by bbrate desc limit $limit";
my $teen_isop_query = "select b.uid, b.name, b.league, b.age, b.pa, s.isop from batters b, stats s where $leaguestring b.uid=s.uid and b.age < 20 and b.pa > $pa order by isop desc limit $limit";
my $teen_woba_query = "select b.uid, b.name, b.league, b.age, b.pa, s.woba from batters b, stats s where $leaguestring b.uid=s.uid and b.age < 20 and b.pa > $pa order by woba desc limit $limit";


my $lg_adj_isop_query = "select b.uid, b.name, b.league, b.age, b.pa, s.lg_adjusted_isop, s.isop from batters b, stats s where $leaguestring b.uid=s.uid and b.pa > $pa order by lg_adjusted_isop desc limit $limit";
my $lg_adj_woba_query = "select b.uid, b.name, b.league, b.age, b.pa, s.lg_adjusted_woba, s.woba from batters b, stats s where $leaguestring b.uid=s.uid and b.pa > $pa order by lg_adjusted_woba desc limit $limit";
my $isop_query = "select b.uid, b.name, b.league, b.age, b.pa, s.isop from batters b, stats s where $leaguestring b.uid=s.uid and b.age < 28 and b.pa > $pa order by isop desc limit $limit";
my $woba_query = "select b.uid, b.name, b.league, b.age, b.pa, s.woba from batters b, stats s where $leaguestring b.uid=s.uid and b.age < 28 and b.pa > $pa order by woba desc limit $limit";

my $both_isop_query = "select b.uid, b.name, b.league, b.age, b.pa, s.both_adjusted_isop from batters b, stats s where $leaguestring b.uid=s.uid and b.age < 28 and b.pa > $pa order by both_adjusted_isop desc limit $limit";
my $both_woba_query = "select b.uid, b.name, b.league, b.age, b.pa, s.both_adjusted_woba from batters b, stats s where $leaguestring b.uid=s.uid and b.age < 28 and b.pa > $pa order by both_adjusted_woba desc limit $limit";
my $both_comb_query = "select b.uid, b.name, b.league, b.age, b.pa, ((s.both_adjusted_woba/2) + s.both_adjusted_isop) as comb, s.both_adjusted_isop, s.both_adjusted_woba, s.krate from batters b, stats s where $leaguestring b.uid=s.uid and b.pa > $pa order by comb desc limit $limit";




my $adjbbratesth = $dbh->prepare($adj_bbrate_query);
my $adjisopsth = $dbh->prepare($adj_isop_query);
my $adjwobasth = $dbh->prepare($adj_woba_query);
my $adjcombsth = $dbh->prepare($adj_comb_query);
my $lg_adj_isop_sth = $dbh->prepare($lg_adj_isop_query);
my $lg_adj_woba_sth = $dbh->prepare($lg_adj_woba_query);
my $both_adj_isop_sth = $dbh->prepare($both_isop_query);
my $both_adj_woba_sth = $dbh->prepare($both_woba_query);
my $both_comb_sth = $dbh->prepare($both_comb_query);

my $teenbbratesth = $dbh->prepare($teen_bbrate_query);
my $teenisopsth = $dbh->prepare($teen_isop_query);
my $teenwobasth = $dbh->prepare($teen_woba_query);
my $isopsth = $dbh->prepare($isop_query);
my $wobasth = $dbh->prepare($woba_query);

header();

print <<HTML;
      <div class="row">
        <div class="span4">
          <h2>BB rate % adjusted by age</h2>
          <table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>Adj BB Rate</th><th>BB Rate</th></tr></thead>\n";
$adjbbratesth->execute();
while (@data = $adjbbratesth->fetchrow_array()) {
   print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td><td>$data[6]</td></tr>\n";
}

print <<HTML;
	   </table>
        </div>
        <div class="span4">
          <h2>ISOP adjusted by age</h2>
          <table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>Adj ISOP</th><th>ISOP</th></tr></thead>\n";
$adjisopsth->execute();
while (@data = $adjisopsth->fetchrow_array()) {
   print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td><td>$data[6]</td></tr>\n";
}

print <<HTML;
          </table>
       </div>
        <div class="span4">
          <h2>wOBA adjusted by age</h2>
          <table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>Adj wOBA</th><th>wOBA</th></tr></thead>\n";
$adjwobasth->execute();
while (@data = $adjwobasth->fetchrow_array()) {
   print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td><td>$data[6]</td></tr>\n";
}

print <<HTML;
</table>
</div>
<div class="span4">
<h2>ISOP + wOBA/2 adj by age</h2>
<table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>adj ISOP+WOBA/2</th><th>adjISOP</th><th>adjWOBA</th></tr></thead>\n";
$adjcombsth->execute();
while (@data = $adjcombsth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td><td>$data[6]</td><td>$data[7]</td></tr>\n";
}


print <<HTML;
         </table>
        </div>
      </div>
      <hr>
      <div class="row">
        <div class="span4">
          <h2>Teen BB rate %</h2>
          <table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>BB Rate</th></tr></thead>\n";
$teenbbratesth->execute();
while (@data = $teenbbratesth->fetchrow_array()) { 
   print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
          </table>
        </div>
        <div class="span4">
          <h2>Teen ISOP</h2>
          <table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>ISOP</th></tr></thead>\n";
$teenisopsth->execute();
while (@data = $teenisopsth->fetchrow_array()) {
   print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}  

print <<HTML;
          </table>
       </div>
        <div class="span4">
          <h2>Teen wOBA</h2>
          <table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>wOBA</th></tr></thead>\n";
$teenwobasth->execute();
while (@data = $teenwobasth->fetchrow_array()) {
   print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}  


print <<HTML;
</table>
</div>
</div>
<hr>
<div class="row">
<div class="span4">
<h2>League Adjusted ISOP %</h2>
<table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>ISOP</th></tr></thead>\n";
$lg_adj_isop_sth->execute();
while (@data = $lg_adj_isop_sth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
</table>
</div>
<div class="span4">
<h2>ISOP</h2>
<table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>ISOP</th></tr></thead>\n";
$isopsth->execute();
while (@data = $isopsth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}



print <<HTML;
</table>
</div>
<div class="span4">
<h2>League Adjusted WOBA</h2>
<table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>wOBA</th></tr></thead>\n";
$lg_adj_woba_sth->execute();
while (@data = $lg_adj_woba_sth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
</table>
</div>
</div>
<hr>
<div class="row">
<div class="span4">
<h2>Both Adjusted ISOP %</h2>
<table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>ISOP</th></tr></thead>\n";
$both_adj_isop_sth->execute();
while (@data = $both_adj_isop_sth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
</table>
</div>
<div class="span4">
<h2>Both Adjusted WOBA</h2>
<table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>WOBA</th></tr></thead>\n";
$both_adj_woba_sth->execute();
while (@data = $both_adj_woba_sth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}



print <<HTML;
</table>
</div>
<div class="span4">
<h2>COMB</h2>
<table class="pure-table pure-table-horizontal">
HTML

print "<thead><tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>COMB</th></tr></thead>\n";
$both_comb_sth->execute();
while (@data = $both_comb_sth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

footer();

sub header() {
print <<HTML;
<!DOCTYPE html>
<html lang="en">
  <head>
      <link rel="stylesheet" href="https://unpkg.com/purecss\@1.0.0/build/pure-min.css" integrity="sha384-nn4HPE8lTHyVtfCBi5yW9d20FjT8BJwUXyWZT9InLYax14RDjBj46LmSztkmNP9w" crossorigin="anonymous">
  </head>

  <body>
HTML
}

sub footer() {
print <<HTML;
  </body>
</html>
HTML
}

