#!/usr/bin/env bash
set -euo pipefail

start(){
	download_files "/tmp/clientInstallationFiles"
	install_client
}

download_files() {
    local base_url="http://backup-files-apache.backup-install-files.svc.cluster.local"
    local output_dir="${1:-.}"  # Optional output directory, defaults to current directory
    
    local files=(
        "gskcrypt64-8.0.60.5.linux.x86_64.rpm"
        "gskssl64-8.0.60.5.linux.x86_64.rpm"
        "TIVsm-API64.x86_64.rpm"
        "TIVsm-BA.x86_64.rpm"
        "TIVsm-BAhdw.x86_64.rpm"
    )
    
    for file in "${files[@]}"; do
        echo "Downloading: $file"
        curl -f -O --output-dir "$output_dir" "$base_url/$file"
        if [ $? -eq 0 ]; then
            echo "✓ Successfully downloaded: $file"
        else
            echo "✗ Failed to download: $file"
            return 1
        fi
    done
    
    echo "All files downloaded to: $output_dir"
}

install_client(){
	cd /tmp/clientInstallationFiles
	rpm -Uvh --nosignature \
      gskcrypt64-8.0.60.5.linux.x86_64.rpm \
      gskssl64-8.0.60.5.linux.x86_64.rpm \
      TIVsm-API64.x86_64.rpm \
      TIVsm-BA.x86_64.rpm \
      TIVsm-BAhdw.x86_64.rpm \
      --nodeps \
      --noposttrans

	# Dynamic linker paths for TSM + GSKit
	ldconfig || true

	ln -sf /etc/tivoli/dsm.opt /opt/tivoli/tsm/client/ba/bin/dsm.opt
	ln -sf /etc/tivoli/dsm.sys /opt/tivoli/tsm/client/ba/bin/dsm.sys
}

start();