#!perl -w
#
#   $Id: 40bindparam.t 6304 2006-05-17 21:23:10Z capttofu $ 
#
#   This is a skeleton test. For writing new tests, take this file
#   and modify/extend it.
#


use Test::More;
use DBI ();
use vars qw($table $test_dsn $test_user $test_password);
use lib 't', '.';
require 'lib.pl';

my $dbh;
eval {$dbh = DBI->connect($test_dsn, $test_user, $test_password,
  { RaiseError => 1, AutoCommit => 1}) or ServerError();};

if ($@) {
    plan skip_all => "ERROR: $DBI::errstr. Can't continue test";
} 
plan tests => 10;

ok $dbh->do("DROP TABLE IF EXISTS $table"), "drop table $table";

my $create= <<EOT; 
CREATE TABLE $table (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    num INT(3))
EOT

ok $dbh->do($create), "create table $table";

ok $dbh->do("INSERT INTO $table VALUES(NULL, 1)"), "insert into $table (null, 1)";

my $rows;
$rows= $dbh->selectall_arrayref("SELECT * FROM $table") or die "select * from $table failed " . $dbh->errstr;

cmp_ok $rows->[0][1], '==', 1, "\$rows->[0][1] == 1";

$sth = $dbh->prepare("UPDATE $table SET num = ? WHERE id = ?") or die "Unable to update $table " . $dbh->errstr;

ok ($sth->bind_param(2, 1, SQL_INTEGER()));
  
ok ($sth->execute());

ok ($sth->finish());

$rows = $dbh->selectall_arrayref("SELECT * FROM $table") or die "select failed " . $dbh->errstr;

ok !defined($rows->[0][1]);

ok ($dbh->do("DROP TABLE $table"));

ok ($dbh->disconnect());
