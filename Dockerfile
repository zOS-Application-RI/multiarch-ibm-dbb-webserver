# FROM ubuntu
## IBM DBB Supports only IBM JAVA v8 on Latest
ARG JAVA_VER=open-8-jdk-focal
FROM ibm-semeru-runtimes:${JAVA_VER}
################################################################################################
LABEL maintainer="ashissah@in.ibm.com"
################################################################################################
ARG IBM_DBB_VER=1.1.3
ARG IBM_DBB_URL=https://public.dhe.ibm.com/ibmdl/export/pub/software/htp/zos/aqua31/dbb/${IBM_DBB_VER}/dbb-server-${IBM_DBB_VER}.tar.gz
ARG DBB_HOME=/var/dbb_home
################################################################################################
RUN apt-get update && apt-get full-upgrade -y \
    && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends tzdata wget curl ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*
ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata
################################################################################################
ENV DEBIAN_FRONTEND noninteractive
################################################################################################
################################IBM DBB Web Server##############################################                                                 
################################################################################################
RUN mkdir -p ${DBB_HOME} \
    && cd ${DBB_HOME} \
    && curl -fsSL ${IBM_DBB_URL} -o ${DBB_HOME}/dbb-server.tar.gz  \
    && tar -xvf dbb-server.tar.gz 
RUN chmod a+x ${DBB_HOME}/wlp/bin/
# RUN chmod 777 /var/dbb_home/wlp/usr/servers/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh 
################################################################################################
################################IBM DBB Web Server Config Files#################################                                                 
################################################################################################
### Copy Server Configurations
COPY configServer/*.*   ${DBB_HOME}/wlp/usr/servers/dbb/
### Copy Other Configurations
### Sample configuration found on config_sample folder
### Edit your samples and move to configDropins/overrides folder
COPY configDropins/overrides/*.* ${DBB_HOME}/wlp/usr/servers/dbb/configDropins/overrides/
#################################################################################################
# Use tini as subreaper in Docker container to adopt zombie processes                           #
#################################################################################################

ARG TINI_VERSION=v0.19.0
COPY tini_pub.gpg ${DBB_HOME}/tini_pub.gpg
RUN curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture) -o /sbin/tini \
    && curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture).asc -o /sbin/tini.asc \
    && gpg --no-tty --import ${DBB_HOME}/tini_pub.gpg \
    && gpg --verify /sbin/tini.asc \
    && rm -rf /sbin/tini.asc /root/.gnupg \
    && chmod +x /sbin/tini

EXPOSE 9080 9443
VOLUME $DBB_HOME/wlp/usr/servers/dbb
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["entrypoint.sh"]

