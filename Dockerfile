FROM ubuntu:22.04

# Set non-interactive frontend for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies, including Node.js and npm
RUN apt-get update -y && apt-get install -y \
  curl build-essential python3 python3-pip python3-distutils \
  git cmake jq tar pv pwgen bc libzmq3-dev \
  nodejs npm \
  && apt-get clean \
  && echo "Dependencies and Node.js installed"

# Set PATH to include /usr/bin explicitly, ensuring Node.js and npm are found
ENV PATH=/usr/bin:$PATH

# Verify Node.js version
RUN node --version && npm --version

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

# Use ENTRYPOINT to run the script in a new shell, ensuring environment variables are available
CMD ["/bin/bash", "-c", "/daemon_initialize.sh"]
