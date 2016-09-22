use strict;
use warnings;

if ( !@ARGV ) {
	die "No input provided!";
}

my $rootDir       = $ARGV[0];

#my $rootDir = "/home/matje/Applications/french_place_names/encyclopedie"; # path to folder containing the geo.headwords.unix.txt file
my @notCapitalized = ("le","la","de","au","aux","l","d","sur","des","les","a"); # list of words that will not be capitalized


##### Main

# initialize hash to store all corrected place names and their frequency
my %places = ();

# open headwords file
open my $in, '<', "$rootDir/geo.headwords.unix.txt" or die "Can't open '$rootDir/geo.headwords.unix.txt': $!";

# open output file, output will be printed tab-separated as [corrected place, original input line]
open my $out, '>', "$rootDir/geo.headwords.unix.corrected.txt" or die "Can't open '$rootDir/geo.headwords.unix.corrected.txt': $!";

# process line by line
while ( defined( my $line = <$in> ) ) {
	
	# remove newline from end of line
	chomp($line);
	
	my $correctedLine = $line;
	$correctedLine =~ s/, \(/ \(/g;
	
	# split conjunctions
	my @splitOnOu = split(" ou ",$correctedLine);
	my @places = ();
	foreach my $part (@splitOnOu) {
		push @places, split(/ *[,&] */,$part);
	}
	
	foreach my $place (@places) {
		
		if (length($place) > 0) {
			my $oldPlace = "$place";
			
			# if the place name contains a bracketed term
			# process the place name both without the bracketed term, and 
			# with the bracketed term placed before the place name in unbracketed format
			if ($place =~ /\(.+\)/) {
				
				# split on the brackets
				my @parts = split(/ *[\(\)]/,$place);
				
				# get correction for place name without the bracketed term
				my $correctedPlaceNoBracketedTerm = correctPlaceName($parts[0]);
				
				if (length($correctedPlaceNoBracketedTerm) > 0) {
						
					# add result to hash
					$places{$correctedPlaceNoBracketedTerm} = exists($places{$correctedPlaceNoBracketedTerm}) ? $places{$correctedPlaceNoBracketedTerm} + 1 : 1;
					
					# print result
					print $out "$correctedPlaceNoBracketedTerm\t$line\n";
					
				}
				
				# get correction for place name with the bracketed term
				my $correctedPlaceWithBracketedTerm = correctPlaceName($parts[1]." ".$parts[0]);
				
				if (length($correctedPlaceWithBracketedTerm) > 0) {
					
					# add result to hash
					$places{$correctedPlaceWithBracketedTerm} = exists($places{$correctedPlaceWithBracketedTerm}) ? $places{$correctedPlaceWithBracketedTerm} + 1 : 1;
					
					# print result
					print $out "$correctedPlaceWithBracketedTerm\t$line\n";
					
				}
			}
			
			# else
			else {
				
				# process the place name as is
				my $correctedPlace = correctPlaceName($place);
				
				if (length($correctedPlace) > 0) {
					
					# add result to hash
					$places{$correctedPlace} = exists($places{$correctedPlace}) ? $places{$correctedPlace} + 1 : 1;
					
					# print result
					print $out "$correctedPlace\t$line\n";
					
				}
				
			}
			
		}
		
	}
	
}

close($out);
close($in);

# open frequency list file for writing
open $out, '>', "$rootDir/geo.headwords.unix.corrected.freqlist.txt" or die "Can't open '$rootDir/geo.headwords.unix.corrected.freqlist.txt': $!";

# print frequency list
foreach my $place (sort keys %places) {
	print $out "$place\t$places{$place}\n";
}

close($out);


##### Subroutines

sub correctPlaceName {
	my ($place) = @_;
	# separate the words
	my @words = split(" ",$place);
	
	# foreach word
	foreach my $word (@words) {
		
		# if the word is hyphenated
		if ($word =~ /\-/) {
			
			# split into parts
			my @parts = split('-',$word);
			
			# process each part individually
			foreach my $part (@parts) {
				$part = correctWordCapitalization($part);
			}
			
			# paste back together
			$word = join('-',@parts);
			
		}
		
		# else
		else {
			
			# correct the word
			$word = correctWordCapitalization($word);
			
		}
		
	}
	
	# paste the words back together
	my $correctedPlace = join(" ",@words);
	
	# remove spaces after apostrophes
	$correctedPlace =~ s/' /'/g;
	
	# remove double spaces
	$correctedPlace =~ s/ +/ /g;
	
	# remove brackets (just to be sure)
	$correctedPlace =~ s/[\(\)]//g;
	
	# if it is a stopword, return empty string
	if (grep {$_ eq $correctedPlace} @notCapitalized) {
		return "";
	}
	return $correctedPlace;
}

sub correctWordCapitalization {
	my ($word) = @_;
	$word =~ s/É/é/g;
	$word =~ s/Ç/ç/g;
	
	# if the word contains any apostrophes
	if ($word =~ /'/) {
		
		# convert to lowercase
		$word = lc($word);
		
		# capitalize only the first character after an apostrophe, if the previous part is included in notCapitalized
		my @parts = split(/'/,$word);
		foreach my $p (1..$#parts) {
			if (grep {$_ eq $parts[$p-1]} @notCapitalized) {
				$parts[$p] = ucfirst($parts[$p]);
			}
		}
		
	}
	
	# else if the word is in 'notCapitalized'
	elsif (grep {$_ eq lc($word)} @notCapitalized) {
		
		# convert to lowercase
		$word = lc($word);
		
	}
	
	# else
	else {
		
		# capitalize only the first letter
		$word = ucfirst(lc($word));
		
	}
	
	return $word;
}
