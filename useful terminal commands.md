# Useful Terminal Commands

## Navigation
| Command | Description |
|---------|-------------|
| `cd <dir>` | Change directory |
| `cd ..` | Go up one directory |
| `cd ~` | Go to home directory |
| `pwd` | Print working directory |
| `ls` | List files and directories |
| `ls -la` | List all files with details (including hidden) |

## File Management
| Command | Description |
|---------|-------------|
| `cp <src> <dest>` | Copy file or directory |
| `mv <src> <dest>` | Move or rename file |
| `rm <file>` | Remove a file |
| `rm -rf <dir>` | Remove a directory recursively |
| `mkdir <dir>` | Create a directory |
| `mkdir -p <path>` | Create nested directories |
| `touch <file>` | Create an empty file |
| `cat <file>` | Display file contents |
| `less <file>` | View file with pagination |
| `head -n <N> <file>` | Show first N lines |
| `tail -n <N> <file>` | Show last N lines |

## Search & Find
| Command | Description |
|---------|-------------|
| `find <path> -name "*.txt"` | Find files by name |
| `grep "pattern" <file>` | Search for text in a file |
| `grep -r "pattern" <dir>` | Search recursively in a directory |
| `which <command>` | Show path of a command |

## Permissions
| Command | Description |
|---------|-------------|
| `chmod +x <file>` | Make a file executable |
| `chmod 755 <file>` | Set read/write/execute permissions |
| `chown user:group <file>` | Change file ownership |

## System Info
| Command | Description |
|---------|-------------|
| `uname -a` | System information |
| `df -h` | Disk usage (human-readable) |
| `du -sh <dir>` | Directory size |
| `free -h` | Memory usage |
| `top` / `htop` | Process monitor |
| `ps aux` | List running processes |
| `kill <PID>` | Kill a process by PID |

## Networking
| Command | Description |
|---------|-------------|
| `ping <host>` | Test connectivity |
| `curl <url>` | Fetch URL content |
| `wget <url>` | Download a file |
| `ip a` | Show network interfaces |
| `ss -tuln` | Show open ports |

## Package Management (Debian/Ubuntu)
| Command | Description |
|---------|-------------|
| `sudo apt update` | Update package list |
| `sudo apt upgrade` | Upgrade installed packages |
| `sudo apt install <pkg>` | Install a package |
| `sudo apt remove <pkg>` | Remove a package |

## Git
| Command | Description |
|---------|-------------|
| `git init` | Initialize a repository |
| `git clone <url>` | Clone a repository |
| `git status` | Check repo status |
| `git add .` | Stage all changes |
| `git commit -m "msg"` | Commit with message |
| `git push` | Push to remote |
| `git pull` | Pull from remote |
| `git log --oneline` | Compact commit history |

## Shortcuts
| Shortcut | Description |
|----------|-------------|
| `Ctrl + C` | Cancel current command |
| `Ctrl + Z` | Suspend current process |
| `Ctrl + R` | Reverse search command history |
| `Ctrl + L` | Clear terminal screen |
| `!!` | Repeat last command |
| `sudo !!` | Repeat last command as root |
