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

bin/logstash -f logstash-grokdate.conf 

# test Input
127.0.0.1 - - [11/Dec/2013:00:01:45 -0800] "GET /xampp/status.php HTTP/1.1" 200 3891 "http://cadenza/xampp/navi.php" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:25.0) Gecko/20100101 Firefox/25.0"

