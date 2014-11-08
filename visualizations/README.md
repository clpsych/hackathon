Data file formats for CLPsych hackathon visualization
=


These data formats are designed to make it easy to break data up into parallel chunks, and also to associate features with users and tweets without assuming much ahead of time about what the features will be.

There are three file formats: tweets, user-level features, and tweet-level features.


* Tweets
-

The format here is simple: just the user ID, the tweet ID, and the tweet itself, tab separated.  No assumption is being made here about the tokenization of the tweet, other than that it is whitespace-tokenized and tabs have been removed or escaped.

Example: 

```
@user1 <tab> 1234 <tab> i slept late today :) do n't hate me
```


* User-level features
-

Each user is assumed to be a member of a category in some externally defined category hierarchy. At a minimum, each user must be assigned to a top-level category (e.g. one of {Depressed, PTSD, and Control}).  Optionally, this can be extended to a colon-separated path in a category tree, e.g. Depressed:Female:18-24yearsold.

To avoid collisions, we recommend that user-level feature names begin with u\_ and tweet-level feature names begin with t\_.  That way, for example, a single tweet could have both a feature for the user-level sentiment score of its author (u\_sentiment) and a tweet-level sentiment score (t\_sentiment).  An exception to this would be surface features of the tweet itself such as unigrams, bigrams, etc.  Feature names should not contain tabs or spaces.

Feature values must be in [0,1], and if no value is present, then value = 1 will be assumed.  This means that features whose values are not between 0 and 1 (e.g. lengths of tweets, counts of words, arbitrary scores) will have to be scaled into the [0,1] range.  One typical way of doing so would be to transform a raw numeric value using some variation of the tanh function (http://reference.wolfram.com/language/ref/Tanh.html); another would be to specify thresholds and convert to discrete (value=1) categories, e.g. t\_short for all tweets with length <= 20 characters, t\_medium for tweets with length 21-80, and t\_long for tweets with length 80-140.

Notice that the section with feature-value pairs is space-separated rather than tab-separated, for easier readability of text files containing features.

Examples:

```
  @user1  <tab> Depressed        <tab> u_LIWC_negemo:0.7 u_LIWC_posemo:0.2 u_TOPIC_drugs:0.02 u_lotsoffollowers
  @user2  <tab> Control:Female <tab> u_LIWC_negemo:0.1 u_LIWC_posemo:0.4 u_TOPIC_parties:0.02 u_nightowl 
```

* Tweet-level features
-

Same as user-level features, except at the level of individual tweets.

```
   @user2  <tab> 1234 <tab> t_sentiment:0.85 t_length:0.25 t_topic3:0.02 t_topic7:0.31 slept late slept_late today 
```

Notice that this format easily permits a join, so that a tweet has its own features plus the features of its user:

```
    @user2  <tab> 1234  <tab> u_LIWC_negemo:0.1 u_LIWC_posemo:0.4 u_TOPIC_parties:0.02 u_nightowl  t_sentiment:0.85 t_length:0.25 t_topic3:0.02 t_topic7:0.31 slept late slept_late today 
```
