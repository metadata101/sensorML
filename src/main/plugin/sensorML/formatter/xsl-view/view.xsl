<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:sml="http://www.opengis.net/sensorML/1.0.1" xmlns:swe="http://www.opengis.net/swe/1.0.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gml="http://www.opengis.net/gml"
  xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
  xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
  xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
  xmlns:gn-fn-sensorML="http://geonetwork-opensource.org/xsl/functions/profiles/sensorML"
  xmlns:saxon="http://saxon.sf.net/" extension-element-prefixes="saxon"
  exclude-result-prefixes="#all">
  <!-- This formatter render a record based on the editor configuration file. 
    The layout is made in 2 modes: * render-field taking care of elements (eg. 
    sections, label) * render-value taking care of element values (eg. characterString, 
    URL) 3 levels of priority are defined: 100, 50, none -->


  <!-- Load the editor configuration to be able to render the different views -->
  <xsl:variable name="configuration"
    select="document('../../layout/config-editor.xml')" />

  <!-- Required for utility-fn.xsl -->
  <xsl:variable name="editorConfig"
    select="document('../../layout/config-editor.xml')" />

  <!-- Some utility -->
  <xsl:include href="../../layout/evaluate.xsl" />
  <xsl:include href="../../layout/utility-tpl-multilingual.xsl" />
  <xsl:include href="../../layout/utility-fn.xsl" />

  <!-- The core formatter XSL layout based on the editor configuration -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl" />

  <!-- Define the metadata to be loaded for this schema plugin -->
  <xsl:variable name="metadata" select="/root/sml:SensorML" />

  <xsl:variable name="langId"
    select="gn-fn-sensorML:getLangId($metadata, $language)" />



  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="sml:SensorML">
    <xsl:for-each select="sml:IdentifierList/sml:identifier[@name='siteFullName']">
      <xsl:value-of select="string(.)" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="getMetadataAbstract" match="sml:SensorML">
    <xsl:for-each select="sml:member/sml:System/gml:description">
      <xsl:value-of select="string(.)" />
    </xsl:for-each>
  </xsl:template>


  <!-- Most of the elements are ... -->
  <xsl:template mode="render-field"
    match="*[gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|
       gco:Angle|gco:Scale|gco:Record|gco:RecordType|
       gco:LocalName|gml:beginPosition|gml:endPosition|
       gco:Date|gco:DateTime|*/@codeListValue]"
    priority="50">
    <xsl:param name="fieldName" select="''" as="xs:string" />


    <dl>
      <dt>
        <xsl:value-of
          select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)" />
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value"
          select="*|*/@codeListValue" />
        <xsl:apply-templates mode="render-value"
          select="@*" />
      </dd>
    </dl>
  </xsl:template>

  <xsl:template mode="render-field" match="*[gco:CharacterString]"
    priority="50">
    <xsl:param name="fieldName" select="''" as="xs:string" />

    <dl>
      <dt>
        <xsl:value-of
          select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)" />
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value"
          select="." />
        <xsl:apply-templates mode="render-value"
          select="@*" />
      </dd>
    </dl>
  </xsl:template>



  <!-- Some major sections are boxed -->
  <xsl:template mode="render-field"
    match="*[name() = $configuration/editor/fieldsWithFieldset/name
                  or @gco:isoType = $configuration/editor/fieldsWithFieldset/name]">

    <div class="entry name">
      <h3>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)" />
        <xsl:apply-templates mode="render-value"
          select="@*" />
      </h3>
      <div class="target">
        <xsl:apply-templates mode="render-field"
          select="*" />
      </div>
    </div>
  </xsl:template>



  <!-- Metadata linkage -->
  <xsl:template mode="render-field" match="sml:identifier"
    priority="100">
    <dl>
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)" />
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value"
          select="*" />
        <xsl:apply-templates mode="render-value"
          select="@*" />

        <a class="btn btn-link" href="xml.metadata.get?id={$metadataId}">
          <i class="fa fa-file-code-o fa-2x"></i>
          <span data-translate="">metadataInXML</span>
        </a>
      </dd>
    </dl>
  </xsl:template>

  <!-- Link to other metadata records -->
  <xsl:template mode="render-field" match="*[@uuidref]"
    priority="100">
    <xsl:variable name="nodeName" select="name()" />

    <!-- Only render the first element of this kind and render a list of 
      following siblings. -->
    <xsl:variable name="isFirstOfItsKind"
      select="count(preceding-sibling::node()[name() = $nodeName]) = 0" />
    <xsl:if test="$isFirstOfItsKind">
      <dl class="gn-md-associated-resources">
        <dt>
          <xsl:value-of
            select="tr:node-label(tr:create($schema), name(), null)" />
        </dt>
        <dd>
          <ul>
            <xsl:for-each select="parent::node()/*[name() = $nodeName]">
              <li>
                <a href="#uuid={@uuidref}">
                  <i class="fa fa-link"></i>
                  <xsl:value-of
                    select="gn-fn-render:getMetadataTitle(@uuidref, $language)" />
                </a>
              </li>
            </xsl:for-each>
          </ul>
        </dd>
      </dl>
    </xsl:if>
  </xsl:template>

  <!-- Traverse the tree -->
  <xsl:template mode="render-field" match="*">
    <xsl:apply-templates mode="render-field" />
  </xsl:template>







  <!-- ########################## -->
  <!-- Render values for text ... -->
  <xsl:template mode="render-value" match="*[gco:CharacterString]">
    <xsl:value-of select="string(.)" />
  </xsl:template>

  <xsl:template mode="render-value"
    match="gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|gco:Angle|
       gco:Scale|gco:Record|gco:RecordType|
       gco:LocalName|gml:beginPosition|gml:endPosition">

    <xsl:choose>
      <xsl:when test="contains(., 'http')">
        <!-- Replace hyperlink in text by an hyperlink -->
        <xsl:variable name="textWithLinks"
          select="replace(., '([a-z][\w-]+:/{1,3}[^\s()&gt;&lt;]+[^\s`!()\[\]{};:'&apos;&quot;.,&gt;&lt;?«»“”‘’])',
                                    '&lt;a href=''$1''&gt;$1&lt;/a&gt;')" />

        <xsl:if test="$textWithLinks != ''">
          <xsl:copy-of
            select="saxon:parse(
                          concat('&lt;p&gt;',
                          replace($textWithLinks, '&amp;', '&amp;amp;'),
                          '&lt;/p&gt;'))" />
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(.)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ... Dates - formatting is made on the client side by the directive -->
  <xsl:template mode="render-value" match="gco:Date[matches(., '[0-9]{4}')]">
    <span data-gn-humanize-time="{.}" data-format="YYYY"></span>
  </xsl:template>

  <xsl:template mode="render-value"
    match="gco:Date[matches(., '[0-9]{4}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="MMM YYYY"></span>
  </xsl:template>

  <xsl:template mode="render-value"
    match="gco:Date[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="DD MMM YYYY"></span>
  </xsl:template>

  <xsl:template mode="render-value"
    match="gco:DateTime[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')]">
    <span data-gn-humanize-time="{.}"></span>
  </xsl:template>

  <xsl:template mode="render-value" match="gco:Date|gco:DateTime">
    <span data-gn-humanize-time="{.}"></span>
  </xsl:template>

  <!-- ... Codelists -->
  <xsl:template mode="render-value" match="@codeListValue">
    <xsl:variable name="id" select="." />
    <xsl:variable name="codelistTranslation"
      select="tr:codelist-value-label(
                            tr:create($schema),
                            parent::node()/local-name(), $id)" />
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
          select="tr:codelist-value-desc(
                            tr:create($schema),
                            parent::node()/local-name(), $id)" />
        <span title="{$codelistDesc}">
          <xsl:value-of select="$codelistTranslation" />
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="render-field" match="swe:Envelope"> <!-- |swe:Position -->
  
    <xsl:variable name="west" select="min(
          */swe:Vector/swe:coordinate[@name='easting']/swe:Quantity/swe:value)" />

    <xsl:variable name="east" select="max(
          */swe:Vector/swe:coordinate[@name='easting']/swe:Quantity/swe:value)" />

    <xsl:variable name="south" select="min(
          */swe:Vector/swe:coordinate[@name='northing']/swe:Quantity/swe:value)" />

    <xsl:variable name="north" select="max(
          */swe:Vector/swe:coordinate[@name='northing']/swe:Quantity/swe:value)" />

    <dl>
      <dt>
        <xsl:value-of
          select="tr:node-label(tr:create($schema), name(), null)" />
      </dt>
      <dd>
        <xsl:copy-of
          select="gn-fn-render:bbox(
                            $west,
                            $south,
                            $east,
                            $north)" />
      </dd>
    </dl>
  </xsl:template>


  <xsl:template mode="render-value" match="@gco:nilReason[. = 'withheld']"
    priority="100">
    <i class="fa fa-lock text-warning" title="{{{{'withheld' | translate}}}}"></i>
  </xsl:template>
  <xsl:template mode="render-value" match="@*" />

</xsl:stylesheet>
