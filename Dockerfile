# FROM ubuntu
## IBM DBB Supports only IBM JAVA v8 on Latest
ARG JAVA_VER=8
FROM ibmjava:${JAVA_VER}
################################################################################################
LABEL maintainer="ashissah@in.ibm.com"
################################################################################################
ARG IBM_DBB_VER=1.1.2
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
# COPY server.xml ${DBB_HOME}/wlp/usr/servers/dbb/
# RUN chmod 777 ${DBB_HOME}/wlp/usr/servers/dbb/server.xml
RUN chmod 777 /var/dbb_home/wlp/usr/servers/
COPY start.sh /usr/local/bin/start.sh
RUN chmod a+x /usr/local/bin/start.sh 
#################################################################################################
# Use tini as subreaper in Docker container to adopt zombie processes
ARG TINI_VERSION=v0.19.0
COPY tini_pub.gpg ${DBB_HOME}/tini_pub.gpg
RUN curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture) -o /sbin/tini \
    && curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture).asc -o /sbin/tini.asc \
    && gpg --no-tty --import ${DBB_HOME}/tini_pub.gpg \
    && gpg --verify /sbin/tini.asc \
    && rm -rf /sbin/tini.asc /root/.gnupg \
    && chmod +x /sbin/tini

EXPOSE 9080 9443
VOLUME $DBB_HOME/wlp/usr/servers/dbb/DBB_DATABASE
ENTRYPOINT ["/sbin/tini", "--"]
CMD [ "/var/dbb_home/wlp/bin/server", "start", "dbb"]
