# Install and start
# ./elasticsearch -Ecluster.name=my_cluster_name -Enode.name=my_node_name
bin/elasticsearch 

# Get status
# Get back stats for merge and refresh only for all indices
curl 'localhost:9200/_stats/merge,refresh'
# Get back stats for type1 and type2 documents for the my_index index
curl 'localhost:9200/my_index/_stats/indexing?types=type1,type2


curl http://localhost:9200/

# Get indices
curl -X GET localhost:9200
curl -X GET localhost:9200/_cat/indices

# Shards status
curl -X GET localhost:9200/_cat/shards

# Cluster health
curl -XGET 'localhost:9200/_cat/health?v&pretty'

# List of nodes
curl -XGET 'localhost:9200/_cat/nodes?v&pretty'

# Peeking indices
curl -XGET 'localhost:9200/_cat/indices?v&pretty'

# Creating new indices
curl -XPUT 'localhost:9200/cliente?pretty&pretty'
curl -XGET 'localhost:9200/_cat/indices?v&pretty'

# Index a document (external type, id = 1). 
curl -XPUT 'localhost:9200/cliente/external/1?pretty&pretty' -H 'Content-Type: application/json' -d'
{
  "name": "Raul"
}'

curl -XPUT 'localhost:9200/cliente/external/2?pretty&pretty' -H 'Content-Type: application/json' -d'
{
  "name": "Ralph"
}'

# Retrieving documents
curl -XGET 'localhost:9200/cliente/external/1?pretty&pretty'
curl -XGET 'localhost:9200/cliente/external/2?pretty&pretty'

# This will return a found: false
curl -XGET 'localhost:9200/cliente/external/3?pretty&pretty'

# Delete an index (cliente index)
curl -XDELETE 'localhost:9200/cliente?pretty'

# Same ID, different document
curl -XPUT 'localhost:9200/cliente/external/2?pretty&pretty' -H 'Content-Type: application/json' -d'
{
  "name": "Ralph2"
}'
# Check version number
curl -XGET 'localhost:9200/cliente/external/2?pretty&pretty'

# Adding a document without ID (POST instead of PUT):
curl -XPOST 'localhost:9200/cliente/external?pretty&pretty' -H 'Content-Type: application/json' -d'
{
  "name": "Ralph III"
}'

# Update a document
curl -XPOST 'localhost:9200/cliente/external/1/_update?pretty&pretty' -H 'Content-Type: application/json' -d'
{
  "doc": { "name": "Raplh I" }
}'

curl -XPOST 'localhost:9200/cliente/external/1/_update?pretty&pretty' -H 'Content-Type: application/json' -d'
{
  "doc": { "name": "Ralph I", "age": 30 }
}'

curl -XGET 'localhost:9200/cliente/external/1?pretty&pretty'

# Using scripts to update
curl -XPOST 'localhost:9200/cliente/external/1/_update?pretty&pretty' -H 'Content-Type: application/json' -d'
{
  "script" : "ctx._source.age += 5"
}'

# Batch processing
curl -XPOST 'localhost:9200/cliente/external/_bulk?pretty&pretty' -H 'Content-Type: application/json' -d'
{"index":{"_id":"1"}}
{"name": "Ralph I" }
{"index":{"_id":"2"}}
{"name": "Ralph II" }'

curl -XPOST 'localhost:9200/cliente/external/_bulk?pretty&pretty' -H 'Content-Type: application/json' -d'
{"update":{"_id":"1"}}
{"doc": { "name": "New Name for 1" } }
{"delete":{"_id":"2"}}'

# Generating data with www.json-generator.com (accounts.json file with 1000 records)

curl -XPOST 'localhost:9200/bank/account/_bulk?pretty&refresh' --data-binary "@accounts.json"&pretty' 
  -H 'Content-Type: application/json' -d'
    curl \u0027localhost:9200/_cat/indices?v\u0027'

# Check 1000 records in bank index.
curl -XGET 'localhost:9200/_cat/indices?v&pretty'

# Using the search API
curl -XGET 'localhost:9200/bank/_search?q=*&sort=account_number:asc&pretty&pretty'

curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ]
}'
 
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'
{
  "query": { "match_all": {} },
  "_source": ["account_number", "balance"]
}'

curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'
{
  "query": { "match_phrase": { "address": "mill lane" } }
}'

# Filters
curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": { "match_all": {} },
      "filter": {
        "range": {
          "balance": {
            "gte": 20000,
            "lte": 30000
          }
        }
      }
    }
  }
}'

# Aggregations

curl -XGET 'localhost:9200/bank/_search?pretty' -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword"
      }
    }
  }
}'

 
# -------------------------------------------

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
   
   



