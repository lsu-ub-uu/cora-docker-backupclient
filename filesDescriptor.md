# IBM Spectrum Protect client Docker image: file mapping and expected runtime behavior

This document explains how the current Docker image is assembled, where each IBM Spectrum Protect client file is placed, and what role each file plays at runtime.

The container is intended to be **ready to run**: it includes the IBM Spectrum Protect client binaries, the required runtime libraries, and the client-side configuration and security material needed for backup/archive operations.

---

## Docker image purpose

This image packages an IBM Spectrum Protect Backup-Archive client inside a minimal Red Hat UBI 9 base image.

At build time, the Docker image:

- installs the OS libraries required by the IBM client,
- extracts the IBM client installation archive,
- installs the Spectrum Protect packages,
- copies client configuration files into their expected locations,
- prepares certificate/key database files required for secure communication,
- creates the standard client configuration layout under `/opt/tivoli/tsm/client/ba/bin` and `/etc/tivoli`.

The result is a container that can start with the IBM Spectrum Protect command-line client available and with the expected runtime files already in place.

---

## Runtime file layout

The image arranges files into two main areas:

- **`/opt/tivoli/tsm/client/ba/bin`**  
  Standard IBM Spectrum Protect Backup-Archive client runtime directory.

- **`/etc/tivoli`**  
  Container-local location for the main operational configuration files.

The Dockerfile also creates a temporary extraction area:

- **`/tmp/clientInstallationFiles`**  
  Used only during image build to unpack and install the IBM packages.

---

## What each file is for


---

### `docker/files/clientInstallationFiles/8.2.2.0-TIV-TSMBAC-Custom-NoWebGUI.tar.gz`

This archive contains the IBM Spectrum Protect client installation media.

It is unpacked during the build and provides the RPM packages that are installed into the image.


#### Role of these packages

- **GSKit cryptography and SSL packages** provide cryptographic and TLS support.
- **TIVsm-API64** provides the API libraries used by IBM Spectrum Protect client integrations.
- **TIVsm-BA** provides the Backup-Archive client binaries.
- **TIVsm-BAhdw** provides additional client support components used by the installed package set.

---

### `docker/files/clientConfiguration/tivoli.conf`

This file is copied to:

- `/etc/ld.so.conf.d/tivoli.conf`

Its role is to make the IBM Spectrum Protect libraries visible to the Linux dynamic linker.

In practice, this helps the container find shared libraries installed by the IBM packages at runtime.

#### Why it matters

Without the correct linker path configuration, the client binaries may fail to start because required shared libraries cannot be resolved.

---

### `docker/files/clientConfiguration/dsmcert.idx`

This is an index file for the certificate/key database copied to:

- `/opt/tivoli/tsm/client/ba/bin/dsmcert.idx`

It is part of the client security material and supports access to the certificate database.

#### Purpose

- Helps the client locate and use the certificate database.
- Is usually managed together with the matching `.kdb` and `.sth` files.

---

### `docker/files/clientConfiguration/dsmcert.kdb`

This is the certificate/key database copied to:

- `/opt/tivoli/tsm/client/ba/bin/dsmcert.kdb`

#### Purpose

- Stores certificates and trust information used by the IBM Spectrum Protect client.
- Is required when secure communication is configured.

#### Notes

This is sensitive security material and should be treated as protected runtime data.

---

### `docker/files/clientConfiguration/dsmcert.sth`

This is the stash file copied to:

- `/opt/tivoli/tsm/client/ba/bin/dsmcert.sth`

#### Purpose

- Stores the obfuscated password used to open `dsmcert.kdb` automatically.
- Allows the client to use the certificate database without interactive password entry.

#### Notes

This file is sensitive and must be protected.

---

### `docker/files/tivoli/dsm.opt`

This is the IBM Spectrum Protect client options file.

It is copied into:

- `/etc/tivoli/dsm.opt`

and then linked to:

- `/opt/tivoli/tsm/client/ba/bin/dsm.opt`

#### Purpose

- Holds client runtime options.
- Points the client to the correct server and configuration inputs.
- May include references to include/exclude definitions and other client behavior settings.

#### Why it matters

This file is one of the primary controls for how the client runs.

---

