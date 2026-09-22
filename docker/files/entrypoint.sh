#!/usr/bin/env bash
set -euo pipefail

start(){
	download_files "/tmp/clientInstallationFiles"
	install_client
	verify_installation
	copy_and_apply_keys_config_files
	run_backup
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
	    if curl -f -O --output-dir "$output_dir" "$base_url/$file"; then
	        echo "✓ Successfully downloaded: $file"
	    else
	        echo "✗ Failed to download: $file"
	        return 1
	    fi
	done
    
    echo "⇒ All files downloaded to: $output_dir"
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
}

verify_installation(){
	local packages=(
		"gskcrypt64"
		"gskssl64"
		"TIVsm-API64"
		"TIVsm-BA"
		"TIVsm-BAhdw"
	)

	local missing=()

	for pkg in "${packages[@]}"; do
		if rpm -q "$pkg" >/dev/null 2>&1; then
			echo "✓ Verified installed: $pkg ($(rpm -q "$pkg"))"
		else
			echo "✗ Package not registered as installed: $pkg"
			missing+=("$pkg")
		fi
	done

	if [ "${#missing[@]}" -ne 0 ]; then
		echo "Installation verification failed for: ${missing[*]}"
		return 1
	fi

	echo "⇒ All packages verified as installed."
}

copy_and_apply_keys_config_files(){
	echo "⇒ Copying config files and keys"
	cp -r /tmp/opt/tivoli/tsm/client/ba/bin/. /opt/tivoli/tsm/client/ba/bin/
	cp -r /tmp/etc/ld.so.conf.d/. /etc/ld.so.conf.d
	
	echo "⇒ Apply config files"
	# Dynamic linker paths for TSM + GSKit
	ldconfig || true

#	ln -sf /etc/tivoli/dsm.opt /opt/tivoli/tsm/client/ba/bin/dsm.opt
#	ln -sf /etc/tivoli/dsm.sys /opt/tivoli/tsm/client/ba/bin/dsm.sys
}

run_backup(){
	echo "⇒ Start backup"
	echo "TMP: starting with a nap! zZzzZzzZzzZz "
	sleep inf
}

start