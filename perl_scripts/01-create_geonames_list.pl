use strict;
use warnings;

if ( !@ARGV ) {
	die "No input provided!";
}

my $rootDir       = $ARGV[0]; # Folder that contains the data.
my $threads = @ARGV > 1 ? $ARGV[1] : 10; # Set this to the number of cores that you have available minus one.

my $setSize = int((11132770 / $threads) + 0.5);
my $countryFile   = $rootDir . "/allCountries.txt"; # The Geonames allCountries file
my $alternateFile = $rootDir . "/alternateNames/alternateNames.txt"; # The Geonames alternateNames file

# Check if the split country files exist, else make them.
# This is done to speed up the processing of the Geonames file, as it is really big.
unless ( -e $countryFile . ".aa" ) {
	print "Splitting allCountries.txt...\n";
	`split -l $setSize $countryFile $rootDir/allCountries.txt.`;
}

local $/ = "\n";

my @namesSeen     = ();
my %coordinates   = ();
my @countryFields = ( # The fields in the geonames allCountries file
	"geonameid",     "name",
	"asciiname",     "alternatenames",
	"latitude",      "longitude",
	"feature class", "feature code",
	"country code",  "cc2",
	"admin1 code",   "admin2 code",
	"admin3 code",   "admin4 code",
	"population",    "elevation",
	"dem",           "timezone",
	"modification date"
);
my ($idIndex) = grep { $countryFields[$_] eq "geonameid" } 0 .. $#countryFields;
my @nameIndices =
  grep { $countryFields[$_] =~ /name/ && $countryFields[$_] ne "geonameid" }
  0 .. $#countryFields;
my ($latIndex) = grep { $countryFields[$_] eq "latitude" } 0 .. $#countryFields;
my ($lngIndex) =
  grep { $countryFields[$_] eq "longitude" } 0 .. $#countryFields;

print "Processing allCountries.txt...\n";
my @countryFiles = <$countryFile.*>;
my @pids = ();
foreach my $n (0..$#countryFiles) {
	my $pid = fork;
	if ( not defined $pid ) {
		warn 'Could not fork';
		next;
	}
	if ($pid) { # Parent
		push @pids, $pid;
	} else { # Child
		my $file = $countryFiles[$n];
		my $outFile = $rootDir . "/geonames_list.".$n.".txt";
		open my $fh, '>', $outFile;
		open my $in, '<', $file;
		my $line = undef;
		my $l = 0;
		while ( defined( $line = <$in> ) ) {
			chomp($line);
			my @fields = split( "\t", $line );
			my $id     = $fields[$idIndex];
			my $lat    = $fields[$latIndex];
			my $lng    = $fields[$lngIndex];
			foreach my $i (@nameIndices) {
				my $name = $fields[$i];
				if ( $countryFields[$i] eq "alternatenames" ) {
					my @names = split( ",", $name );
					foreach my $n (@names) {
						print $fh join( "\t", ( $n, $lat, $lng, $id ) ) . "\n";
					}
				} else {
					print $fh join( "\t", ( $name, $lat, $lng, $id ) ) . "\n";
				}
			}
			$l++;
			if ($l % 500000 == 0) {
				print "Processed $l lines ($n)\n";
			}
		}
		close $in;
		close $fh;
		exit 0;
	}
}

waitpid $_, 0 for @pids;

# Join the separate output files back together
my $str = "$rootDir/geonames_list.".join(".txt $rootDir/geonames_list.",(0..$#countryFiles)).".txt";
`cat $str | uniq > $rootDir/geonames_list.txt`;

my @alternateFields = ( # The fields in the geonames alternateNames file
	"alternateid", "geonameid", "language",   "name",
	"preferred",   "short",     "colloquial", "historic"
);
($idIndex) =
  grep { $alternateFields[$_] eq "geonameid" } 0 .. $#alternateFields;
my ($nameIndex) =
  grep { $alternateFields[$_] eq "name" } 0 .. $#alternateFields;
my ($langIndex) =
  grep { $alternateFields[$_] eq "language" } 0 .. $#alternateFields;

print "Processing alternateNames.txt...\n";
print "Loading Geonames...\n";
open my $handle, '<', "$rootDir/geonames_list.txt";
chomp(my @geonames = <$handle>);
close $handle;
my %geo = ();
while (@geonames) {
	my $line = shift(@geonames);
	my @parts = split( "\t", $line );
	$geo{$parts[3]} = [$parts[1],$parts[2]];
}
print "Geonames loaded.\n";

my $outFile = $rootDir . "/geonames_alternates_list.txt";
open my $fh, '>', $outFile;
open my $in, '<', $alternateFile;
my $line = undef;
my $l = 0;
while ( defined( $line = <$in> ) ) {
	chomp($line);
	my @fields = split( "\t", $line );
	my $id     = $fields[$idIndex];
	my $name   = $fields[$nameIndex];
	my $lang   = $fields[$langIndex];
	unless ($lang eq 'link') {
		print $fh join( "\t", ( $name, ${$geo{$id}}[0], ${$geo{$id}}[1], $id ) ) . "\n";
	}
	$l++;
	if ($l % 1000000 == 0) {
		print "Processed $l lines (A)\n";
	}
}
close $in;
close $fh;

$str = "$rootDir/geonames_alternates_list.txt";
`cat $str $rootDir/geonames_list.txt | uniq > $rootDir/geonames_list2.txt`;
`mv $rootDir/geonames_list2.txt $rootDir/geonames_list.txt`;


