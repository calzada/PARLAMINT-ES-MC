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
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:TEI/@xml:id">
    <xsl:attribute name="xml:id" select="concat(., '.ana')"/>
  </xsl:template>

  <xsl:template match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:idno[@type='handle']">
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
  
  <xsl:template match="tei:extent/tei:measure[@unit = 'words']">
    <xsl:variable name="words" select="count(//tei:w)"/>
    <measure quantity="{$words}" unit="words" xml:lang="{@xml:lang}">
      <xsl:value-of select="replace(., '0', string($words))"/>
    </measure>
  </xsl:template>
  <xsl:template match="tei:tagsDecl/tei:namespace">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:s"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:name"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:w"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:pc"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:linkGrp"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:link"/>
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

</xsl:stylesheet>
