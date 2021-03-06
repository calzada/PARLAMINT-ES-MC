#Test of first step of conversion
test1:
	$s -xsl:bin/cd2parmamint.xsl CD/CD190122.xml > TEST.xml
	${vct} TEST.xml

# Process in background, save log
nohup:
	nohup time make all > log.txt &

# Process ParlaMint-ES corpus
all:	cnv1 cnv2 val

# Validate corpus
val:
	$s -xi -xsl:bin/copy.xsl ParlaMint-ES/ParlaMint-ES.xml | $j schemas/parla-clarin.rng
	-${vrt} ParlaMint/ParlaMint-ES.xml 
	-${vct} ParlaMint/ParlaMint-ES_*.xml
	bin/validate-parlamint.pl schemas ParlaMint

#Second conversion: from TEI-ish corpus components to final TEI components + root
cnv2:
	rm -f ParlaMint/*.xml
	$s inDir="../tmp" outDir="ParlaMint" \
	-xsl:bin/parlamint2root.xsl bin/ParlaMint-template.xml

#First conversion: from CD format to TEI-ish corpus components
cnv1:
	ls CD/*.xml | $P --jobs 10 \
	'$s -xsl:bin/cd2parmamint.xsl {} > tmp/{/.}-PM.xml'
	ls tmp/*-PM.xml | xargs ${pc} 
	$j schemas/parla-clarin.rng tmp/*-PM.xml

#Generate the XInclude part of the (temporary) corpus root
xis:
	cd tmp/; ls *-PM.xml | \
	perl -pe 's|^|   <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="|; s|\n|"/>\n|' > \
	../bin/ParlaMint-xi.tmp

s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
P = parallel --gnu --halt 2
pc = -I % $s -xi -xsl:bin/copy.xsl % | $j schemas/parla-clarin.rng
# Corpus root / text
vrt = $j schemas/ParlaMint-teiCorpus.rng
# Corpus component / text
vct = $j schemas/ParlaMint-TEI.rng
# Corpus root / analysed
vra = $j schemas/ParlaMint-teiCorpus.ana.rng
# Corpus component / analysed
vca = $j schemas/ParlaMint-TEI.ana.rng
