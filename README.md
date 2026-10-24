# SandboxAuditor

<<<<<<< HEAD
**SandboxAuditor** is a security orchestration and privilege audit suite designed to automate the provisioning, monitoring, and audit of restricted user environments (such as `/bin/rbash` restricted shells) on Linux systems.

---

## Features

- **Automated Sandbox Provisioning:** Rapidly set up isolated, restricted user accounts (`/bin/rbash`) with tailored environment profiles.
- **Privilege & Exposure Auditing:** Scan home directories and restricted user environments for misconfigurations, writable binaries, broad file permissions, and potential privilege escalation paths.
- **Active Sandbox Management:** Easily inspect, list, or remove sandbox user accounts across the system.
- **System Integration:** Includes global CLI command integration (`SandboxAuditor`) and complete manual pages (`man SandboxAuditor`).

---

## Installation

### Prerequisites

- Linux operating system
- `bash` (version 4.0 or higher)
- `python3`
- Root/`sudo` privileges for installation and administration tasks

### Installing SandboxAuditor

1. **Clone or download the repository:**
   ```bash
   git clone https://github.com/your-repo/SandboxAuditor.git
   cd SandboxAuditor
   ```

2. **Make the installer executable:**
   ```bash
   chmod +x INSTALL
   ```

3. **Run the installation script:**
   ```bash
   sudo ./INSTALL
   ```

   By default, this installs files to `/usr/local`:
   - Global executable launcher: `/usr/local/bin/SandboxAuditor`
   - Internal libraries and scripts: `/usr/local/lib/sandboxauditor/`
   - Manual page: `/usr/local/share/man/man1/SandboxAuditor.1`

   *(Optional)* To install to a custom directory prefix, specify the `PREFIX` environment variable:
   ```bash
   sudo PREFIX=/opt/local ./INSTALL
   ```

---

## Usage

Once installed, you can execute `SandboxAuditor` from any directory without needing `./` notation.

```bash
sudo SandboxAuditor [OPTIONS] [USERNAME]
```

### Options

| Option | Long Option | Description |
| :--- | :--- | :--- |
| `<username>` | *(default)* | Runs a privilege and file exposure audit on the specified user's home directory. |
| `-a` | `--audit <user>` | Explicitly runs privilege and file exposure audit on `<user>`. |
| `-c` | `--create <user>` | Provisions a new restricted user sandbox environment. |
| `-d` | `--delete <user>` | Removes an existing sandbox user account and cleans up their home directory. |
| `-l` | `--list` | Lists all active sandbox users on the system (users with `/bin/rbash` shell). |
| `-h` | `--help` | Displays help information and usage instructions. |

### Usage Examples

- **List active sandbox users:**
  ```bash
  sudo SandboxAuditor --list
  ```

- **Provision a new sandbox user:**
  ```bash
  sudo SandboxAuditor --create guest_user
  ```

- **Audit a sandbox user for privilege leaks and file exposures:**
  ```bash
  sudo SandboxAuditor guest_user
  ```

- **Remove a sandbox user account:**
  ```bash
  sudo SandboxAuditor --delete guest_user
  ```

- **Access complete documentation:**
  ```bash
  man SandboxAuditor
  ```

---

## Uninstallation

To completely remove SandboxAuditor, including its global binary launcher, internal libraries, and installed manual pages from your system, run the `UNINSTALL` script:

1. **Make the uninstaller executable (if not already set):**
   ```bash
   chmod +x UNINSTALL
   ```

2. **Run the uninstaller:**
   ```bash
   sudo ./UNINSTALL
   ```

   *(Optional)* If you installed using a custom prefix, pass the same prefix during uninstallation:
   ```bash
   sudo PREFIX=/opt/local ./UNINSTALL
   ```
=======
A lightweight, defense-in-depth Linux security suite for automated user sandbox provisioning, privilege auditing, and security compliance verification.

## Overview

**SandboxAuditor** provides automated tools to enforce system-level containment and perform continuous privilege auditing on Linux environments. Designed around standard Defense-in-Depth security principles, it automates the creation of restricted user sandboxes and scans filesystem trees for common security misconfigurations and privilege escalation vectors.

### Key Capabilities
- **Automated Sandbox Provisioning:** Rapid creation and cleanup of restricted user environments.
- **Shell Containment:** Enforces Restricted Bash (`rbash`) login shells to limit command execution and directory navigation.
- **Strict Permission Baselines:** Sets default file creation masks (`umask 027`) and locks down directory permissions (`750` root-owned root directory tree).
- **Automated Telemetry & Auditing:** Recursively inspects file modes and attributes to detect security drift, exposed keys, and dangerous permission bitmasks.
- **Structured Findings:** Outputs JSON reports suitable for integration into SIEMs, security monitoring dashboards, or automated reporting pipelines.

