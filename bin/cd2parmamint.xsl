<?xml version='1.0' encoding='UTF-8'?>
<!-- Convert Spanish CD format to ParlaMint -->
<!-- * remove non-ParlaMint elements
     * in <participDesc> collect speaker metadata (static and timestamped memberships)
     * change \n in speeches to <lb/>
     * rename to TEI
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:et="http://nl.ijs.si/et"
                xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
                exclude-result-prefixes="xsl et mk tei">
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="speech"/>

  <!-- Why exactly was this date chosen? -->
  <xsl:param name="COVID-date">2019-11-01</xsl:param>
  
  <!-- To stamp file with today's date: -->
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:variable name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  
  
  <!-- More metadata could probably be collected apart from the date? -->
  <xsl:variable name="session-date">
    <xsl:variable name="date" select="et:digits2date(/ecpc_CD/header/date)"/>
    <xsl:if test="not(matches($date, '20[12][0-9](-[01][12](-[0-3][0-9])?)?'))">
      <xsl:message select="concat('ERROR: Bad session date ', $date, ' in ', base-uri())"/>
    </xsl:if>
    <xsl:value-of select="$date"/>
  </xsl:variable>
  
  <xsl:template match="header">
    <teiHeader xmlns="http://www.tei-c.org/ns/1.0">
      <fileDesc>
        <titleStmt>
          <xsl:variable name="n" select="replace(label, '.+ núm. (\d+).*', '$1')"/>
          <xsl:variable name="title-en">
            <xsl:choose>
              <xsl:when test="contains(label, 'plenaria')">
                <xsl:text>Plenary session </xsl:text>
                <xsl:value-of select="$n"/>
                <xsl:if test="ends-with($id, '-bis')">
                  <xsl:text>, cont.</xsl:text>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message select="concat('ERROR: Strange label ', label)"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="concat(' (', $session-date, ')')"/>
          </xsl:variable>
          <xsl:variable name="title-es">
            <xsl:apply-templates select="label"/>
            <xsl:if test="ends-with($id, '-bis')">
              <xsl:text>, bis</xsl:text>
            </xsl:if>
            <xsl:value-of select="concat(' (', $session-date, ')')"/>
          </xsl:variable>
          <title xml:lang="en" type="main">
            <xsl:text>Spanish parliamentary corpus ParlaMint-ES, </xsl:text>
            <xsl:value-of select="$title-en"/>
            <xsl:text> [ParlaMint]</xsl:text>
          </title>
          <title xml:lang="es" type="main">
            <xsl:text>Corpus parlamentario en español ParlaMint-ES, </xsl:text>
            <xsl:value-of select="$title-es"/>
            <xsl:text> [ParlaMint]</xsl:text>
          </title>
          <title xml:lang="es" type="sub">
            <xsl:value-of select="$title-es"/>
          </title>
          <title xml:lang="en" type="sub">
            <xsl:value-of select="$title-en"/>
          </title>
          <meeting n="{$session-date}" corresp="#CD" ana="#parla.lower #parla.sitting"><xsl:value-of select="$session-date"/></meeting>
          <meeting n="{$n}" corresp="#CD" ana="#parla.lower #parla.session">
      <xsl:apply-templates select="label"/>
    </meeting>
          <meeting>
            <xsl:attribute name="n">
              <xsl:choose>
                <xsl:when test="legislature = 'VIII'">8</xsl:when>
                <xsl:when test="legislature = 'IX'">9</xsl:when>
                <xsl:when test="legislature = 'X'">10</xsl:when>
                <xsl:when test="legislature = 'XI'">11</xsl:when>
                <xsl:when test="legislature = 'XII'">12</xsl:when>
                <xsl:when test="legislature = 'XIII'">13</xsl:when>
                <xsl:when test="legislature = 'XIV'">14</xsl:when>
                <xsl:when test="legislature = 'XV'">15</xsl:when>
    <xsl:when test="legislature = 'XVI'">16</xsl:when>
    <xsl:when test="legislature = 'XVII'">17</xsl:when>
    <xsl:when test="legislature = 'XVIII'">18</xsl:when>
    <xsl:when test="legislature = 'XIX'">19</xsl:when>
    <xsl:when test="legislature = 'XX'">20</xsl:when>
                <xsl:otherwise>
                  <xsl:message select="concat('ERROR: wrong legislature ', legislature)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="corresp">#CD</xsl:attribute>
            <xsl:attribute name="ana">
              <xsl:text>#parla.lower #parla.term </xsl:text>
              <xsl:choose>
                <xsl:when test="legislature = 'VIII'">#CD.8</xsl:when>
                <xsl:when test="legislature = 'IX'">#CD.9</xsl:when>
                <xsl:when test="legislature = 'X'">#CD.10</xsl:when>
                <xsl:when test="legislature = 'XI'">#CD.11</xsl:when>
                <xsl:when test="legislature = 'XII'">#CD.12</xsl:when>
                <xsl:when test="legislature = 'XIII'">#CD.13</xsl:when>
                <xsl:when test="legislature = 'XIV'">#CD.14</xsl:when>
    <xsl:when test="legislature = 'XV'">#CD.15</xsl:when>
    <xsl:when test="legislature = 'XVI'">#CD.16</xsl:when>
    <xsl:when test="legislature = 'XVII'">#CD.17</xsl:when>
    <xsl:when test="legislature = 'XVIII'">#CD.18</xsl:when>
    <xsl:when test="legislature = 'XIX'">#CD.19</xsl:when>
    <xsl:when test="legislature = 'XX'">#CD.20</xsl:when>
                <xsl:otherwise>
                  <xsl:message select="concat('ERROR: wrong legislature ', legislature)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:text>Legislatura </xsl:text>
            <xsl:value-of select="legislature"/>
          </meeting>
        </titleStmt>
        <editionStmt>
          <edition>2.0</edition>
        </editionStmt>
        <extent>
          <measure unit="speeches" quantity="0" xml:lang="en">0 speeches</measure>
          <measure unit="speeches" quantity="0" xml:lang="es">0 intervenciones</measure>
          <measure unit="words" quantity="0" xml:lang="en">0 words</measure>
          <measure unit="words" quantity="0" xml:lang="es">0 palabras</measure>
        </extent>
        <publicationStmt>
          <publisher>
            <orgName xml:lang="es">Infraestructura de investigación CLARIN</orgName>
            <orgName xml:lang="en">The CLARIN research infrastructure</orgName>
            <ref target="https://www.clarin.eu/">www.clarin.eu</ref>
          </publisher>
          <idno type="URI" subtype="handle">http://hdl.handle.net/11356/1388</idno>
          <availability status="free">
            <licence>http://creativecommons.org/licenses/by/4.0/</licence>
               <p xml:lang="es">Este trabajo se encuentra protegido por la licencia <ref target="https://creativecommons.org/licenses/by/4.0/">Atribución 4.0 Internacional</ref>.</p>
            <p xml:lang="en">This work is licensed under the <ref target="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</ref></p>
          </availability>
          <date when="{$today-iso}">
            <xsl:value-of select="$today"/>
          </date>
        </publicationStmt>
        <sourceDesc>
          <bibl>
            <title xml:lang="es" type="main">
              <xsl:value-of select="normalize-space(title)"/>
            </title>
            <idno type="URI">http://www.congreso.es</idno>
            <date when="{$session-date}">
              <xsl:value-of select="$session-date"/>
            </date>
          </bibl>
        </sourceDesc>
      </fileDesc>
      <encodingDesc>
        <projectDesc>
            <p xml:lang="es">
               <ref target="https://www.clarin.eu/content/parlamint">ParlaMint</ref>
            </p>
          <p xml:lang="en"><ref target="https://www.clarin.eu/content/parlamint">ParlaMint</ref> is a project that aims to (1) create a multilingual set of comparable corpora of parliamentary proceedings uniformly encoded according to the <ref target="https://github.com/clarin-eric/parla-clarin">Parla-CLARIN recommendations</ref> and covering the COVID-19 pandemic from November 2019 as well as the earlier period from 2015 to serve as a reference corpus; (2) process the corpora linguistically to add Universal Dependencies syntactic structures and Named Entity annotation; (3) make the corpora available through concordancers and Parlameter; and(4) build use cases in Political Sciences and Digital Humanities based on the corpus data.</p>
        </projectDesc>
        <tagsDecl/>
      </encodingDesc>
      <profileDesc>
        <settingDesc>
          <setting>
            <name type="address">Calle Floridablanca, s/n. 28071</name>
            <name type="city">Madrid</name>
            <name type="country" key="ES">Spain</name>
            <date ana="#parla.sitting" when="{$session-date}">
              <xsl:value-of select="$session-date"/>
            </date>
          </setting>
        </settingDesc>
        <xsl:variable name="listOrg">
          <xsl:variable name="parties">
            <!-- Collect all party affiliations -->
            <xsl:for-each select="/ecpc_CD/body//intervention/speaker/affiliation">
              <xsl:sort/>
              <xsl:variable name="party_name" select="mk:fix-party-name(national_party)"/>
              <xsl:if test="et:set($party_name)">
                <org role="politicalParty" xml:id="party.{et:str2id($party_name)}">
                  <orgName full="init">
                    <xsl:value-of select="$party_name"/>
                  </orgName>
                  <orgName full="yes">?</orgName>
                </org>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <listOrg>
            <!-- Make parties unique based on their ID -->
            <xsl:for-each select="$parties/tei:org">
              <xsl:variable name="pid" select="@xml:id"/>
              <xsl:if test="not(preceding-sibling::tei:org/@xml:id = $pid)">
                <xsl:copy-of select="."/>
              </xsl:if>
            </xsl:for-each>
          </listOrg>
        </xsl:variable>
        <xsl:variable name="listPerson">
          <!-- Collect all speakers -->
          <xsl:variable name="persons">
            <xsl:for-each select="/ecpc_CD/body//intervention/speaker">
              <xsl:sort/>
              <xsl:call-template name="speaker2person"/>
            </xsl:for-each>
          </xsl:variable>
          <listPerson>
            <!-- Make speakers unique based on their ID (= short name) -->
            <xsl:for-each select="$persons/tei:person">
              <xsl:variable name="pid" select="@xml:id"/>
              <xsl:if test="not(preceding-sibling::tei:person/@xml:id = $pid)">
                <xsl:copy-of select="."/>
              </xsl:if>
            </xsl:for-each>
          </listPerson>
        </xsl:variable>
        <xsl:if test="$listOrg//tei:org or $listPerson//tei:person">
          <particDesc>
            <xsl:if test="$listOrg//tei:org">
              <xsl:copy-of select="$listOrg"/>
            </xsl:if>
            <xsl:if test="$listPerson//tei:person">
              <xsl:copy-of select="$listPerson"/>
            </xsl:if>
          </particDesc>
        </xsl:if>
      </profileDesc>
    </teiHeader>
  </xsl:template>
  
  <!-- ParlaMint root ID  -->
  <xsl:variable name="id">
    <xsl:text>ParlaMint-ES_</xsl:text>
    <xsl:value-of select="$session-date"/>
    <xsl:text>-</xsl:text>
    <!-- This is *not* the filename! -->
    <!--xsl:value-of select="/ecpc_CD/header/@filename"/-->
    <xsl:value-of select="replace(base-uri(), '.*?([^/]+)\.xml', '$1')"/>
  </xsl:variable>
  
  <!-- XML ROOT -->
  <!-- 2 pass processing, second pass computes size -->
  <xsl:template match="/">
    <xsl:variable name="pass1">
      <xsl:apply-templates/>
    </xsl:variable>
    <!-- Count elements for the teiHeader: extent + tagUsage -->
    <xsl:apply-templates mode="extents" select="$pass1"/>
  </xsl:template>
  <!-- Process the CD root element -->

  <xsl:template match="ecpc_CD">
    <xsl:message select="concat('INFO: processing ', replace(base-uri(), '.+/', ''))"/>
    <!-- Give id and covid/reference subcorpus -->
    <!-- @ana should also contain the session / sitting ... number! -->
    <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:lang="es"
         xml:id="{$id}" ana="{concat('#parla.sitting ',et:subcorpus($session-date))}">
      <xsl:apply-templates/>
    </TEI>
  </xsl:template>

  <!-- extent mode computes size of the TEI/text (extent + tagUsage) -->
  <xsl:template mode="extents" match="tei:measure[@unit='speeches']">
    <xsl:variable name="quant" select="count(//tei:u)"/>
    <xsl:copy>
      <xsl:attribute name="unit" select="@unit"/>
      <xsl:attribute name="quantity" select="format-number($quant, '#')"/>
      <xsl:attribute name="xml:lang" select="@xml:lang"/>
      <xsl:variable name="formatted" select="format-number($quant, '###,###,###')"/>
      <xsl:choose>
        <xsl:when test="@xml:lang = 'es'">
          <xsl:value-of select="replace(., '^\d+', $formatted)"/>
        </xsl:when>
        <xsl:when test="@xml:lang = 'en'">
          <xsl:value-of select="replace(., '^\d+', replace($formatted, ',', '.'))"/>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="extents" match="tei:tagsDecl">
    <xsl:copy>
      <namespace xmlns="http://www.tei-c.org/ns/1.0" name="http://www.tei-c.org/ns/1.0">    
        <xsl:apply-templates mode="extents" select="@*"/>
        <xsl:apply-templates mode="tagCount" select="//tei:text/tei:*"/>
      </namespace>
    </xsl:copy>
  </xsl:template>
  <!-- Count all elements -->
  <xsl:template mode="tagCount" match="*">
    <xsl:variable name="self" select="name()"/>
    <xsl:if test="not(following::*[name()=$self] or descendant::*[name()=$self] )">
      <tagUsage xmlns="http://www.tei-c.org/ns/1.0" gi="{$self}">
        <xsl:attribute name="occurs">
          <xsl:number level="any" from="tei:text"/>
        </xsl:attribute>
      </tagUsage>
    </xsl:if>
    <xsl:apply-templates mode="tagCount"/>
  </xsl:template>
  <xsl:template mode="tagCount" match="text()"/>
  <!-- Act as a filter -->
  <xsl:template mode="extents" match="tei:*">
    <xsl:copy>
      <xsl:apply-templates mode="extents" select="@*"/>
      <xsl:apply-templates mode="extents"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="extents" match="@*">
    <xsl:copy-of select="."/>
  </xsl:template>
  <xsl:template mode="extents" match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- eg. 
       <label>Sesión plenaria núm. 65</label> or
       <label>Sesión plenaria núm. 24 <omit type="comment">Sesión extraordinaria</omit></label> 
  -->
  <xsl:template match="label">
    <xsl:variable name="str">
      <xsl:value-of select="."/>
      <xsl:text>&#32;</xsl:text>
      <xsl:value-of select="omit"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($str)"/>
  </xsl:template>
  
  <!-- Remove non-ParlaMint elements -->
  <xsl:template match="title"/>
  <xsl:template match="date"/>
  <xsl:template match="place"/>
  <xsl:template match="edition"/>
  <xsl:template match="index"/>
  <xsl:template match="indexitem"/>
  <xsl:template match="back"/>

  <xsl:template match="body">
    <text xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="ana" select="et:subcorpus($session-date)"/>
      <body>
        <xsl:apply-templates/>
      </body>
    </text>
  </xsl:template>
  
  <!-- Make divs based on headings -->
  <xsl:template match="chair">
    <xsl:for-each-group select="*" group-starting-with="heading">
      <div xmlns="http://www.tei-c.org/ns/1.0" type="debateSection">
        <xsl:apply-templates select="current-group()"/>
      </div>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="page_number">
    <xsl:text>&#32;</xsl:text>
    <pb xmlns="http://www.tei-c.org/ns/1.0"
        n="{replace(., '.*?(\d+)$', '$1')}"/>
  </xsl:template>

  <!-- For now, everything is note, but could be made better:
       Rumores, Aplausos, Denegaciones, ..
       "Rumors, Applause, Denials, .."
  -->
  <xsl:template match="omit">
    <xsl:choose>
      <xsl:when test="ancestor::omit">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <note xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates/>
        </note>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="heading">
    <head xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="node()[not(self::omit)]"/>
    </head>
  </xsl:template>

  <!-- 1 Speech -->
  <xsl:template match="intervention">
    <u xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="xml:id">
        <xsl:value-of select="$id"/>
        <xsl:text>.u</xsl:text>
        <xsl:number/>
      </xsl:attribute>
      <xsl:if test="et:set(speaker/name)">
        <xsl:attribute name="who">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="et:name2id(speaker/name)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="ana">
        <xsl:text>#</xsl:text>
        <xsl:choose>
          <xsl:when test="matches(speaker/national_party, '^\s*NA\+?\s*$')">guest</xsl:when>
          <xsl:when test="matches(speaker/post, '^\s*(VICE)?PRESIDENT[AE]\s*$', 'i')">chair</xsl:when>
          <xsl:when test="not(speaker/institution/ni[text()='CD'])">guest</xsl:when>
          <xsl:otherwise>regular</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </u>
  </xsl:template>
  
  <!-- Speakers are collected in the teiHeader -->
  <xsl:template match="speaker"/>
  
  <xsl:template match="speech">
    <xsl:if test="@language != 'ES'">
      <xsl:message select="concat('WARN: strange speech@amp;language = ', @id)"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Insert tag for line-breaks and fixing bad note punct: 
       de Fomento. <omit type="comment">Rumores</omit>. Silencio, señorías. 
  -->
  <xsl:template match="speech/text()">
    <xsl:variable name="text">
      <xsl:variable name="t1">
        <xsl:choose>
          <xsl:when test="preceding-sibling::*[1]/self::omit">
            <xsl:value-of select="replace(., '^\.', '')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="t2" select="replace($t1,'&#x85;','…')"/>
      <xsl:variable name="t3" select="replace($t2,'([^\d\p{L}])-(\p{L})','$1- $2')"/>
      <xsl:variable name="t4" select="replace($t3,'^-(\p{L})','- $1')"/>
      <xsl:variable name="t5" select="replace($t4,'(\p{L})-([^\d\p{L}])','$1 -$2')"/>
      <xsl:variable name="t6" select="replace($t5,'(\p{L})-$','$1 -')"/>
      <xsl:variable name="tfixed" select="$t6"/>
      <xsl:choose>
        <xsl:when test="preceding-sibling::*[1]/self::page_number and
                        following::*[1]/self::page_number">
          <xsl:value-of select="replace($tfixed, '^ *\n(.+?) *\n$', '$1', 's')"/>
        </xsl:when>
        <xsl:when test="preceding-sibling::*[1]/self::page_number">
          <xsl:value-of select="replace($tfixed, '^ *\n', '')"/>
        </xsl:when>
        <xsl:when test="following::*[1]/self::page_number">
          <xsl:value-of select="replace($tfixed, ' *\n$', '')"/>
        </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$tfixed"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pass1">
      <xsl:if test="preceding-sibling::*[1]/self::omit and matches($text,'^ *\n')">
        <lb xmlns="http://www.tei-c.org/ns/1.0"/>
      </xsl:if>
      <xsl:for-each select="tokenize($text, '\n')">
        <xsl:if test="normalize-space(.)">
          <lb xmlns="http://www.tei-c.org/ns/1.0"/>
          <xsl:value-of select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1]/self::*">
        <xsl:for-each select="$pass1/node()">
          <!-- DOESNT WORK FOR <note> -->
          <xsl:if test="not(self::tei:lb) or preceding-sibling::node()">
            <xsl:copy-of select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$pass1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1]/self::omit">
        <xsl:value-of select="replace(replace(., '^\. ', ''),'&#x85;','…')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="replace(.,'&#x85;','…')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Named templates -->
  
  <xsl:template name="speaker2person">
    <xsl:if test="et:set(name)">
      <xsl:variable name="id" select="et:name2id(name)"/>
      <xsl:if test="not(normalize-space($id))">
        <xsl:message select="concat('ERROR: empty ID for person name ', name)"/>
      </xsl:if>
      <person xmlns="http://www.tei-c.org/ns/1.0"
              xml:id="{$id}">
        <xsl:copy-of select="et:speaker2name(name)"/>
        <xsl:choose>
          <xsl:when test="gender = 'male'">
            <sex value="M"/>
          </xsl:when>
          <xsl:when test="gender = 'female'">
            <sex value="F"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="et:set(gender)">
              <xsl:message select="concat('ERROR: strange value for gender = ', gender)"/>
            </xsl:if>
            <sex value="U"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="et:set(birth_date)">
          <xsl:variable name="birthDate" select="et:digits2date(birth_date)"/>
          <xsl:if test="$birthDate">
            <birth>
              <xsl:if test="et:set(birth_date)">
                <xsl:attribute name="when" select="$birthDate"/>
              </xsl:if>
              <xsl:if test="et:set(birth_place)">
                <placeName>
                  <xsl:value-of select="replace(
                                        normalize-space(birth_place),
                                        '([^ ])\(', '$1 (')"/>
                </placeName>
              </xsl:if>
            </birth>
          </xsl:if>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="institution/ni[@country='ES'] = 'CD'">
            <affiliation when="{$session-date}" ref="#CD" role="MP"/>
          </xsl:when>
          <!-- ToDo: -->
          <xsl:when test="institution/ni">
            <xsl:message>WARN: Don't know what to do with institution/ni!</xsl:message>
          </xsl:when>
          <xsl:when test="institution/io">
            <xsl:message>WARN: Don't know what to do with institution/io!</xsl:message>
          </xsl:when>
          <xsl:when test="institution/ngo">
            <xsl:message>WARN: Don't know what to do with institution/ngo!</xsl:message>
          </xsl:when>
        </xsl:choose>
        <!-- ToDo, except <national_party>:
            <constituency country="ES" region="Asturias"/>
            <affiliation>
                <national_party>Cs</national_party>
              <cd group="GCs"/>
            </affiliation>
            <post> VICEPRESIDENTE</post>
        -->
        <!-- Insert reference to party, parties are collected separately in the teiHeader -->
        <xsl:variable name="party" select="affiliation/national_party"/>
        <xsl:if test="et:set($party)">
          <affiliation role="member" ref="#party.{et:str2id(mk:fix-party-name($party))}" when="{$session-date}"/>
        </xsl:if>
        <!--
        <xsl:if test="./post[starts-with(text(),'MINISTR')]">
          <affiliation role="member" ref="#GOV" when="{$session-date}"/>
          <affiliation role="minister" ref="#GOV" when="{$session-date}">
            <roleName><xsl:value-of select="normalize-space(./post)"/></roleName>
          </affiliation>
        </xsl:if>
      -->
      </person>
    </xsl:if>
  </xsl:template>

  <!-- Functions -->

  <!-- Convert name string to structured persName, meant for Spanish names -->
  <xsl:function name="et:speaker2name">
    <xsl:param name="nameIn"/>
    <xsl:variable name="name" select="normalize-space(replace($nameIn,',',', '))"/>
    <persName xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:variable name="forenames">
        <xsl:choose>
          <!-- e.g. Prendes Prendes, José Ignacio -->
          <xsl:when test="contains($name, ',')">
            <xsl:value-of select="substring-after($name, ', ')"/>
          </xsl:when>
          <!-- e.g. LUIS BAIL -->
          <xsl:when test="contains($name, ' ')">
            <xsl:value-of select="substring-before($name, ' ')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="surnames">
        <xsl:choose>
          <!-- e.g. Prendes Prendes, José Ignacio -->
          <xsl:when test="contains($name, ',')">
            <xsl:value-of select="substring-before($name, ', ')"/>
          </xsl:when>
          <!-- e.g. LUIS BAIL -->
          <xsl:when test="contains($name, ' ')">
            <xsl:value-of select="substring-after($name, ' ')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:for-each select="tokenize($forenames, ' ')">
        <xsl:choose>
          <xsl:when test="matches(., '^Doña$', 'i') or
                          matches(., '^Don$', 'i')">
            <roleName>
              <xsl:value-of select="normalize-space(et:cap-case(.))"/>
            </roleName>
          </xsl:when>
          <xsl:when test=". = 'Mª'">
            <forename>María</forename>
          </xsl:when>
          <xsl:otherwise>
            <forename>
              <xsl:value-of select="normalize-space(et:cap-case(.))"/>
            </forename>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:for-each select="tokenize($surnames, ' ')">
        <xsl:choose>
          <xsl:when test="matches(., '^i$', 'i') or
                          matches(., '^y$', 'i') or
                          matches(., '^la$', 'i')">
            <nameLink>
              <xsl:value-of select="normalize-space(lower-case(.))"/>
            </nameLink>
          </xsl:when>
          <xsl:when test="matches(., '^Del?$', 'i')">
            <nameLink>
              <xsl:value-of select="normalize-space(et:cap-case(.))"/>
            </nameLink>
          </xsl:when>
          <xsl:otherwise>
            <surname>
              <xsl:value-of select="normalize-space(et:cap-case(.))"/>
            </surname>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </persName>
  </xsl:function>
  
  <!-- Name string to ID, taking only the first surname and first forename, 
       and not converting to ASCII is this OK? -->
  <xsl:function name="et:name2id">
    <xsl:param name="name"/>
    <xsl:variable name="persName" select="et:speaker2name($name)"/>
    <xsl:value-of select="et:str2id(string-join(
                          $persName/*,''))"/>
  </xsl:function>
  
  <!-- IDREF for subcorpus -->
  <xsl:function name="et:subcorpus">
    <xsl:param name="date"/>
    <xsl:choose>
      <xsl:when test="$date &lt; $COVID-date">#reference</xsl:when>
      <xsl:otherwise>#covid</xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Test if value is set -->
  <xsl:function name="et:set" as="xs:boolean">
    <xsl:param name="str"/>
    <xsl:choose>
      <xsl:when test="not($str) or $str = '' or $str = 'UNKNOWN'
                      or $str = 'NA' or $str = 'NA+'
                      or matches($str, '^0+$')">
        <xsl:value-of select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="true()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Make valid ID from string: no Punctuation, Spaces, or Zs -->
  <xsl:function name="et:str2id">
    <xsl:param name="str"/>
    <xsl:value-of select="replace($str, '[\p{P}\p{S}\p{Z}]', '')"/>
  </xsl:function>
  
  <xsl:function name="et:digits2date">
    <xsl:param name="digits"/>
    <xsl:choose>
      <!-- 20210301 -> 2021-03-01 -->
      <xsl:when test="matches($digits, '^\d+(-bis)?$')">
        <!-- For 20201118-bis -->
        <xsl:variable name="clean" select="replace($digits, '-.*$', '')"/>
        <xsl:analyze-string select="$clean" regex="^(\d\d\d\d)(\d\d)(\d\d)$">
          <xsl:matching-substring>
            <xsl:choose>
              <xsl:when test="regex-group(2) = '00' and regex-group(3) = '00'">
                <xsl:value-of select="regex-group(1)"/>
              </xsl:when>
              <xsl:when test="regex-group(3) = '00'">
                <xsl:value-of select="concat(regex-group(1), '-',
                                      regex-group(2))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat(regex-group(1), '-',
                                      regex-group(2),  '-',
                                      regex-group(3))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:message>
              <xsl:text>ERROR: Can't make date from </xsl:text>
              <xsl:value-of select="$digits"/>
            </xsl:message>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:when>

      <xsl:when test="matches($digits, '^\d+\d+\d+\d+/\d+\d+/\d+\d+$')">
        <!-- For 1961/04/06 -->
        <xsl:analyze-string select="$digits" regex="^(\d\d\d\d)/(\d\d)/(\d\d)$">
          <xsl:matching-substring>
            <xsl:value-of select="concat(regex-group(1), '-',
                                  regex-group(2),  '-',
                                  regex-group(3))"/>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:message>
              <xsl:text>ERROR: Can't make date from </xsl:text>
              <xsl:value-of select="$digits"/>
            </xsl:message>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:when>

      
      <!-- "celebrada el miércoles, 20 de abril de 2016" -> 2016-04-20 -->
      <xsl:when test="matches($digits, 'de .* de')">
        <xsl:variable name="day" select="format-number(
                                         number(replace($digits, '.+, (\d+) de.+', '$1')),
                                         '00')"/>
        <xsl:variable name="year" select="replace($digits, '.+de (\d+)$', '$1')"/>
        <xsl:variable name="month" as="xs:string">
          <xsl:choose>
            <xsl:when test="contains($digits, 'de enero')">01</xsl:when>
            <xsl:when test="contains($digits, 'de febrero')">02</xsl:when>
            <xsl:when test="contains($digits, 'de marzo')">03</xsl:when>
            <xsl:when test="contains($digits, 'de abril')">04</xsl:when>
            <xsl:when test="contains($digits, 'de mayo')">05</xsl:when>
            <xsl:when test="contains($digits, 'de junio')">06</xsl:when>
            <xsl:when test="contains($digits, 'de julio')">07</xsl:when>
            <xsl:when test="contains($digits, 'de agosto')">08</xsl:when>
            <xsl:when test="contains($digits, 'de septiembre')">09</xsl:when>
            <xsl:when test="contains($digits, 'de octubre')">10</xsl:when>
            <xsl:when test="contains($digits, 'de noviembre')">11</xsl:when>
            <xsl:when test="contains($digits, 'de diciembre')">12</xsl:when>
            <xsl:otherwise>
              <xsl:message>
                <xsl:text>ERROR: Can't make date from </xsl:text>
                <xsl:value-of select="$digits"/>
              </xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($year, '-', $month,  '-', $day)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>ERROR: Can't make date from </xsl:text>
          <xsl:value-of select="$digits"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Capital case, e.g. "Jose" or Grande-Marlaska-->
  <xsl:function name="et:cap-case">
    <xsl:param name="str"/>
    <xsl:variable name="init" select="substring($str, 1, 1)"/>
    <xsl:variable name="tail" select="substring($str, 2)"/>
    <xsl:choose>
      <xsl:when test="contains($tail,'-')">
        <xsl:value-of select="concat(upper-case($init),
                                     lower-case(substring-before($tail,'-')),
                                     '-',
                                     et:cap-case(substring-after($tail,'-')))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(upper-case($init), lower-case($tail))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mk:fix-party-name">
    <xsl:param name="party"/>
    <xsl:choose>
      <xsl:when test="$party = ' GP'">
        <xsl:message>WARN: changing party name from ' GP' to 'PP'</xsl:message>
        <xsl:text>PP</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space($party) = 'PSdeG-PSOE'">
        <xsl:message>WARN: changing party name from 'PSdeG-PSOE' to 'PsdeG-PSOE'</xsl:message>
        <xsl:text>PsdeG-PSOE</xsl:text>
      </xsl:when>
      <xsl:when test="matches($party,'^.+\(.*\)$')">
        <xsl:message>WARN: changing party name from 'PSdeG-PSOE' to 'PsdeG-PSOE'</xsl:message>
        <xsl:value-of select="normalize-space(replace($party,'\(.*\)',''))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($party)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>
