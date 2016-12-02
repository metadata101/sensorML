<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:gn-fn-sensorML="http://geonetwork-opensource.org/xsl/functions/profiles/sensorML"
  xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
  exclude-result-prefixes="#all">

  <!-- return the lang iso3code in uper case. -->
  <xsl:function name="gn-fn-sensorML:getLangId" as="xs:string">
    <xsl:param name="md" />
    <xsl:param name="lang" />
    <xsl:value-of select="concat('#', upper-case($lang))" />
  </xsl:function>

  <xsl:function name="gn-fn-sensorML:getCodeListType" as="xs:string">
    <xsl:param name="name" as="xs:string" />

    <xsl:variable name="configType"
      select="$editorConfig/editor/fields/for[@name = $name]/@use" />

    <xsl:value-of select="if ($configType) then $configType else 'select'" />
  </xsl:function>




</xsl:stylesheet>
