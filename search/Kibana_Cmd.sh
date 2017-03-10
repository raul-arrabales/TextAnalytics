# Getting sample data sets: 

# Shakespeare data
# https://download.elastic.co/demos/kibana/gettingstarted/shakespeare.json 

# Fake bank customer data
# https://download.elastic.co/demos/kibana/gettingstarted/accounts.zip 

# Randomly generated log files
# https://download.elastic.co/demos/kibana/gettingstarted/logs.jsonl.gz

# Unzip the files: 
unzip accounts.zip
gunzip logs.jsonl.gz

# Shakespeare data mapping
curl -XPUT http://localhost:9200/shakespeare -d '
{
 "mappings" : {
  "_default_" : {
   "properties" : {
    "speaker" : {"type": "string", "index" : "not_analyzed" },
    "play_name" : {"type": "string", "index" : "not_analyzed" },
    "line_id" : { "type" : "integer" },
    "speech_number" : { "type" : "integer" }
   }
  }
 }
}
';

# Geo point mapping for logs in different dates
curl -XPUT http://localhost:9200/logstash-2015.05.18 -d '
{
  "mappings": {
    "log": {
      "properties": {
        "geo": {
          "properties": {
            "coordinates": {
              "type": "geo_point"
            }
          }
        }
      }
    }
  }
}
';
curl -XPUT http://localhost:9200/logstash-2015.05.19 -d '
{
  "mappings": {
    "log": {
      "properties": {
        "geo": {
          "properties": {
            "coordinates": {
              "type": "geo_point"
            }
          }
        }
      }
    }
  }
}
';
curl -XPUT http://localhost:9200/logstash-2015.05.20 -d '
{
  "mappings": {
    "log": {
      "properties": {
        "geo": {
          "properties": {
            "coordinates": {
              "type": "geo_point"
            }
          }
        }
      }
    }
  }
}
';

# Load all data using Bulk API
curl -XPOST 'localhost:9200/bank/account/_bulk?pretty' --data-binary @accounts.json
curl -XPOST 'localhost:9200/shakespeare/_bulk?pretty' --data-binary @shakespeare.json
curl -XPOST 'localhost:9200/_bulk?pretty' --data-binary @logs.jsonl

# Check indices:
curl 'localhost:9200/_cat/indices?v'

# Set Kibana index pattern similar to: 
# logstash-2015.05* 
# shakes*
# bank*


