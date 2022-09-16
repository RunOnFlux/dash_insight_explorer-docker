FROM debian:buster-slim
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
apt-get install -y wget curl jq lsb-release libzmq3-dev python3 gnupg dirmngr unzip tar pv build-essential

COPY daemon_initialize.sh /daemon_initialize.sh
COPY check-health.sh /check-health.sh
VOLUME /root/.dashcore
EXPOSE 3001/tcp
RUN chmod 755 daemon_initialize.sh check-health.sh
HEALTHCHECK --start-period=15m --interval=2m --retries=5 --timeout=15s CMD ./check-health.sh
CMD ./daemon_initialize.sh
