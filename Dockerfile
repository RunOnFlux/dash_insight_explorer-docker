FROM ubuntu:22.04

# Set non-interactive frontend for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt update -y && apt install -y \
  curl build-essential python3 python3-pip python3-distutils \
  git cmake jq tar pv pwgen bc libzmq3-dev \
  && apt-get install -y npm \
  && echo "Dependencies installed"

# Install NVM (Node Version Manager)
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Install Node.js via NVM and ensure it is available in the path
RUN export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install 18 && \
    nvm use 18 && \
    nvm alias default 18 && \
    echo "Node.js and npm installed using NVM"

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
