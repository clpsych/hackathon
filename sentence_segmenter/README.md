Sentence Segmenter
=========

This attempts to find sentences based on the TweeboParser's dependency parse tree. 

Build:

The Dockerfile grabs the TweeboParser and builds it.

Run:

* To build two big files of ids and tweets for non-empty tweets, run `ruby split.rb <tweet_dir> tweets.txt ids.txt`
* In the docker, run `./run.sh /path/to/tweets.txt`, making a tweets.txt.predict file
* To join the results into distinct sentences, run `ruby join.rb /path/to/tweets.txt.predict /path/to/ids.txt`
