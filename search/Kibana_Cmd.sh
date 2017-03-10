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




curl -XPOST 'localhost:9200/_bulk?pretty' --data-binary @logs.jsonl 
