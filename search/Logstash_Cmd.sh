bin/logstash -f logstash-simple.conf 

# Sending events from stdin: 
Hola from logstash stdin input!
{
    "@timestamp" => 2017-03-10T16:19:25.876Z,
      "@version" => "1",
          "host" => "array-VirtualBox",
       "message" => "Hola from logstash stdin input!"
}

# curl -XGET 'localhost:9200/logs*/_search?q="hola"&pretty&pretty'