---

## Technical Architecture & Security Specifications

### Provisioning Framework (`src/provision_sandbox.sh`)
* **Orchestration Language:** POSIX-compliant Bash (`set -euo pipefail`).
* **Shell Containment:** Resolves or symlinks `/bin/rbash` as the mandatory user shell.
* **Environment Controls:** Appends `umask 027` to `.bashrc`, ensuring default file permissions created by the user evaluate to `750` (`rwxr-x---`) for directories and `640` (`rw-r-----`) for files.
* **Directory Lockdown:** Applies `750` permissions on home directories, retaining `root` ownership to prevent directory tampering or permission escapes.
* **Lifecycle Management:** Supports interactive credential setup and full automated user teardown (`--delete`).

### Privilege Auditor (`src/audit_privileges.py`)
* **Core Engine:** Python 3 standard library (`os`, `stat`, `pwd`, `json`).
* **Identity Resolution:** Dynamically inspects system password entries (`pwd.getpwnam`) to map target usernames to home paths.
* **Traversal Mechanism:** Utilizes `os.walk` to traverse nested directory paths without following external symbolic links (`follow_symlinks=False`).
* **Audit Checks:**
  1. **World-Writable Bits (`WORLD_WRITABLE`):** Evaluates `st_mode` against bitmask `stat.S_IWOTH`.
  2. **Exposed Private Keys (`EXPOSED_PRIVATE_KEY`):** Scans regular files (`stat.S_ISREG`) matching sensitive extensions/naming patterns (`id_*`, `.pem`, `.key`) for group or global read/write/execute bits (`stat.S_IRWXG | stat.S_IRWXO`).

---

## Directory Structure

```text
SandboxAuditor/
├── .gitignore
├── README.md
└── src/
    ├── audit_privileges.py
    └── provision_sandbox.sh
```

---

## Requirements

* **Operating System:** Linux (Ubuntu/Debian, RHEL/Fedora, or general POSIX-compliant Linux systems).
* **Interpreter:** Python 3.x.
* **Privileges:** Root / `sudo` access required for user management and full directory inspection.

---

## Usage Guide

### 1. Installation & Environment Setup

Clone the repository and make the core scripts executable:

```bash
git clone https://github.com/KTStrandPhD/SandboxAuditor.git
cd SandboxAuditor
chmod +x src/provision_sandbox.sh src/audit_privileges.py
```

---

### 2. Sandbox Provisioning

#### Provision a New Sandbox User
To create a restricted user sandbox, run the provisioner script with `sudo` and pass the target username:

```bash
sudo ./src/provision_sandbox.sh sandbox_user
```

**Execution Steps:**
1. Verifies `/bin/rbash` exists (creates a symlink from `/bin/bash` if necessary).
2. Provisions `sandbox_user` with `/bin/rbash` as their default login shell.
3. Prompts interactively for a password with built-in confirmation validation.
4. Enforces `umask 027` in `/home/sandbox_user/.bashrc`.
5. Restricts permissions on `/home/sandbox_user` to `750` (`drwxr-x---`) with `root:sandbox_user` ownership.

#### Teardown a Sandbox User
To remove a sandbox user, clean up their home directory, and delete the user account:

```bash
sudo ./src/provision_sandbox.sh --delete sandbox_user
```

---

### 3. Privilege Auditing

Run `audit_privileges.py` by supplying the username to be audited. The auditor dynamically looks up the home directory path and performs recursive telemetry checks.

```bash
sudo python3 src/audit_privileges.py sandbox_user
```

#### Example JSON Output
If security drift or loose file permissions are detected, the auditor outputs structured JSON findings:

```json
[
  {
    "type": "WORLD_WRITABLE",
    "path": "/home/sandbox_user/public_notes.txt",
    "mode": "777"
  },
  {
    "type": "EXPOSED_PRIVATE_KEY",
    "path": "/home/sandbox_user/.ssh/id_rsa",
    "mode": "644"
  }
]
```

If no security vulnerabilities are detected, the script returns an empty JSON array (`[]`).
>>>>>>> 0722a3cf51377b6b85ffe6cf2bb21cfa37d6e9c4

---

## License

<<<<<<< HEAD
This project is released under the MIT License.
=======
This project is open source and available under the MIT License.
>>>>>>> 0722a3cf51377b6b85ffe6cf2bb21cfa37d6e9c4
