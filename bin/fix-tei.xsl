<?xml version='1.0' encoding='UTF-8'?>
<!-- Give extents from .ana and fix bugs in ParlaMint-ES -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:et="http://nl.ijs.si/et"
  exclude-result-prefixes="et fn tei">
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="tei:change tei:seg"/>

  <xsl:param name="anaDir"/>
  <xsl:param name="version">2.0</xsl:param>
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:variable name="id" select="replace(document-uri(/), '.+/([^/]+)\.xml', '$1')"/>
  
  <xsl:variable name="words">
    <xsl:variable name="anaFile" select="concat($anaDir, '/', $id, '.ana.xml')"/>
    <xsl:value-of select="document($anaFile)//tei:measure[@unit = 'words'][1]/@quantity"/>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:text>&#10;</xsl:text>
    <xsl:variable name="pass1">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:apply-templates mode="count" select="$pass1"/>
  </xsl:template>

  <xsl:template match="tei:editionStmt/tei:edition">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="$version"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:attribute name="when" select="$today-iso"/>
      <xsl:value-of select="$today-iso"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- FIX -->

  <!-- Remove these elements -->
  <xsl:template match="tei:seg[not(normalize-space(.))]"/>
  
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
  
  <!-- Pass 2: extents -->
  
  <xsl:template mode="count" match="tei:extent/tei:measure[@unit = 'words']">
    <measure quantity="{$words}" unit="words" xml:lang="{@xml:lang}">
      <xsl:value-of select="replace(., '0', string($words))"/>
    </measure>
  </xsl:template>
  <xsl:template mode="count" match="tei:tagsDecl/tei:namespace">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:body"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:div"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:head"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:u"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:seg"/>
      <xsl:apply-templates mode="tagCount" select="//tei:text//tei:note"/>
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
