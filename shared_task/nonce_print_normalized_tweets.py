"""
Author: Glen Coppersmith
Email: coppersmith@jhu.edu
"""

import os
"""
NB: Normally I would use ujson instead of json -- WAY faster,
it does not handle these large IDs well, though.
"""
import json 

from tweet_normalization import normalize_and_tokenize_tweet

data_loc = 'data/anonymized_control_tweets/'
control_user_files = os.listdir(data_loc)

a_control_user_file = data_loc + control_user_files[0]

for line in open(a_control_user_file):
    tweet = json.loads(line)
    tweet = normalize_and_tokenize_tweet(tweet)
    if 'clean_text' in tweet:
        print tweet['text']
        print tweet['clean_text']
    




