#!bash 

# Pre-build. 
# Assigns port numbers and #names of resources
# deliberately done in bash 
shopt -s extglob
declare -A def_ports=( [EXPOSER]=8000 [SCRAPPER]=9090 [VIEWER]=3000 )
declare -A new_ports

#EXPOSER=${EXPOSER:=8000}
#SCRAPPER=${PROMETHEUS:=9090}
#VIEWER=${VIEWER:=3000}

echo ${def_ports[@]}


get_params(){

for param in ${!def_ports[@]};do
read -p "Enter port for $param  [${def_ports[${param}]}] :" port

case $port in
+([0-9]) )   #proper input - change value
         new_ports[$param]=$port
		 echo value ${ports[@]}
		 ;;
"" )         new_ports[$param]=${def_ports[$param]} 
        ;;
*)
		 echo Wrong input, going to keep default value
		 ;;
esac


echo DEBUG $param port $port and ${new_ports[$param]}
done
}

replace_port(){
shopt -s globstar nullglob  #to avoid 'find' employing for collecting filenames
echo $DEBUG curr $0

  
 # sed -i -e "s///g" -e "s///g" $file
 for param in ${!def_ports[@]};do
    patterns+=" -e 's/${def_ports[$param]}/${new_ports[$param]}/g'"
 
 for file in **/*;do  #get file list 
#bypass ./setup.sh itself and  folders
  if [[ ! -f $file || $file == $(basename $0) ]] ;then continue;fi
  
  echo Filename is $file
  cmd="sed -i $patterns $file"
 echo sed command: $cmd
 eval $cmd #  ?
done
done
}


get_params
for i in ${!new_ports[@]} ;do
    echo Ok "$i -> ${new_ports[$i]}"
done
replace_port


 
