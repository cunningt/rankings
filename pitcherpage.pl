#!/usr/local/Cellar/perl/5.22.0/bin/perl

use DBI;
use DBD::mysql;
my $curdir = `pwd`;
chomp $curdir;
my $dbh = DBI->connect("DBI:mysql:mysql_read_default_file=$curdir/dbi.conf;mysql_read_default_group=minors", undef, undef, {});

$ip = 4;

my $bfpergame_query = "select p.uid, p.name, p.league, p.age, p.ip, ps.bfpergame from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.ip > $ip  order by ps.bfpergame desc limit 25";
my $kminusbb_query = "select p.uid, p.name, p.league, p.age, p.ip, ps.kminusbb from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.ip > $ip order by ps.kminusbb desc limit 25";
my $kminusbbip_query = "select p.uid, p.name, p.league, p.age, p.ip, ps.kminusbbip from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.ip > $ip order by ps.kminusbbip desc limit 25";

my $adj_bbrate_query = "select p.uid, p.name, p.league, p.age, p.ip, ps.adjustedbfpergame from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.ip > $ip  order by ps.adjustedbfpergame desc limit 25";
my $adj_isop_query = "select p.uid, p.name, p.league, p.age, p.ip, ps.adjustedkminusbb from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.ip > $ip order by ps.adjustedkminusbb desc limit 25";
my $adj_woba_query = "select p.uid, p.name, p.league, p.age, p.ip, ps.adjustedkminusbbip from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.ip > $ip order by ps.adjustedkminusbbip desc limit 25";

my $fip_query = "select p.uid, p.name, p.league, p.age, p.ip, ps.fip from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.ip > $ip order by fip asc limit 25";
my $adj_fip_query = "select p.uid, p.name, p.league, p.age, p.ip, ps.adjustedfip from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.ip > $ip order by adjustedfip asc limit 25";
my $teen_fip_query = "select p.uid, p.name, p.league, p.age, p.ip, ps.fip from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.age < 20 and p.ip > $ip order by fip asc limit 25";


my $teen_bbrate_query = "select p.uid, p.name, p.league, p.age, p.ip, ps.bfpergame from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.age < 20 and p.ip > $ip order by bfpergame desc limit 25";
my $teen_isop_query = "select p.uid, p.name, p.league, p.age, p.ip, ps.kminusbb from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.age < 20 and p.ip > $ip order by ps.kminusbb desc limit 25";
my $teen_woba_query = "select p.uid, p.name, p.league, p.age, p.ip, ps.kminusbbip from pitchers p, pitcherstats ps where p.age < 26 and p.uid=ps.uid and p.age < 20 and p.ip > $ip order by ps.kminusbbip desc limit 25";

my $bfpergamesth = $dbh->prepare($bfpergame_query);
my $kminusbbsth = $dbh->prepare($kminusbb_query);
my $kminusbbipsth = $dbh->prepare($kminusbbip_query);

my $adjbbratesth = $dbh->prepare($adj_bbrate_query);
my $adjisopsth = $dbh->prepare($adj_isop_query);
my $adjwobasth = $dbh->prepare($adj_woba_query);

my $fipsth = $dbh->prepare($fip_query);
my $adjfipsth = $dbh->prepare($adj_fip_query);
my $teenfipsth = $dbh->prepare($teen_fip_query);

my $teenbbratesth = $dbh->prepare($teen_bbrate_query);
my $teenisopsth = $dbh->prepare($teen_isop_query);
my $teenwobasth = $dbh->prepare($teen_woba_query);

print <<HTML;
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Prospect Screens</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le styles -->
    <link href="bootstrap/css/bootstrap.css" rel="stylesheet">
    <style type="text/css">
      body {
        padding-top: 60px;
        padding-bottom: 40px;
      }
    </style>
    <link href="bootstrap/css/bootstrap-responsive.css" rel="stylesheet">

    <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

  </head>

  <body>

    <div class="container">

      <!-- Main hero unit for a primary marketing message or call to action -->
      <div class="hero-unit">
        <h1>Prospect Rankings by Age</h1>
        <p>These are a few sample screens of weighted prospect performance by age.  I'm looking for some constructive feedback here - what I've done is for each league (South Atlantic, Eastern, International, etc) I've computed the average age.   I then found the standard deviation for each level, and then applied a bonus to each player <i>(1 + (difference of age from mean/(10*stdev)))</i>.    This should result in statistics that can be compared cross-level and cross-league.</p>
        <p>It's a work in progress and quick and dirty - for example for wOBA, I've just used the linear weights from 2011 MLB rather than trying to compute them for each league.</p>
        <p><a class="btn btn-primary btn-large">Learn more &raquo;</a></p>
      </div>

