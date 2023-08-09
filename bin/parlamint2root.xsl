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
  <xsl:param name="componentFiles"/>
  <xsl:param name="listOrgTemplate"/>
  <xsl:param name="govListPerson"/>
  <xsl:param name="taxonomyDir"/>

  <!-- From - to of the complete corpus -->
  <xsl:param name="start-date">2015-01-20</xsl:param>
  <xsl:param name="end-date">2020-12-15</xsl:param>
  
  <!-- Gather URIs of component xi + files and map to new xi + files -->
  <xsl:variable name="docs">
    <xsl:for-each select="document($componentFiles)//xi:include">
      <xsl:variable name="n" select="position()"/>
      <xsl:variable name="xi-orig" select="@href"/>
      <xsl:variable name="url-orig" select="concat($inDir, '/', $xi-orig)"/>
      <xsl:variable name="xi-new" select="concat(document($url-orig)/tei:TEI/@xml:id, '.xml')"/>
      <xsl:variable name="url-new" select="concat($outDir, '/', $xi-new)"/>
      <item>
        <n>
          <xsl:value-of select="$n"/>
        </n>
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
  

  <!-- Get corpus timespan from component files -->
  <xsl:variable name="timespan">
    <xsl:variable name="dt">
      <xsl:for-each select="$docs/tei:item/tei:url-orig/document(.)/tei:TEI/tei:teiHeader//
                            tei:setting/tei:date[@when]">
        <item>
          <xsl:value-of select="@when"/>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="from" select="replace(min($dt/tei:item/translate(.,'-','')),'(....)(..)(..)','$1-$2-$3')"/>
    <xsl:variable name="to" select="replace(max($dt/tei:item/translate(.,'-','')),'(....)(..)(..)','$1-$2-$3')"/>
    <date>
      <xsl:attribute name="from" select="$from"/>
      <xsl:attribute name="to" select="$to"/>
      <xsl:value-of select="concat($from, ' - ', $to)"/>
    </date>
  </xsl:variable>

  <!-- Get terms from component files -->
  <xsl:variable name="meeting-terms">
    <xsl:variable name="mt-all">
      <xsl:for-each select="$docs/tei:item/tei:url-orig/document(.)/tei:TEI/tei:teiHeader//
                            tei:meeting[contains(@ana,'#parla.term')]">
        <xsl:sort select="./@n"/>
        <item n="{@n}">
          <xsl:copy-of select="."/>
        </item>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="ns" select="distinct-values($mt-all/tei:item/tei:meeting/@n)"/>
    <xsl:variable name="mt-uniq">
      <xsl:for-each select="$ns">
        <xsl:variable name="n" select="."/>
        <xsl:copy-of select="$mt-all/*[@n = $n][1]"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:copy-of select="$mt-uniq//tei:meeting"/>
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
  <xsl:variable name="orgs">
    <xsl:apply-templates select="document($listOrgTemplate)//tei:org" mode="orgs"/>
    <xsl:copy-of select="document($listOrgTemplate)//tei:listRelation"/>
  </xsl:variable>

  <xsl:variable name="govPersons">
    <xsl:copy-of select="document($govListPerson)//tei:person"/>
  </xsl:variable>

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
      <xsl:variable name="govPersons1">
        <xsl:for-each select="$govPersons//tei:person">
          <xsl:variable name="govName" select="./tei:persName"/>
          <xsl:copy>
            <xsl:variable name="matchingSpeaker" select="$pass1/tei:person[
                                                                $govName/tei:forename[1] = tei:persName/tei:forename[1]
                                                                and
                                                                $govName/tei:surname[1] = tei:persName/tei:surname[1]
                                                                and
                                                                (
                                                                  $govName/tei:forename[2] = tei:persName/tei:forename
                                                                  or
                                                                  not($govName/tei:forename[2])
                                                                )
                                                                and
                                                                (
                                                                  $govName/tei:surname[2] = tei:persName/tei:surname
                                                                  or
                                                                  not($govName/tei:surname[2])
                                                                )
                                                                ]"/>
            <xsl:attribute name="xml:id">
              <xsl:choose>
                <xsl:when test="$matchingSpeaker[2] and count(distinct-values($matchingSpeaker/@xml:id))>1">
                  <xsl:message>WARN: multiple matching person found for <xsl:value-of select="@xml:id"/> (<xsl:value-of select="string-join(distinct-values($matchingSpeaker/@xml:id),' ')"/>)</xsl:message>
                  <xsl:value-of select="@xml:id"/>
                </xsl:when>
                <xsl:when test="$matchingSpeaker[1]">
                  <xsl:message>WARN: changing government person id from '<xsl:value-of select="@xml:id"/>' to '<xsl:value-of select="$matchingSpeaker[1]/@xml:id"/>'</xsl:message>
                  <xsl:value-of select="$matchingSpeaker[1]/@xml:id"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@xml:id"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="@role"/>
            <xsl:apply-templates/>
          </xsl:copy>
        </xsl:for-each>
      </xsl:variable>
      <xsl:for-each-group select="$pass1/tei:person | $govPersons1/tei:person" group-by="@xml:id">
        <xsl:variable name="id" select="current-group()[1]/@xml:id"/>
        <listPerson xmlns="http://www.tei-c.org/ns/1.0" xml:id="{current-group()[1]/@xml:id}">
          <xsl:copy-of select="current-group()[not(@role)]"/>
          <xsl:copy-of select="current-group()[@role]"/>
          <!-- <xsl:copy-of select="$govPersons//tei:person[@xml:id = $id]"/> -->
        </listPerson>
      </xsl:for-each-group>
    </xsl:variable>
    <!-- Now go through each person records and 
         - compute their tenure as MP and for their party membership
         - output the person
    -->
    <xsl:for-each select="$pass2/tei:listPerson">
      <xsl:sort select="@xml:id"/>
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
          <affiliation ref="#CD" role="member">
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
      <xsl:variable name="group-affiliations">
        <xsl:variable name="groups">
          <xsl:variable name="list-groups">
            <xsl:for-each select="tei:person/tei:affiliation[@role='member' and $orgs//tei:org[@role='parliamentaryGroup']/@xml:id/concat('#',.) = @ref]">
              <xsl:sort select="@ref"/>
              <xsl:sort select="@when"/>
              <xsl:copy-of select="."/>
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="ignored" select="tei:person/tei:affiliation[
                                                @role='member'
                                                and not($orgs//tei:org[@role='parliamentaryGroup']/@xml:id/concat('#',.) = @ref)
                                                and starts-with(@ref,'#party.')]"/>
          <xsl:if test="$ignored">
            <xsl:message>ERROR: ignoring parties (person=<xsl:value-of select="tei:person/@xml:id"/>)</xsl:message>
          </xsl:if>
          <xsl:for-each select="$list-groups/tei:affiliation">
            <xsl:variable name="group" select="@ref"/>
            <xsl:if test="not(preceding-sibling::tei:affiliation[@ref = $group])">
              <xsl:variable name="dates">
                <item xmlns="http://www.tei-c.org/ns/1.0">
                  <xsl:value-of select="@when"/>
                </item>
                <xsl:for-each select="following-sibling::tei:affiliation[@ref = $group]">
                  <item xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:value-of select="@when"/>
                  </item>
                </xsl:for-each>
              </xsl:variable>
              <affiliation role="member" ref="{$group}"
                           from="{$dates/tei:item[1]}" to="{$dates/tei:item[last()]}"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
          <!-- Belongs to only one party, get rid of dates -->
          <xsl:when test="$groups/tei:affiliation and not($groups/tei:affiliation[2])">
            <affiliation role="member" ref="{$groups/tei:affiliation/@ref}"/>
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
            <xsl:copy-of select="$groups/tei:affiliation"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="other-affiliations">
        <xsl:for-each select="tei:person/tei:affiliation[$orgs//tei:org[not(@role='parliamentaryGroup') and not(@role='parliament') ]/@xml:id/concat('#',.) = @ref]">
          <xsl:sort select="concat(./@from,./@role)"/>
          <xsl:copy-of select="."/>
        </xsl:for-each>
      </xsl:variable>
      <!-- Output person -->
      <xsl:for-each select="tei:person[1]">
        <person xmlns="http://www.tei-c.org/ns/1.0" xml:id="{@xml:id}">
          <xsl:copy-of select="tei:persName"/>
          <xsl:copy-of select="tei:sex"/>
          <xsl:copy-of select="tei:birth"/>
          <xsl:copy-of select="$MP-affiliation"/>
          <xsl:copy-of select="$group-affiliations"/>
          <xsl:copy-of select="$other-affiliations"/>
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
        <xsl:text>.p</xsl:text>
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

  <xsl:template mode="comp" match="tei:pb"/>

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
          <xsl:if test="$seg/text()[normalize-space(.)]">
            <seg>
              <xsl:apply-templates mode="edge-out" select="$seg"/>
            </seg>
          </xsl:if>
          <xsl:apply-templates mode="edge-in" select="$seg"/>
        </xsl:if>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="edge-out" match="tei:lb"/>
  <xsl:template mode="edge-out" match="tei:pb"/>
  <xsl:template mode="edge-out" match="tei:*">
    <xsl:if test="following-sibling::text()[normalize-space(.)]">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates mode="copy" select="*|text()"/>
      </xsl:copy>
      <xsl:if test="local-name() = 'pb'">
        <xsl:text>&#32;</xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <xsl:template mode="edge-out" match="text()">
    <!--xsl:value-of select="normalize-space(.)"/-->
    <!--xsl:apply-templates mode="comp" select="."/-->
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
      <xsl:when test="(not(preceding-sibling::text()[normalize-space(.)]) and matches($str, '^ ')) and
                      (not(following-sibling::text()[normalize-space(.)]) and matches($str, ' $'))">
        <xsl:value-of select="replace($str, '^ (.+?) $', '$1')"/>
      </xsl:when>
      <xsl:when test="not(preceding-sibling::text()[normalize-space(.)]) and matches($str, '^ ')">
        <xsl:value-of select="replace($str, '^ ', '')"/>
      </xsl:when>
      <xsl:when test="not(following-sibling::text()[normalize-space(.)]) and matches($str, ' $')">
        <xsl:value-of select="replace($str, ' $', '')"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$str"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="edge-in" match="tei:lb"/>
  <xsl:template mode="edge-in" match="tei:pb"/>
  <xsl:template mode="edge-in" match="tei:*">
    <xsl:if test="not(following-sibling::text()[normalize-space(.)])">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates mode="copy" select="*|text()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template mode="edge-in" match="text()"/>
  

  <xsl:template mode="copy" match="tei:*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="copy" select="*|text()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="copy" match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

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
  <xsl:template match="/tei:teiCorpus">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <!-- insert component files gathered from $componentFiles -->
      <xsl:for-each select="$docs/tei:item">
        <xsl:sort select="./tei:n"/>
        <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="{./tei:xi-new}"/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

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
  <xsl:template match="tei:listOrg">
    <xsl:message>INFO: processing listOrg</xsl:message>
    <xsl:result-document href="{concat($outDir, '/ParlaMint-ES-listOrg.xml')}">
      <listOrg>
        <xsl:attribute name="xml:id">ParlaMint-ES-listOrg</xsl:attribute>
        <xsl:attribute name="xml:lang">es</xsl:attribute>
        <xsl:copy-of copy-namespaces="no" select="$orgs"/>
      </listOrg>
    </xsl:result-document>
    <xsl:element name="xi:include" namespace="http://www.w3.org/2001/XInclude">
      <xsl:namespace name="xi" select="'http://www.w3.org/2001/XInclude'"/>
      <xsl:attribute name="href">ParlaMint-ES-listOrg.xml</xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:listPerson">
    <xsl:message>INFO: processing listPerson </xsl:message>
    <xsl:result-document href="{concat($outDir, '/ParlaMint-ES-listPerson.xml')}">
      <listPerson>
        <xsl:attribute name="xml:id">ParlaMint-ES-listPerson</xsl:attribute>
        <xsl:attribute name="xml:lang">es</xsl:attribute>
        <head xml:lang="es">Lista de Oradores/Oradoras</head>
        <head xml:lang="en">List of speakers</head>
        <xsl:copy-of copy-namespaces="no" select="$persons"/>
      </listPerson>
    </xsl:result-document>
    <xsl:element name="xi:include" namespace="http://www.w3.org/2001/XInclude">
      <xsl:namespace name="xi" select="'http://www.w3.org/2001/XInclude'"/>
      <xsl:attribute name="href">ParlaMint-ES-listPerson.xml</xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:taxonomy[not(./*) and @xml:id]">
    <xsl:variable name="taxId" select="@xml:id"/>
    <xsl:message>INFO: processing <xsl:value-of select="$taxId"/></xsl:message>
    <xsl:result-document href="{concat($outDir, '/',$taxId,'.xml')}">
      <xsl:copy-of select="document(concat($taxonomyDir,'/',$taxId,'.xml'))"/>
    </xsl:result-document>
    <xsl:element name="xi:include" namespace="http://www.w3.org/2001/XInclude">
      <xsl:namespace name="xi" select="'http://www.w3.org/2001/XInclude'"/>
      <xsl:attribute name="href" select="concat($taxId,'.xml')"/>
    </xsl:element>
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
        <xsl:when test="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'es'">
          <xsl:value-of select="replace(., '^\d+', replace($formatted, ',', '.'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="replace(., '^\d+', $formatted)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:tagsDecl/tei:namespace">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of copy-namespaces="no" select="$tagUsages"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:bibl/tei:date | tei:setting/tei:date">
    <xsl:copy-of select="$timespan"/>
  </xsl:template>
  <xsl:template match="tei:PLACEHOLDER[@name='yeartimespan']">
    <xsl:value-of select="concat(replace($timespan//@from,'-.*',''),'-',replace($timespan//@to,'-.*',''))"/>
  </xsl:template>
  <xsl:template match="tei:PLACEHOLDER[@name='meetingterms']">
    <xsl:copy-of select="$meeting-terms"/>
  </xsl:template>
  <xsl:template match="tei:PLACEHOLDER[@name='termsspanA']">
    <xsl:value-of select="concat($meeting-terms/*[1]/@n,'-',$meeting-terms/*[last()]/@n)"/>
  </xsl:template>
  <xsl:template match="tei:PLACEHOLDER[@name='termsspanR']">
    <xsl:value-of select="concat(replace($meeting-terms/*[1]/text(),'.* ',''),'-',replace($meeting-terms/*[last()]/text(),'.* ',''))"/>
  </xsl:template>

  <!-- debug template -->
  <xsl:template name="genPath">
    <xsl:param name="prevPath"/>
    <xsl:variable name="currPath" select="concat('/',name(),'[',
      count(preceding-sibling::*[name() = name(current())])+1,']',$prevPath)"/>
    <xsl:for-each select="parent::*">
      <xsl:call-template name="genPath">
        <xsl:with-param name="prevPath" select="$currPath"/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:if test="not(parent::*)">
      <xsl:value-of select="$currPath"/>
    </xsl:if>
  </xsl:template>


  <!-- org mode -->
  <xsl:template match="*" mode="orgs">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="orgs"/>
      <xsl:apply-templates  mode="orgs"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*[not(name()='role' and .='politicalParty')]" mode="orgs">
    <xsl:copy/>
  </xsl:template>
  <xsl:template match="@role[.='politicalParty']" mode="orgs">
    <xsl:message>INFO: <xsl:value-of select="../@xml:id"/> - changing politicalParty role to parliamentaryGroup</xsl:message>
    <xsl:attribute name="role">parliamentaryGroup</xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
