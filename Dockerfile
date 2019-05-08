FROM adoptopenjdk/openjdk8:jdk8u212-b03-alpine


RUN echo @edge http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
    && echo @edge http://dl-cdn.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories \
    && apk add --no-cache \
    bash \
    ttf-dejavu fontconfig && \
    fc-cache -f


ENV LD_LIBRARY_PATH=/usr/lib:/lib
RUN ln -s /usr/lib/libfontconfig.so.1 /usr/lib/libfontconfig.so

MAINTAINER draca <info@draca.be>

ARG CONF_VERSION=6.13.0
ARG CONF_DOWNLOAD=https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-6.13.0.tar.gz

ENV CONF_HOME=/opt/atlassian/confluence/data
ENV CONF_INSTALL=/opt/atlassian/confluence/install
ENV CONF_CERTS=/opt/atlassian/confluence/certs

ENV RUN_USER=confluence
ENV RUN_GROUP=confluence

ENV JVM_MINIMUM_MEMORY=1024m
ENV JVM_MAXIMUM_MEMORY=1024m

EXPOSE 8090

WORKDIR $CONF_HOME

RUN apk add --no-cache curl tar shadow tzdata\
    && groupadd -r ${RUN_GROUP} \
    && useradd -d "${CONF_HOME}" -r -g ${RUN_GROUP} ${RUN_USER} \
    && mkdir -p "${CONF_HOME}" "${CONF_INSTALL}" "${CONF_CERTS}" \
    && curl -Ls ${CONF_DOWNLOAD} | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \
    && echo -e "\nconfluence.home=${CONF_HOME}" >> "${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" \
    && apk del curl tar shadow \
    && chown -R ${RUN_USER}:${RUN_GROUP} "${CONF_HOME}" "${CONF_INSTALL}" "${CONF_CERTS}"


COPY "entrypoint.sh" "/"
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/opt/atlassian/confluence/install/bin/start-confluence.sh", "-fg"]