# Install and start
bin/elasticsearch 

curl http://localhost:9200/

# Get indices
curl -X GET localhost:9200
curl -X GET localhost:9200/_cat/indices

# New index myindex
curl -XPUT localhost:9200/myindex

# New index test with settings
curl -XPUT localhost:9200/test -d 
 '{
   "settings": {
     "number_of_shards": 1,
     "number_of_replicas": 0 
     }
  }'
  
curl -XPUT localhost:9200/test -d 
 '{
   "settings": {
     "number_of_shards": 3,
     "number_of_replicas": 2 
     }
  }'
   
   
# Loading new data with PUT
curl -XPUT localhost:9200/indexP/test/id1 -d 
 '{
    "name": "raul",
    "gender": "m"
  }'

# Loading new data with POST
curl -XPOST localhost:9200/indexP/test -d 
 '{
    "name": "raul",
    "gender": "m"
  }'

# Quering
curl localhost:9200/indexP/_search?pretty
curl -XGET localhost:9200/indexP/test/_search
curl -XGET localhost:9200/indexP/test/id1

# Free text search
curl -XPOST "http://localhost:9200/indexP/test" -d
 '{
   "gender": "m"
  }'
  

# Delete the index
curl -XDELETE localhost:9200/indexP


