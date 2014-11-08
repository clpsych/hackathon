Utterance Segmenter
=========

This attempts to find utterances in tweets based on the TweeboParser's dependency parse tree. 

Build:

The Dockerfile grabs the TweeboParser and builds it.

Run:

* To build a batch directory with batches of a million non-empty tweets, run `ruby split.rb <tweet_dir> <batch_dir>`
* In the docker, assuming the batch directory is mounted as /twitter/batches, run 
```
find /twitter/batches/ -name '*.tweets.txt' -print | parallel --progress bash ./run.sh {}
```
* To build json blobs linking the results to the correct tweet id, run outside the docker
```
find <batch_dir> '*.tweets.txt.predict' -exec ruby join.rb {} \;
```
