# How to Disable Autostart

These apps open automatically when you log in. Here's how to stop them.

---

## Option 1: Delete the autostart file

Each autostart item is a `.desktop` file in `~/.config/autostart/`. Remove the one you don't want:

```bash
# Stop Brave from opening GitHub
rm ~/.config/autostart/brave-github.desktop

# Stop the .md folder from opening
rm ~/.config/autostart/open-md-folder.desktop

# Stop the terminal commands file from opening
rm ~/.config/autostart/open-useful-commands.desktop

# Remove all three at once
rm ~/.config/autostart/brave-github.desktop ~/.config/autostart/open-md-folder.desktop ~/.config/autostart/open-useful-commands.desktop
```

## Option 2: Disable without deleting

Edit the file and change `X-GNOME-Autostart-enabled` to `false`:

```bash
# Example: disable Brave autostart
sed -i 's/X-GNOME-Autostart-enabled=true/X-GNOME-Autostart-enabled=false/' ~/.config/autostart/brave-github.desktop
```

To re-enable it later, change it back to `true`.

## Option 3: Use the GUI

1. Open **Startup Applications** (search for it in your app menu)
2. Uncheck or remove the entries you don't want

---

## Current autostart files

| File | Opens |
|------|-------|
| `~/.config/autostart/brave-github.desktop` | Brave Browser → GitHub |
| `~/.config/autostart/open-md-folder.desktop` | .md folder in Nautilus |
| `~/.config/autostart/open-useful-commands.desktop` | useful terminal commands.md |
