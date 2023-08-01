#!/bin/sh
#This script aims to refine <note>. This final script HAS SPEECIFC CASES ONLY
#author: María Calzada Pérez, Rubén de Líbano, Mónica Albini, 
#original date: 31/07/2023

#Potential onliners and other bobs used
# perl -pi -e 's///gi' *.xml in one paragraph ONELINER
# perl -0777 -pi -e 's///gi' *.xml in various paragraphs
#\p{Z}+?
# echo "XXXXX"

#FINAL BUGS
echo "final bugs"

##INCIDENT TYPE ACTION
echo "inicident type action"
perl -pi -e 's/<note type="comment">(Rompe el cartel antes de abandonar la tribuna)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

perl -pi -e 's/<note type="comment">(rompiendo el papel del tuit)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

perl -pi -e 's/<note type="comment">(sacando la documentación del interior del sobre)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

perl -pi -e 's/<note type="comment">(Se desaloja el hemiciclo)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

perl -pi -e 's/<note type="comment">(Una persona arroja desde la tribuna pública unas octavillas)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml


#KINESIC TYPE GESTURE
echo "kinesic type gesture"

perl -pi -e 's/<note type="comment">(se palmea la mejilla)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

perl -pi -e 's/<note type="comment">(tocándose la solapa)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

#VOCAL TYPE SPEAKING

echo "vocal type speaking"

perl -pi -e 's/<note type="comment">(se palmea la mejilla)<\/note>/<vocal type="speaking">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note type="comment">(sextorsión y pornovenganza)<\/note>/<vocal type="speaking">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note type="comment">(¡para niños y niñas!)<\/note>/<vocal type="speaking">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note type="comment">(terroristas)<\/note>/<vocal type="speaking">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note type="comment">(un señor diputado). (¡Qué barbaridad!)<\/note>/<vocal type="speaking">\n <desc>$1\: $2<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note type="comment">(varios señores diputados). (¡Nooo!)<\/note>/<vocal type="speaking">\n <desc>$1\: $2<\/desc>\n<\/vocal>/gi' *.xml

echo "END OF 05/05"