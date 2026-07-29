# Bluetooth

## Hardware & Driver
- **Adapter**: Realtek Semiconductor Corp. Bluetooth Radio (`0bda:8771` / RTL8761BU).
- **Firmware**: `/lib/firmware/rtl_bt/rtl8761bu_fw.bin` & `rtl8761bu_config.bin`.
- **Known Issue**: USB autosuspend triggers command timeouts (`hci0: command 0x0405 tx timeout`) and reset loops.

## Device Pairing (Logitech K380)
- **Stale HID Error**: `org.bluez.Error.Failed br-connection-create-socket` / `Can't get HIDP connection info`.
- **Fix Procedure**:
  1. Reset pairable state: `bluetoothctl pairable on && bluetoothctl discoverable on`
  2. Clear stale pair: `bluetoothctl remove F4:73:35:5E:84:FF`
  3. Scan & Pair: `bluetoothctl scan on`, `bluetoothctl pair F4:73:35:5E:84:FF`
  4. Trust & Connect: `bluetoothctl trust F4:73:35:5E:84:FF`, `bluetoothctl connect F4:73:35:5E:84:FF`
