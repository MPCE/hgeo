// Produces all results for which characters in headword are included in a name. For ex.:
// AC� | Apac� | 8548529 | -3.5131 | -55.37839
// AC� | Apa?e | 3204796 | 46.69722 | 15.91056
// AC� | Apa?e | 3204797 | 46.37694 | 15.8025
// AC� | Arac�m | 3471855 | -20.4 | -47.81667
// AC� | Arapova?e | 3211307 | 44.10974 | 18.62852
// AC� | Arga?e | 832851 | 41.93083 | 20.84556
// AC� | Arrecife | 2521570 | 28.96302 | -13.54769
// AC� | As S?q al Qad?m | 8075339 | 31.70444 | 35.20394
// AC� | Axel Oxenstierna palace | 6944464 | 59.3258 | 18.0692
// AC� | Bablja?e | 3341778 | 42.63306 | 19.47083


<?php
header('Content-Type: text/html; charset=UTF-8');

$localhost = "localhost";
$username = "root";
$password = "root";
$db = "hgeo";
$mysqli_link = mysqli_connect("$localhost","$username","$password");
mysqli_select_db($mysqli_link, $db);

$headwords = array();
$query = "SELECT Headword FROM headwords ORDER BY Headword ASC";
$result = mysqli_query($mysqli_link,$query);
while ($row = mysqli_fetch_row($result)) {
	$headwords[] = trim($row[0]);
}

$poo = 0;
echo "<pre>\n";
foreach($headwords as $h) {
	$match = "n";
//	$query = "SELECT * FROM geonames WHERE name = \"$h\" OR alternatenames = \"$h\" OR asciiname = \"$h\" ORDER BY name ASC";
//	$result = mysqli_query($mysqli_link, $query);
//	while ($row = mysqli_fetch_row($result)) {
//		echo "$h | $row[1] | $row[0] | $row[4] | $row[5]\n";
//		$match = "y";
//	}
	$query = "SELECT * FROM geonames WHERE alternatenames LIKE \"%$h,%\" ORDER BY name ASC";
	$result = mysqli_query($mysqli_link, $query);
	while ($row = mysqli_fetch_row($result)) {
		echo "$h | $row[1] | $row[0] | $row[4] | $row[5]\n";
		$match = "y";
		$poo++;
		if(($poo == 100)) {
			die;
		}
	}
	if(($match != "y")) {
		echo "$h | NOT FOUND!\n";
	}
	
}
echo "</pre>";

?>