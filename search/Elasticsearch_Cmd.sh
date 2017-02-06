
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
   
   

   
