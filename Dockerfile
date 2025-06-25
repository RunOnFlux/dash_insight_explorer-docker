FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade && apt-get install -y \
    wget curl jq gnupg lsb-release dirmngr tar pv pwgen bc build-essential libzmq3-dev git npm \
    rm -rf /var/lib/apt/lists/*

COPY daemon_initialize.sh /daemon_initialize.sh
COPY check-health.sh /check-health.sh
VOLUME /root/.dashcore
EXPOSE 3001/tcp
RUN chmod 755 daemon_initialize.sh check-health.sh
HEALTHCHECK --start-period=15m --interval=2m --retries=5 --timeout=15s CMD ./check-health.sh
CMD ["/bin/bash","./daemon_initialize.sh"]
