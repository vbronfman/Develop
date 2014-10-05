#copy files
use File::Basename;
use File::Path qw(make_path);  
$DEST=$ARGV[1];

open (FILE, "<", $ARGV[0]) or die "Can not open $ARGV[0]";

while(<FILE>){
chomp;
($SHARE_NAME,$FILE_PATH)=split (/\$/, $_);

$SOURCE_NAME= dirname "$_";
$SOURCE_RESOURCE_NAME=$SOURCE_NAME;

$DEST_PATH="${DEST}$FILE_PATH";
$DIR_NAME=dirname "${DEST}${FILE_PATH}";
$BASENAME=basename "${DEST}${FILE_PATH}";
#print " DIRNAME ",$DIR_NAME, "\n\n";
#print " BASENAME ", $BASENAME, "\n\n";

if (! -d "$DIR_NAME" ) {
    unless (make_path($DIR_NAME)){
        print "error create ", dirname "${DEST}$FILE_PATH", "error  $0: $! \n"; next;
    }
}

#print "copy $SOURCE_NAME to $DIR_NAME\n";
$CMD=qq{xcopy /C/Y $_ $SOURCE_NAME $DIR_NAME};
#unless (`$CMD`){
#    print "Error $CMD : $! \n\n";
#}


 $SOURCE_NAME=~s/(.*\\)[a-zA-Z0-9]+$/${1}RESOURCES/;
${DIR_NAME}=~s/(.*)\\[a-zA-Z0-9]+$/${1}/;
if ( -d $SOURCE_NAME && ! -d "${DIR_NAME}\\RESOURCES"){

print "copy $SOURCE_NAME to $DIR_NAME\\RESOURCES \n";
unless (`xcopy /I/E $SOURCE_NAME $DIR_NAME\\RESOURCES`){
    print "ERROR while xcopy $SOURCE_NAME $DIR_NAME: $? $!";
}

}
}

close FILE;