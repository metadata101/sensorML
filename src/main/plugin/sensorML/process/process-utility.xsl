<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exslt="http://exslt.org/common" xmlns:geonet="http://www.fao.org/geonetwork"
  xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  version="2.0" exclude-result-prefixes="exslt">
  
  <!-- Language of the GUI -->
  <xsl:param name="guiLang" select="'eng'"/>
  
  <!-- Webapp name-->
  <xsl:param name="baseUrl" select="''"/>
  
  <!-- Catalog URL from protocol to lang -->
  <xsl:param name="catalogUrl" select="''"/>
  <xsl:param name="nodeId" select="''"/>
  
  <!-- Search for any of the searchStrings provided -->
  <xsl:function name="geonet:parseBoolean" as="xs:boolean">
    <xsl:param name="arg"/>
    <xsl:value-of
      select="if ($arg='on' or $arg=true() or $arg='true' or $arg='1') then true() else false()"/>
  </xsl:function>

  <!-- Return the message identified by the id in the required language
  or return the english message if not found. -->
  <xsl:function name="geonet:i18n" as="xs:string">
    <xsl:param name="loc"/>
    <xsl:param name="id"/>
    <xsl:param name="lang"/>
    <xsl:value-of
      select="if ($loc/msg[@id=$id and @xml:lang=$lang]) then $loc/msg[@id=$id and @xml:lang=$lang] else $loc/msg[@id=$id and @xml:lang='en']"/>
  </xsl:function>

</xsl:stylesheet>
