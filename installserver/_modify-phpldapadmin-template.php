<?php

require 'QueryPath/QueryPath.php';

$XML_PATH = '/usr/share/phpldapadmin/templates/creation/posixAccount.xml';

function addEmailField()
{
	global $XML_PATH;
	$xml = file_get_contents($XML_PATH);

	$attributeList = qp($xml, "attributes")->children("attribute");
	//print $attributeList->size() . PHP_EOL;
	$attributeCount = $attributeList->size();
	
	$emailAttribute = qp($xml, "attributes > attribute[id=mail]");
	//echo "attribute email count=".count($emailAttribute)."\n";
	
	$uidAttribute = qp($xml, "attributes > attribute[id=uid]");
	//echo "attribute uid count=".count($uidAttribute)."\n";
	
	if ( count($emailAttribute) == 0 )
	{
		//echo "appending email...\n";
		$indexOfEmailAttribute = $attributeCount + 1;
		qp($xml, "attributes")->append('<attribute id="mail"><display>Email</display><icon>mail.png</icon><order>'.$indexOfEmailAttribute.'</order><page>1</page></attribute>'.PHP_EOL)->writeXML($XML_PATH);
	}
	else
	{
		//print "Email attribute already exists in XML...\n";
	}
}

function changeToBourneShell()
{
	global $XML_PATH;
	$xml = file_get_contents($XML_PATH);

	$shells = qp($xml, "attributes > attribute[id=loginShell] > value");
	//print "shells count=".count($shells).PHP_EOL;
	foreach ( $shells as $shell )
	{
		//print "shell-id: ".$shell->attr("id").PHP_EOL;
		if ( $shell->attr("id") == "/bin/sh" )
		{
			$shell->attr("id", "/bin/bash")->text("/bin/bash")->writeXML($XML_PATH);
		}
	}
	$defaultShell = qp($xml, "attributes > attribute[id=loginShell] > default");
	if ( count($defaultShell) == 0 )
	{
		qp($xml, "attributes > attribute[id=loginShell]")->append("\t<default>/bin/bash</default>\n")->writeXML($XML_PATH);
	}
}

function updateCommonName()
{
	global $XML_PATH;

	$xml = file_get_contents($XML_PATH);
	$readonly = qp($xml, "attribute[id=cn] > readonly");
	if ( count($readonly) == 0 )
	{
		qp($xml, "attribute[id=cn]")->append("\t<readonly>1</readonly>".PHP_EOL)->writeXML($XML_PATH);
	}

	$xml = file_get_contents($XML_PATH);
	$onchangeList = qp($xml, "attribute[id=givenName] onchange");
	$hasAutoFillEmail = false;
	foreach ( $onchangeList as $onchange )
	{
		//echo "onchange: ".$onchange->text()."\n";
		if ( $onchange->text() == "=autoFill(cn;%givenName% %sn%)" )
		{
			$onchange->text("=autoFill(cn;%givenName/l%.%sn/l%)")->writeXML($XML_PATH);
		}
		if ( $onchange->text() == "=autoFill(uid;%givenName|0-1/l%%sn/l%)" )
		{
			$onchange->text("=autoFill(uid;%givenName/l%.%sn/l%)")->writeXML($XML_PATH);
		}
		//echo "strpos = " . strpos( $onchange->text(), "=autoFill(mail;" ) . "\n";
		if ( strpos( $onchange->text(), "=autoFill(mail;" ) === 0 )
		{
			$hasAutoFillEmail = true;
		}
	}
	if ( !$hasAutoFillEmail )
	{
		//echo "no auto-fill email... add\n";
		$xml = file_get_contents($XML_PATH);
		$onchangeList = qp($xml, "attribute[id=givenName]")
			->append("\t<onchange>=autoFill(mail;%givenName/l%.%sn/l%@)</onchange>\n")->writeXML($XML_PATH);
	}

	

	$xml = file_get_contents($XML_PATH);
	$onchangeList = qp($xml, "attribute[id=sn] onchange");
	$hasAutoFillEmail = false;
	foreach ( $onchangeList as $onchange )
	{
		//echo "onchange: ".$onchange->text()."\n";
		if ( $onchange->text() == "=autoFill(cn;%givenName% %sn%)" )
		{
			$onchange->text("=autoFill(cn;%givenName/l%.%sn/l%)")->writeXML($XML_PATH);
		}
		if ( $onchange->text() == "=autoFill(uid;%givenName|0-1/l%%sn/l%)" )
		{
			$onchange->text("=autoFill(uid;%givenName/l%.%sn/l%)")->writeXML($XML_PATH);
		}
		//echo "strpos = " . strpos( $onchange->text(), "=autoFill(mail;" ) . "\n";
		if ( strpos( $onchange->text(), "=autoFill(mail;" ) === 0 )
		{
			$hasAutoFillEmail = true;
		}
	}
	if ( !$hasAutoFillEmail )
	{
		//echo "no auto-fill email... add\n";
		$xml = file_get_contents($XML_PATH);
		$onchangeList = qp($xml, "attribute[id=sn]")
			->append("\t<onchange>=autoFill(mail;%givenName/l%.%sn/l%@)</onchange>\n")->writeXML($XML_PATH);
	}
}

function updateUID()
{
	global $XML_PATH;

	$xml = file_get_contents($XML_PATH);
	$onchangeList = qp($xml, "attribute[id=uid] onchange");
	foreach ( $onchangeList as $onchange )
	{
		if ( $onchange->text() == "=autoFill(homeDirectory;/home/users/%uid%)" )
		{
			$onchange->text("=autoFill(homeDirectory;/home/%uid%)")->writeXML($XML_PATH);
		}
	}

	$xml = file_get_contents($XML_PATH);
	$readonly = qp($xml, "attribute[id=uid] > readonly");
	if ( count($readonly) == 0 )
	{
		qp($xml, "attribute[id=uid]")->append("\t<readonly>1</readonly>".PHP_EOL)->writeXML($XML_PATH);
	}
}
function updateHome()
{
	global $XML_PATH;

	$xml = file_get_contents($XML_PATH);
	$readonly = qp($xml, "attribute[id=homeDirectory] > readonly");
	if ( count($readonly) == 0 )
	{
		qp($xml, "attribute[id=homeDirectory]")->append("\t<readonly>1</readonly>".PHP_EOL)->writeXML($XML_PATH);
	}
}

addEmailField();
changeToBourneShell();
updateCommonName();
updateUID();
updateHome();


?>

