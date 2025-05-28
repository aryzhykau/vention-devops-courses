# Assignment 2 – File Permissions and Special Bits

## Regular Permissions
- Modified permissions using `chmod` and `umask`
- Changed ownership using `chown` and `chgrp`

## Special Permissions
- SUID: Used for privileged binaries like `/usr/bin/passwd`
- SGID: Applied to group-managed folders
- Sticky Bit: Used on shared writable directories like `/tmp`

## Troubleshooting
- Used sample files and directories in `special_permissions_test/`
- Verified permissions with `ls -l` and `stat`
