# First stage is the build environment
FROM sgrio/java-oracle:jdk_8 as builder
MAINTAINER Jian Li <gunine@sk.com>

# Set the environment variables
ENV HOME /root
ENV BUILD_NUMBER docker
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8

# Configure JAR path
RUN update-alternatives --install "/usr/bin/jar" "jar" "${JAVA_HOME}/bin/jar" 1 && \
    update-alternatives --set jar "${JAVA_HOME}/bin/jar"

# Install dependencies
RUN apt-get update && apt-get install -y git

# Copy in the source
RUN git clone https://gerrit.onosproject.org/onos onos && \
        mkdir -p /src/ && \
        cp -R onos /src/

# Download SONA buck definition file
RUN git clone https://github.com/sonaproject/onos-sona-bazel-defs.git bazel-defs
RUN cp bazel-defs/sona.bzl /src/onos/
RUN sed -i 's/modules.bzl/sona.bzl/g' /src/onos/BUILD

# Install Bazel build tool
RUN apt-get update && apt-get install -y pkg-config zip g++ zlib1g-dev unzip python bzip2 wget && \
        wget https://github.com/bazelbuild/bazel/releases/download/0.15.2/bazel-0.15.2-installer-linux-x86_64.sh && \
        chmod +x bazel-0.15.2-installer-linux-x86_64.sh && ./bazel-0.15.2-installer-linux-x86_64.sh --user

# Build ONOS
# We extract the tar in the build environment to avoid having to put the tar
# in the runtime environment - this saves a lot of space
# FIXME - dependence on ONOS_ROOT and git at build time is a hack to work around
# build problems
WORKDIR /src/onos
RUN export ONOS_ROOT=/src/onos && \
        /root/bin/bazel build onos && \
        mkdir -p /src/tar && \
        cd /src/tar && \
        tar -xf /src/onos/bazel-bin/onos.tar.gz --strip-components=1 && \
        rm -rf /src/onos/bazel-bin .git

# Second stage is the runtime environment
FROM anapsix/alpine-java:8_server-jre

# Change to /root directory
RUN apk update && \
        apk add curl && \
        mkdir -p /root/onos
WORKDIR /root/onos

# Install ONOS
COPY --from=builder /src/tar/ .

# Configure ONOS to log to stdout
RUN sed -ibak '/log4j.rootLogger=/s/$/, stdout/' $(ls -d apache-karaf-*)/etc/org.ops4j.pax.logging.cfg

LABEL org.label-schema.name="ONOS" \
      org.label-schema.description="SDN Controller" \
      org.label-schema.usage="http://wiki.onosproject.org" \
      org.label-schema.url="http://onosproject.org" \
      org.label-scheme.vendor="Open Networking Foundation" \
      org.label-schema.schema-version="1.0"

RUN   touch apps/org.onosproject.drivers/active && \
      touch apps/org.onosproject.openflow-base/active && \
      touch apps/org.onosproject.openstacknetworking/active && \
      touch apps/org.onosproject.openstacktroubleshoot/active

# Ports
# 6653 - OpenFlow
# 6640 - OVSDB
# 8181 - GUI
# 8101 - ONOS CLI
# 9876 - ONOS intra-cluster communication
EXPOSE 6653 6640 8181 8101 9876

# Get ready to run command
ENTRYPOINT ["./bin/onos-service"]
CMD ["server"]
