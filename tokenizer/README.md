Tokenizer
=========

Compile:

* Install [gradle](http://www.gradle.org/)
* run `gradle fatJar` in this directory

Run:

* run `java -jar build/libs/tokenizer-all.jar <input_dir> <output_dir>`

Results:

* Tweets in the output_dir should have a new field called `tokenized_text` which can be now easily tokenized by splitting on spaces.
