#!/bin/sh
#This script aims to refine <note>
#author: María Calzada Pérez, Rubén de Líbano, Mónica Albini, 
#original date: 31/07/2023

#Potential onliners and other bobs used
# perl -pi -e 's///g' *.xml in one paragraph ONELINER
# perl -0777 -pi -e 's///g' *.xml in various paragraphs
#\p{Z}+?
# echo "XXXXX"



#VOCAL INTERRUPTIONS
##INSULTS
echo "INTERRUPTING insults"
perl -pi -e 's/<note>(ladrón|ladrones|bi.la.te.ra.les|cobarde|chabacano|bruja|idiota|Gobierno\p{Z}+criminal|golpistas?|golpistas\p{Z}+?y\p{Z}+?filoterroristas|gorrinos?|hez|es\p{Z}+el\p{Z}+hijo\p{Z}+de\p{Z}+un\p{Z}+terrorista|especialmente\,\p{Z}+especialmente|Haití\,\p{Z}+por\p{Z}+ejemplo|es\p{Z}+ironía)<\/note>/<vocal type="interruption">\n <desc>$1<\/desc><\/vocal>/gi' *.xml

perl -pi -e 's/<note>(de\p{Z}+?algo\p{Z}+?tenía\p{Z}+?que\p{Z}+?beneficiarse\p{Z}+?al\p{Z}+?tratarse\p{Z}+?de\p{Z}+?una\p{Z}+?isla|corromperles\p{Z}+?sexualmente|corrupción\p{Z}+?de\p{Z}+?los\p{Z}+?Borbones|corrupción\p{Z}+?de\p{Z}+?menores|corrupta\p{Z}+?Monarquía\p{Z}+?que\p{Z}+?roba\p{Z}+?sin\p{Z}+?descaro|monarquía\p{Z}+?corrupta|los desfalcos y la corrupción pública y notoria de la familia real española)<\/note>/<vocal type="interruption">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(facha|falangista|fascista|franquistas o fascistas|miserable|molestos y ajenos nos sentimos millones de catalanes)<\/note>/<vocal type="interruption">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

##OTHERS
echo "Other interruptions"
perl -pi -e 's/<note>(hay\p{Z}+?que.+?)<\/note>/<vocal type="interruption">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(algunos no cuando buscaban los votos)<\/note>/<vocal type="interruption">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(.para\p{Z}+?niños\p{Z}+?y\p{Z}+?niñas.)<\/note>/<vocal type="interruption">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

#VOCAL CLARIFICATION

echo "Vocal type clarification"

perl -pi -e 's/<note>(.+?lengua de signos.*?)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(aunque tengo que decirle, y no se lo tome a mal, señor Bedera, que la del señor Álvarez Areces estuvo mucho más centrada, de verdad, en temas educativos)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(nuestra enmienda tiene como objeto explicar las enmiendas del resto de secciones y de títulos en términos de gasto)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(y también en Latinoamérica)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(y a mí esta parte me parece estremecedora)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(y muy superiores salarios de sus mánager)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(y por tal ha de ser tenido mientras no haya una decisión judicial en contra)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(por cierto, el único por el que en dos ocasiones un Estado ha sido condenado por utilizar toda la excepcionalidad y la ilegalidad contra una persona, y ahí podríamos hablar de la razón de Estado contra el independentismo vasco o el independentismo catalán, pero eso lo haremos otro día)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(Me queda poco tiempo)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(el\p{Z}+terrorismo\p{Z}+de\p{Z}+Dáesh,\p{Z}+etcétera)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(el título que tenemos hoy aquí fue el que puso precisamente la organización de estos actos)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(El noi del sucre)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(el oficio más antiguo del mundo, ese que tanto gusta a los socialistas andaluces)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc><\/vocal>/gi' *.xml


perl -pi -e 's/<note>(ayer se acordó la ampliación del plazo de enmiendas durante una semana)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(he dicho muchas veces que si este Gobierno tiene un debe no es con todas las mujeres, es particularmente con las madres de este país, también con las mujeres jóvenes, pero particularmente con las madres, que han hecho malabares en el último año)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc><\/vocal>/gi' *.xml

perl -pi -e 's/<note>(creación del un fondo social|de los trabajadores, de las empresas, de las pymes, de los autónomos, de las familias y de los pensionistas)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc>\n<\/vocal>/gi' *.xml

perl -pi -e 's/<note>(democrático, plural, participativo, aconfesional y humanista, abierto al progreso y a todos los movimientos de avance de la civilización que mejoren la calidad de vida de las personas)<\/note>/<vocal type="clarification">\n <desc>$1<\/desc><\/vocal>/gi' *.xml

#KINESIC SIGNAL
echo "kinesic final signal"

perl -pi -e 's/<note>(indicando a las tribunas del público)<\/note>/<kinesic type="signal">\n <desc>$1<\/desc>\n<\/kinesic>/gi' *.xml

echo "END OF 03/05"
