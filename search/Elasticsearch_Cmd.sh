
curl -XPUT localhost:9200/test -d'{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0 }
   }'
   
   
