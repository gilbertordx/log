# Disable Autostart Items

Autostart entries are `.desktop` files located in `~/.config/autostart/`.

## Methods

### 1. Delete Entry
```bash
rm ~/.config/autostart/<filename>.desktop
```

### 2. Disable Entry (Without Deleting)
```bash
sed -i 's/X-GNOME-Autostart-enabled=true/X-GNOME-Autostart-enabled=false/' ~/.config/autostart/<filename>.desktop
```

### 3. GUI (Startup Applications)
Open **Startup Applications** from app launcher to toggle or remove entries visually.
