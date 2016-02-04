<?php
// Create datetime objcects
$dt1 = new DateTime($argv[1]);
$dt2 = new DateTime($argv[2]);

// Conver difference to seconds
$dt3 = $dt2->format('U') - $dt1->format('U');

// echo $dt3."\n";
$h = (int)($dt3 / 3600);
$dt3 %= 3600;
$m = (int)($dt3 / 60);
$dt3 %= 60;
$s = $dt3;

// Dump as H:M:S
echo $h . ":" . $m . ":" . $s;

?>
