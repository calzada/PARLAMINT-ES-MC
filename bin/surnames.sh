#!/bin/sh
#author: Rubén de Líbano
#original date: 31/07/2023
#This script fixes some instances where "surname" is tagged as "namelink"


echo "Fixing Delgado"

perl -pi -e 's/<nameLink>delgado<\/nameLink>/<surname>delgado<\/surname>/gi' *.xml
perl -pi -e 's/<nameLink>delmo<\/nameLink>/<surname>delmo<\/surname>/gi' *.xml
perl -pi -e 's/<nameLink>devesa<\/nameLink>/<surname>devesa<\/surname>/gi' *.xml
