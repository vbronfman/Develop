#!bash 
 
# Initial setup and start. 
#     Assigns listening port of EXPOSER;
#     Creates .env file of environment variables for docker-compose
#     Creates target file for prometheus
#     Commence docker-compose build_and_run
# 
# For simplicity sake processing of input args and help are omitted.
# Script process 

#required for "regex" of 'case' loop
shopt -s extglob 
declare -A def_ports=( [exposer]=8000 [scraper]=9090 [viewer]=3000 )
#declare -A new_ports #deprecated

#set ports to expose
get_ports(){

cat << MSG
Script sets initial configuration of this contraption. Refer README.md for details

NOTE! It is urgely recomended to keep ports of scraper and VIEWER intact: both employs 
well-known ports - changing would result in integration issue.

Hit <Enter> to keep default
MSG
 
	 
for param in ${!def_ports[@]};do
read -p "Enter port for $param  [${def_ports[${param}]}] :" port

case $port in
+([0-9]) )   #proper input - change value
         def_ports[$param]=$port
		 echo Service $param port $port
		 ;;
"" )         #new_ports[$param]=${def_ports[$param]} 
        ;;
*)
		 echo Wrong input, going to keep default value
		 ;;
esac

done
}

#Sets targets by creating corresponding file of prometheus/<target>.json
# Updates general prometheus_jaml with target references.
generate_targets_file(){
  prometheus_targets_dir='prometheus/targets'
  prometheus_jaml="prometheus/prometheus.yaml"

#fetch service and port definitions
  for param in ${!def_ports[@]};do

    targetfile=${prometheus_targets_dir}/${param}.json
    echo '[' > $targetfile #opens JSON
    cat << EOS >> ${targetfile}  #ugly, I know
  {
    "labels": {
      "job": "${param}" 
    },
    "targets": [
      "${param}:${def_ports[$param]}"
    ]
  }
EOS
    echo ']' >> $targetfile #close JSON
	
### append content of prometheus.jaml if there is no corresponding section
    job=${param}
 # hideous pattern is to suppress lines of #;if there is commented - 'job_name:' script will add a new one.
 # bypass if there is string  
    grep -P "job_name\s*:\s*[\"\']$job" <<<$(grep '^[[:blank:]]*[^[:blank:]#;]' $prometheus_jaml)  && continue

   cat << EOS >> $prometheus_jaml
  - job_name: '$job'  
    file_sd_configs:
      - files:
        - /etc/prometheus/targets/${job}.json
EOS
done
}

#creates .env in root of the project.
# VARNAME=VALUE 
generate_env_file(){ 
  env_file=".env"
  :> $env_file 
  
  for param in ${!def_ports[@]};do
	echo ${param^^}_PORT=${def_ports[$param]} >> $env_file
  done 
}

build_and_run(){

  bash -cx 'docker-compose up -d && docker-compose ps'

}

<< 'DEPRECATED' 
#traverses directory tree and replaces PORTs in all files
replace_port(){
shopt -s globstar nullglob  #to avoid 'find' employing for collecting filenames
echo $DEBUG curr $0

  
 # sed -i -e "s///g" -e "s///g" $file
 for param in ${!def_ports[@]};do
    patterns+=" -e 's/${def_ports[$param]}/${new_ports[$param]}/g'"
 
 for file in **/*;do  #get file list 
#bypass ./setup.sh itself and folders
  if [[ ! -f $file || $file == $(basename $0) ]] ;then continue;fi
  
  echo Filename is $file
  cmd="sed -i $patterns $file"
 echo sed command: $cmd
 eval $cmd #  ?
done
done
}
DEPRECATED


#### main ###
get_ports
generate_targets_file
generate_env_file 

echo "Environment has been set. "
read -p "Proceed with build:[y/N]" confirm
if [[ $confirm == 'y' ]];then
    build_and_run
else
   echo "You can build and start with 'docker-compose up' later on "
fi


 
