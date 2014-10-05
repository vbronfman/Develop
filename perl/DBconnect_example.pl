######
# DBI connect example
# http://www.perl.com/pub/1999/10/DBI.html
##

#use DBI;
#
##$dbname = "dbi:Sybase:server=YourDBHost;database=YourTable";
#$dbname = "dbi:Oracle:vantst3";
#$dbuser = "reports";
#$dbpass = "reports";
#
#my $dbh = DBI->connect($dbname,$dbuser,$dbpass,{PrintError => 0});
#if (!$dbh) { die "Unable for connect to server: $DBI::errstr\n" }
#
#my $query = "Your SQL query here";
#my $sth = $dbh->prepare($query);
#$sth->execute;
#if ($DBI::errstr) { print "$DBI::errstr\n" }
#while (@row = $sth->fetchrow_array) { print join(',',@row)."\n" }
#$sth->finish;

use DBI;
use DBD::Oracle;
use Partner::Init;

use constant DEBUG=>1;

my($DB, $USER)=@ARGV;
print_msg (DEBUG,$DB);

#dbi:Oracle:host=$orachehost:sid=$oraclesid",
#$dbh = DBI->connect("dbi:Oracle:dbname", "username", "passwd", {PrintError => 1, RaiseError => 0, AutoCommit => 1,})
$dbh = DBI->connect("dbi:Oracle:$DB", $USER, $USER, {PrintError => 1, RaiseError => 0, AutoCommit => 1,})
            or die "Couldn't connect to database: " . DBI->errstr;
            
            #select  *from Mpscftab where cfcode in(14,17)
            
#        my $sth = $dbh->prepare('SELECT * FROM people WHERE lastname = ?')
#;select  * from Mpscftab where cfcode in (14,17)
        #my $sth = $dbh->prepare('select host from  gmd_destination where host = \'HOST\' OR host = \'HOME\'')
        #        or die "Couldn't prepare statement: " . $dbh->errstr;
        
$label="\'MAILCOM_30042012\', \'core_billing_29042012\'";
                  
        $sql_request=<<SQL;
        -----prepare file for billing version script SYSADM@BSCSDOC
select DISTINCT a.default_username||\'/\'||a.default_username||\'@\'||a.default_db||\' \'|| b.filename||\' UNKNOWN\'
,a.label_name,b.label_seq,b.seq
 from install_labels a ,install_files b
where a.seq = b.label_seq
AND LABEL_NAME in  (
$label
 )
and username is null
union
select DISTINCT B.username||\'/\'||B.username||\'@\'||B.db||\' \'|| b.filename||\' UNKNOWN\'
,a.label_name,b.label_seq,b.seq
 from install_labels a ,install_files b
where a.seq = b.label_seq
AND LABEL_NAME in (
$label
 )
and username is not null
order by label_seq,seq
SQL

print $sql_request;


my $sth = $dbh->prepare(qq{$sql_request})
                or die "Couldn't prepare statement: " . $dbh->errstr;
        
                $label="\'MAILCOM_30042012\', \'core_billing_29042012\'";
#$sth->execute('core_billing_29042012','core_billing_29042012');
$sth->execute();
$sth->rows;

while(@data = $sth->fetchrow_array()){

#@data = $sth->fetchrow_array();

print_msg ( DEBUG, join('----',@data));
@data;

}



############################################################
#Prepare request

 my $sth = $dbh->prepare('SELECT * FROM people WHERE lastname = ?')
                or die "Couldn't prepare statement: " . $dbh->errstr;


        print "Enter name> ";
        while ($lastname = <>) {               # Read input from the user
          my @data;
          chomp $lastname;
          $sth->execute($lastname)             # Execute the query
            or die "Couldn't execute statement: " . $sth->errstr;

          # Read the matching records and print them out          
          while (@data = $sth->
                 ()) {
            my $firstname = $data[1];
            my $id = $data[2];
            print "\t$id: $firstname $lastname\n";
          }

          if ($sth->rows == 0) {
            print "No names matched `$lastname'.\n\n";
          }

          $sth->finish;
          print "\n";
          print "Enter name> ";
        }
      
      
#If you're doing an UPDATE, INSERT, or DELETE there is no data that comes back from the database, so there is a short cut. You can say
#
 $dbh->do('DELETE FROM people WHERE age > 65');
#
#for example, and DBI will prepare the statement, execute it, and finish it. do returns a true value if it succeeded, and a
#false value if it failed. Actually, if it succeeds it returns the number of affected rows. In the example it would return
#the number of rows that were actually deleted. (DBI plays a magic trick so that the value it turns is true even when it is 0.
#This is bizarre, because 0 is usually false in Perl. But it's convenient because you can use it either as a number or as a
#true-or-false success code, and it works both ways.)      
          
        $dbh->disconnect;
