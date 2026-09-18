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
        shadow-utils && \
    microdnf clean all && \
    rm -rf /var/cache/{yum,dnf}

# Prepare directories
RUN mkdir -p /tmp/clientInstallationFiles \
    /opt/tivoli/tsm/client/ba/bin \
    /etc/tivoli

# Copy install media and config
#COPY files/clientInstallationFiles/ /tmp/clientInstallationFiles/
#COPY files/clientConfiguration/tivoli.conf /etc/ld.so.conf.d/tivoli.conf
#COPY files/clientConfiguration/dsmcert.idx /opt/tivoli/tsm/client/ba/bin/dsmcert.idx
#COPY files/clientConfiguration/dsmcert.sth /opt/tivoli/tsm/client/ba/bin/dsmcert.sth
#COPY files/clientConfiguration/dsmcert.kdb /opt/tivoli/tsm/client/ba/bin/dsmcert.kdb
#COPY files/tivoli/ /etc/tivoli/


# Extract and install TSM packages
# - API64 is required by BA
# - fallback to --nodeps for container-only environments (missing libgpfs/libdmapi)
#RUN cd /tmp/clientInstallationFiles && \
#    tar -xzf 8.2.2.0-TIV-TSMBAC-Custom-NoWebGUI.tar.gz && \
#    rpm -Uvh --nosignature \
#      gskcrypt64-8.0.60.5.linux.x86_64.rpm \
#      gskssl64-8.0.60.5.linux.x86_64.rpm \
#      TIVsm-API64.x86_64.rpm \
#      TIVsm-BA.x86_64.rpm \
#      TIVsm-BAhdw.x86_64.rpm \
#      --nodeps \
#      --noposttrans

# Dynamic linker paths for TSM + GSKit
#RUN ldconfig || true

# Set up entrypoint
COPY files/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Link BA client config to /etc/tivoli
# (TSM client typically reads these in ba/bin)
#Moved to entrypoint
#RUN ln -sf /etc/tivoli/dsm.opt /opt/tivoli/tsm/client/ba/bin/dsm.opt && \
#    ln -sf /etc/tivoli/dsm.sys /opt/tivoli/tsm/client/ba/bin/dsm.sys