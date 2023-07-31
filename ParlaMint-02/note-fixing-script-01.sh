#!/bin/sh
#This script aims to refine <note>
#author: María Calzada Pérez, Rubén de Líbano, Mónica Albini, 
#original date: 31/07/2023

#Potential onliners and other bobs used
# perl -pi -e 's///g' *.xml in one paragraph ONELINER
# perl -0777 -pi -e 's///g' *.xml in various paragraphs
#\p{Z}+?
# echo "XXXXX"


#FIRST CHANGES

echo "Words stuck together"

perl -pi -e 's/delhemiciclo/del hemiciclo/gi' *.xml

perl -pi -e 's/MartínezOblanca/Martínez Oblanca/gi' *.xml

perl -pi -e 's/laPresidencia/la Presidencia/gi' *.xml

perl -pi -e 's/encatalán/en catalán/gi' *.xml


#GETTING NOTES IN DIFFERENT PARAGRAPHS FOR SAFETY REASONS
echo "SPLITTING.- Add a \n after $1XXYY
 so that finding and replacing is easier and safer"
perl -pi -e 's/(<\/note>)/$1XXYY\n/g' *.xml

#DELETE: IT IS NOT A NOTE 

echo "deleting: these are not notes"

perl -pi -e 's/<note>(han condenado por corrupción a M. Rajoy)<\/note>XXYY\n/ $1 /gi' *.xml

perl -pi -e 's/<note>(.te acordás de esa mujer.)<\/note>XXYY\n/ $1 /gi' *.xml

perl -pi -e 's/<note>(promueven la cultura de la violación)<\/note>XXYY\n/ $1 /gi' *.xml

perl -pi -e 's/<note>(por ahora)<\/note>XXYY\n/ $1 /gi' *.xml

#NOTES ON OTHER SPANISH LANGUAGES 
echo "LANGUAGES.- <note>El señor Tardà i Coma finaliza su discurso en catalán$1XXYY
"

echo "Adding <vocal type='clarification'>"

perl -pi -e 's/<note>((comienza|empieza|finaliza|continúa).+?en.+?(euskera|catalán|gallego|bable|valenciano|hebreo).*?)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>((el|la)\p{Z}+?(señor|señora).+?\p{Z}+?(comienza|empieza|finaliza|continúa|termina).+?en\p{Z}+?(euskera|catalán|gallego|bable|valenciano|hebreo).*?)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>((pronuncia|termina).+?en.+?(euskera|catalán|gallego|bable|valenciano|hebreo).*?)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

#GAPS
echo "GAPS.- gaps:(.+?el micrófono apagado|.+?el micrófono cerrado|.l micrófono no funciona.+?)"

perl -pi -e 's/<note>(.+?el\p{Z}+?micrófono\p{Z}+?apagado.*?|.+?el\p{Z}+?micrófono\p{Z}+?cerrado|el\p{Z}+?micrófono\p{Z}+?no\p{Z}+?funciona.+?)<\/note>/<gap reason="inaudible">\n <desc>$1<\/desc>\n<\/gap>/gi' *.xml


echo "...palabras que no se perciben"
perl -pi -e 's/<note>(.+?)(palabras\p{Z}+?que\p{Z}+?no\p{Z}+?se\p{Z}+?perciben)(.*?)<\/note>/<gap reason="inaudible">\n <desc>$1$2$3<\/desc>\n<\/gap>/gi' *.xml

#PAUSE
echo "<note>(Paus.|Pausa|Pausa.+?)<\/note>"

# KINESIC TYPE GESTURE: ASSENTING DISSENTING 
echo "ASSENTING/DISSENTING.- asentimiento/denegación"
perl -pi -e 's/<note>(.*?)(.sentimiento|.sentimientos)(.*?)<\/note>/<kinesic type="gesture">\n<\/kinesic>/gi' *.xml

perl -pi -e 's/<note>(.*?Denegaciones.*?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml


#NOTE TYPE PRESIDENT

perl -pi -e 's/
<note>(.+?ocupa\p{Z}+?la\p{Z}+?Presidencia.*?)<\/note>/<note type="president">$1<\/note>/gi' *.xml

echo "END OF 01/05"


