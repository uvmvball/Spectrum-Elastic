# Spectrum-Elastic
Integration between spectrum and elasticsearch for alarmas and events.

CA Spectrum is licensed by CA technologies www.ca.com

Elasticsearch and Kibana are from www.elastic.co 

All the rest of integration is from my own :)


# Arquitectura

Spectrum Alarm Notifier  → elasticsearch ←→ kibana

MySQL srmdbapi.db ← scheduled script → elasticsearch ←→ kibana

<img src="https://github.com/pereyrdi/Spectrum-Elastic/blob/master/arquitectura.png" />
<br>


# Requerimientos
I inform the used version of each tool, but this can vary without generating drawbacks in the integration.

•	SO LINUX

•	Kibana 4.6.0

•	Elasticsearch 2.4.0

•	CA Spectrum 9.2

# Implementation
It is not going to indicate the steps to integrate each tool, only focus focus on the configuration of the integration.

# ElasticSearch
	# Mapping 
	Mapping is the process of defining how a document, and the fields it contains, are stored and indexed
	•	Mapping\spec_alarms
	•	Mapping\spec_events

	ie curl -XPOST <ELASTICSEARCHIP>:9200/spec_events -d ‘{............ 

# Kibana
	# Index Pattern
	Add new index into kibana from elastic
	•	Index name or pattern "spec_alarms", time-field name "StarTime"
	•	Index name or pattern "spec_events", time-field name "Time"

	# Scripted fields for "spec_alarms"
	“AlarmDuration” 
	((doc[’EndTime’]) - (doc[’StartTime’])) < 0 ? 1 : ((doc[’EndTime’]) - (doc[’StartTime’])) 

# Spectrum - DB Events
Where the ReporManager is instaled (or in a remote server) 
	Events/GiveMeEvents.sh get 1 minute of events between "NOW() - INTERVAL 90 MINUTE AND v_fact_event.time < NOW() - INTERVAL 89 MINUTE"

	This script is installed in crontab
	*/3   *    *    *    *     /opt/Spectrum/mysql/bin/GiveMeEvents.sh &> /dev/null

# Spectrum - AlarmNotifier
Where AlarmNotifier is working you must create a new instance for AlarmNotifier, here the files

	<$SPECROOT/lib/SDPM/partslist>
		ELASTICSEARCH.idb

	<$SPECROOT/Notifier>
	•	.ElasticSearchRC
	•	ElasticSearch_SetScript
	•	ElasticSearch_UpdateScript
	•	ElasticSearch_ClearScript
	•	ModelClassArray.sh

# Spectrum - AlarmNotifier - Attributes
	0x12adb	CollectionsModelNameString
	0x12022	TicketID
	0x11564	Notes	
	0x23000d	Location	(SNMP Location)
	0x12bfb	USER_AssetTag	
	0x12bfc	USER_AssetID	
	0x12bfd	USER_AssetOwner	
	0x12bfe	USER_AssetOrganization	
	0x12bff	USER_AssetOffice	
	0x12c03	USER_AssetDescription	
	0x129e7	TopologyModelNameString	
	0x11ee8	Model_Class	
	0x12b4c	AlarmTittle (GEO Location) such as ”-30.21705,-64.13628”
	0x118cd	DeviceLocation


# Spectrum - Oneclick - SANM
You must restart the proccesd service to see the new APP for AlarmNotifier installed.
LOCATER → SANM → ALL APPLICATIONS: ElasticSearchDB SANMApp appears
Then we create a Policy (SANMPolicy) for this App, and then a filter where you can selectd which alarms will be sent to AlarmNotifier/ElasticSearchRC



An then.... in ElasticSearchDb.OUT

{”_index”:”spec_alarms”,”_type”:”SANM”,”_id”:”9189358”,”_version”:1,”_shards”:{”total”:1,”successful”:1,”failed”:0},”created”:true}
{”_index”:”spec_alarms”,”_type”:”SANM”,”_id”:”9183217”,”_version”:1,”_shards”:{”total”:1,”successful”:1,”failed”:0},”created”:true}
{”_index”:”spec_alarms”,”_type”:”SANM”,”_id”:”7983171”,”_version”:1,”_shards”:{”total”:1,”successful”:1,”failed”:0},”created”:true}

<img src="https://github.com/pereyrdi/Spectrum-Elastic/blob/master/MIX.png" />

Enjoy !
Diego Pereyra
From Argentine
