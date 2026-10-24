# SandboxAuditor

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

---

## License

This project is released under the MIT License.