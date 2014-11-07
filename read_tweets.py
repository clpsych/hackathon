"""
Author: Glen Coppersmith
Email: coppersmith@jhu.edu

Here are some easy ways to access the data via python
"""

filename = ‘path/to/files/ptsd_tweets/234223.tweets’
for line in open(filename):
    tweet = json.loads(line)
    print tweet[‘text’]


[x['text'] for x in map(json.loads, open(filename).readlines()) if 'text' in x]
[x.get('text','') for x in map(json.loads, open(filename).readlines())]

