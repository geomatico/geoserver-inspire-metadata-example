FROM tomcat:9-jdk11

#DOWNLOAD GEOSERVER
ARG GEOSERVER_VERSION
RUN set -eux;\
    tempFolder="$(mktemp -d)";\
    curl -L "https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/geoserver-$GEOSERVER_VERSION-war.zip/download#" -o "$tempFolder/geoserver-war.zip";\
    unzip "$tempFolder/geoserver-war.zip" -d "$tempFolder/geoserver";\
    unzip "$tempFolder/geoserver/geoserver.war" -d webapps/geoserver;\
    rm -R "$tempFolder/geoserver/geoserver.war";\
    rm -R webapps/geoserver/data/demo;\
    rm -R webapps/geoserver/data/workspaces;\
    rm -R webapps/geoserver/data/layergroups;

#ENABLE CORS
RUN sed -i '\:</web-app>:i\
<filter>\n\
    <filter-name>CorsFilter</filter-name>\n\
    <filter-class>org.apache.catalina.filters.CorsFilter</filter-class>\n\
    <init-param>\n\
        <param-name>cors.allowed.origins</param-name>\n\
        <param-value>*</param-value>\n\
    </init-param>\n\
    <init-param>\n\
        <param-name>cors.allowed.methods</param-name>\n\
        <param-value>GET,POST,HEAD,OPTIONS,PUT</param-value>\n\
    </init-param>\n\
</filter>\n\
<filter-mapping>\n\
    <filter-name>CorsFilter</filter-name>\n\
    <url-pattern>/*</url-pattern>\n\
</filter-mapping>' webapps/geoserver/WEB-INF/web.xml

#DOWNLOAD GEOSERVER PLUGINS
RUN set -eux;\
     plugin=vectortiles;\
     tempFolder="$(mktemp -d)";\
     curl -L "https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-$plugin-plugin.zip/download#" -o "$tempFolder/$plugin.zip";\
     unzip -o "$tempFolder/$plugin.zip" -d "webapps/geoserver/WEB-INF/lib";

RUN set -eux;\
    plugin=querylayer;\
    tempFolder="$(mktemp -d)";\
    curl -L "https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-$plugin-plugin.zip/download#" -o "$tempFolder/$plugin.zip";\
    unzip -o "$tempFolder/$plugin.zip" -d "webapps/geoserver/WEB-INF/lib";

RUN set -eux;\
    plugin=importer;\
    tempFolder="$(mktemp -d)";\
    curl -L "https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-$plugin-plugin.zip/download#" -o "$tempFolder/$plugin.zip";\
    unzip -o "$tempFolder/$plugin.zip" -d "webapps/geoserver/WEB-INF/lib";

RUN set -eux;\
    plugin=csw;\
    tempFolder="$(mktemp -d)";\
    curl -L "https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-$plugin-plugin.zip/download#" -o "$tempFolder/$plugin.zip";\
    unzip -o "$tempFolder/$plugin.zip" -d "webapps/geoserver/WEB-INF/lib";

RUN set -eux;\
    plugin=inspire;\
    tempFolder="$(mktemp -d)";\
    curl -L "https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-$plugin-plugin.zip/download#" -o "$tempFolder/$plugin.zip";\
    unzip -o "$tempFolder/$plugin.zip" -d "webapps/geoserver/WEB-INF/lib";

RUN set -eux;\
    plugin=mbstyle;\
    tempFolder="$(mktemp -d)";\
    version="$(echo "$GEOSERVER_VERSION" | cut -d '.' -f 1,2)";\
    curl -L "https://sourceforge.net/projects/geoserver/files/GeoServer/$GEOSERVER_VERSION/extensions/geoserver-$GEOSERVER_VERSION-$plugin-plugin.zip/download#" -o "$tempFolder/$plugin.zip";\
    unzip -o "$tempFolder/$plugin.zip" -d "webapps/geoserver/WEB-INF/lib";

RUN set -eux;\
    plugin=csw-iso;\
    tempFolder="$(mktemp -d)";\
    version="$(echo "$GEOSERVER_VERSION" | cut -d '.' -f 1,2)";\
    curl -L "https://build.geoserver.org/geoserver/$version.x/community-latest/geoserver-$version-SNAPSHOT-$plugin-plugin.zip" -o "$tempFolder/$plugin.zip";\
    unzip -o "$tempFolder/$plugin.zip" -d "webapps/geoserver/WEB-INF/lib";

RUN set -eux;\
    plugin=metadata;\
    tempFolder="$(mktemp -d)";\
    version="$(echo "$GEOSERVER_VERSION" | cut -d '.' -f 1,2)";\
    curl -L "https://build.geoserver.org/geoserver/$version.x/community-latest/geoserver-$version-SNAPSHOT-$plugin-plugin.zip" -o "$tempFolder/$plugin.zip";\
    unzip -o "$tempFolder/$plugin.zip" -d "webapps/geoserver/WEB-INF/lib";

# This is just to get jackson-annotation*.jar and snakeyaml-*.jar dependencies in place. Needed but not included in "metadata" plugin.
RUN curl -L "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/2.10.1/jackson-annotations-2.10.1.jar" -o "webapps/geoserver/WEB-INF/lib/jackson-annotations-2.10.1.jar"
RUN curl -L "https://repo1.maven.org/maven2/org/yaml/snakeyaml/1.24/snakeyaml-1.24.jar" -o "webapps/geoserver/WEB-INF/lib/snakeyaml-2.10.1.jar"

RUN ["/bin/bash", "-c", "bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)"]

COPY files/security/users.xml webapps/geoserver/data/security/usergroup/default/users.xml
COPY files/security/roles.xml webapps/geoserver/data/security/role/default/roles.xml
COPY files/security/passwd webapps/geoserver/data/security/masterpw/default/passwd
COPY files/security/rest.properties webapps/geoserver/data/security/rest.properties
COPY files/security/services.properties webapps/geoserver/data/security/services.properties
ADD files/styles webapps/geoserver/data/styles

#CREATE TOMCAT USER
RUN set -eux;\
    groupadd -r tomcat ;\
    useradd -r -g tomcat --home-dir=/etc/tomcat --shell=/bin/bash tomcat;\
    mkdir -p /etc/tomcat; \
    chown -R tomcat:tomcat /etc/tomcat

#TOMCAT ENVIRONMENT
ENV CATALINA_OPTS "-server -Djava.awt.headless=true -Xms1024m -Xmx4096m -XX:NewSize=48m -Dfile.encoding=UTF-8"

EXPOSE 8080
