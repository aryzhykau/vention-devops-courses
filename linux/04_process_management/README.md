# Assignment 4: Working with Processes

In this assignment, you will learn how to view running processes, manage them, and run commands in the background and foreground in Linux-based operating systems.

## Assignment Goal

nano linux/04_process_management/README.md
Understand the process lifecycle, learn to use various utilities for monitoring and managing processes, and master methods for controlling command execution in background and foreground modes.

## Tasks

1. **Viewing Processes:**
    * Use the `ps`, `top` (or `htop` if available) commands to list running processes.
    * Find information about a specific process by its name or PID.
    * Filter the output of `ps` commands to display processes for a specific user or with a particular status.
2. **Managing Processes:**
    * Start a simple command (e.g., `sleep 60`) and find its PID.
    * Terminate the process using the `kill` command with its PID.
    * Use the `killall` or `pkill` commands to terminate processes by their name.
nano linux/04_process_management/README.md
3. **Managing Command Execution:**
    * Run a command in the background (`&`).
    * Use the `jobs` command to view background jobs.
    * Bring a background job to the foreground (`fg`).
    * Move a foreground job to the background (`Ctrl+Z` and `bg`).

---

# Troubleshooting Scenarios

## Scenario 1: High CPU Usage

To simulate a high CPU usage scenario, you can run the following command:

```bash
cd linux/04_process_management/troubleshooting/scenario1
chmod +x setup.sh
./setup.sh
nano linux/04_process_management/README.md
