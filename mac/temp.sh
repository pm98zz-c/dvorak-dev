#!/bin/bash

for letter in {a..z} ; do
  echo "<action id=\"$letter\">" >> actions.xml
	echo  "<when state=\"none\" output=\"$letter\" />"  >> actions.xml
	echo "</action>"  >> actions.xml
  echo "<action id=\"${letter^}\">" >> actions.xml
	echo  "<when state=\"none\" output=\"${letter^}\" />"  >> actions.xml
	echo "</action>"  >> actions.xml
done