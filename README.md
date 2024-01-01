![PiJARR](/pijarr.png)

[![GitHub Repo stars](https://img.shields.io/github/stars/pijarr/pijarr)](https://github.com/pijarr/pijarr/stargazers)
[![GitHub Repo issues](https://img.shields.io/github/issues/pijarr/pijarr)](https://github.com/pijarr/pijarr/issues)
[![GitHub Repo issues](https://img.shields.io/github/issues-closed/pijarr/pijarr)](https://github.com/pijarr/pijarr/issues?q=is%3Aissue+is%3Aclosed)

# PiJARR

PiJARR is a shell script designed to simplify the installation and configuration of a suite of media management tools on Debian-based distributions. This script is compatible with various systems, including Debian 11 (bullseye), Debian 12 (bookworm), Raspberry Pi OS, Ubuntu, Pop!\_OS, Kali Linux, and more. It supports both ARM (Raspberry Pi) and Intel/AMD x64 architectures.

### WHAT ARR THEY?

PiJARR streamlines the deployment of the following applications:

- [**Jackett**](https://github.com/Jackett/Jackett): Integrates your favorite torrent trackers with a unified API.
- [**Sonarr**](https://github.com/Sonarr/Sonarr): Acts as an Internet PVR for Usenet and BitTorrent, automating TV show downloads.
- [**Radarr**](https://github.com/Radarr/Radarr): Manages movie collections for Usenet and BitTorrent users.
- [**Lidarr**](https://github.com/Lidarr/Lidarr): Organizes music collections from Usenet and BitTorrent sources.
- [**Readarr**](https://github.com/Readarr/Readarr): Manages ebook collections, catering to both Usenet and BitTorrent users.
- [**Prowlarr**](https://github.com/Prowlarr/Prowlarr): Serves as an indexer manager/proxy, integrating with applications like Sonarr, Radarr, Lidarr, and Readarr.
- [**Bazarr**](https://github.com/morpheus65535/bazarr): Enhances Sonarr and Radarr by managing and downloading subtitles.

### LATEST UPDATE

- [x] Added support for Sonarr v4.
- [x] Integrated an installation option for qBittorrent-nox, a headless torrent client, defaulting to port 8080.
- [x] Expanded functionality to include Bazarr installation.
- [x] Enhanced script with code cleanup and improved validation.

### TESTED ENVIRONMENTS

PiJARR has been tested in the following setups:

- Debian GNU/Linux 12 (bookworm) 6.1.0-16-amd64
- Debian GNU/Linux 11 (bullseye) 5.10.0-23-amd64
- Raspberry Pi OS (64-bit Lite) based on Debian Bullseye - Kernel 5.15
- Raspberry Pi OS (Legacy 32-bit Lite) based on Debian Buster - Kernel 5.10

### NOTES

- **Testing Environment**: The script has been primarily tested on clean, vanilla Debian installations. While it should work on other Debian-based OSes, minor adjustments might be needed. Please note that due to changes in package sources, occasional breaks can occur. This project is updated in my spare time and is not actively monitored or maintained.

- **Desktop Environment**: No desktop environment like GNOME or KDE is required. The script is designed to run headless on a minimal Debian installation with basic system tools.

- **Hardware Recommendations**: The script is compatible with Raspberry Pi 3, but installation and performance may be slow. For optimal performance, a Raspberry Pi 4, other x64 hardware, or a virtual machine is recommended.

- **Installation Notes**: Larger dependencies, such as Mono, may appear to stall or hang during installation, especially on slower hardware like Raspberry Pi 3. However, they will eventually complete.

- **Bazarr Dependencies**: Bazarr requires additional Python packages. It will be configured to run in a Python virtual environment (venv) to avoid dependency conflicts.

- **Application Removal**: The removal script will delete everything in /var/lib/{appname} and /opt/{appname}. Please note that the removal process only works if the application was originally installed using the PiJARR script.

- **Headless Torrent Client**: The menu now includes qbittorrent-nox for users who prefer a headless setup. This client is suitable for machines without a graphical desktop environment. For those who need a desktop GUI torrent client, you can install them using `apt`` as shown below:

```terminal
# qBittorrent desktop GUI torrent client
sudo apt install qbittorrent
```

```terminal
# transmission desktop GUI torrent client
sudo apt install transmission
```

### EXAMPLE - MENU OPTIONS

Below is an example of the menu options presented by the PiJARR script:

```terminal

    ▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓         ▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓
    ▓▓▓▓    ▓▓▓▓              ▓▓▓▓ ▓▓▓▓    ▓▓▓▓ ▓▓▓▓    ▓▓▓▓ ▓▓▓▓    ▓▓▓▓
    ▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓ ▓▓▓▓    ▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓
    ▓▓▓▓         ▓▓▓▓ ▓▓▓▓    ▓▓▓▓ ▓▓▓▓    ▓▓▓▓ ▓▓▓▓  ▓▓▓▓   ▓▓▓▓  ▓▓▓▓
    ▓▓▓▓         ▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓    ▓▓▓▓ ▓▓▓▓   ▓▓▓▓▓ ▓▓▓▓   ▓▓▓▓▓

==============
 Menu Options
==============

1.  Install ALL (jackett sonarr lidarr radarr readarr prowlarr bazarr)
2.  Install jackett only
3.  Install sonarr only
4.  Install lidarr only
5.  Install radarr only
6.  Install readarr only
7.  Install prowlarr only
8.  Install bazarr only
9.  Install qBittorrent-nox (headless torrent client) only

10. Remove ALL (jackett sonarr lidarr radarr readarr prowlarr bazarr)
11. Remove jackett only
12. Remove sonarr only
13. Remove lidarr only
14. Remove radarr only
15. Remove readarr only
16. Remove prowlarr only
17. Remove bazarr only
18. Remove qbittorrent-nox only

19. Show active services
20. Show application default ports
21. Show application source urls

22. Exit

```

### DEFAULT APP PORT NUMBERS

Once all applications are installed and the services are started they can be accessed at the following port numbers:

```terminal
Jackett:         http://hostip:9117
Sonarr:          http://hostip:8989
Lidarr:          http://hostip:8686
Radarr:          http://hostip:7878
Readarr:         http://hostip:8787
Prowlarr:        http://hostip:9696
Bazarr:          http://hostip:6767
qBittorrent-nox: http://hostip:8080
```

### USAGE

#### **Method 1 (Quick easy setup):**

Use the wget or curl command lines shown below for quick setup.

```terminal
sudo sh -c "$(wget -qO- https://raw.githubusercontent.com/pijarr/pijarr/main/setup.sh)"
```

```terminal
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/pijarr/pijarr/main/setup.sh)"
```

#### **Method 2:** Clone and run locally

(Optional) This method allows you to edit and customize the script as needed.

```terminal
git clone https://github.com/pijarr/pijarr.git
sudo sh pijarr/setup.sh
```
