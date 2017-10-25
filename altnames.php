<?php

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
		if(($poo == 10)) {
			die;
		}
	}
	if(($match != "y")) {
		echo "$h | NOT FOUND!\n";
	}
	
}
echo "</pre>";

?>