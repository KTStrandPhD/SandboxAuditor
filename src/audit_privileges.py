#!/usr/bin/env python3
import os
import sys
import stat
import pwd
import json

def audit_user_home(username):
    try:
        # Get user entry from system password database
        user_info = pwd.getpwnam(username)
        target_dir = user_info.pw_dir
    except KeyError:
        print(f"[-] Error: User '{username}' does not exist on this system.", file=sys.stderr)
        sys.exit(1)

    if not os.path.exists(target_dir):
        print(f"[-] Error: Home directory '{target_dir}' does not exist.", file=sys.stderr)
        sys.exit(1)

    print(f"[*] Auditing home directory for '{username}' at: {target_dir}")
    
    findings = []

    for root, dirs, files in os.walk(target_dir):
        # Combine files and dirs to check everything
        all_items = files + dirs
        for item in all_items:
            filepath = os.path.join(root, item)
            
            # Skip symlinks to avoid following links outside the sandbox
            if os.path.islink(filepath):
                continue

            try:
                st = os.stat(filepath, follow_symlinks=False)
                mode = st.st_mode
            except (PermissionError, FileNotFoundError):
                continue

            # Check 1: World-writable files/folders
            if mode & stat.S_IWOTH:
                findings.append({
                    "type": "WORLD_WRITABLE",
                    "path": filepath,
                    "mode": oct(mode)[-3:]
                })

            # Check 2: Exposed private keys (files matching typical private key patterns)
            if stat.S_ISREG(mode) and (item.startswith("id_") or item.endswith(".pem") or item.endswith(".key")):
                # If group or others have any read/write/execute access
                if mode & (stat.S_IRWXG | stat.S_IRWXO):
                    findings.append({
                        "type": "EXPOSED_PRIVATE_KEY",
                        "path": filepath,
                        "mode": oct(mode)[-3:]
                    })

    # Output structured JSON report
    print(json.dumps(findings, indent=2))

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"[-] Usage: python3 {sys.argv[0]} <username>", file=sys.stderr)
        sys.exit(1)
    
    audit_user_home(sys.argv[1])
