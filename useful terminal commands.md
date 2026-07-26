# Terminal Quick Reference

## Navigation & Files
- `cd <dir>` | `pwd` | `ls -la`
- `cp <src> <dest>` | `mv <src> <dest>` | `rm -rf <dir>`
- `mkdir -p <path>` | `cat <file>` | `head -n N <file>` | `tail -n N <file>`

## Search & Permissions
- `find <path> -name "*.ext"` | `grep -r "pattern" <dir>`
- `chmod +x <file>` | `chown user:group <file>`

## System & Network
- `df -h` (disk) | `free -h` (RAM) | `top` / `htop` (processes)
- `ps aux` | `kill <PID>`
- `curl <url>` | `ping <host>` | `ip a`

## Git & Packages
- `git status` | `git add .` | `git commit -m "msg"` | `git push`
- `sudo apt update && sudo apt upgrade` | `sudo apt install <pkg>`

## Shortcuts
- `Ctrl+C` (cancel) | `Ctrl+R` (search history) | `Ctrl+L` (clear terminal)

## Audio & Sound Controls
- Unmute PulseAudio sink & set volume to 80%:
  `pactl set-sink-mute @DEFAULT_SINK@ 0 && pactl set-sink-volume @DEFAULT_SINK@ 80%`
- Unmute ALSA master, front speakers, and headphones:
  `amixer -c 2 set Master 100% unmute && amixer -c 2 set Front 100% unmute && amixer -c 2 set Headphone 100% unmute`
- Disable ALSA auto-mute (keeps speakers & headphones active):
  `amixer -c 2 set 'Auto-Mute Mode' Disabled`
- Switch output port to Headphones:
  `pactl set-sink-port alsa_output.pci-0000_09_00.4.analog-stereo analog-output-headphones`
- Switch output port to Speakers (Line Out):
  `pactl set-sink-port alsa_output.pci-0000_09_00.4.analog-stereo analog-output-lineout`
- Test audio playback:
  `speaker-test -D pulse -c 2 -t wave -l 1`

