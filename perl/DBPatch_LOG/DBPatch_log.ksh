#!/bin/ksh 
#Should be located along with /ITLAB_share/Amdocs_DBTools/DB_PATCH/rosh_db_patch.sh

REMOTE_HOST=test_user@it4tst3
LOG=/tmp/`basename $0`_`date '+%H:%M-%d-%h-%Y'`
exec 1>>$LOG
exec 2>&1 

print $0 started ${*} 

FILE=`basename $1`
[[ -z ${FILE} ]] || exit 1

DIR=`dirname $1`

MASK=`echo $FILE | sed -e 's/\.log$/\.\*/'`

export MASK=$DIR/$MASK

if [[ -e ${MASK} ]];then
print File ${MASK} not exist 
exit 1
fi



#echo  "scp $MASK $REMOTE_HOST:/tmp/ && ssh $REMOTE_HOST /ITLAB_share/itlab/DBPatch_LOG/DBPatch_log.pl /tmp/$FILE" | at now
#echo "scp $MASK $REMOTE_HOST:/tmp/ &&  ssh $REMOTE_HOST \"cd /ITLAB_share/itlab/DBPatch_LOG && /ITLAB_share/itlab/DBPatch_LOG/DBPatch_log.pl /tmp/$FILE\" " | at now
 cp $MASK /ITLAB_share/tmp/ 
 ssh -v $REMOTE_HOST "/ITLAB_share/itlab/DBPatch_LOG/DBPatch_log.pl /ITLAB_share/tmp/$FILE" 
echo $0 finished $? 