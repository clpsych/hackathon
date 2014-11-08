# 
# treemap_viz.pl 
#   --dirname         DIRNAME 
#   --description     "DESCRIPTION" 
#   --tweets          tweets1.tsv,tweets2.tsv,...
#   --userfeatures    uf1.tsv,uf2.tsv,...
#   --tweetfeatures   tf1.tsv,tf2.tsv,...
#   
# dirname:       output directory that will contain index.html and treemap_data.js
# description:   HTML description to be included at top of index.html
# file formats:  see documentation of hackathon visualization data formats
#

use POSIX;
use Getopt::Long;   # Command line handling
no warnings 'utf8'; # Turn off annoying "wide character in print" msgs

print "Hello, world.\n";


