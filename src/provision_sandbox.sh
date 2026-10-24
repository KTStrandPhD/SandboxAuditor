
#!/usr/bin/env bash
#
# provision_sandbox.sh - Provision or delete a restricted user sandbox
# Usage:
#   Provision user:  sudo ./provision_sandbox.sh <username>
#   Delete user:     sudo ./provision_sandbox.sh --delete <username>
#   Help:            ./provision_sandbox.sh --help
#

set -euo pipefail

# ==============================================================================
# Helper Functions
# ==============================================================================
show_help() {
  cat << 'EOF'
Sandbox Provisioner - Provision and manage restricted user sandboxes

Usage:
  sudo ./provision_sandbox.sh [OPTIONS] <username>

Options:
  <username>           Provision a new restricted sandbox user account.
  -d, --delete         Remove an existing sandbox user and clean up home directory.
  -h, --help           Display this help message and exit.

Examples:
  sudo ./provision_sandbox.sh testuser
  sudo ./provision_sandbox.sh --delete testuser
  ./provision_sandbox.sh --help
EOF
}

# ==============================================================================
# Argument Validation & Help Processing
# ==============================================================================
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  show_help
  exit 0
fi

# Ensure all administrative actions are executed with root privileges
if [[ $EUID -ne 0 ]]; then
  echo "[-] Error: This script must be run as root." >&2
  exit 1
fi

# ==============================================================================
# Deletion Workflow (--delete or -d)
# ==============================================================================
if [[ "${1:-}" == "--delete" || "${1:-}" == "-d" ]]; then
  shift
  TARGET_USER="${1:-}"

  if [[ -z "${TARGET_USER}" ]]; then
    echo "[-] Error: Username required for deletion." >&2
    echo "[-] Usage: $0 --delete <username>" >&2
    exit 1
  fi

  if id "${TARGET_USER}" &>/dev/null; then
    echo "[*] Removing user '${TARGET_USER}' and their home directory..."

    # Retrieve home directory before deleting user entry
    USER_HOME=$(eval echo "~${TARGET_USER}")

    # Remove user from system
    userdel "${TARGET_USER}"

    # Safely remove root-owned home directory
    if [[ -d "${USER_HOME}" && "${USER_HOME}" != "/" ]]; then
      rm -rf "${USER_HOME}"
      echo "[+] Successfully removed home directory: ${USER_HOME}"
    fi

    echo "[+] Successfully deleted sandbox user: ${TARGET_USER}"
  else
    echo "[-] Error: User '${TARGET_USER}' does not exist on this system." >&2
    exit 1
  fi
  exit 0
fi

# ==============================================================================
# Provisioning Workflow
# ==============================================================================
TARGET_USER="${1:-}"

if [[ -z "${TARGET_USER}" ]]; then
  echo "[-] Error: Username required for provisioning." >&2
  echo "[-] Usage: $0 <username> OR $0 --delete <username>" >&2
  exit 1
fi

# Ensure restricted bash (/bin/rbash) exists on host system
if [[ ! -e /bin/rbash ]]; then
  echo "[*] /bin/rbash not found. Creating symbolic link to bash..."
  if [[ -f /bin/bash ]]; then
    ln -s /bin/bash /bin/rbash
  elif [[ -f /usr/bin/bash ]]; then
    ln -s /usr/bin/bash /bin/rbash
  else
    echo "[-] Error: Base bash binary not found. Cannot create rbash link." >&2
    exit 1
  fi
  echo "[+] Successfully created /bin/rbash symlink."
fi

echo "[+] Creating restricted user: ${TARGET_USER}"

# Create restricted account if it does not exist
if ! id "${TARGET_USER}" &>/dev/null; then
  useradd -m -s /bin/rbash "${TARGET_USER}"

  echo "[+] Please set a password for ${TARGET_USER}:"
  passwd "${TARGET_USER}"

  echo "[+] User '${TARGET_USER}' created successfully with restricted shell."
else
  echo "[*] User '${TARGET_USER}' already exists. Updating environment configuration..."
fi

# Resolve home directory path
USER_HOME=$(eval echo "~${TARGET_USER}")
BASHRC_PATH="${USER_HOME}/.bashrc"

# Ensure .bashrc exists
touch "${BASHRC_PATH}"

# Enforce strict umask (027 -> rwxr-x--- default for new files)
if ! grep -q "^umask 027" "${BASHRC_PATH}"; then
  {
    echo ""
    echo "# Enforce strict umask for security"
    echo "umask 027"
  } >> "${BASHRC_PATH}"
  echo "[+] Added umask 027 to ${BASHRC_PATH}"
fi

# Harden home directory permissions
# Root owns the directory structure; target user has read/execute, others denied
chown -R root:"${TARGET_USER}" "${USER_HOME}"
chmod 750 "${USER_HOME}"

echo "[+] Provisioning complete. Sandbox ready for ${TARGET_USER}."
