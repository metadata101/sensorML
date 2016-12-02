# SensorML schema plugin

This is the SensorML schema plugin version 1.0.1 for GeoNetwork 3.0.x or greater version.

## Reference documents:

* http://www.opengeospatial.org/standards/sensorml
 

## Description:

This plugin is composed of:

* indexing
* viewing
* validation (XSD and Schematron)

## Metadata rules:

### Metadata identifier

The metadata identifier is stored in the element sml:SensorML/sml:member/sml:System/sml:identification/sml:IdentifierList/sml:identifier.
Only the code is set by default but more complete description may be defined.

```
<sml:identification>
<sml:IdentifierList>
<sml:identifier xmlns:gco="http://www.isotc211.org/2005/gco" name="GeoNetwork-UUID">
<sml:Term>
<sml:value>3ec82b03-f9b4-446e-8540-82898cfa395a</sml:value>
</sml:Term>
</sml:identifier>
<sml:identifier name="siteID">
<sml:Term definition="">
<sml:codeSpace xlink:href=""/>
<sml:value/>
</sml:Term>
</sml:identifier>
<sml:identifier name="siteShortName">
<sml:Term definition="">
<sml:codeSpace xlink:href=""/>
<sml:value/>
</sml:Term>
</sml:identifier>
<sml:identifier name="siteFullName">
<sml:Term definition="">
<sml:codeSpace xlink:href=""/>
<sml:value>Template for SensorML Deployment Site/Platform</sml:value>
</sml:Term>
</sml:identifier>
</sml:IdentifierList>
</sml:identification>
```

### Validation

Validation steps are first XSD validation made on the schema, then the schematron validation defined in folder  [sensorML/schematron](https://github.com/metadata101/sensorML/tree/3.2.x/src/main/plugin/sensorML/schematron). one set of rules is available:
* SensorML rules

## Installing the plugin

### GeoNetwork version to use with this plugin

This is an implementation of the latest XSD published by ISO-TC211. 
It'll not be supported in 2.10.x series so don't plug it into it!
Use GeoNetwork 3.0+ version.

### Adding the plugin to the source code

The best approach is to add the plugin as a submodule into GeoNetwork schema module.

```
cd schemas
git submodule add https://github.com/metadata101/sensorML.git sensorML
```

Add the new module to the schema/pom.xml:

```
  <module>iso19139</module>
  <module>sensorML</module>
</modules>
```

Add the dependency in the web module in web/pom.xml:

```
<dependency>
  <groupId>${project.groupId}</groupId>
  <artifactId>sensorML</artifactId>
  <version>${project.version}</version>
</dependency>
```

Add the module to the webapp in web/pom.xml:

```
<execution>
  <id>copy-schemas</id>
  <phase>process-resources</phase>
  ...
  <resource>
    <directory>${project.basedir}/../schemas/sensorML/src/main/plugin</directory>
    <targetPath>${basedir}/src/main/webapp/WEB-INF/data/config/schema_plugins</targetPath>
  </resource>
```


Build the application.


## More work required

### Editor support


## Community

Comments and questions to geonetwork-developers or geonetwork-users mailing lists.


## Contributors

* María Arias de Reyna (GeoCat)
