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

  <!-- From - to of the complete corpus -->
  <xsl:param name="start-date">2015-01-20</xsl:param>
  <xsl:param name="end-date">2020-12-15</xsl:param>
  
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
      <xsl:for-each select="$docs/tei:item/tei:url-orig/document(.)/tei:TEI/tei:teiHeader//
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
  <!--xsl:variable name="orgs">
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
  </xsl:variable-->

  <!-- Get all persons from component files -->
  <!-- Also gets from - to dates for their affiliations -->
  <!-- which doesn't quite work... Should check when their firt/last speech was
       and compare the affiliation dates with that!
  -->
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
	 - compute their tenure as MP and for their party membership 
	 - output the person
    -->
    <xsl:for-each select="$pass2/tei:listPerson">
      <xsl:variable name="MP-affiliation">
	<xsl:variable name="list-MP">
	  <xsl:for-each select="tei:person/tei:affiliation[@role='MP']">
	    <xsl:sort select="@when"/>
	    <item xmlns="http://www.tei-c.org/ns/1.0">
	      <xsl:value-of select="@when"/>
	    </item>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:if test="$list-MP/tei:item">
	  <xsl:variable name="start" select="$list-MP/tei:item[1]"/>
	  <xsl:variable name="end" select="$list-MP/tei:item[last()]"/>
          <affiliation ref="#CD" role="MP">
	    <xsl:attribute name="from" select="$start"/>
	    <xsl:attribute name="to" select="$end"/>
	    <!-- Such could be without dates:
		 <affiliation ref="#CD" role="MP" from="2015-01-20" to="2020-12-15"/>
	    -->
	    <!--
		<xsl:if test="$start &gt; $start-date">
		<xsl:attribute name="from" select="$start"/>
		</xsl:if>
		<xsl:if test="$end &lt; $end-date">
		<xsl:attribute name="to" select="$end"/>
		</xsl:if>
	    -->
	  </affiliation>
	</xsl:if>
      </xsl:variable>
      
      <!-- All party affiliations with corpus-gathered from-to dates -->
      <xsl:variable name="party-affiliations">
	<xsl:variable name="parties">
	  <xsl:variable name="list-parties">
	    <xsl:for-each select="tei:person/tei:affiliation[@role='member']">
	      <xsl:sort select="@ref"/>
	      <xsl:sort select="@when"/>
	      <xsl:copy-of select="."/>
	    </xsl:for-each>
	  </xsl:variable>
	  <xsl:for-each select="$list-parties/tei:affiliation">
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
	<xsl:choose>
	  <!-- Belongs to only one party, get rid of dates -->
	  <xsl:when test="not($parties/tei:affiliation[2])">
	    <affiliation role="member" ref="{$parties/tei:affiliation/@ref}"/>
	  </xsl:when>
	  <!-- This needs to be sorted, we have e.g.
               <affiliation role="member" ref="#party.PP" from="2016-12-14" to="2020-12-02"/>
               <affiliation role="member" ref="#party.PPEU" from="2015-01-20" to="2015-05-14"/>
	  should probably go to:
               <affiliation role="member" ref="#party.PP" not-before="2016-12-14"/>
               <affiliation role="member" ref="#party.PPEU" not-after="2016-12-14"/>
	  we can also have 3:
	  -->
	  <xsl:otherwise>
	    <xsl:copy-of select="$parties/tei:affiliation"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <!-- Output person -->
      <xsl:for-each select="tei:person[1]">
	<person xmlns="http://www.tei-c.org/ns/1.0" xml:id="{@xml:id}">
	  <xsl:copy-of select="tei:persName"/>
	  <xsl:copy-of select="tei:sex"/>
	  <xsl:copy-of select="tei:birth"/>
	  <xsl:copy-of select="$MP-affiliation"/>
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
	<xsl:variable name="pass1">
	  <xsl:apply-templates mode="comp" select="document(tei:url-orig)/tei:TEI"/>
	</xsl:variable>
	<xsl:apply-templates mode="id-segs" select="$pass1"/>
      </xsl:result-document>
    </xsl:for-each>
    <!-- Output Root file -->
    <xsl:message>INFO: processing root </xsl:message>
    <xsl:result-document href="{concat($outDir, '/ParlaMint-ES.xml')}">
      <xsl:apply-templates/>
    </xsl:result-document>
  </xsl:template>

  <!-- Give IDs to segments -->
  <xsl:template mode="id-segs" match="tei:seg">
    <xsl:copy>
      <xsl:apply-templates mode="id-segs" select="@*"/>
      <xsl:attribute name="xml:id">
	<xsl:value-of select="parent::tei:u/@xml:id"/>
	<xsl:text>.</xsl:text>
	<xsl:number/>
      </xsl:attribute>
      <xsl:apply-templates mode="id-segs"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="id-segs" match="*">
    <xsl:copy>
      <xsl:apply-templates mode="id-segs" select="@*"/>
      <xsl:apply-templates mode="id-segs"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="id-segs" match="@*">
    <xsl:copy/>
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

  <xsl:template mode="comp" match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="when" select="$today"/>
      <xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y]')"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- lb is changed to seg -->
  <xsl:template mode="comp" match="tei:tagUsage[@gi = 'lb']">
    <xsl:copy>
      <xsl:attribute name="gi">seg</xsl:attribute>
      <xsl:attribute name="occurs" select="@occurs"/>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Change lb to seg and lift out edge elements (pb, note) from seg -->
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
      <change when="{$today}"><name>Tomaž Erjavec</name>: Conversion to ParlaMint TEI.</change>
    </xsl:copy>
  </xsl:template>

  <!--xsl:template match="tei:org[@role='politicalParty']">
    <xsl:copy-of copy-namespaces="no"  select="$orgs"/>
  </xsl:template-->
  <xsl:template match="tei:listPerson/tei:person">
    <xsl:copy-of copy-namespaces="no" select="$persons"/>
  </xsl:template>

  <xsl:template match="tei:measure[@unit='words']">
    <xsl:message>WARN: Word extent not yet implemented</xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:measure">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="quant">
	<xsl:choose>
	  <xsl:when test="@unit='sessions'">
	    <xsl:value-of select="count($docs/tei:item)"/>
	  </xsl:when>
	  <xsl:when test="@unit='speeches'">
	    <xsl:value-of select="$speech_n"/>
	  </xsl:when>
	</xsl:choose>
      </xsl:variable>
      <xsl:attribute name="quantity" select="format-number($quant, '#')"/>
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
