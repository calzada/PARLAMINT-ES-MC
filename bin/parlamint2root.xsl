<?xml version="1.0"?>
<!-- Take template for root ParlaMint-ES corpus file and add info from XIncluded components -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="xsl tei et xi"
  version="2.0">

  <xsl:variable name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:output method="xml" indent="yes"/>
  
  <!-- Directory where to write the output corpus -->
  <xsl:param name="outDir">.</xsl:param>
  <!-- Path from bin/ to ES component files -->
  <xsl:param name="inDir">..</xsl:param>
  
  <!-- Gather URIs of component xi + files and map to new xi + files -->
  <xsl:variable name="docs">
    <xsl:for-each select="//xi:include">
      <xsl:variable name="xi-orig" select="@href"/>
      <xsl:variable name="url-orig" select="concat($inDir, '/', $xi-orig)"/>
      <xsl:variable name="xi-new" select="concat(document($url-orig)/tei:TEI/@xml:id, '.xml')"/>
      <xsl:variable name="url-new" select="concat($outDir, '/', $xi-new)"/>
      <item>
	<xi-orig>
	  <xsl:value-of select="$xi-orig"/>
	</xi-orig>
	<url-orig>
	  <xsl:value-of select="$url-orig"/>
	</url-orig>
	<xi-new>
	  <xsl:value-of select="$xi-new"/>
	</xi-new>
	<url-new>
	  <xsl:value-of select="$url-new"/>
	</url-new>
      </item>
      </xsl:for-each>
  </xsl:variable>
  
  <!-- Get number of speeches in component files -->
  <xsl:variable name="speech_n">
    <xsl:variable name="ns">
      <xsl:for-each select="$docs/tei:item/document(tei:url-orig)/tei:TEI/tei:teiHeader//
			    tei:extent/tei:measure[@xml:lang = 'en'][@unit = 'speeches']">
	<item>
	  <xsl:value-of select="@quantity"/>
	</item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="sum($ns/tei:item)"/>
  </xsl:variable>
  
  <!-- Get tagUsages in component files -->
  <xsl:variable name="tagUsages">
    <xsl:variable name="tUs">
      <xsl:for-each select="$docs/tei:item/document(tei:url-orig)/
			    tei:TEI/tei:teiHeader//tei:tagUsage">
	<xsl:sort select="@gi"/>
	<xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="$tUs/tei:tagUsage">
      <xsl:variable name="gi" select="@gi"/>
      <xsl:if test="not(following-sibling::tei:tagUsage[@gi = $gi])">
	<xsl:variable name="occurences">
	  <xsl:for-each select="$tUs/tei:tagUsage[@gi = $gi]">
	    <item>
	      <xsl:value-of select="@occurs"/>
	    </item>
	  </xsl:for-each>
	</xsl:variable>
	<!-- We change here lb to seg -->
	<xsl:variable name="true-gi">
	  <xsl:choose>
	    <xsl:when test="$gi = 'lb'">seg</xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$gi"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
        <tagUsage xmlns="http://www.tei-c.org/ns/1.0" gi="{$true-gi}"
		  occurs="{format-number(sum($occurences/tei:item), '#')}"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  
  <!-- Get all organisations from component files -->
  <xsl:variable name="orgs">
    <xsl:variable name="pass1">
      <xsl:for-each select="$docs//tei:item">
	<xsl:for-each select="document(tei:url-orig)/tei:TEI/tei:teiHeader/
			      tei:profileDesc/tei:particDesc//tei:org">
	  <xsl:sort select="@xml:id"/>
	  <xsl:copy-of select="."/>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="$pass1/tei:org">
      <xsl:variable name="id" select="@xml:id"/>
      <xsl:if test="not(following-sibling::tei:org[@xml:id = $id])">
	<xsl:copy-of select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <!-- Get all persons from component files -->
  <!-- Also gets from - to dates for their affiliatons -->
  <xsl:variable name="persons">
    <!-- Put the same person records in one listPerson -->
    <xsl:variable name="pass2">
      <xsl:variable name="pass1">
	<xsl:for-each select="$docs//tei:item">
	  <xsl:for-each select="document(tei:url-orig)/tei:TEI/tei:teiHeader/
				tei:profileDesc/tei:particDesc//tei:person">
	    <xsl:sort select="@xml:id"/>
	    <xsl:copy-of select="."/>
	  </xsl:for-each>
	</xsl:for-each>
      </xsl:variable>
      <xsl:for-each-group select="$pass1/tei:person" group-by="@xml:id">
	<listPerson xmlns="http://www.tei-c.org/ns/1.0" xml:id="{current-group()[1]/@xml:id}">
	  <xsl:copy-of select="current-group()"/>
	</listPerson>
      </xsl:for-each-group>
    </xsl:variable>
    <!-- Now go through each person records and 
	 - compute their tenure as MP and for teir party membership 
	 - output the person
    -->
    <xsl:for-each select="$pass2/tei:listPerson">
      <!-- Sorted dates when person was MP -->
      <xsl:variable name="MP-dates">
	<xsl:for-each select="tei:person/tei:affiliation[@role='MP']">
	  <xsl:sort select="@when"/>
	  <item xmlns="http://www.tei-c.org/ns/1.0">
	    <xsl:value-of select="@when"/>
	  </item>
	</xsl:for-each>
      </xsl:variable>
      <!-- All party affiliations with corpus-gathered from-to dates -->
      <xsl:variable name="party-affiliations">
	<xsl:variable name="parties">
	  <xsl:for-each select="tei:person/tei:affiliation[@role='member']">
	    <xsl:sort select="@ref"/>
	    <xsl:sort select="@when"/>
	    <xsl:copy-of select="."/>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:for-each select="$parties/tei:affiliation">
	  <xsl:variable name="party" select="@ref"/>
	  <xsl:if test="not(preceding-sibling::tei:affiliation[@ref = $party])">
	    <xsl:variable name="dates">
	      <item xmlns="http://www.tei-c.org/ns/1.0">
		<xsl:value-of select="@when"/>
	      </item>
	      <xsl:for-each select="following-sibling::tei:affiliation[@ref = $party]">
		<item xmlns="http://www.tei-c.org/ns/1.0">
		  <xsl:value-of select="@when"/>
		</item>
	      </xsl:for-each>
	    </xsl:variable>
            <affiliation role="member" ref="{$party}"
			 from="{$dates/tei:item[1]}" to="{$dates/tei:item[last()]}"/>
	  </xsl:if>
	</xsl:for-each>
      </xsl:variable>
      <!-- Output person -->
      <xsl:for-each select="tei:person[1]">
	<person xmlns="http://www.tei-c.org/ns/1.0" xml:id="{@xml:id}">
	  <xsl:copy-of select="tei:persName"/>
	  <xsl:copy-of select="tei:sex"/>
	  <xsl:copy-of select="tei:birth"/>
	  <xsl:if test="$MP-dates/tei:item">
            <affiliation ref="#federal_parliament" role="MP"
			 from="{$MP-dates/tei:item[1]}" to="{$MP-dates/tei:item[last()]}"/>
	  </xsl:if>
	  <xsl:copy-of select="$party-affiliations"/>
	</person>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="/">
    <!-- Process component files -->
    <xsl:for-each select="$docs//tei:item">
      <xsl:message select="concat('INFO: ', tei:xi-orig, ' to ', tei:url-new)"/>
      <xsl:result-document href="{tei:url-new}">
	<xsl:apply-templates mode="comp" select="document(tei:url-orig)/tei:TEI"/>
      </xsl:result-document>
    </xsl:for-each>
    <!-- Output Root file -->
    <xsl:message>INFO: processing root </xsl:message>
    <xsl:result-document href="{concat($outDir, '/ParlaMint-ES.xml')}">
      <xsl:apply-templates/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template mode="comp" match="*">
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="comp" match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template mode="comp" match="tei:u">
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:variable name="uid" select="@xml:id"/>
      <xsl:for-each-group select="node()" group-starting-with="tei:lb">
	<xsl:if test="current-group()[tei:*] or current-group()[normalize-space(.)]">
	  <!-- Notes and page-breaks at end of seg are lifted out of seg -->
	  <xsl:variable name="seg">
	    <xsl:apply-templates mode="comp" select="current-group()"/>
	  </xsl:variable>
	  <seg>
	    <xsl:apply-templates mode="edge-out" select="$seg"/>
	  </seg>
	  <xsl:apply-templates mode="edge-in" select="$seg"/>
	</xsl:if>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="edge-out" match="tei:lb"/>
  <xsl:template mode="edge-out" match="tei:*">
    <xsl:if test="following-sibling::text()[normalize-space(.)]">
      <xsl:copy>
	<xsl:apply-templates select="@*"/>
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:copy>
      <xsl:text>&#32;</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template mode="edge-out" match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  <xsl:template mode="edge-in" match="tei:lb"/>
  <xsl:template mode="edge-in" match="tei:*">
    <xsl:if test="not(following-sibling::text()[normalize-space(.)])">
      <xsl:copy>
	<xsl:apply-templates select="@*"/>
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template mode="edge-in" match="text()"/>
  
  <!-- Remove leading, trailing and multiple spaces -->
  <xsl:template mode="comp" match="text()[normalize-space(.)]">
    <xsl:variable name="str" select="replace(., '\s+', ' ')"/>
    <xsl:choose>
      <xsl:when test="(not(preceding-sibling::tei:*) and matches($str, '^ ')) and 
		      (not(following-sibling::tei:*) and matches($str, ' $'))">
	<xsl:value-of select="replace($str, '^ (.+?) $', '$1')"/>
      </xsl:when>
      <xsl:when test="not(preceding-sibling::tei:*) and matches($str, '^ ')">
	<xsl:value-of select="replace($str, '^ ', '')"/>
      </xsl:when>
      <xsl:when test="not(following-sibling::tei:*) and matches($str, ' $')">
	<xsl:value-of select="replace($str, ' $', '')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$str"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Remove now useless orgs and persons -->
  <xsl:template mode="comp" match="tei:particDesc"/>

  <!-- ROOT -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="when" select="$today"/>
      <xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y]')"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <change when="{$today}"><name>Tomaž Erjavec</name>: First try.</change>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:org[@role='politicalParty']">
    <xsl:copy-of copy-namespaces="no"  select="$orgs"/>
  </xsl:template>
  <xsl:template match="tei:listPerson/tei:person">
    <xsl:copy-of copy-namespaces="no" select="$persons"/>
  </xsl:template>
    
  <xsl:template match="tei:measure[@unit='texts']">
    <xsl:variable name="texts" select="count($docs/tei:item)"/>
    <measure xml:lang="en" unit="texts" quantity="{format-number($texts, '#')}">
      <xsl:value-of select="concat(format-number($texts, '###,###,###'), ' texts')"/>
    </measure>
  </xsl:template>
  
  <xsl:template match="tei:measure[@unit='speeches']">
    <measure xml:lang="en" unit="speeches" quantity="{format-number($speech_n, '#')}">
      <xsl:value-of select="concat(format-number($speech_n, '###,###,###'), ' speeches')"/>
    </measure>
  </xsl:template>
  
  <xsl:template match="tei:tagsDecl/tei:namespace">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of copy-namespaces="no" select="$tagUsages"/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="xi:include/@href">
    <xsl:attribute name="href">
      <xsl:variable name="xi-orig" select="."/>
      <xsl:value-of select="$docs/tei:item[tei:xi-orig = $xi-orig]/tei:xi-new"/>
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
