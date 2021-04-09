<?xml version='1.0' encoding='UTF-8'?>
<!-- Fix bugs in ParlaMint-ES.ana -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:et="http://nl.ijs.si/et"
  exclude-result-prefixes="et fn tei">
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="tei:change tei:seg"/>

  <xsl:param name="version">2.0</xsl:param>
  <xsl:param name="handle-ana">http://hdl.handle.net/11356/1405</xsl:param>
  <xsl:param name="change">
    <change when="{$today-iso}"><name>Tomaž Erjavec</name>: Fixes for Version 2.</change>
  </xsl:param>
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:variable name="id" select="replace(document-uri(/), '.+/([^/]+)\.xml', '$1')"/>
  
  <xsl:template match="/">
    <xsl:text>&#10;</xsl:text>
    <xsl:variable name="pass1">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:apply-templates mode="count" select="$pass1"/>
  </xsl:template>

  <xsl:template match="tei:TEI/@xml:id">
    <xsl:attribute name="xml:id" select="concat(., '.ana')"/>
  </xsl:template>
  
  <!-- Fix from:
       <meeting ana="#parla.session" corresp="#CD #CD.10" n="237">Sesión plenaria núm. 237. (X)</meeting>
       to:
       <meeting n="237" corresp="#CD" ana="#parla.session">Sesión plenaria núm. 237.</meeting>
       <meeting n="10" corresp="#CD" ana="#parla.term #CD.10">Legislatura X</meeting>
  -->
  <xsl:template match="tei:TEI/tei:teiHeader//tei:meeting[@ana='#parla.session']
		       [contains(@corresp, '#CD #CD')]">
    <xsl:copy>
      <xsl:attribute name="n" select="@n"/>
      <xsl:attribute name="corresp">#CD</xsl:attribute>
      <xsl:attribute name="ana" select="@ana"/>
      <xsl:value-of select="replace(., ' \(.+?\)$', '')"/>
    </xsl:copy>
    <xsl:variable name="term-roman" select="replace(., '.+ \((.+?)\)$', '$1')"/>
    <xsl:variable name="term-arab">
      <xsl:choose>
	<xsl:when test="$term-roman = 'VIII'">8</xsl:when>
	<xsl:when test="$term-roman = 'IX'">9</xsl:when>
	<xsl:when test="$term-roman = 'X'">10</xsl:when>
	<xsl:when test="$term-roman = 'XI'">11</xsl:when>
	<xsl:when test="$term-roman = 'XII'">12</xsl:when>
	<xsl:when test="$term-roman = 'XIII'">13</xsl:when>
	<xsl:when test="$term-roman = 'XIV'">14</xsl:when>
	<xsl:when test="$term-roman = 'XV'">15</xsl:when>
	<xsl:otherwise>
	  <xsl:message terminate="yes" select="concat('ERROR: wrong legislature ', legislature)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:attribute name="n" select="$term-arab"/>
      <xsl:attribute name="corresp">#CD</xsl:attribute>
      <xsl:attribute name="ana">
	<xsl:text>#parla.term #CD.</xsl:text>
	<xsl:value-of select="$term-arab"/>
      </xsl:attribute>
      <xsl:text>Legislatura </xsl:text>
      <xsl:value-of select="$term-roman"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:idno[matches(., 'hdl.handle.net')]">
    <xsl:copy>
      <xsl:attribute name="type">URI</xsl:attribute>
      <xsl:attribute name="subtype">handle</xsl:attribute>
      <xsl:value-of select="$handle-ana"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:attribute name="when" select="$today-iso"/>
      <xsl:value-of select="$today-iso"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Put in <revisionDesc> if there is none in the teiHeader -->
  <xsl:template match="tei:teiHeader">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <xsl:if test="not(tei:revisionDesc)">
	<revisionDesc>
	  <xsl:copy-of select="$change"/>
	</revisionDesc>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="$change"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
    
  <!-- FIX -->

  <xsl:template match="tei:title[@type = 'main']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="replace(., '\]', '.ana]')"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:linkGrp/tei:link/@ana[. = 'ud-syn:&lt;PAD&gt;']">
    <xsl:attribute name="ana">ud-syn:dep</xsl:attribute>
  </xsl:template>
  
  <!-- Remove these elements -->
  <xsl:template match="tei:seg[not(normalize-space(.))]"/>
  <xsl:template match="tei:name[not(normalize-space(.))]"/>
  <xsl:template match="tei:pb"/>
  
  <!-- COPY REST -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:function name="et:sort_feats">
    <xsl:param name="feats"/>
    <xsl:variable name="sorted">
      <xsl:for-each select="tokenize($feats, '\|')">
	<xsl:sort select="lower-case(.)" order="ascending"/>
	<xsl:value-of select="."/>
	<xsl:text>|</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="replace($sorted, '\|$', '')"/>
  </xsl:function>
  
  <!-- Pass 2: extents -->
  
  <xsl:template mode="count" match="tei:extent/tei:measure[@unit = 'words']">
    <xsl:variable name="words" select="count(//tei:w)"/>
    <measure quantity="{$words}" unit="words" xml:lang="{@xml:lang}">
      <xsl:value-of select="replace(., '0', string($words))"/>
    </measure>
  </xsl:template>
  <xsl:template mode="count" match="tei:tagsDecl/tei:namespace">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <!--xsl:apply-templates/-->
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:body"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:div"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:head"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:u"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:seg"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:note"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:s"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:name"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:w"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:pc"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:linkGrp"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:link"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="tagCount" match="tei:*">
    <xsl:variable name="self" select="name()"/>
    <xsl:if test="not(following::*[name()=$self] or descendant::*[name()=$self] )">
      <tagUsage xmlns="http://www.tei-c.org/ns/1.0" gi="{$self}">
	<xsl:attribute name="occurs">
	  <xsl:number level="any" from="tei:text"/>
	</xsl:attribute>
      </tagUsage>
    </xsl:if>
  </xsl:template>
  <xsl:template mode="tagCount" match="text()"/>
  <xsl:template mode="count" match="*">
    <xsl:copy>
      <xsl:apply-templates mode="count" select="@*"/>
      <xsl:apply-templates mode="count"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="count" match="@*">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
