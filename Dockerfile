ARG JDK_VER=11
ARG JOBS=2
ARG BAZEL_VER=2.0.0
# First stage is the build environment
FROM azul/zulu-openjdk:${JDK_VER} as builder
MAINTAINER Jian Li <gunine@sk.com>

# Set the environment variables
ENV HOME /root
ENV BUILD_NUMBER docker
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
ENV ONOS_BRANCH onos-2.2

# Install dependencies
ENV BUILD_DEPS \
    ca-certificates \
    zip \
    python \
    python3 \
    git \
    bzip2 \
    build-essential \
    curl \
    unzip
RUN apt-get update && apt-get install -y ${BUILD_DEPS}

# Install Bazel
ARG BAZEL_VER
RUN curl -L -o bazel.sh https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VER}/bazel-${BAZEL_VER}-installer-linux-x86_64.sh
RUN chmod +x bazel.sh && ./bazel.sh

# Copy in the source
RUN git clone --branch ${ONOS_BRANCH} https://github.com/opennetworkinglab/onos.git onos && \
        mkdir /src && \
	cp -R onos /src/onos

RUN ls /src/onos

COPY sona.bzl /src/onos/tools/build/bazel/sona.bzl
RUN sed -i 's/modules.bzl/sona.bzl/g' /src/onos/BUILD

# Build ONOS
# We extract the tar in the build environment to avoid having to put the tar
# in the runtime environment - this saves a lot of space
# FIXME - dependence on ONOS_ROOT and git at build time is a hack to work around
# build problems
WORKDIR /src/onos

ARG JOBS
ARG JDK_VER

RUN bazel build onos \
    --jobs ${JOBS} \
    --verbose_failures \
    --javabase=@bazel_tools//tools/jdk:absolute_javabase \
    --host_javabase=@bazel_tools//tools/jdk:absolute_javabase \
    --define=ABSOLUTE_JAVABASE=/usr/lib/jvm/zulu-${JDK_VER}-amd64

# We extract the tar in the build environment to avoid having to put the tar in
# the runtime stage. This saves a lot of space.
RUN mkdir /output
RUN tar -xf bazel-bin/onos.tar.gz -C /output --strip-components=1

# Second stage is the runtime environment
FROM azul/zulu-openjdk:${JDK_VER}

LABEL org.label-schema.name="ONOS" \
      org.label-schema.description="SDN Controller" \
      org.label-schema.usage="http://wiki.onosproject.org" \
      org.label-schema.url="http://onosproject.org" \
      org.label-scheme.vendor="Open Networking Foundation" \
      org.label-schema.schema-version="1.0"

RUN apt-get update && apt-get install -y curl && \
	rm -rf /var/lib/apt/lists/*

# Install ONOS in /root/onos
COPY --from=builder /output/ /root/onos/
WORKDIR /root/onos

# Set JAVA_HOME (by default not exported by zulu images)
ARG JDK_VER
ENV JAVA_HOME /usr/lib/jvm/zulu-${JDK_VER}-amd64

# Ports
# 6653 - OpenFlow
# 6640 - OVSDB
# 8181 - GUI
# 8101 - ONOS CLI
# 9876 - ONOS intra-cluster communication
EXPOSE 6653 6640 8181 8101 9876

RUN   touch apps/org.onosproject.gui2/active && \
      touch apps/org.onosproject.drivers/active && \
      touch apps/org.onosproject.drivers.ovsdb/active && \
      touch apps/org.onosproject.openflow-base/active && \
      touch apps/org.onosproject.openstacknetworking/active && \
      touch apps/org.onosproject.openstacktroubleshoot/active

# Get ready to run command
ENTRYPOINT ["./bin/onos-service"]
CMD ["server"]
