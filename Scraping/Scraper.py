
# sudo pip install requests requests_oauthlib
# pip install oauth2

import socket
import sys
from thread import *
import requests
import requests_oauthlib
import json
import oauth2 as oauth
from datetime import datetime
import time


#Variables that contains the user credentials to access Twitter API

auth = requests_oauthlib.OAuth1(
    consumer_key, 
    consumer_secret,
    access_token, 
    access_token_secret)

#Function for handling connections. This will be used to read data from tweeter and write to socket
def clientthread(conn):
    url='https://stream.twitter.com/1.1/statuses/filter.json'
    #
    data      = [('language', 'en'), ('locations', '-130,-20,100,50')]
    #,('track','ibm,google,microsoft')
    query_url = url + '?' + '&'.join([str(t[0]) + '=' + str(t[1]) for t in data])
    response  = requests.get(query_url, auth=auth, stream=True)
    print(query_url, response) # 200 <OK>
    count = 0
    for line in response.iter_lines():  # Iterate over streaming tweets
        try:
            if count > 10000000:
                break
            post= json.loads(line.decode('utf-8'))
            #contents = [post['text'], post['coordinates'], post['place']]
            count+= 1
            conn.send(line+'\n')
            #time.sleep(1)

            print (str(datetime.now())+' '+'count:'+str(count))
        except:
            e = sys.exc_info()[0]
            print( "Error: %s" % e )
    conn.close()

    
