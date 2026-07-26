# 🧠 What We've Built Together

A living catalog of every automation, script, and setup from our sessions.

---

## 🔧 Automations & Scripts

### Bluetooth — Connect K380
> One-click desktop shortcut to connect the Logitech K380 keyboard via Bluetooth.

| Item | Path |
|------|------|
| Desktop shortcut | `~/Desktop/connect-k380.desktop` |
| Shell script | `~/log/bt-connect.sh` |

**What it does:**
- Powers on the Bluetooth adapter if off
- Scans, pairs, trusts, and connects the K380 automatically
- Full recovery flow with retries — idempotent and safe to re-run
- Color-coded terminal output

**Run it:**
```bash
# Double-click the desktop shortcut, or:
~/log/bt-connect.sh
~/log/bt-connect.sh --status
~/log/bt-connect.sh <MAC>
```

---

### Autostart — Apps on Boot
> XDG autostart entries that open key apps every time you log in (like Windows Startup folder).

| Entry | File | Opens |
|-------|------|-------|
| Brave → GitHub | `~/.config/autostart/brave-github.desktop` | Brave Browser at github.com |
| .md folder | `~/.config/autostart/open-md-folder.desktop` | Notes folder in Nautilus |
| Terminal commands | `~/.config/autostart/open-useful-commands.desktop` | useful terminal commands.md |
| /log folder | `~/.config/autostart/open-log-folder.desktop` | Diary / second-brain folder |

**Disable any of them:**
```bash
# Delete it
rm ~/.config/autostart/<filename>.desktop

# Or just toggle it off
sed -i 's/X-GNOME-Autostart-enabled=true/X-GNOME-Autostart-enabled=false/' ~/.config/autostart/<filename>.desktop
```

See also: `~/Desktop/.md/how to disable autostart.md`

---

## 📁 Infrastructure — Folder Structure

```
~/
├── Desktop/
│   ├── connect-k380.desktop        # BT keyboard shortcut
│   └── .md/                        # Hidden notes folder (auto-opens on boot)
│       ├── useful terminal commands.md
│       ├── how to disable autostart.md
│       └── what we built.md        # ← this file
│
├── log/                            # Diary & second-brain (auto-opens on boot)
│   ├── bt-connect.sh               # Bluetooth connection script
│   └── ...                         # Future diary entries, scripts, notes
│
└── .config/autostart/              # XDG autostart entries
    ├── brave-github.desktop
    ├── open-md-folder.desktop
    ├── open-useful-commands.desktop
    └── open-log-folder.desktop
```

---

## 📚 Studies & Notes on Desktop

| File | Description |
|------|-------------|
| `~/Desktop/My thoughts on "vibe coding"...md` | Essay on vibe coding as a 10x engineer |
| `~/Desktop/Untitled Document 1` | Scratch notes |

---

## 💡 Philosophy

This setup is a **second-brain** that lives on the machine:
- **`/log`** is the diary — auto-opens on boot with Antigravity to keep focus
- **`.md`** is the reference library — quick-access terminal commands, guides, docs
- **Autostart** makes sure everything is ready the moment you sit down
- **Scripts** automate the tedious stuff so you can focus on building

> Every boot is a fresh start with everything you need already open.
