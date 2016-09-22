use strict;
use warnings;

my $rootDir = ""; # absolute path to data directory, which should contain the Geonames files (allCountries.txt, and alternateNames/alternateNames.txt) and the head words file (geo.headwords.unix.txt)
my $maxThreads = 10; # Max number of threads used by 01-create_geonames_list.pl; set this to number of cores minus one.

my $scriptDir = __FILE__;
$scriptDir =~ s/\/geonames_simple_baseline.pl$//;

system("perl $scriptDir/01-create_geonames_list.pl $rootDir $maxThreads");
system("perl $scriptDir/02-preprocess_head_words.pl $rootDir");
system("perl $scriptDir/03-match_corrected_list_to_geonames.pl $rootDir");
