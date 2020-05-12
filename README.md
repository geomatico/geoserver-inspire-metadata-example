# Managing an INSPIRE metadata catalog in Geoserver

Using CSW, CSW-ISO and Metadata extensions, and applying a modified version of the sample files from the manual.

* [CSW extension documentation](https://docs.geoserver.org/stable/en/user/services/csw/index.html#csw)
* [CSW-ISO extension documentation](https://docs.geoserver.org/stable/en/user/community/csw-iso/index.html)
* [Metadata extension documentation](https://docs.geoserver.org/stable/en/user/community/metadata/index.html)
* [INSPIRE metadata tutorial and sample files](https://docs.geoserver.org/stable/en/user/tutorials/metadata/index.html#tutorial-metadata)

## Found bugs

The extension can be used, with some rough edges.

Could be interesting to talk to [Niels Charlier](https://github.com/NielsCharlier), contributor of latest changes to csw-iso and metadata extensions, to work together in fixing these.

### Extension is missing some requirements

[The release file](https://github.com/geoserver/geoserver/blob/master/src/community/release/ext-metadata.xml) should include as well:

```xml
<include>jackson-annotations-*.jar</include>
<include>snakeyaml-*.jar</include>
```

Jar file versions for GeoServer 2.17.0 can be downloaded from:

* https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/2.10.1/jackson-annotations-2.10.1.jar
* https://repo1.maven.org/maven2/org/yaml/snakeyaml/1.24/snakeyaml-1.24.jar

### Errors found when trying to use INSPIRE sample files from user manual

* Some constants and dictionaries are in dutch. Better provide an example in English.
* In `wms/MD_Metadata.properties`, the `isCached` function cannot be resolved.
* Error when applying values to `Anchor.@href`, probably related to the `xlink` namespace?
* Bad XML generated when applying values to `gml:TimePeriod`. The `gml` prefix is rendered as `null`, and its namespace is not declared in XML root element.
* The "Metadata" tab doesn't fully render the form, only the first 20 entries or so. Last attributes cannot be filled.

The provided files in `data_dir` will fix these issues to provide a working example.

## Some useful code:

* ResourceInfo: https://github.com/geoserver/geoserver/blob/master/src/main/src/main/java/org/geoserver/catalog/impl/ResourceInfoImpl.java
* CatalogStore: https://github.com/geoserver/geoserver/blob/master/src/extension/csw/core/src/main/java/org/geoserver/csw/store/internal/InternalCatalogStore.java#L100
* MetaDataDescriptor: https://github.com/geoserver/geoserver/blob/master/src/community/csw-iso/src/main/java/org/geoserver/csw/records/iso/MetaDataDescriptor.java
