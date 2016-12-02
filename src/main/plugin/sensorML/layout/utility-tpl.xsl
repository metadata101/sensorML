<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:sml="http://www.opengis.net/sensorML/1.0.1"
  xmlns:swe="http://www.opengis.net/swe/1.0.1"
  xmlns:gn="http://www.fao.org/geonetwork"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all">

  <xsl:include href="utility-tpl-multilingual.xsl"/>

  <xsl:template name="get-sensorML-is-service">
    <xsl:value-of
            select="false()"/>
  </xsl:template>
  
  
  <xsl:template name="get-sensorML-title">
    <xsl:value-of select="$metadata/sml:member/sml:System/gml:name"/>
  </xsl:template>

  <xsl:template name="get-sensorML-extents-as-json">[  ]
  </xsl:template>
  
  
  <xsl:template name="get-sensorML-online-source-config">
    <xsl:param name="pattern"/>
    <config>
      
    </config>
  </xsl:template>

</xsl:stylesheet>
