import json,os,pymongo

data_loc = 'data/' #Your mileage may vary

generic_condition_loc = data_loc + 'anonymized_%s_tweets/'

from shared_task.tweet_normalization import normalize_and_tokenize_tweet

for condition in ['ptsd','depression','control']:
    condition_loc = generic_condition_loc % condition
    for user_file in os.listdir( condition_loc ):
        print "Processing ", user_file
        for line in open(condition_loc + user_file):
            tweet = json.loads(line)
            tweet = normalize_and_tokenize_tweet(tweet)
            print tweet.keys()
            import sys
            sys.exit()
            


