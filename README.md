# sysmonitor

A GUI-based system monitoring tool for Linux, built entirely in Bash. It provides real-time resource usage stats and system info through a clean Zenity dialog interface — no terminal clutter required.

---

## Features

- **Basic System Information** — architecture, CPU model, core/thread count, frequencies, RAM summary, and kernel info
- **CPU Usage** — per-core utilization with ASCII progress bars, refreshed at a configurable interval
- **RAM Usage** — live used/available memory displayed as progress bars
- **GPU VRAM Usage** — dedicated VRAM used vs. available (requires `glxinfo`)
- **Disk Usage** — all mounted filesystems shown in a sortable table
- **Save Log to File** — collect periodic snapshots of CPU frequency, RAM, and disk usage into a timestamped report file

---

## Requirements

The following tools must be installed and available in `PATH`:

| Tool | Purpose |
|------|---------|
| `zenity` | GUI dialogs |
| `mpstat` (sysstat) | CPU usage stats |
| `nproc` | CPU core count |
| `jq` | JSON parsing for `mpstat` output |
| `glxinfo` (mesa-utils) | GPU VRAM info |
| `free`, `df`, `lscpu` | Standard Linux tools (usually pre-installed) |

Install missing dependencies on Debian/Ubuntu:

```bash
sudo apt install zenity sysstat jq mesa-utils
```

---

## Installation & Usage

1. **Clone the repository:**

```bash
git clone https://github.com/your-username/sysmonitor.git
cd sysmonitor
```

2. **Make the main script executable:**

```bash
chmod +x sysmonitor.sh
```

3. **Run it:**

```bash
./sysmonitor.sh
```

### Command-line options

```
./sysmonitor.sh [OPTION]

  -h    Show help message and exit
  -v    Show script version and exit
```

---

## Configuration

Edit `config.cfg` in the project directory to customize behavior:

```ini
REFRESH_RATE=3          # Default refresh interval in seconds
LOG_DIR=./logs          # Directory where log files are saved
VERSION=1.1             # Script version
DESCRIPTION="..."       # Description shown in -h help output
```

If `config.cfg` is not found, the script falls back to safe defaults (`REFRESH_RATE=1`, `LOG_DIR=./logs`).

---

## Project Structure

```
sysmonitor/
├── sysmonitor.sh     # Main entry point
├── cpu_usage.sh      # CPU monitoring module
├── ram_usage.sh      # RAM monitoring module
├── gpu_usage.sh      # GPU VRAM monitoring module
├── save_log.sh       # Log saving module
├── config.cfg        # Configuration file
└── sysmonitor.1      # Man page
```

---

## Man Page

A man page is included. To view it:

```bash
man ./sysmonitor.1
```

---

## Log Files

When using the **Save log to file** feature, you will be prompted for:
- **Interval** — how often (in seconds) a snapshot is taken
- **Duration** — how long (in seconds) the collection runs

Log files are saved to the directory defined in `config.cfg` (`./logs` by default), with filenames in the format:

```
system_report_YYYY-MM-DD_HH-MM-SS.txt
```

Each log entry includes CPU frequencies, RAM usage, and disk space.
