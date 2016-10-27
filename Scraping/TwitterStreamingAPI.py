# !pip install oauth2 

# !pip install requests_oauthlib

import socket
import sys
from thread import *
import requests
import requests_oauthlib
import json
import oauth2 as oauth
from datetime import datetime
import time

auth = requests_oauthlib.OAuth1(
    "XXX", 
    "XXX",
    "XXX", 
    "XXX")

url='https://stream.twitter.com/1.1/statuses/filter.json'
    
data = [('language', 'en'), ('locations', '-130,-20,100,50'), ('clinton','trump')]
  
query_url = url + '?' + '&'.join([str(t[0]) + '=' + str(t[1]) for t in data])
    
response  = requests.get(query_url, auth=auth, stream=True)

print(query_url, response)

count = 0
for line in response.iter_lines():
    print(line + '\n')
    count +=1
    if count > 10:
        break;
        
# Example line:        
# {"created_at":"Thu Oct 27 11:06:08 +0000 2016","id":791596841833947136,"id_str":"791596841833947136","text":"Happy birthday to my bro @Big___Ry \ud83d\udcaf","source":"\u003ca href=\"http:\/\/twitter.com\/download\/iphone\" rel=\"nofollow\"\u003eTwitter for iPhone\u003c\/a\u003e","truncated":false,"in_reply_to_status_id":null,"in_reply_to_status_id_str":null,"in_reply_to_user_id":null,"in_reply_to_user_id_str":null,"in_reply_to_screen_name":null,"user":{"id":2424700413,"id_str":"2424700413","name":"\u2663\ufe0fJ@LEN\u2663\ufe0f","screen_name":"jalenjohnson66","location":"Michigan, ","url":null,"description":"gone....","protected":false,"verified":false,"followers_count":219,"friends_count":124,"listed_count":0,"favourites_count":704,"statuses_count":646,"created_at":"Thu Mar 20 13:13:34 +0000 2014","utc_offset":null,"time_zone":null,"geo_enabled":true,"lang":"en","contributors_enabled":false,"is_translator":false,"profile_background_color":"C0DEED","profile_background_image_url":"http:\/\/abs.twimg.com\/images\/themes\/theme1\/bg.png","profile_background_image_url_https":"https:\/\/abs.twimg.com\/images\/themes\/theme1\/bg.png","profile_background_tile":false,"profile_link_color":"0084B4","profile_sidebar_border_color":"C0DEED","profile_sidebar_fill_color":"DDEEF6","profile_text_color":"333333","profile_use_background_image":true,"profile_image_url":"http:\/\/pbs.twimg.com\/profile_images\/787737786879062016\/DleX5nQy_normal.jpg","profile_image_url_https":"https:\/\/pbs.twimg.com\/profile_images\/787737786879062016\/DleX5nQy_normal.jpg","profile_banner_url":"https:\/\/pbs.twimg.com\/profile_banners\/2424700413\/1475616840","default_profile":true,"default_profile_image":false,"following":null,"follow_request_sent":null,"notifications":null},"geo":null,"coordinates":null,"place":{"id":"0b40afc99807b6ac","url":"https:\/\/api.twitter.com\/1.1\/geo\/id\/0b40afc99807b6ac.json","place_type":"city","name":"Farmington Hills","full_name":"Farmington Hills, MI","country_code":"US","country":"United States","bounding_box":{"type":"Polygon","coordinates":[[[-83.437523,42.439001],[-83.437523,42.529556],[-83.316839,42.529556],[-83.316839,42.439001]]]},"attributes":{}},"contributors":null,"is_quote_status":false,"retweet_count":0,"favorite_count":0,"entities":{"hashtags":[],"urls":[],"user_mentions":[{"screen_name":"Big___Ry","name":"1\ufe0f\u20e30\ufe0f\u20e32\ufe0f\u20e37\ufe0f\u20e3","id":633081115,"id_str":"633081115","indices":[25,34]}],"symbols":[]},"favorited":false,"retweeted":false,"filter_level":"low","lang":"en","timestamp_ms":"1477566368908"}
