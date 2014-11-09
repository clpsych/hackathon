
Treemap visualization of CLPsych hackathon features
=

Author: Philip Resnik (resnik@umd.edu)

* Usage
---

```
Usage: treemap\_viz.pl [parameters] > outfile.html
--description           "Description for HTML file (can be HTML)"
--userfeatures          uf1.tsv,uf2.tsv,...
--tweetfeatures        tf1.tsv,tf2.tsv,...
--focus\_category    CATEGORY (e.g. depressed)
--mindiff                  NUM (=minimum frequency for a feature to appear, default=5)
--minratio                NUM (=minimum likelihood ratio for a feature to appear, default=1.5)
```

For userfeatures and tweetfeatures files, see README.md in the parent directory for data formats.  (This program does not currently require a tweets file.)

The _focus-category_ is the user category we're interested in, e.g. _depression_ (as distinct from _control_).

Mindiff is the minimum frequency difference for a feature to be relevant, comparing frequency in the focus category to frequency in the other category or categories. It defaults to 5.

Minratio is the minimum frequency ratio difference for a feature to be relevant, e.g. at the default of 1.5, we're only interested in seeing features that are 1.5 more likely in the _depression_category.

* Output
--

On STDOUT, an HTML file containing a Google Charts treemap visualization (https://developers.google.com/chart/interactive/docs/gallery/treemap) where the size of the box is the frequency in the focus category and the color scale is the log likelihood ratio between the focus and non-focus categories.  For example, if the focus category is _depression_, in theory large red boxes should be features that are both frequently seen for depressed users, and a positive sign of depression as compared to control, at least in terms of the log likelihood ratio.

