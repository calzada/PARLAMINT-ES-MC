#Fixing the .tei files
#Insert word extent for ana, remove empty segs, redo tagUsage
#We also need to fix root file (date, extents)
test-fix-tei:
	rm -f tmp/*
	cp ParlaMint/ParlaMint-ES.xml tmp
	bin/fix-tei.pl 'ParlaMint/ParlaMint-ES_2015-01-20-CD150120.xml' ParlaMint.ana tmp
	bin/validate-parlamint.pl schemas tmp

#Fixing the .ana files
#the result is in tmp, which has then has to be moved to ParlaMint.ana
#overwritting the original files
#We also need to fix root file (date, extents)
test-fix-ana:
	rm -f tmp/*
	cp ParlaMint.ana/ParlaMint-ES.ana.xml tmp
	bin/fix-ana.pl 'ParlaMint.ana/ParlaMint-ES_2015-01-*.xml' tmp
	bin/validate-parlamint.pl schemas tmp
nohup-fix:
	nohup time make fix-ana > nohup.fix &
fix-ana:
	rm -f tmp/*
	cp ParlaMint.ana/ParlaMint-ES.ana.xml tmp
	ls ParlaMint.ana/*_*.xml | $P --jobs 10 \
	'bin/fix-ana.pl {} tmp'
	bin/validate-parlamint.pl schemas tmp

# Process in background, save log
nohup-gen:
	nohup time make all > log.txt &

# Process ParlaMint-ES corpus
all:	cnv1 cnv2 val

# Validate corpus
val:
	$s -xi -xsl:bin/copy.xsl ParlaMint/ParlaMint-ES.xml | $j schemas/parla-clarin.rng
	-${vrt} ParlaMint/ParlaMint-ES.xml 
	-${vct} ParlaMint/ParlaMint-ES_*.xml
	bin/validate-parlamint.pl schemas ParlaMint

#Second conversion: from TEI-ish corpus components to final TEI components + root
cnv2:
	rm -f ParlaMint/*.xml
	$s inDir="../tmp" outDir="ParlaMint" \
	-xsl:bin/parlamint2root.xsl bin/ParlaMint-template-ES.xml

#First conversion: from CD format to TEI-ish corpus components
cnv1:
	rm -f tmp/*
	ls CD/*.xml | $P --jobs 10 \
	'$s -xsl:bin/cd2parmamint.xsl {} > tmp/{/.}-PM.xml'
	#ls tmp/*-PM.xml | xargs ${pc} 
	#$j schemas/parla-clarin.rng tmp/*-PM.xml

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
