#!/bin/bash -x
source ~/conf

# constants
TIMEOUT_SECS=30
#cmd="aws elbv2 '$op' --target-group-arn ${TARGET_GROUP_ARN}"
cmd="aws elbv2 " #'$op' --target-group-arn ${TARGET_GROUP_ARN}"
# remove from elb and wait for instance to be actually removed
remove_from_lb_and_wait() {
        echo "removing $1"
        #remove instance

        op=deregister-targets
        eval $cmd $op --target-group-arn ${TARGET_GROUP_ARN}  --targets Id=$1

        #wait till actually removed
        sleep $TIMEOUT_SECS
        #verify instances are registered or deregistered
        op=describe-target-health
        [[ $(eval $cmd $op --target-group-arn ${TARGET_GROUP_ARN} --targets Id=$1 --query 'TargetHealthDescriptions[0].[TargetHealth.State]' --output text) =~ 'healthy' ]] && echo "[ERROR] wasn't regestred " # ad-hoc - have to add parsing of actual error with --query

}

# insert into elb and wait for instance to be in service
insert_into_lb_and_wait() {
        echo "inserting $1"
        #add instance
        op=register-targets
        eval $cmd $op --target-group-arn ${TARGET_GROUP_ARN}  --targets Id=$1
        #wait till inservice
        sleep $TIMEOUT_SECS
        #verify instances are registered or deregistered
        op=describe-target-health
        [[ $(eval $cmd $op --target-group-arn ${TARGET_GROUP_ARN}  --targets Id=$1 --query 'TargetHealthDescriptions[0].[TargetHealth.State]' --output text ) =~ 'healthy' ]] || echo "[ERROR] wasn't regestred " # ad-hoc - have to add parsing of actual error with --query
}

# deploy
deploy_instance() {
        echo "deploying $1"
        # update ~/index.html with your name
        file2upd='~/index.html'
        # to update use: sshInstance.sh INSTANCE_ID COMMAND
        ./sshInstance.sh i-0af0045b65bf54372 "[[ -w $file2upd ]] && echo $USER >  file2upd "  #for simplicity sake validation is ommited here
}

#main
main() {
        echo "ELB URL is: $ELB_URL"
        #get the list of instances from the LB
        #loop over all instances in the LB (no need to change)
        op=describe-target-health
        list=$( eval $cmd $op --target-group-arn ${TARGET_GROUP_ARN}   --output text | grep -w 'TARGET' | awk '{ print $2}' ) # ugly, I know, but I'm running out of time
        for current in $list; do
                echo now at: $current
                remove_from_lb_and_wait $current
                deploy_instance $current
                insert_into_lb_and_wait $current
        done
}

main
