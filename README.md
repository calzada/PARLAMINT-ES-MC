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
```<note> </notes>``` are specified further according to TEI-PARLAMINT notes (documentation: https://clarin-eric.github.io/ParlaMint/#sec-comments)


## 2. Conversion to TEI format (Tomaz Erjavec)

### 2.1 Translating ECPC XML to TEI formate with Parlamint Makefile.

NOTICE Implementation can be placed in cd2parmamint.xsl or in a separate script (then Makefile modification is needed)

Notice Makefile steps should be implemented from bottom to top. Targets are run with "make" command and the target (for instance: make cnv1).

If you are working on Windows, it is advisable to install a Windows Subsystem for Linux (WSL) to use bash command-line tools on Windows and run makefile smoothly. Several errors will crop up while trying to run the makefile.

2.0. Enable WSL

Open Windows Features, scroll down and check Windows Susbsystem for Linux. Select OK and restart Windows.

2.1. Open PowerShell or Command prompt (terminal) as an administrator (right click)

type wsl --list --online to view a list of available WSL distributions that can be installed

2.2. Type the specific distribution (for example, Ubuntu): wsl --install -d Ubuntu and press enter. Restart your computer

2.3. After restarting, it may take a while to install your desirable distribution.

2.4. Once installation of Ubuntu is complete, you'll be prompted to enter your username and password

2.5. Launch Ubuntu from the start menu on Windows

2.6. Do apt upgrade and apt update

Update by typing

$ sudo apt-get update

you'll be prompted to enter your password (step 7)

Upgrade by typing

$ sudo apt-get upgrade

2.7. Install packages and dependencies (you'll be prompted several times "Do you want to continue? [Y/n]" type Y)

$ sudo apt install moreutils

$ sudo apt install make

$ sudo apt install parallel

$ sudo apt install openjdk-19-jre-headless

$ sudo apt install unzip

There's a script loaded from the Ukrainian ParlaMint repository so you need to have svn installed:

$ sudo apt install subversion

$ sudo apt install jing

2.8. Saxon needs to be in the right place. This setup works (you should place SaxonHE12-3J here):

/opt/SaxonHE12-3J/saxon-he-12.3.jar

-rw-r--r-- 1 root root 5559891 Jul 12 11:45 /opt/SaxonHE12-3J/saxon-he-12.3.jar

go to /otp and make a dir to install SaxonHE12-3J.zip

$ cd /otp

$ sudo mkdir SaxonHE12-3J

Download SaxonHE12-3J.zip from [https://www.saxonica.com/download/] and move the file to /otp/SaxonHE12-3J

$ sudo mv /mnt/c/Users/XXXXX/Downloads/SaxonHE12-3J.zip /opt/SaxonHE12-3J

where XXXXX is your windows username

Unzip SaxonHE12-3J.zip

$ cd /otp/SaxonHE12-3J

$ sudo unzip SaxonHE12-3J.zip

then, you must create a symlink here

$ sudo ln -s /opt/SaxonHE12-3J/saxon-he-12.3.jar /usr/share/java/saxon.jar

verify that you have saxon.jar in the right place: /usr/share/java/saxon.jar

$ ll /usr/share/java/saxon.jar

lrwxrwxrwx 1 root root 35 Jul 12 11:52 /usr/share/java/saxon.jar -> /opt/SaxonHE12-3J/saxon-he-12.3.jar

Notice you should use Saxon-HE, because it allows you to run XSLT2.0 scripts

Now you can run makefile.

## 3. Annotation (Luciana de Macedo)
### 3.1. Luciana de Macedo's magic script
the script https://github.com/calzada/PARLAMINT-ES-MC/blob/master/bin/ana_work_stanza.py  (by Luciana de Macedo) is working! But my machine is taking around 1 hour per file! It is important to have the best of GPU.

To run de Macedo's script: 

#### 3.1.1 It's necessary to download the stanza package (pip install stanza). The other necessary libraries will me signaled by the system.

#### 3.1.2 It's important to create a directory called "result" before running the code.

#### 3.1.3 It's also super important to run the second script as a final step (ana_fix_after_bugs). It corrects some other formatting errors and changes the name of the files to .ana.xml

