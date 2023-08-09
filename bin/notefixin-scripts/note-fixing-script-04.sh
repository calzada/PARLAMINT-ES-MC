#!/bin/sh
#This script aims to refine <note>
#author: María Calzada Pérez, Rubén de Líbano, Mónica Albini, 
#original date: 31/07/2023

#Potential onliners and other bobs used
# perl -pi -e 's///g' *.xml in one paragraph ONELINER
# perl -0777 -pi -e 's///g' *.xml in various paragraphs
#\p{Z}+?
# echo "XXXXX"


# APPLAUSE. RUMOURS. PROTESTS. LAUGHTER

echo ".- APPLAUDING/RUMOURS/PROTESTS.- Aplausos, rumores y protestas"

## APPLAUSE
echo "Applause"

# ---- I commented all the lines to then group all under 'applause' -----

#perl -pi -e 's/

# <note>(.*?)(.plauso|.plausos)(.+?)(.umor|.umores)(.+?)(.rotestas|.rotesta)(.*?)<\/note>

#<kinesic type="applause">
#<desc>$1$2$3$4$5$6$7<\/desc>
#<\/kinesic>/g' *.xml

# echo "Rumores y protestas.- Aplausos"
#perl pi -e 's/<note>(.*?)(.umor|.umores)(.+?)(.rotestas|.rotesta)(.*?)(.plauso|.plausos)(.*?)<\/note>
#/

#<kinesic type="applause-rumors-protest">
# <desc>$1$2$3$4$5$6$7<\/desc>
#<\/kinesic>/g' *.xml


#echo "protestas y aplausos"

#perl -pi -e 's/
#<note>(.*?)(.rotesta|.rotestas)(.+?)(.plauso|.plausos)(.*?)<\/note>

#<kinesic type="protest-applause">
# <desc>$1$2$3$4$5<\/desc>
#<\/kinesic>/g' *.xml

#echo "aplausos y protestas"

#perl -pi -e 's/
#<note>(.*?)(.plauso|.plausos)(.+?)(.rotesta|.rotestas)(.*?)<\/note>

#<kinesic type="protest-applause">
# <desc>$1$2$3$4$5<\/desc>
#<\/kinesic>/g' *.xml

#echo "rumores-aplausos"

#perl -pi -e 's/
#<note>(.*?)(.umores|.umor)(.+?)(.plauso|.plausos)(.*?)<\/note>

#<kinesic type="rumour-applause">
# <desc>$1$2$3$4$5<\/desc>
#<\/kinesic>/g' *.xml

#echo "aplausos y rumores"

#perl -pi -e 's/
#<note>(.*?)(.plauso|.plausos)(.+?)(.umor|.umores)(.*?)<\/note>

#<kinesic type="rumour-applause">
# <desc>$1$2$3$4$5<\/desc>
#<\/kinesic>/g' *.xml

echo "Aplausos" #--------- all aplause grouped ----------

#Notice Applauding may be combined with other kinesic or non kinesic actions like rumours laughter, protests, and even vocal interruptions, etc. 

perl -pi -e 's/<note>(.*?)(.plaude|.plausos|.plauso|.plauden)(.*?)<\/note>/<kinesic type="applause">\n <desc>$1$2$3<\/desc>\n<\/kinesic>/gi' *.xml

##PROTESTS

echo "protestas"

perl -pi -e 's/<note>(.*?)(protesta|protestas)(.*?)<\/note>/<vocal type="shouting">\n <desc>$1$2$3<\/desc>\n<\/vocal>/gi' *.xml

## RUMOURS

echo "rumores"

perl -pi -e 's/<note>(.*?)(rumor|rumores)(.*?)<\/note>/<vocal type="murmuring">\n <desc>$1$2$3<\/desc>\n<\/vocal>/gi' *.xml

#LAUGHTER

echo "laughter"

#VOCAL / kinesic [Ruben: I have commented all this because all this can be grouped under "laughter"]

#echo "VOCAL/KINESIC..."

#echo "risas, rumores y aplausos"
#perl -pi -e 's/<note>(.*?risas?.+?rumore?s?.+?aplausos?.*?)<\/note>
#/
#<kinesic type="laughter">
# <desc>$1<\/desc>
#<\/kinesic>

#/gi' *.xml

#echo "Risas.-Aplausos.-Protestas / Risas y aplausos y protestas"

#perl -pi -e 's/<note>(.*?risas?.+?aplausos?.+?protestas?.*?)<\/note>
#/
#<kinesic type="laughter">
# <desc>$1<\/desc>
#<\/kinesic>

