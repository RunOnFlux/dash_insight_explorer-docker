FROM ubuntu:22.04

# Set non-interactive frontend for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies and Node.js
RUN apt update -y && apt install -y \
  curl build-essential python3 python3-pip python3-distutils \
  git cmake jq tar pv pwgen bc libzmq3-dev npm \
  && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs \
  && echo "Node.js and npm installed at:" \
  && which node \
  && which npm \
  && node -v \
  && npm -v \
  && echo "Ensure Node.js is in the PATH"

# Add Node.js to PATH explicitly (if it's not in /usr/bin/)
ENV PATH=$PATH:/usr/local/bin

# Copy initialization and health check scripts into the container
COPY daemon_initialize.sh /daemon_initialize.sh
COPY check-health.sh /check-health.sh

# Set volume for dashcore data
VOLUME /root/.dashcore

# Expose the necessary port
EXPOSE 3001/tcp

# Set executable permissions for the copied scripts
RUN chmod 755 /daemon_initialize.sh /check-health.sh

# Set health check command to monitor the health of the container
HEALTHCHECK --start-period=15m --interval=2m --retries=5 --timeout=15s CMD /check-health.sh

# Default command to run the daemon initialization script
CMD ["/bin/bash", "/daemon_initialize.sh"]
