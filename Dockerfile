# First stage is the build environment
FROM opensona/java-oracle:jdk_8 as builder
MAINTAINER Jian Li <gunine@sk.com>

# Set the environment variables
ENV HOME /root
ENV BUILD_NUMBER docker
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
ENV BAZEL_VERSION 1.0.0
ENV ONOS_LATEST_BRANCH onos-1.15
ENV ONOS_VERSION c5bbd3c15e6d4cc715e1dadc9b21ca13c406e241
ENV K8S_BAZEL_BRANCH k8s

# Install dependencies
RUN apt-get update && apt-get install -y git git-review

# Copy in the source
RUN git clone --branch ${ONOS_LATEST_BRANCH} https://gerrit.onosproject.org/onos onos && \
        cd onos && \
	git reset --hard ${ONOS_VERSION} && \
        mkdir -p /src/ && \
        cd ../ && \
        cp -R onos /src/

COPY sona.bzl /src/onos/
RUN sed -i 's/modules.bzl/sona.bzl/g' /src/onos/BUILD

# Download and patch ONOS core changes which affect ONOS
# RUN git clone https://github.com/sonaproject/onos-sona-patch.git patch && \
#    cp patch/${ONOS_VERSION}/*.patch /src/onos/ && \
#    cp patch/patch.sh /src/onos/

WORKDIR /src/onos
# RUN ./patch.sh

# Download latest SONA app sources
WORKDIR /onos
RUN git checkout ${ONOS_LATEST_BRANCH} && \
    cp -R apps/k8s* ../src/onos/apps

# Build ONOS
# We extract the tar in the build environment to avoid having to put the tar
# in the runtime environment - this saves a lot of space
# FIXME - dependence on ONOS_ROOT and git at build time is a hack to work around
# build problems
WORKDIR /src/onos
RUN apt-get update && apt-get install -y zip python git bzip2 build-essential && \
        curl -L -o bazel.sh https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh && \
        chmod +x bazel.sh && \
        ./bazel.sh --user && \
        export ONOS_ROOT=/src/onos && \
        ln -s /usr/lib/jvm/java-8-oracle/bin/jar /etc/alternatives/jar && \
        ln -s /etc/alternatives/jar /usr/bin/jar && \
        ~/bin/bazel build onos --verbose_failures && \
        mkdir -p /src/tar && \
        cd /src/tar && \
        tar -xf /src/onos/bazel-bin/onos.tar.gz --strip-components=1 && \
        rm -rf /src/onos/bazel-* .git

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

# Configure ONOS to activate HTTPS
# RUN sed -ibak 's/org.osgi.service.http.secure.enabled=false/org.osgi.service.http.secure.enabled=true/g' $(ls -d apache-karaf-*)/etc/org.ops4j.pax.web.cfg
# RUN sed -ibak 's/OBF:1xtn1w1u1uob1xtv1y7z1xtn1unn1w1o1xtv/onos-sona/g' $(ls -d apache-karaf-*)/etc/org.ops4j.pax.web.cfg
# RUN sed -ibak 's/etc\/keystore/..\/keystore\/keystore.jks/g' $(ls -d apache-karaf-*)/etc/org.ops4j.pax.web.cfg

LABEL org.label-schema.name="ONOS" \
      org.label-schema.description="SDN Controller" \
      org.label-schema.usage="http://wiki.onosproject.org" \
      org.label-schema.url="http://onosproject.org" \
      org.label-scheme.vendor="Open Networking Foundation" \
      org.label-schema.schema-version="1.0"

RUN   touch apps/org.onosproject.drivers/active && \
      touch apps/org.onosproject.openflow-base/active && \
      touch apps/org.onosproject.k8s-networking/active

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
