# Install / Update Java8
sudo apt-get update
sudo apt-get install default-jre

# Download Solr
# http://apache.rediris.es/lucene/solr/6.4.1/

# Install Solr
sudo ./install_solr_service.sh ../../solr-6.4.1.zip 

# Browser to Solr admin
# http://localhost:8983/solr/#/ 

# Starting and stopping service (after solr service installation script)
sudo /etc/init.d/solr stop
sudo /etc/init.d/solr start

# Starting and stopping service (manually)
# Standalone service
# cd to solr dir
bin/solr start
bin/solr stop

# Availabler solr execution modes
bin/solr start -help 

# Starting the cloud mode
bin/solr start -cloud 

# Check collection creation options
bin/solr create -help

# Create a collection
bin/solr create -c Colec1 

# Running solr examples
# cloud        : SolrCloud example
# dih          : Data Import Handler (rdbms, mail, rss, tika)
# schemaless   : Schema-less example (schema is inferred from data during indexing)
# techproducts : Kitchen sink example providing comprehensive examples of Solr features
bin/solr stop
bin/solr -e cloud

# Indexing a dir of rich files (own solr doc dir):
bin/post -c ColeccionNube docs/ 

# Browse and query collection in the GUI
# http://127.0.1.1:7574/solr/#/ColeccionNube/query 

# Indexing other types of files: http://lucene.apache.org/solr/quickstart.html








