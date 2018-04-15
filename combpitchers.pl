#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;

my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

$ip = 4;

my $adjustedkminusbb = "select p.uid, p.name, p.league, p.age, p.ip, ps.adjustedkminusbb, p.bb, p.so, ps.fip from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.ip > $ip order by ps.adjustedkminusbb desc limit 25";

my $adjustedkminusbbsth = $dbh->prepare($adjustedkminusbb);

my $lastupdatequery = "select lastupdate from pitchingupdate";
my $lastupdatesth = $dbh->prepare($lastupdatequery);

my $date = "";
$lastupdatesth->execute();
while (@data = $lastupdatesth->fetchrow_array()) {
    $date = $data[0];
}


header();
print "<table class=\"pure-table pure-table-horizontal\"><thead>\n";
print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>BB</th><th>K</th><th>FIP</th><th>KMinusBB</th></tr></thead>\n";
$adjustedkminusbbsth->execute();
while (@data = $adjustedkminusbbsth->fetchrow_array()) {
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
      <font size="1"><b>Generated:</b> $date</font>
HTML
}

sub footer() {
print <<HTML;
  </body>
</html>
HTML
}
