#!/bin/sh
#This script aims to refine <note>
#author: María Calzada Pérez, Rubén de Líbano, Mónica Albini, 
#original date: 31/07/2023

#Potential onliners and other bobs used
# perl -pi -e 's///gi' *.xml in one paragraph ONELINER
# perl -0777 -pi -e 's///g' *.xml in various paragraphs
#\p{Z}+?
# echo "XXXXX"

#INCIDENTS

#INCIDENT TYPE ACTION: MINUTE OF SILENCE
echo "minuto de silencio"
perl -pi -e 's/<note>(.+?minuto\p{Z}+?de\p{Z}+?silencio.*?)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

echo "La Presidencia desconecta el micrófono"
perl -pi -e 's/<note>(La\p{Z}+?Presidencia\p{Z}+?desconecta\p{Z}+?el\p{Z}+?micrófono.*?)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

echo "Acerca el móvil al micrófono"
perl -pi -e 's/<note>(Acerca\p{Z}+?el\p{Z}+?móvil\p{Z}+?al\p{Z}+?micrófono.*?)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

echo "Antes de iniciar su intervención deposita dos naranjas sobre la tribuna"
perl -pi -e 's/<note>(Antes de iniciar su intervención deposita dos naranjas sobre la tribuna)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

echo "abandonan el hemiciclo"
perl -pi -e 's/<note>(.*?abandonan el hemiciclo.*?)<\/note>/<incident type="leaving">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

echo "abandonan su escaño"
perl -pi -e 's/<note>(.*?abandona.+?escaño.*?)<\/note>/<incident type="leaving">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

perl -pi -e 's/<note>(.*?abandonando\p{Z}+?el\p{Z}+?hemiciclo.*?)<\/note>/<incident type="leaving">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

echo "... se ausenta..."
perl -pi -e 's/<note>(.*?se\p{Z}+?ausenta.*?)<\/note>/<incident type="leaving">\n <desc>$1<\/desc>\n <\/incident>/gi' *.xml

echo "... se reincorpora..."
perl -pi -e 's/<note>(.*?se\p{Z}+?reincorpora.*?)<\/note>/<incident type="entering">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

echo "... (entra|entran\entrar).."
perl -pi -e 's/<note>(.*?(\sentra\s|\sentran\s|\sentrar\s).*?)<\/note>/<incident type="entering">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

echo "regresan?\p{Z}+?al\p{Z}+?hemiciclo"
perl -pi -e 's/<note>(.*?regresan?\p{Z}+?al\p{Z}+?hemiciclo.*?)<\/note>/<incident type="entering">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

echo "vuelven?\p{Z}+?al\p{Z}+?hemiciclo"
perl -pi -e 's/<note>(.*?vuelven?\p{Z}+?al\p{Z}+?hemiciclo.*?)<\/note>/<incident type="entering">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

echo "...desinfecta la tribuna..."
perl -pi -e 's/<note>(.+?desinfecta\p{Z}+?la\p{Z}+?tribuna.*?)<\/note>/<incident type="action">\n <desc>$1<\/desc>\n<\/incident>/gi' *.xml

#KINESIC TYPE GESTURE:DO THIS BEFORE .+?\:-+?

echo "(muestra|muestran)...:..."

perl -pi -e 's/<note>(muestra.+?\:.+?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

perl -pi -e 's/<note>(.+?muestra.+?\:.+?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

perl -pi -e 's/<note>(.*?muestra.+?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

perl -pi -e 's/<note>(.+?mostrar.+?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

perl -pi -e 's/<note>(.*?mostrando.+?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

perl -pi -e 's/<note>(.*?enseñan?.+?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

echo "entrecomilla con los dedos"
perl -pi -e 's/<note>(.*?entrecomilla\p{Z}+?con\p{Z}+?los\p{Z}+?dedos.*?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml


echo "gesturing"
perl -pi -e 's/<note>(.*?)(gestos?|signos?)(.*?)<\/note>/<kinesic type="gesture">\n <desc>$1$2$3<\/desc>\n<\/kinesic>/gi' *.xml

perl -pi -e 's/<note>(mirando.+?)<\/note>/<kinesic type="gesture">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

#KINESIC TYPE SIGNAL
echo "...señala|señalan..."
perl -pi -e 's/<note>(.*?)(señalan?|señalando)(.*?)<\/note>/<kinesic type="signal">\n <desc>$1$2$3<\/desc>\n<\/kinesic>/gi' *.xml

echo "pide la palabra"
perl -pi -e 's/<note>(.*?pide.?\p{Z}+?la\p{Z}+?palabra.*?).*?<\/note>/<kinesic type="signal">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

echo "levanta la mano"
perl -pi -e 's/<note>(.*?levanta\p{Z}+?la\p{Z}+?mano.*?).*?<\/note>/<kinesic type="signal">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

echo "levanta el dedo"
perl -pi -e 's/<note>(.*?levanta\p{Z}+?el\p{Z}+?dedo.*?)<\/note>/<kinesic type="signal">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

echo "levantando... "
perl -pi -e 's/<note>(.*?levantado\p{Z}.+?)<\/note>/<kinesic type="signal">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

#VOCAL

##VOCAL GREETING

perl -pi -e 's/<note>(Veo que el señor ministro acude, y se lo agradezco)<\/note>/<vocal type="greeting">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

##VOCAL SPEAKING

echo "COMMENT ON SPEAKING"
perl -pi -e 's/<note>(.*?)(intercambian?\p{Z}+?algunas\p{Z}+?palabras|intercambian?\p{Z}+?unas\p{Z}+?palabras|uso\p{Z}+?de\p{Z}+?la\p{Z}+?palabra|una\p{Z}+?conversación|hablando|hablar|hablan?|dialogan?)(.*?)<\/note>/<vocal type="speaking">\n <desc>$1$2$3<\/desc>\n<\/vocal>/gi' *.xml


perl -pi -e 's/<note>(.+?alusión.+?)<\/note>/<vocal type="speaking">\n\s}<desc>$1<\/desc>\n<\/vocal>/gi' *.xml

echo "El señor...: ..."
perl -pi -e 's/<note>(El\p{Z}+?señor|La\p{Z}+?señora|Los\p{Z}+?señores|las\p{Z}+?señoras)(.+?\:.+?)<\/note>/<vocal type="speaking">\n <desc>$1$2<\/desc>\n<\/vocal>/gi' *.xml

echo "END OF 02/05"