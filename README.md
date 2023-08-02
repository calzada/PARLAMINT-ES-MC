# PARLAMINT-ES-MC

Files with CD (Spanish Congress) interventions. They are processed in the following way:

[Processes so far]

## 1. ECPC XML (María Calzada Pérez)
The original workflow is kept in a separate SCRIPT repository. However, this original workflow is refined for Parlamint 3.0. 

### Original workflow:
#### 1.1 Download CD interventions
#### 1.2 Scripting to translate from HTML to XML with regexp
#### 1.3. Refining a first dtd to validate temporary XMl
#### 1.4. Renaming files  (script by María del Mar Bonet Ramos)
#### 1.5. Downloading metadata from cd web
#### 1.6. Formating information in a sandfromhash required format with regexp
#### 1.7. Adding filename
#### 1.8. Refining a second dtd to validate definite XML
#### 1.9. Numbering interventions and speeches is possible with separate scripts. Adding paragraphs and sentences is possible with a separate script (by Saturnino Luz) 

### Refinements
<note> </notes> are specified further according to TEI-PARLAMINT notes (documentation: https://clarin-eric.github.io/ParlaMint/#sec-comments)


## 2. Conversion to TEI format (Tomaz Erjavec)

### 2.1 Translating ECPC XML to TEI formate with Parlamint Makefile.

NOTICE Implementation can be placed in cd2parmamint.xsl or in a separate script (then Makefile modification is needed)
Notice Makefile  steps should be implemented from bottom to top. Targets are run with "make" command and the target (for instance: make cnv1).
If you are working on Windows, it is advisable to install ubuntu for Windows, to run makefile smoothly. Several errors will crop up while trying to run the makefile. 

2.0. Do apt upgrade and apt update

2.1. Saxon needs to be in the right place. This setup works (you should place SaxonHE12-3J here):
 /opt/SaxonHE12-3J/saxon-he-12.3.jar
-rw-r--r-- 1 root root 5559891 Jul 12 11:45 /opt/SaxonHE12-3J/saxon-he-12.3.jar

And the then you must create a symlink here
matyas@mPC:~$ ll /usr/share/java/saxon.jar
lrwxrwxrwx 1 root root 35 Jul 12 11:52 /usr/share/java/saxon.jar -> /opt/SaxonHE12-3J/saxon-he-12.3.jar 
saxon.jar in the right place: /usr/share/java/saxon.jar

Notice you should use Saxon-HE, because it allows you to run XSLT2.0 scripts

2.2. Parallel command is needed too. Check https://installati.one/install-parallel-ubuntu-20-04/ : sudo apt-get -y install parallel

2.3. SVN version is needed. You can install it (in Ubuntu) with apt install subversion
When install SVN because one script is loaded from the Ukrainian ParlaMint repository (you need to have svn installed for that.

## 3. Annotation (Luciana de Macedo)
### 3.1. Luciana de Macedo's magic script
the script https://github.com/calzada/PARLAMINT-ES-MC/blob/master/bin/ana_work_stanza.py  (by Luciana de Macedo) is working! But my machine is taking around 1 hour per file! It is important to have the best of GPU.


