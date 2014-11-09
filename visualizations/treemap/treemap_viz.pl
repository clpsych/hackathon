# 
# treemap_viz.pl [parameters] > outfile.html
#
#   Author: Philip Resnik (resnik@umd.edu)
#
#   Creates an HTML file with treemap visualization for the input data.
#   Run with --help flag for usage details.
#

use POSIX;
use Getopt::Long;   # Command line handling
no warnings 'utf8'; # Turn off annoying "wide character in print" msgs

my $debug   = 0;     # Set >0 for debugging output, higher value = more verbose
my $epsilon = 0.001; # epsilon for Laplace smoothing of focus vs. non-focus category frequencies

#
# Command line handling
#
GetOptions(  "description=s"=>\$description,
	     "userfeatures=s"=>\$userfeatures,
	     "tweetfeatures=s"=>\$tweetfeatures,
	     "mindiff=s"=>\$mindiff,
	     "minratio=s"=>\$minratio,
	     "focus_category=s"=>\$focus_category,
             "h|help"=>\$help)
  or usage();

if ($help || !$description || !$userfeatures || !$tweetfeatures) 
  { usage(); }

# Defaults
$mindiff = 5    if (!$mindiff);
$minratio = 1.5 if (!$minratio);

sub usage {
  print "Usage: $0 [parameters] > outfile.html\n";
  print "--description     \"Description for HTML file (can be HTML)\" [required]\n";
  print "--userfeatures    uf1.tsv,uf2.tsv,... [at least one required]\n";
  print "--tweetfeatures   tf1.tsv,tf2.tsv,...[at least one required]\n";
  print "--focus_category  Focus_category (e.g. Depressed) [required]\n";
  print "--mindiff         NUM (=minimum frequency for a feature to appear, default=5)\n";
  print "--minratio        NUM (=minimum likelihood ratio for a feature to appear, default=1.5)\n";
  die "\n";
}

#
# Read in tweets
#
my (@tweetfiles) = split(/\,/,$tweets);
foreach my $tweetfile (@tweetfiles) 
  {
    print STDERR "Reading tweets from $tweetfile\n";
    open(IN, "< $tweetfile") || die "Unable to read $tweetfile\n";
    while (my $line = <IN>) 
    {
      chomp($line);
      my ($userid,$tweetid,$tweet) = split(/\s*\t\s*/,$line);
      $tweetid2tweet{$tweetid} = $tweet;
    }
    close(IN);
  }


#
# Read in user features
#
my (@userfiles) = split(/\,/,$userfeatures);
foreach my $userfile (@userfiles) 
  {
    print STDERR "Reading users from $userfile\n";
    open(IN, "< $userfile") || die "Unable to read $userfile\n";
    while (my $line = <IN>) 
    {
      chomp($line);

      # Record user's category or category tree
      my ($userid,$category,$features) = split(/\s*\t\s*/,$line);
      $userid2category{$userid} = $category;
      if ($category =~ /:/) {
	($topcategory) = ($category =~ /(.*?):/); }
      else {
	$topcategory = $category;
      }

      $userid2topcategory{$userid} = $topcategory;
      $topcategories{$topcategory} = 1;

      # Record user's features
      my @userfeatures = ();
      foreach my $feature (split/\s+/,$features) {
	($featurename,$featurevalue) = split(/:/,$feature);
	if (!$featurevalue) { $featurevalue = 1; }
	$userid2features{$userid}{$featurename} = $featurevalue;
      }
    }
    close(IN);
  }



#
# Read in tweet features
#
my (@tweetfeaturefiles) = split(/\,/,$tweetfeatures);
foreach my $tweetfeaturefile (@tweetfeaturefiles) 
  {
    print STDERR "Reading tweet features from $tweetfeaturefile\n";
    open(IN, "< $tweetfeaturefile") || die "Unable to read $tweetfeaturefile\n";
    while (my $line = <IN>) 
    {
      chomp($line);
      my ($userid,$tweetid,$features) = split(/\s*\t\s*/,$line);
      $tweetid2user{$tweetid} = $userid;
      my @tweetfeatures = ();
      foreach my $feature (split/\s+/,$features) {
	$feature =~ s/\\/\\\\/g; # escape backslashes
	($featurename,$featurevalue) = split(/:/,$feature);
	if (!$featurevalue) { $featurevalue = 1; }
	$tweetid2features{$tweetid}{$featurename} = $featurevalue;
      }
    }
    close(IN);
  }


