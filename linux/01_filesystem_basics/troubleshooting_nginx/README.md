# Linux Module: Assignment 1.2 - Nginx Troubleshooting

**Objective:** Practice filesystem navigation, file searching, and problem diagnosis skills by investigating a non-running Nginx configuration.

## Problem Scenario

Imagine you are working on a server where Nginx is installed. After recent changes, the Nginx service failed to start. Your task is to find the cause of the problem and fix it using:

- Check the Nginx configuration syntax using the `nginx -t` command. This command is very useful for quick checks.
- Restart the Nginx service (`systemctl restart nginx`).
- Verify that the service is successfully running (`systemctl status nginx`).

## Expected Outcome

The Nginx service starts successfully after fixing the configuration problem. You should clearly understand which file caused the issue, where it was located, and how you identified it.

## Assignment

1. **Preparation:**
   - Ensure you have access to a server terminal with Nginx installed (or install Nginx locally).
   - Navigate to the `linux/01_filesystem_basics/troubleshooting_nginx` directory.
   - Execute the `sudo ./setup.sh.x` script located in this directory. **ATTENTION:** This script will make changes to system files (install Nginx if not present, modify configuration).
   - After running `sudo ./setup.sh.x`, try checking the Nginx service status (`systemctl status nginx`) and confirm it is not running and shows an error.

2. **Diagnosis and Searching:**
   - Use navigation commands (`cd`, `pwd`, `ls`) to move around the filesystem and inspect directory contents.
   - Use commands to view system logs (`journalctl`) and Nginx-specific logs (usually in `/var/log/nginx/`) to find the cause of the startup error. Logs often point to the problem.
   - Examine Nginx configuration files (the main `/etc/nginx/nginx.conf` and included files). Pay attention to lines that might include other files.
   - Use search commands (`find`, `grep`) to locate modified or new Nginx configuration files in non-obvious locations on the filesystem.

3. **Troubleshooting:**
   - Find the file(s) with the incorrect configuration using information from logs and search results.
   - Correct the syntax or logical error in the configuration file.