#/gi' *.xml

#echo "Risas.-Aplausos.-Rumores / Risas y aplausos y rumores"

#perl -pi -e 's/<note>(.*?risas?.+?aplausos?.+?rumore?s?.*?)<\/note>
#/
#<kinesic type="laughter">
# <desc>$1<\/desc>
#<\/kinesic>

#/gi' *.xml


#echo "Risas-Aplausos / Risas y aplausos"

#perl -pi -e 's/<note>(.*?risas?.+?aplausos?.*?)<\/note>
#/
#<kinesic type="laughter">
# <desc>$1<\/desc>
#<\/kinesic>

#/gi' *.xml


#echo "Risas.-Rumores."

#perl -pi -e 's/<note>(.*?risas?.+?rumore?s?.*?)<\/note>
#/
#<kinesic type="laughter">
# <desc>$1<\/desc>
#<\/kinesic>

#/gi' *.xml

echo "risas"
perl -pi -e 's/<note>(.*?risas?.*?)<\/note>/<kinesic type="laughter">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

echo "se ríe"
perl -pi -e 's/<note>(.*?se ríe.*?)<\/note>/<kinesic type="laughter">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml


#Note this regex only gets notes starting with "Pausa". But there are other cases where Pausa is mixed with other COMMENTS.

perl -pi -e 's/<note>(.*?)(Paus.|Pausa|Pausa.+?)(.*?)<\/note>/<incident type="pause">\n <desc>$1$2$3<\/desc>\n<\/incident>/gi' *.xml


#KINESIC GESTURE
echo "kinesic"
perl -pi -e 's/<note>(.+?golpes?.*?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

perl -pi -e 's/<note>(.+?manos?.*?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

perl -pi -e 's/<note>(.+?dedos?.*?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

perl -pi -e 's/<note>(.+?)(rompen?|romper)(.*?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

echo "en pie (this tends to appear with applause and will be generally tagged as applause. But remaining cases are classified here"

perl -pi -e 's/<note>(.*?en\p{Z}+?pie.*?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

#INCIDENT ACTION
echo "incident action"

perl -pi -e 's/<note>(.*?coloca.+?)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

perl -pi -e 's/<note>(.*?retiran?\p{Z}+?.+?)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

perl -pi -e 's/<note>(.*?Se procede a.+?)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

perl -pi -e 's/<note>(.*?alarma.*?)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

echo "...deposita..."
perl -pi -e 's/<note>(.*?)(Deposita|despliega)(.+?)<\/note>/<incident type="action">\n <desc>$1$2$3<\/desc>\n<\/incident>/gi' *.xml

echo "...desinfectar la tribuna..."
perl -pi -e 's/<note>(.+?desinfectar\p{Z}+?la\p{Z}+?tribuna.*?)<\/note>/<incident type="action">\n <desc>$1<\/desc><\/incident>/gi' *.xml


#vOCAL TYPE CLARIFICATION
echo "dirige sus palabras / dirigiéndose"  
perl -pi -e 's/<note>(.*?)(dirige sus palabras|dirigiéndose|se dirige)(.*?)<\/note>/<vocal type="clarification">\n <desc>$1$2$3<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(.*?(leen?|leyendo).*?)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml


#FINAL INCIDENT TYPE ACTION
#to be run after El señor ... : ...

perl -pi -e 's/<note>(El\p{Z}+?señor|La\p{Z}+?señora|Los\p{Z}+?señores|Las\p{Z}+?señora)(.+?)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml


#FINAL VOCAL TYPE SPEAKING
echo "VOCAL TYPE SPEAKING- MPs speaking"

perl -pi -e 's/<note>(.+?\:.+?)<\/note>/<vocal type="speaking">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

#ENDING THE SCRIPT

perl -pi -e 's/<note>(.*?)<\/note>/<note type="comment">$1<\/note>/gi' *.xml

#RESTORING XXYY

echo "restoring XXYY\n (NOT ADDING a space)"
perl -pi -e 's/XXYY\n//g' *.xml

echo "fixing where we've put two spaces"
perl -pi -e 's/\s\s/ /g' *.xml

#BUG FIXING

#perl -pi -e 's/<note type=\"comment\">(Muesta un recorte de prensa)/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

#perl -pi -e 's/<note type=\"comment\">(señala a la bancada del Grupo Parlamentario Popular en el Congreso)/<kinesic type="signal">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

echo "END OF 04/05"