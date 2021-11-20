# FROM ubuntu
## IBM DBB Supports only IBM JAVA v8 on Latest
ARG JAVA_VER=8
FROM ibmjava:${JAVA_VER}
################################################################################################
LABEL maintainer="ashissah@in.ibm.com"
################################################################################################
ARG IBM_DBB_VER=1.1.2
ARG IBM_DBB_URL=https://public.dhe.ibm.com/ibmdl/export/pub/software/htp/zos/aqua31/dbb/${IBM_DBB_VER}/dbb-server-${{IBM_DBB_VER}}.tar.gz
ARG DBB_HOME=/var/dbb_home
################################################################################################
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends wget curl ca-certificates \
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
COPY server.xml ${DBB_HOME}/wlp/usr/servers/dbb/
RUN chmod 777 ${DBB_HOME}/wlp/usr/servers/dbb/server.xml
RUN chmod 777 /var/dbb_home/wlp/usr/servers/
COPY start.sh /usr/local/bin/start.sh
RUN chmod a+x /usr/local/bin/start.sh
#################################################################################################
# VOLUME $DBB_HOME
# ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
