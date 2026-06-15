# Geometry Dash — Linux
 
A ready-to-run Geometry Dash build for Linux using Wine. No Steam or Windows required.
 
---
 
## Requirements
 
- Linux (Ubuntu/Debian, Fedora, or any other distro)
- Wine (x32 and x64)
---
 
## Installation
 
### 1. Clone the repository
 
```bash
git clone https://github.com/tumka82290-eng/GeometryDash-Linux.git
cd GeometryDash-Linux
```
 
### 2. Install Wine
 
**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install wine
```
 
**Fedora:**
```bash
sudo dnf update && sudo dnf install wine
```
 
### 3. Run the game
 
```bash
chmod +x start.sh
./start.sh
```
 
---
 
## Installing Mods (Geode)
 
[Geode](https://geode-sdk.org) is the most popular mod loader for Geometry Dash, featuring a built-in in-game mod browser.
 
### Installing Geode
 
1. Download the Geode Installer (Windows version) from [geode-sdk.org](https://geode-sdk.org)
2. Run it with Wine:
```bash
   wine GeodeInstaller.exe
```
3. Point the installer to your game folder
4. Add the DLL override to `start.sh`:
```bash
   export WINEDLLOVERRIDES="xinput1_4=n,b"
```
5. Launch the game — a Geode icon will appear on the main menu
### Installing mods via Geode
 
- Click the Geode icon on the main menu
- Go to the **Download** tab
- Find a mod and click **Download**
### Manual mod installation
 
Place the `.geode` file into:
```
<game folder>/geode/mods/
```
 
> Note: Use Geode v5+ for Geometry Dash version 2.208x support.
 
---
 
## Repository Structure
 
```
GeometryDash-Linux/
├── game_info/        # Game info files
├── wine_x32/         # Wine (32-bit)
├── wine_x64/         # Wine (64-bit)
├── start.sh          # Launch script
├── start-actual.sh   # Alternative launch script
└── README.md
```
 
---
 
## Troubleshooting
 
**Game won't launch**
- Check that Wine is installed: `wine --version`
- Make sure the script is executable: `chmod +x start.sh`
**Geode doesn't work**
- Make sure you added `WINEDLLOVERRIDES="xinput1_4=n,b"` to `start.sh`
**No audio**
- Try installing `wineasio` or `pulseaudio`
---
 
## License
 
This repository only contains the Wine runtime environment. Geometry Dash is the property of [RobTop Games](https://www.robtopgames.com/). Please buy the game on [Steam](https://store.steampowered.com/app/322170/Geometry_Dash/).
