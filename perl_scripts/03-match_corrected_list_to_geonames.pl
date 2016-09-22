use strict;
use warnings;

if ( !@ARGV ) {
	die "No input provided!";
}

my $rootDir       = $ARGV[0];
#my $rootDir = "/home/matje/Applications/french_place_names/encyclopedie"; # path to folder containing geo.headwords.unix.corrected.txt and geonames_list.txt

print "Loading Geonames...\n";
open my $handle, '<', "$rootDir/geonames_list.txt";
chomp(my @geonames = <$handle>);
close $handle;
my %geo = ();
while (@geonames) {
	my $line = shift(@geonames);
	my @parts = split( "\t", $line );
	unless (exists $geo{$parts[0]}) {
		$geo{$parts[0]} = [];
	}
	push @{$geo{$parts[0]}}, \@parts;
#	$geo{$parts[0]} = \@parts;
}
print "Geonames loaded.\n";

# open headwords file
open my $in, '<', "$rootDir/geo.headwords.unix.corrected.txt" or die "Can't open '$rootDir/geo.headwords.unix.corrected.txt': $!";

# open output file, output will be printed tab-separated as [corrected name, original headword, geonames name, latitude, longitude, geonamesid] if a match is found,
# and as [corrected, original] otherwise
open my $out, '>', "$rootDir/geo.headwords.unix.corrected.identified.txt" or die "Can't open '$rootDir/geo.headwords.unix.corrected.identified.txt': $!";

# initialize counters
my $hits = 0;
my $misses = 0;

# initialize array to track uniquely matched geonamesids
my @matches = ();

print "Matching place names...\n";

# process input line by line
while ( defined( my $line = <$in> ) ) {
	
	# remove newline from end of line
	chomp($line);
	
	my ($corrected,$original) = split("\t",$line);
	
	# if an exact match is found
	if (exists $geo{$corrected}) {
		
		# increment hits
		$hits++;
		
		foreach my $arr (@{$geo{$corrected}}) {
				
			# print to output file
			print $out join("\t",$corrected,$original,@$arr) . "\n";
			
			# add match to list if not already added
			unless (grep {$_ == $$arr[3]} @matches) {
				push @matches, $$arr[3];
			}
			
		}
		
		
	# if no match is found
	} else {
		
		# increment misses
		$misses++;
		
		# print to output file
		print $out "$corrected\t$original\n";
		
	}
	
}

close($out);
close($in);

my $uniq = @matches;
print "Matching finished. Hits: $hits ($uniq unique). Misses: $misses.\n";
