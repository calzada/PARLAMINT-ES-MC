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

ana1: bin/ParCzech/udpipe2
	mkdir -p tmp.UD$(DIRSUFFIX)
	find ParlaMint$(DIRSUFFIX)/ -type f -printf "%P\n" |sort| grep 'ParlaMint-ES_' > tmp.UD$(DIRSUFFIX).fl
	perl -I bin/ParCzech/lib bin/ParCzech/udpipe2/udpipe2.pl \
	                             --colon2underscore \
	                             --model "es:spanish-ancora-ud-2.10-220711" \
	                             --elements "seg" \
	                             --debug \
	                             --no-space-in-punct \
	                             --try2continue-on-error \
	                             --filelist tmp.UD$(DIRSUFFIX).fl \
	                             --input-dir ParlaMint$(DIRSUFFIX)/ \
	                             --output-dir tmp.UD$(DIRSUFFIX)/

ana2: bin/ParCzech/nametag2
	mkdir -p tmp.NER$(DIRSUFFIX)
	perl -I bin/ParCzech/lib bin/ParCzech/nametag2/nametag2.pl \
	                                 --model "es:spanish-conll-200831" \
	                                 --filelist tmp.UD$(DIRSUFFIX).fl \
	                                 --input-dir tmp.UD$(DIRSUFFIX)/ \
	                                 --output-dir tmp.NER$(DIRSUFFIX)

ana-finalize:
	echo "TODO $@"
tei-finalize:
	echo "TODO $@"

# Process ParlaMint-ES corpus
gen:	cnv1 xis cnv2 val

# Validate corpus
val:
	echo "TODO: validation"
	# $s -xi -xsl:bin/copy.xsl ParlaMint$(DIRSUFFIX)/ParlaMint-ES.xml | $j schemas/parla-clarin.rng
	# -${vrt} ParlaMint$(DIRSUFFIX)/ParlaMint-ES.xml
	# -${vct} ParlaMint$(DIRSUFFIX)/ParlaMint-ES_*.xml
	# bin/validate-parlamint.pl schemas ParlaMint$(DIRSUFFIX)

#Second conversion: from TEI-ish corpus components to final TEI components + root
cnv2: patch-cnv1-result
	mkdir ParlaMint$(DIRSUFFIX) || :
	rm -f ParlaMint$(DIRSUFFIX)/*.xml
	$s inDir="../tmp$(DIRSUFFIX)" outDir="ParlaMint$(DIRSUFFIX)" componentFiles="../tmp$(DIRSUFFIX)/ParlaMint-component-ES.xml" \
	listOrgTemplate="../templates/ParlaMint-templateOrgs-ES.xml" \
	govListPerson="../data-wiki/gov-listPerson.xml" \
	taxonomyDir="../templates" \
	-xsl:bin/parlamint2root.xsl templates/ParlaMint-template-ES.xml
	make fix-affiliations DIRSUFFIX="$(DIRSUFFIX)"

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

patch-cnv1-result:
	cd tmp$(DIRSUFFIX)/; \
	  ../bin/notefixin-scripts/note-fixing-script-01.sh ;\
	  ../bin/notefixin-scripts/note-fixing-script-02.sh ;\
	  ../bin/notefixin-scripts/note-fixing-script-03.sh ;\
	  ../bin/notefixin-scripts/note-fixing-script-04.sh ;\
	  ../bin/notefixin-scripts/note-fixing-script-05.sh
	echo "cnv1 patched"


CD.sample:
	mkdir CD.sample
	ls CD/CD*.xml |sort | perl -ne '($$prev)=($$x//"CD00") =~ m/.*CD(..)/; $$x=$$_;print "$$x" unless $$x =~ m/CD$$prev/; END{print "$$x";}'| xargs -I {} cp {}  CD.sample/
	cp CD/*.dtd CD.sample/

create-sample: CD.sample
	make cnv1 DIRSUFFIX=".sample"
	make xis DIRSUFFIX=".sample"
	make cnv2 DIRSUFFIX=".sample"


download: data-wiki

data-wiki:
	mkdir data-wiki || :
	wget https://en.wikipedia.org/wiki/Second_government_of_Pedro_S%C3%A1nchez -O data-wiki/gov-2020-01-13.htm
	wget https://en.wikipedia.org/wiki/First_government_of_Pedro_S%C3%A1nchez -O data-wiki/gov-2018-06-07.htm
	wget https://en.wikipedia.org/wiki/Second_government_of_Mariano_Rajoy -O data-wiki/gov-2016-11-04.htm
	wget https://en.wikipedia.org/wiki/First_government_of_Mariano_Rajoy -O data-wiki/gov-2011-12-21.htm

data-gov-wiki2tei:
	perl bin/gov-wiki2tei.pl data-wiki/gov-listPerson.xml data-wiki/gov-????-??-??.htm

fix-affiliations: bin/affiliations-remove-overlaps.xsl bin/ParlaMint-UA-lib.xsl
	mv ParlaMint$(DIRSUFFIX)/ParlaMint-ES-listPerson.xml ParlaMint$(DIRSUFFIX)/ParlaMint-ES-listPerson.xml.bak
	$s -xsl:bin/affiliations-remove-overlaps.xsl \
	  ParlaMint$(DIRSUFFIX)/ParlaMint-ES-listPerson.xml.bak \
	  > ParlaMint$(DIRSUFFIX)/ParlaMint-ES-listPerson.xml


######---------------
annotation-prereq: bin/ParCzech/udpipe2 bin/ParCzech/nametag2 bin/ParCzech/lib

bin/ParCzech/udpipe2: bin/ParCzech bin/ParCzech/lib
	svn checkout https://github.com/ufal/ParCzech/trunk/src/udpipe2 bin/ParCzech/udpipe2
bin/ParCzech/nametag2: bin/ParCzech bin/ParCzech/lib
	svn checkout https://github.com/ufal/ParCzech/trunk/src/nametag2 bin/ParCzech/nametag2
bin/ParCzech/lib: bin/ParCzech
	svn checkout https://github.com/ufal/ParCzech/trunk/src/lib bin/ParCzech/lib
bin/ParCzech:
	mkdir bin/ParCzech


bin/affiliations-remove-overlaps.xsl:
	svn export https://github.com/ufal/ParlaMint-UA/trunk/Scripts/affiliations-remove-overlaps.xsl bin/affiliations-remove-overlaps.xsl
bin/ParlaMint-UA-lib.xsl:
	svn export https://github.com/ufal/ParlaMint-UA/trunk/Scripts/ParlaMint-UA-lib.xsl bin/ParlaMint-UA-lib.xsl




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