### `docker/files/tivoli/dsm.sys`

This is the system/server definition file.

It is copied into:

- `/etc/tivoli/dsm.sys`

and then linked to:

- `/opt/tivoli/tsm/client/ba/bin/dsm.sys`

#### Purpose

- Defines the IBM Spectrum Protect server connection settings.
- Typically contains node identity, communication settings, and secure communication configuration.
- Drives how the client connects to the backup infrastructure.

#### Why it matters

This is one of the core runtime configuration files for the client.

---

### `docker/files/tivoli/inclexcl.def`

This is the include/exclude definition file copied into:

- `/etc/tivoli/inclexcl.def`

#### Purpose

- Defines what should be included or excluded from backup.
- Controls the scope of what the client protects.

#### Why it matters

This file directly affects backup behavior and data selection rules.

---

### `docker/files/tivoli/TSM.IDX`

This is an index file associated with the TSM key database files.

#### Purpose

- Supports access to the encrypted key/password database.
- Works together with `TSM.KDB` and `TSM.sth`.

#### Notes

This file is part of the security data set and should be considered sensitive operational material.

---

### `docker/files/tivoli/TSM.KDB`

This is the key database file.

#### Purpose

- Stores encrypted security material used by the client.
- May contain trusted certificates and/or credentials needed by the IBM Spectrum Protect runtime.

#### Notes

This is sensitive and should not be handled as plain configuration.

---

### `docker/files/tivoli/TSM.sth`

This is the stash file for the TSM key database.

#### Purpose

- Stores the protected password used to unlock `TSM.KDB` automatically.
- Supports non-interactive operation.

#### Notes

This file is sensitive and should be protected carefully.

---

## `tivoli/Nodes/EPC-DVP1/`

This directory appears to store **node-specific certificate data** for the client node `EPC-DVP1`.

### `spclicert.crl`
- **What it is:** Certificate revocation list file.
- **Purpose:** Used to validate whether related certificates have been revoked.
- **Notes:** Security-related supporting file.

### `spclicert.kdb`
- **What it is:** Node-specific GSKit key database.
- **Purpose:** Stores certificate material specific to this node/client identity.
- **Notes:** Likely created or updated during node registration or secure setup.

### `spclicert.rdb`
- **What it is:** Supporting runtime database file.
- **Purpose:** Internal support file associated with the node certificate database.
- **Notes:** Managed by the client/GSKit tooling.

### `spclicert.sth`
- **What it is:** Stash file for `spclicert.kdb`.
- **Purpose:** Stores the obfuscated password required to open the node-specific key database automatically.
- **Notes:** Sensitive file.

---

## Final summary

This Docker image packages an IBM Spectrum Protect client into a minimal container and lays out the files so the client can run immediately.

The important runtime relationships are:

- `dsm.opt` and `dsm.sys` define how the client behaves and connects.
- `inclexcl.def` defines what data is in scope.
- `dsmcert.*` and `TSM.*` provide certificate and key database support for secure and automated operation.
- `tivoli.conf` ensures the installed libraries are discoverable by the system linker.
- The installation archive provides the IBM binaries and dependencies needed by the client.

This is the expected structure and behavior of the Docker image in its current form.

## File extension quick reference

### `.deb`
Meaning: Debian package.  
Purpose: Installs software.

### `.sh`
Meaning: Shell script.  
Purpose: Automates installation or setup.

### `.opt`
Meaning: Tivoli client options.  
Purpose: Runtime client options.

### `.sys`
Meaning: Tivoli system config.  
Purpose: Server and communication settings.

### `.def`
Meaning: Definition file.  
Purpose: Include/exclude backup rules.

### `.kdb`
Meaning: GSKit key database.  
Purpose: Certificates, keys, trust material.

### `.sth`
Meaning: Stash file.  
Purpose: Stored password for opening `.kdb`.

### `.idx` / `.IDX`
Meaning: Index file.  
Purpose: Supports certificate database access.

### `.rdb`
Meaning: Runtime/support database.  
Purpose: Internal support data.

### `.crl`
Meaning: Certificate revocation list.  
Purpose: Revocation checking.

### `.conf`
Meaning: Generic config file.  
Purpose: Custom environment/config settings.

---
