<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                exclude-result-prefixes="gmd xsl gco srv geonet">


  <!-- Example of replacements parameter:

     <replacements>
      <caseInsensitive>i</caseInsensitive>
      <replacement>
        <field>id.contact.individualName</field>
        <searchValue>John Doe</searchValue>
        <replaceValue>Jennifer Smith</replaceValue>
      </replacement>
      <replacement>
        <field>id.contact.organisationName</field>
        <searchValue>Acme</searchValue>
        <replaceValue>New Acme</replaceValue>
      </replacement>
    </replacements>
  -->
  <xsl:param name="replacements"/>

  <!-- by default is case sensitive, sending i value in the param makes replacements case insensitive -->
  <xsl:variable name="case_insensitive" select="$replacements/replacements/caseInsensitive"/>

  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove geonet:* elements. -->
  <xsl:template match="geonet:*" priority="2"/>

  <!--
    Field replacement template. Checks if a replacement for the field is defined to apply it, otherwise copies the field value.
  -->
  <xsl:template name="replaceField">
    <xsl:param name="fieldId"/>

    <xsl:copy>
      <xsl:copy-of select="@*"/>

      <xsl:choose>
        <!-- A replacement defined for the field, apply it -->
        <xsl:when
            test="$replacements/replacements/replacement[field = $fieldId]
                    and string($replacements/replacements/replacement[field = $fieldId]/searchValue)">

          <xsl:choose>
            <!-- gmd:URL -->
            <xsl:when test="name() = 'gmd:URL'">
              <xsl:call-template name="replaceValueForField">
                <xsl:with-param name="fieldId" select="$fieldId" />
                <xsl:with-param name="value" select="." />
              </xsl:call-template>
            </xsl:when>

            <!-- Fields with gco:CharacterString -->
            <xsl:when test="name(*[1]) = 'gco:CharacterString'">
              <gco:CharacterString>
                <xsl:call-template name="replaceValueForField">
                  <xsl:with-param name="fieldId" select="$fieldId" />
                  <xsl:with-param name="value" select="gco:CharacterString" />
                </xsl:call-template>
              </gco:CharacterString>

              <xsl:if test="gmd:PT_FreeText">
                <xsl:for-each select="gmd:PT_FreeText">
                  <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:for-each select="gmd:textGroup">
                      <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:for-each select="gmd:LocalisedCharacterString">
                          <gmd:LocalisedCharacterString locale="{@locale}">
                            <xsl:call-template name="replaceValueForField">
                              <xsl:with-param name="fieldId" select="$fieldId" />
                              <xsl:with-param name="value" select="." />
                            </xsl:call-template>
                          </gmd:LocalisedCharacterString>
                        </xsl:for-each>
                      </xsl:copy>
                    </xsl:for-each>
                  </xsl:copy>

                </xsl:for-each>
              </xsl:if>
            </xsl:when>

            <!-- Other type, just copy them -->
            <xsl:otherwise>
              <xsl:apply-templates select="@*|node()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <!-- No replacement defined, just process the field to copy it -->
        <xsl:otherwise>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>

  </xsl:template>

  <!--
  Template to manage about a field value replacement using the case insensitive parameter.
  -->
  <xsl:template name="replaceValueForField">
    <xsl:param name="fieldId" />
    <xsl:param name="value" />

    <xsl:choose>
      <xsl:when test="string($case_insensitive)">
        <xsl:call-template name="replaceCaseInsensitive">
          <xsl:with-param name="fieldId" select="$fieldId" />
          <xsl:with-param name="currentValue" select="$value" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="replaceCaseSensitive">
          <xsl:with-param name="fieldId" select="$fieldId" />
          <xsl:with-param name="currentValue" select="$value" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="replaceCaseInsensitive">
    <xsl:param name="fieldId" />
    <xsl:param name="currentValue" />

    <xsl:variable name="newValue"
                  select="replace($currentValue, $replacements/replacements/replacement[field = $fieldId]/searchValue, $replacements/replacements/replacement[field = $fieldId]/replaceValue, $case_insensitive)"/>

    <!--<xsl:message>====== replaceCaseInsensitive fieldId:<xsl:value-of select="$fieldId" /></xsl:message>
    <xsl:message>====== replaceCaseInsensitive currentVal:<xsl:value-of select="$currentValue" /></xsl:message>
    <xsl:message>====== replaceCaseInsensitive newVal:<xsl:value-of select="$newValue" /></xsl:message>-->


    <xsl:if test="$currentValue != $newValue">
      <xsl:attribute name="geonet:change" select="$fieldId"/>
      <xsl:attribute name="geonet:original" select="$currentValue"/>
      <xsl:attribute name="geonet:new" select="$newValue"/>
    </xsl:if>

    <xsl:value-of select="$newValue"/>
  </xsl:template>


  <xsl:template name="replaceCaseSensitive">
    <xsl:param name="fieldId" />
    <xsl:param name="currentValue" />

    <xsl:variable name="newValue"
                  select="replace($currentValue, $replacements/replacements/replacement[field = $fieldId]/searchValue, $replacements/replacements/replacement[field = $fieldId]/replaceValue)"/>

    <!--<xsl:message>====== replaceCaseSensitive fieldId:<xsl:value-of select="$fieldId" /></xsl:message>
    <xsl:message>====== replaceCaseSensitive currentVal:<xsl:value-of select="$currentValue" /></xsl:message>
    <xsl:message>====== replaceCaseSensitive newVal:<xsl:value-of select="$newValue" /></xsl:message>-->

    <xsl:if test="$currentValue != $newValue">
      <xsl:attribute name="geonet:change" select="$fieldId"/>
      <xsl:attribute name="geonet:original" select="$currentValue"/>
      <xsl:attribute name="geonet:new" select="$newValue"/>
    </xsl:if>

    <xsl:value-of select="$newValue"/>
  </xsl:template>
</xsl:stylesheet>
