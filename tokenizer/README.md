Tokenizer
=========

Compile:

* Install [gradle](http://www.gradle.org/)
* run `gradle fatJar` in this directory

Run:

* run `java -jar build/libs/tokenizer-all.jar <input_dir> <output_dir>`
* If that doesn't work, try running `java -cp build/libs/tokenizer-all.jar io.github.clpsych.hackathon.tokenizer.Tokenizer <input_Dir> <output_dir>`

Results:

* Tweets in the output_dir should have a new field called `tokenized_text` which can be now easily tokenized by splitting on spaces.
