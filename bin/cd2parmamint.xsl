<?xml version='1.0' encoding='UTF-8'?>
<!-- Convert Spanish CD format to ParlaMint -->
<!-- * remove non-ParlaMint elements
     * in <participDesc> collect speaker metadata (static and timestamped memberships)
     * change \n in speeches to <lb/>
     * rename to TEI
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:et="http://nl.ijs.si/et"
		exclude-result-prefixes="xsl et">
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="speech"/>

  <!-- Why exactly was this date chosen? -->
  <xsl:param name="COVID-date">2019-11-01</xsl:param>
  
  <xsl:variable name="respStmt">
    <respStmt xmlns="http://www.tei-c.org/ns/1.0">
      <persName>María Calzada Pérez</persName>
      <resp xml:lang="en">Data retrieval and conversion to XML</resp>
    </respStmt>
    <respStmt xmlns="http://www.tei-c.org/ns/1.0">
      <persName>Tomaž Erjavec</persName>
      <resp xml:lang="en">Conversion to ParlaMint TEI</resp>
    </respStmt>
  </xsl:variable>
  
  <!-- More metadata could probably be collected apart from the date? -->
  <xsl:variable name="session-date">
    <xsl:variable name="date" select="et:digits2date(/ecpc_CD/header/date)"/>
    <xsl:if test="not(matches($date, '20[12][0-9](-[01][12](-[0-3][0-9])?)?'))">
      <xsl:message select="concat('ERROR: Bad session date ', $date, ' in ', base-uri())"/>
    </xsl:if>
    <xsl:value-of select="$date"/>
  </xsl:variable>
  
  <!-- DRAFT! -->
  <xsl:template match="header">
    <teiHeader xmlns="http://www.tei-c.org/ns/1.0">
      <fileDesc>
        <titleStmt>
	  <xsl:variable name="n" select="replace(label, '.+ núm. (\d+).*', '$1')"/>
          <title xml:lang="en" type="main">
	    <xsl:text>Spanish parliamentary corpus ParlaMint-ES, </xsl:text>
	    <xsl:choose>
	      <xsl:when test="contains(label, 'Sesión plenaria')">
		<xsl:text>Plenary session </xsl:text>
		<xsl:value-of select="$n"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:message select="concat('ERROR: Strange label ', label)"/>
	      </xsl:otherwise>
	    </xsl:choose>
	    <xsl:text> [ParlaMint]</xsl:text>
	  </title>
          <title xml:lang="es" type="sub">
	    <xsl:value-of select="label"/>
	  </title>
          <meeting ana="#parla.session" corresp="#federal_parliament" n="{$n}">
	    <xsl:value-of select="label"/>
	  </meeting>
	  <xsl:copy-of select="$respStmt"/>
          <funder>
            <orgName xml:lang="en">The CLARIN research infrastructure</orgName>
          </funder>
          <funder>
            <orgName xml:lang="en">XXX</orgName>
          </funder>
        </titleStmt>
        <editionStmt>
          <edition>0.1</edition>
        </editionStmt>
        <extent>
          <measure unit="speeches" quantity="0" xml:lang="en">XXX speeches</measure>
          <measure unit="words" quantity="0" xml:lang="en">XXX words</measure>
        </extent>
        <publicationStmt>
          <publisher>
            <orgName xml:lang="en">XXX</orgName>
            <orgName xml:lang="en">The CLARIN research infrastructure</orgName>
            <ref target="https://www.clarin.eu/">www.clarin.eu</ref>
          </publisher>
          <idno type="handle">http://hdl.handle.net/11356/1388</idno>
          <pubPlace>
            <ref target="http://hdl.handle.net/11356/1388">http://hdl.handle.net/11356/1388</ref>
          </pubPlace>
          <availability status="free">
            <licence>http://creativecommons.org/licenses/by/4.0/</licence>
            <p xml:lang="en">This work is licensed under the <ref target="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</ref></p>
          </availability>
          <date when="{$today-iso}">
	    <xsl:value-of select="$today-iso"/>
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
          <p xml:lang="en"><ref target="https://www.clarin.eu/content/parlamint">ParlaMint</ref> is a project that aims to (1) create a multilingual set of comparable corpora of parliamentary proceedings uniformly encoded according to the <ref target="https://github.com/clarin-eric/parla-clarin">Parla-CLARIN recommendations</ref> and covering the COVID-19 pandemic from November 2019 as well as the earlier period from 2015 to serve as a reference corpus; (2) process the corpora linguistically to add Universal Dependencies syntactic structures and Named Entity annotation; (3) make the corpora available through concordancers and Parlameter; and(4) build use cases in Political Sciences and Digital Humanities based on the corpus data.</p>
        </projectDesc>
        <tagsDecl/>
      </encodingDesc>
      <profileDesc>
        <settingDesc>
          <setting>
            <name type="city">Madrid</name>
            <name type="country" key="ES">Spain</name>
            <date ana="#parla.sitting" when="{$session-date}">
              <xsl:value-of select="$session-date"/>
	    </date>
          </setting>
        </settingDesc>
        <particDesc>
	  <listOrg>
	    <xsl:variable name="parties">
	      <!-- Collect all party affiliations -->
	      <xsl:for-each select="/ecpc_CD/body//intervention/speaker/affiliation">
		<xsl:sort/>
		<xsl:variable name="party_name" select="normalize-space(national_party)"/>
		<xsl:if test="$party_name != 'UNKNOWN'">
		  <org role="politicalParty" xml:id="party.{et:str2id($party_name)}">
		    <orgName full="init">
		      <xsl:value-of select="$party_name"/>
		    </orgName>
		    <orgName full="yes">?</orgName>
		  </org>
		</xsl:if>
	      </xsl:for-each>
	    </xsl:variable>
	    <!-- Make parties unique based on their ID -->
	    <xsl:for-each select="$parties/tei:org">
	      <xsl:variable name="pid" select="@xml:id"/>
	      <xsl:if test="not(preceding-sibling::tei:org/@xml:id = $pid)">
		<xsl:copy-of select="."/>
	      </xsl:if>
	    </xsl:for-each>	    
	  </listOrg>
          <listPerson>
	    <!-- Collect all speakers -->
	    <xsl:variable name="persons">
	      <xsl:for-each select="/ecpc_CD/body//intervention/speaker">
		<xsl:sort/>
		<xsl:call-template name="speaker2person"/>
	      </xsl:for-each>
	    </xsl:variable>
	    <!-- Make speakers unique based on their ID (= short name) -->
	    <xsl:for-each select="$persons/tei:person">
	      <xsl:variable name="pid" select="@xml:id"/>
	      <xsl:if test="not(preceding-sibling::tei:person/@xml:id = $pid)">
		<xsl:copy-of select="."/>
	      </xsl:if>
	    </xsl:for-each>
	  </listPerson>
	</particDesc>
      </profileDesc>
      <revisionDesc>
        <change when="{$today-iso}"><name>Tomaž Erjavec</name>: initial version.</change>
      </revisionDesc>
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
  
  <!-- To stamp file with today's date: -->
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  
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
    <xsl:message select="concat('INFO: processing ', base-uri())"/>
    <!-- Give id and covid/reference subcorpus -->
    <!-- @ana should also contain the session / sitting ... number! -->
    <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:lang="es"
	 xml:id="{$id}" ana="{et:subcorpus($session-date)}">
      <xsl:apply-templates/>
    </TEI>
  </xsl:template>


  <!-- extent mode computes size of the TEI/text (extent + tagUsage) -->
  <xsl:template mode="extents" match="tei:measure[@unit='speeches']">
    <xsl:variable name="quant" select="count(//tei:u)"/>
    <measure xmlns="http://www.tei-c.org/ns/1.0" xml:lang="en"
	     unit="speeches" quantity="{format-number($quant, '#')}">
      <xsl:value-of select="concat(format-number($quant, '###,###,###'), ' speeches')"/>
    </measure>
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
  
  <!-- Remove non-ParlaMint elements -->
  <xsl:template match="legislature"/>
  <xsl:template match="title"/>
  <xsl:template match="label"/>
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
    <note xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates/>
    </note>
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
      <xsl:if test="speaker/name != 'UNKNOWN'">
	<xsl:attribute name="who">
	  <xsl:text>#</xsl:text>
	  <xsl:value-of select="et:name2id(speaker/name)"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:attribute name="ana">
	<xsl:text>#</xsl:text>
	<xsl:choose>
	  <xsl:when test="speaker/post = 'PRESIDENTA'">chair</xsl:when>
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
	    <xsl:value-of select="replace(., '^\. ', '')"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="."/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:choose>
	<xsl:when test="preceding-sibling::*[1]/self::page_number and
			following::*[1]/self::page_number">
	  <xsl:value-of select="replace($t1, '^ *\n(.+?) *\n$', '$1', 's')"/>
	</xsl:when>
	<xsl:when test="preceding-sibling::*[1]/self::page_number">
	  <xsl:value-of select="replace($t1, '^ *\n', '')"/>
	</xsl:when>
	<xsl:when test="following::*[1]/self::page_number">
	  <xsl:value-of select="replace($t1, ' *\n$', '')"/>
	</xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$t1"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="pass1">
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
	<xsl:value-of select="replace(., '^\. ', '')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Named templates -->
  
  <xsl:template name="speaker2person">
    <xsl:if test="name != 'UNKNOWN'">
      <person xmlns="http://www.tei-c.org/ns/1.0"
	      xml:id="{et:name2id(name)}">
	<xsl:copy-of select="et:speaker2name(name)"/>
	<xsl:choose>
	  <xsl:when test="gender = 'male'">
	    <sex value="M"/>
	  </xsl:when>
	  <xsl:when test="gender = 'female'">
	    <sex value="F"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:if test="gender != 'UNKNOWN'">
	      <xsl:message select="concat('ERROR: strange value for gender = ', gender)"/>
	    </xsl:if>
	    <sex value="U"/>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:if test="(birth_place or birth_date) and 
		      (birth_place != 'UNKNOWN' or 
		      (birth_date != 'UNKNOWN' and not(matches(birth_date, '^0+$')))
		      )">
	  <birth>
	    <xsl:if test="birth_date and birth_date != 'UNKNOWN' 
			  and not(matches(birth_date, '^0+$'))">
	      <xsl:attribute name="when" select="et:digits2date(birth_date)"/>
	    </xsl:if>
	    <xsl:if test="birth_place and birth_place != 'UNKNOWN'">
              <placeName>
		<xsl:value-of select="replace(
				      normalize-space(birth_place),
				      '([^ ])\(', '$1 (')"/>
	      </placeName>
	    </xsl:if>
	  </birth>
	</xsl:if>
	<xsl:choose>
	  <xsl:when test="institution/ni[@country='ES'] = 'CD'">
	    <affiliation when="{$session-date}" ref="#federal_parliament" role="MP"/>
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
	<!-- ToDo, except national_party:
	    <constituency country="ES" region="Asturias"/>
	    <affiliation>
  	      <national_party>Cs</national_party>
	      <cd group="GCs"/>
	    </affiliation>
	    <post> VICEPRESIDENTE</post>
	-->
	<!-- Insert reference to party, parties are collected separately in the teiHeader -->
	<xsl:variable name="party" select="affiliation/national_party"/>
	<xsl:if test="normalize-space($party) and $party  != 'UNKNOWN'">
	  <affiliation role="member" ref="#party.{et:str2id($party)}" when="{$session-date}"/>
	</xsl:if>
      </person>
    </xsl:if>
  </xsl:template>

  <!-- Functions -->

  <!-- Convert name string to structured persName, meant for Spanish names -->
  <xsl:function name="et:speaker2name">
    <xsl:param name="name"/>
    <persName xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:variable name="surnames" select="substring-before($name, ', ')"/>
      <xsl:variable name="forenames" select="substring-after($name, ', ')"/>
      <xsl:for-each select="tokenize($forenames, ' ')">
	<xsl:choose>
	  <xsl:when test="matches(., '^Doña$', 'i') or
			  matches(., '^Don$', 'i')">
	    <roleName>
	      <xsl:value-of select="normalize-space(et:cap-case(.))"/>
	    </roleName>
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
	  <xsl:when test="matches(., '^Del?', 'i')">
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
    <xsl:value-of select="et:str2id(concat($persName/tei:surname[1], $persName/tei:forename[1]))"/>
  </xsl:function>
  
  <!-- IDREF for subcorpus -->
  <xsl:function name="et:subcorpus">
    <xsl:param name="date"/>
    <xsl:text>#</xsl:text>
    <xsl:choose>
      <xsl:when test="$date &lt; $COVID-date">reference</xsl:when>
      <xsl:otherwise>covid</xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Make valid ID from string: no Punctuation, Spaces, or Zs -->
  <xsl:function name="et:str2id">
    <xsl:param name="str"/>
    <xsl:value-of select="replace($str, '[\p{P}\p{S}\p{Z}]', '')"/>
  </xsl:function>
  
  <!-- 20210301 -> 2021-03-01 -->
  <xsl:function name="et:digits2date">
    <xsl:param name="digits"/>
    <!-- For 20201118-bis! -->
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
  </xsl:function>

  <!-- Capital case, e.g. "Jose" -->
  <xsl:function name="et:cap-case">
    <xsl:param name="str"/>
    <xsl:variable name="init" select="substring($str, 1, 1)"/>
    <xsl:variable name="tail" select="substring($str, 2)"/>
    <xsl:value-of select="concat(upper-case($init), lower-case($tail))"/>
  </xsl:function>
  
</xsl:stylesheet>
