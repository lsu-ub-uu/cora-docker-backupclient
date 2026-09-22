FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

# Install base runtime dependencies
RUN microdnf -y update && \
    microdnf -y install \
        ca-certificates \
        perl \
        glibc \
        libstdc++ \
        libX11 \
        libXext \
        libXtst \
        libXi \
        gtk2 \
        pam \
        nano \
        tar \
        gzip \
        findutils \
		ps \
        shadow-utils && \
    microdnf clean all && \
    rm -rf /var/cache/{yum,dnf}

# Prepare directories
RUN mkdir -p /tmp/clientInstallationFiles \
    /opt/tivoli/tsm/client/ba/bin

# Set up entrypoint
COPY files/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

