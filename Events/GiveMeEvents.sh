#!/bin/bash
#
#Escrito por Pereyra Diego  2015
#pereyrdi@gmail.com
#

host="127.0.0.1"
user="USER"
psw="PASSWORD"
database="srmdbapi"
query="SELECT    
	    ( v_fact_event.event_key ),
	    ( v_dim_secure_model_nofx.model_name ), 
	    ( v_fact_event.time ),    
	    ( v_fact_event.event_msg ),
	    ( v_dim_event.title ),    
	    ( v_fact_event.landscape_h_hex ),
	    ( v_fact_event.type_hex ),
	    ( v_dim_event_creator.creator_name )
	FROM     
	    v_dim_event INNER JOIN v_fact_event ON (v_fact_event.type_dec=v_dim_event.type_dec)     
	    INNER JOIN v_dim_secure_model_nofx ON (v_fact_event.model_key=v_dim_secure_model_nofx.model_key)      
	    INNER JOIN v_dim_event_creator ON (v_fact_event.creator_id=v_dim_event_creator.creator_id)    
	WHERE 
	    (v_fact_event.time > NOW() - INTERVAL 90 MINUTE AND v_fact_event.time < NOW() - INTERVAL 89 MINUTE) 
	AND NOT ( v_dim_secure_model_nofx.model_name = 'SSPerformance')	
	AND NOT ( v_dim_secure_model_nofx.model_name = 'rpt_segment')		
	AND	( v_dim_event.title NOT LIKE '%SPM%')
	AND NOT ( v_dim_event.title = 'Alarm Generated')
	AND NOT ( v_dim_event.title = 'Alarm Cleared') 
"
##
##  0x11DB1	The SNMP engine on device {t}, named {m} has be
##  0x10306 Device Cold Started (2)

##	

myread() {
    local input
    IFpascS= read -r input || return $?
    while (( $# > 1 )); do
	IFS= read -r "$1" <<< "${input%%[$IFS]*}"
	input="${input#*[$IFS]}"
	shift
    done
    IFS= read -r "$1" <<< "$input"
	 }

Z="-0300"

while IFS=$'\t' myread event_key model_name time  event_msg title  landscape_h_hex type_hex creator_name ; do
	if [ "${event_key}" != "event_key" ]
		then	
			echo $event_msg | grep ^[^\]]*\] | awk 'NR==1'
			echo $event_msg > imput.txt			
			tr -cd '\11\12\15\40-\176' < imput.txt > output1.txt
			cat output1.txt | sed 's/\"//g' > output2.txt
			event_msg=`cat output2.txt`

			echo $titleg | grep ^[^\]]*\] | awk 'NR==1'
			echo $title > imput.txt
			tr -cd '\11\12\15\40-\176' < imput.txt > output1.txt
			cat output1.txt | sed 's/\"//g' > output2.txt
			title=`cat output2.txt`

			#$	"StartTime":"2015-09-10T09:40:53-0300",
			STARTTIME=${time:0:10}T${time:11:8}$Z
			MNAME=`echo ${model_name} | awk '{print toupper($0)}'`

			echo_json()
			{	
				echo "{"
				echo "\"EventKey\":\"${event_key}\","
				echo "\"ModelName\":\"${MNAME}\","			
				echo "\"Time\":\"${STARTTIME}\","
				echo "\"EventMessage\":\"${event_msg}\","
				echo "\"EventTitle\":\"${title}\","
				echo "\"Landscape\":\"${landscape_h_hex}\","
				echo "\"Type\":\"${type_hex}\","
				echo "\"Creator\":\"${creator_name}\""
				echo "}"
			}

			JSON=`echo_json`		
			URL="http://<ELASTICSEARCHIP>:9200/spec_events/srmdbapi/${event_key}"
			curl -s -XPUT "$URL" -d "$JSON"
			echo ""
	
	fi	
done < <(mysql -h${host} -u${user} -p${psw}  ${database} -e "${query}")
