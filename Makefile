DIRSUFFIX =

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
	nohup time make gen > log.txt &

# Process ParlaMint-ES corpus
gen:	cnv1 cnv2 val

# Validate corpus
val:
	$s -xi -xsl:bin/copy.xsl ParlaMint$(DIRSUFFIX)/ParlaMint-ES.xml | $j schemas/parla-clarin.rng
	-${vrt} ParlaMint$(DIRSUFFIX)/ParlaMint-ES.xml
	-${vct} ParlaMint$(DIRSUFFIX)/ParlaMint-ES_*.xml
	bin/validate-parlamint.pl schemas ParlaMint$(DIRSUFFIX)

#Second conversion: from TEI-ish corpus components to final TEI components + root
cnv2:
	mkdir ParlaMint$(DIRSUFFIX) || :
	rm -f ParlaMint$(DIRSUFFIX)/*.xml
	$s inDir="../tmp$(DIRSUFFIX)" outDir="ParlaMint$(DIRSUFFIX)" componentFiles="../tmp$(DIRSUFFIX)/ParlaMint-component-ES.xml" \
	listOrgTemplate="../templates/ParlaMint-templateOrgs-ES.xml" \
	-xsl:bin/parlamint2root.xsl templates/ParlaMint-template-ES.xml

#First conversion: from CD format to TEI-ish corpus components
cnv1: tmp$(DIRSUFFIX)
	rm -f tmp$(DIRSUFFIX)/*
	ls CD$(DIRSUFFIX)/*.xml | $P --jobs 10 \
	'$s -xsl:bin/cd2parmamint.xsl {} | bin/polish.pl > tmp$(DIRSUFFIX)/{/.}-PM.xml'
	#ls tmp/*-PM.xml | xargs ${pc} 
	#$j schemas/parla-clarin.rng tmp/*-PM.xml

#Generate the XInclude part of the (temporary) corpus root
xis: tmp$(DIRSUFFIX)
	cd tmp$(DIRSUFFIX)/; \
	echo '<?xml version="1.0" encoding="UTF-8"?>' > ParlaMint-component-ES.xml; \
	echo '<teiCorpus xmlns="http://www.tei-c.org/ns/1.0">' >> ParlaMint-component-ES.xml; \
	ls *-PM.xml | \
	perl -pe 's|^|   <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="|; s|\n|"/>\n|' >> \
	ParlaMint-component-ES.xml ;\
	echo '</teiCorpus>' >> ParlaMint-component-ES.xml

tmp$(DIRSUFFIX):
	mkdir tmp$(DIRSUFFIX)

CD.sample:
	mkdir CD.sample
	ls CD/CD*.xml |sort | perl -ne '($$prev)=($$x//"CD00") =~ m/.*CD(..)/; $$x=$$_;print "$$x" unless $$x =~ m/CD$$prev/; END{print "$$x";}'| xargs -I {} cp {}  CD.sample/
	cp CD/*.dtd CD.sample/

create-sample: CD.sample
	make cnv1 DIRSUFFIX=".sample"
	make xis DIRSUFFIX=".sample"
	make cnv2 DIRSUFFIX=".sample"

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
