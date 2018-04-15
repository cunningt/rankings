#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

$pa = 10;
$limit = 50;
$league = $ARGV[0];

if ($league eq '') {
    $leaguestring = "";
} else {
    $leaguestring = "b.level = '$league' and ";
}

my $both_comb_query = "select b.uid, b.name, b.league, b.age, b.pa, (((s.both_adjusted_woba/2) + s.both_adjusted_isop) * (1 - s.krate) * (1 - s.krate)) as comb, s.isop, s.woba, s.krate from batters b, stats s where $leaguestring b.uid=s.uid and b.pa > $pa order by comb desc limit $limit";

my $both_comb_sth = $dbh->prepare($both_comb_query);

header();
print "<table class=\"pure-table pure-table-horizontal\"><thead>\n";
print "<tr><th>Name</th><th>League</th><th>Age</th><th>PA</th><th>ISO</th><th>wOBA</th><th>K%</th><th>COMB</th></tr></thead>\n";
$both_comb_sth->execute();
while (@data = $both_comb_sth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[6]</td><td>$data[7]</td><td>$data[8]</td><td>$data[5]</td></tr>\n";
}
print "</table>\n";
footer();

exit 0;


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
