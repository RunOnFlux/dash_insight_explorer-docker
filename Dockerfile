FROM ubuntu:22.04
ENV DEBIAN_FRONTEND noninteractive


RUN apt update -y && apt install -y \
  curl build-essential python3 python3-pip python3-distutils \
  git cmake jq tar pv pwgen bc libzmq3-dev \
  && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs

COPY daemon_initialize.sh /daemon_initialize.sh
COPY check-health.sh /check-health.sh
VOLUME /root/.dashcore
EXPOSE 3001/tcp
RUN chmod 755 daemon_initialize.sh check-health.sh
HEALTHCHECK --start-period=15m --interval=2m --retries=5 --timeout=15s CMD ./check-health.sh
CMD ["/bin/bash","./daemon_initialize.sh"]
