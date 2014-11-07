"""
Author: Glen Coppersmith
Email: coppersmith@jhu.edu

Simple and not-so-simple tokenization and normalization for (primarily) English Twitter data.
"""

from __future__ import division
import csv,sys,codecs
try:
    import ujson as json
except:
    import json

import re
URL_ex = re.compile(ur"http[s]{0,1}://\S+", re.UNICODE)
username_ex = re.compile(ur"@[a-zA-Z_1-9]+", re.UNICODE)

text_ex = re.compile(ur"[\w'#@]+", re.UNICODE)
text_URL_ex = re.compile(ur"http[s]{0,1}://\S+|[\w'#@]+", re.UNICODE)
"""
def tokenize( s, as_set=False ):
    if s:
        #return text_URL_ex.findall(s)
        if as_set:
            return list(set(text_URL_ex.findall(s.strip())))
        else:
            return text_URL_ex.findall(s.strip())
    else:
        return []
"""
"""
def tokenize( s, as_set=False ):
    if s:
        #return text_URL_ex.findall(s)
        if as_set:
            return list(set(text_URL_ex.findall(s.strip())))
        else:
            return text_URL_ex.findall(s.strip())
    else:
        return []
   """
stripper_ex = re.compile(ur"http[s]{0,1}://\S+|[ ,.\"!:;\-&*\(\)\[\]]",re.UNICODE)
def tokenize( s, as_set=False ):
    if s:
        if as_set:
            return list(set(filter(None,[x.strip() for x in stripper_ex.split(s.strip())])))
        else:
            return filter(None,[x.strip() for x in stripper_ex.split(s.strip())])
    else:
        return []

def convert(s):
    try:
        return s.group(0).encode('latin1').decode('utf8')
    except:
        return s.group(0)
    
def normalize( s ):
    try:
        a = unicode(s)
        a = a.encode('utf-8')
    except UnicodeDecodeError, TypeError:
        print "problem on unicode decode:", s
        import sys
        sys.exit()
        return ""
    s_prime = s.replace(u'\u201d','"')
    s_prime = s_prime.replace(u'\u201c','"')
    s_prime = s_prime.replace('\n', ' ')
    final_string = unicode(s_prime).encode('utf-8').lower()
    return final_string

import codecs,unidecode
def clean_tweet(text):
    normalized = re.sub(URL_ex, '*', normalize(text))
    normalized = re.sub(username_ex, '@', normalized)
    return unidecode.unidecode(normalized)


def normalize_and_tokenize_tweet( tweet ):
    """
    Given a tweet object encoded as a python {},
    if text exists, clean it and write text back
    as 'clean_text' and a tokenized version of 
    the same as 'tokens'

    NB: START HERE if you don't know what to do 
    in this file and/or don't have strong religious
    beliefs about normalization and tokenization of 
    text.
    """
    if 'text' in tweet and tweet['text']:
        tweet['clean_text'] = clean_tweet( tweet['text'])
        tweet['tokens'] = tweet['clean_text'].split() #Simple tokenizer, much room for improvement
    return tweet
        