if ($debug >= 2) {
  # DEBUG
  foreach my $user (keys %userid2features)
    {
      print "Features for user $user (top category = $userid2topcategory{$user})\n";
      foreach my $feature (keys %{$userid2features{$user}}) {
	print "$user\t$feature\t$userid2features{$user}{$feature}\n";
      }
    }

  # DEBUG
  foreach my $tweetid (keys %tweetid2features)
    {
      print "Features for tweetid $tweetid:\n";
      foreach my $feature (keys %{$tweetid2features{$tweetid}}) {
	print "$tweetid\t$feature\t$tweetid2features{$tweetid}{$feature}\n";
      }
    }
}



#
# Build feature-by-feature probability distributions over categories
#
foreach my $tweetid (keys %tweetid2features)
{
  my $userid       = $tweetid2user{$tweetid};
  my $category     = $userid2topcategory{$userid};
  my $featurelistr = $tweetid2features{$tweetid};

  # Keep track of all categories
  $categories{$category} = 1;

  foreach my $feature (keys %{$tweetid2features{$tweetid}}) {
    my $value = $tweetid2features{$tweetid}{$feature};
    $feature_count{$feature}{$category} += $value;
    $feature_total{$feature}            += $value;

    print " userid=$userid category=$category feature=$feature value=$value: incrementing $category($feature) by $value\n" if ($debug >= 3);
  }
}


# 
# Build treemap spec with frequency-in-focus_category and LLR discrimination
# controlling size and color, respectively.

print "<html>\n";
print "\n";
print "<!-- Include Google Charts treemap, https://developers.google.com/chart/interactive/docs/gallery/treemap -->\n";
print "<script type=\"text/javascript\" src=\"https://www.google.com/jsapi?autoload={'modules':[{'name':'visualization','version':'1','packages':['treemap']}]}\"></script>\n";
print "\n";
print "<!-- Code for this treemap -->\n";
print "<script type=\"text/javascript\">\n";
print "google.setOnLoadCallback(drawChart);\n";
print "function drawChart() {\n";
print "\n";
print "  var data = google.visualization.arrayToDataTable([\n";
print "\t['Feature', 'Parent', 'Frequency in $focus_category', 'LLR'],\n";
print "\t['TOP', null, 0, 0]";


foreach my $feature (sort keys %feature_count) 
{
  # Filtering out features we don't want to report on
  next if ($feature eq "DEFAULT");
  next if ($feature =~ /\'/);

  # Compute log likelihood ratio of focus category vs. non-focus category/categories
  my $focus_frequency    = 0 + $feature_count{$feature}{$focus_category};
  my $nonfocus_frequency = 0;
  print "\nDistribution for feature=$feature (total = $feature_total{$feature})..." if ($debug);
  foreach my $category (keys %categories) 
  {
    my $count                = 0 +  $feature_count{$feature}{$category};
    my $prob                 = ($count + $epsilon) / ($feature_total{$feature} + $epsilon);
    if ($category ne $focus_category) {
      $nonfocus_frequency += $count;
    }
    print "\t$category $count ($prob)" if ($debug >= 2);
  }
  my $lr                 = ($focus_frequency + $epsilon) / ($nonfocus_frequency + $epsilon); # Ugly but quick smoothing
  my $llr                = log2($lr);
  print " [focus_frequency=$focus_frequency, nonfocus-frequency=$nonfocus_frequency, lr=$lr, llr=$llr]" if ($debug >= 2);

  # Using hash to ensure no duplicates
  if ($focus_frequency - $nonfocus_frequency >= $mindiff &&
      $lr > $minratio) {
    # print "  DEBUG: difference ($focus_frequency - $nonfocus_frequency) for $feature >= $mindiff, ratio=$lr\n";
    $output_rows{$feature} = ",\n\t['$feature',\t'TOP',\t$focus_frequency,\t$llr]";
  }
}

foreach my $feature (sort keys %feature_count) 
{
  print "$output_rows{$feature}";
}


print "\n  ]);\n";
print "\n";
print "  tree = new google.visualization.TreeMap(document.getElementById('chart_div'));\n";
print "\n";
print "  tree.draw(data, {\n";
print "    minColor: '#f00',\n";
print "    midColor: '#ddd',\n";
print "    maxColor: '#0d0',\n";
print "    headerHeight: 30,\n";
print "    fontColor: 'black',\n";
print "    showScale: true\n";
print "  });\n";
print "}\n";
print "\n";
print "</script>\n";
print "\n";
print "$description\n";
print "\n";
print "<!-- Div on the page that holds the treemap -->\n";
print "<!-- <div id=\"chart_div\" style=\"width: 900px; height: 500px;\"></div> -->\n";
print "\n";
print "<div id=\"chart_div\" style=\"width: 90%; height: 90%;\"></div> -->\n";
print "\n";
print "</html>\n";





sub log2
{
  my ($num) = @_;
  return log($num)/log(2);
}