<!-- Example row of columns -->
<div class="row">
<div class="span4">
<h2>FIP</h2>
<table>
HTML

print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>FIP</th></tr>\n";
$fipsth->execute();
while (@data = $fipsth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
</table>
</div>
<div class="span4">
<h2>ADJ FIP</h2>
<table>
HTML

print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>ADJ FIP</th></tr>\n";
$adjfipsth->execute();
while (@data = $adjfipsth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
</table>
</div>
<div class="span4">
<h2>TEEN FIP</h2>
<table>
HTML

print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>FIP</th></tr>\n";
$teenfipsth->execute();
while (@data = $teenfipsth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
</table>
</div>
<div class="span4">
<h2>KMinusBB/IP</h2>
<table>
HTML

print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>BFPerGame</th></tr>\n";
$bfpergamesth->execute();
while (@data = $bfpergamesth->fetchrow_array()) {
   print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
	   </table>
        </div>
        <div class="span4">
          <h2>KMinusBB</h2>
          <table>
HTML

print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>KMinusBB</th></tr>\n";
$kminusbbsth->execute();
while (@data = $kminusbbsth->fetchrow_array()) {
   print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
          </table>
       </div>
        <div class="span4">
          <h2>KMinusBB/IP</h2>
          <table>
HTML

print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>KMinusBB/IP</th></tr>\n";
$kminusbbipsth->execute();
while (@data = $kminusbbipsth->fetchrow_array()) {
   print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
</table>
</div>
</div>
<hr>
<div class="row">
<div class="span4">
<h2>Adjusted BFPG</h2>
<table>
HTML

print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>BFPerGame</th></tr>\n";
$adjbbratesth->execute();
while (@data = $adjbbratesth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
</table>
</div>
<div class="span4">
<h2>KMinusBB adjusted by age</h2>
<table>
HTML

print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>KMinusBB</th></tr>\n";
$adjisopsth->execute();
while (@data = $adjisopsth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
</table>
</div>
<div class="span4">
<h2>KMinusBB/IP adjusted by age</h2>
<table>
HTML

print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>KMinusBB/IP</th></tr>\n";
$adjwobasth->execute();
while (@data = $adjwobasth->fetchrow_array()) {
    print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}



print <<HTML;
         </table>
        </div>
      </div>
      <hr>
      <div class="row">
        <div class="span4">
          <h2>Teen BFPG</h2>
          <table>
HTML

print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>BFPerGame</th></tr>\n";
$teenbbratesth->execute();
while (@data = $teenbbratesth->fetchrow_array()) { 
   print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}

print <<HTML;
          </table>
        </div>
        <div class="span4">
          <h2>Teen KMinusBB</h2>
          <table>
HTML

print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>KMinusBB</th></tr>\n";
$teenisopsth->execute();
while (@data = $teenisopsth->fetchrow_array()) {
   print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}  

print <<HTML;
          </table>
       </div>
        <div class="span4">
          <h2>Teen KMinusBB/IP</h2>
          <table>
HTML

print "<tr><th>Name</th><th>League</th><th>Age</th><th>IP</th><th>KMinusBB/IP</th></tr>\n";
$teenisopsth->execute();
while (@data = $teenisopsth->fetchrow_array()) {
   print "<tr><td>$data[1]</td><td>$data[2]</td><td>$data[3]</td><td>$data[4]</td><td>$data[5]</td></tr>\n";
}  

print <<HTML;
          </table>
        </div>
      </div>
      <hr>

      <footer>
        <p>&copy; Tom Cunningham cunningt@gmail.com 2012</p>
      </footer>

    </div> <!-- /container -->

    <!-- Le javascript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="bootstrap/js/jquery.js"></script>
    <script src="bootstrap/js/bootstrap-transition.js"></script>
    <script src="bootstrap/js/bootstrap-alert.js"></script>
    <script src="bootstrap/js/bootstrap-modal.js"></script>
    <script src="bootstrap/js/bootstrap-dropdown.js"></script>
    <script src="bootstrap/js/bootstrap-scrollspy.js"></script>
    <script src="bootstrap/js/bootstrap-tab.js"></script>
    <script src="bootstrap/js/bootstrap-tooltip.js"></script>
    <script src="bootstrap/js/bootstrap-popover.js"></script>
    <script src="bootstrap/js/bootstrap-button.js"></script>
    <script src="bootstrap/js/bootstrap-collapse.js"></script>
    <script src="bootstrap/js/bootstrap-carousel.js"></script>
    <script src="bootstrap/js/bootstrap-typeahead.js"></script>

  </body>
</html>
HTML
