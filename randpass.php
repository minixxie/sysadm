#!/usr/bin/env php
<?php

$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890123456789012345678901234567890123456789";

$length = 10;
if ( !empty( $argv[1] ) )
{
	$length = $argv[1];
}

for ( $i = 0 ; $i < $length ; $i++ )
{
	$index = rand(0, strlen($chars)-1);
	echo $chars[$index];
}
echo "\n";

?>
