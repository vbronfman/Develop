use File::Basename;

$file="H:\\VERSION\\billing_version_1.txt";


open(FILE,$file) or die "cancnot oopen fffff";
open(OUT,">","$file.out");
while(<FILE>){
    chomp;
    ($user,$pass,$schema,$sql)=split(/;/);
$sql=(basename ($sql,".sql"));
print OUT "$user\/$pass\@$schema $sql.sql UNKNONW\n";
}

close FILE;
close OUT;