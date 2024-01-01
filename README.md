# PiJARR

![PiJARR](/pijarr.png)

[![GitHub Repo stars](https://img.shields.io/github/stars/pijarr/pijarr)](https://github.com/pijarr/pijarr/stargazers)
[![GitHub Repo issues](https://img.shields.io/github/issues/pijarr/pijarr)](https://github.com/pijarr/pijarr/issues)
[![GitHub Repo issues](https://img.shields.io/github/issues-closed/pijarr/pijarr)](https://github.com/pijarr/pijarr/issues?q=is%3Aissue+is%3Aclosed)

A shell script to automate the installation and configuration of [Jackett](https://github.com/Jackett/Jackett), [Sonarr](https://github.com/Sonarr/Sonarr), [Radarr](https://github.com/Radarr/Radarr), [Lidarr](https://github.com/Lidarr/Lidarr), [Readarr](https://github.com/Readarr/Readarr), [Prowlarr](https://github.com/Prowlarr/Prowlarr), and [Bazarr](https://github.com/morpheus65535/bazarr) on Debian based distros. Including Debian 11 (bullseye) and 12 (bookworm), Raspberry PI OS, Ubuntu, Pop!\_OS Kali etc. Supports ARM **Raspberry Pi** and Intel/AMD x64 systems.

### WHAT ARR THEY?

PiJARR automates the installation of the following applications: [Jackett](https://github.com/Jackett/Jackett) (API Support for your favorite torrent trackers), [Sonarr](https://github.com/Sonarr/Sonarr) (an Internet PVR for Usenet and torrents), [Radarr](https://github.com/Radarr/Radarr) (a movie collection manager for Usenet and BitTorrent users), [Lidarr](https://github.com/Lidarr/Lidarr) (a music collection manager for Usenet and BitTorrent users), [Readarr](https://github.com/Readarr/Readarr) (a ebook collection manager for Usenet and BitTorrent users), [Prowlarr](https://github.com/Prowlarr/Prowlarr) (an indexer manager/proxy built on the popular \*arr .net/reactjs base stack to integrate apps including Sonarr, Radarr, Lidarr and Readarr), and [Bazarr](https://github.com/morpheus65535/bazarr) (a companion application to Sonarr and Radarr to manages and download subtitles.)

### LATEST UPDATE

- [x] Support for Sonarr v4
- [x] Added an installation option for qBittorrent-nox (a headless version of the qBittorrent client) by default will run on port 8080
- [x] Added support for [Bazarr](https://github.com/morpheus65535/bazarr) installation.
- [x] Clean up code, and introduced more validation.

### TESTED

**Note:** Most testing was done on clean vanilla Debian installs, minor adjustments or edits may be required for other OS. Also, occasional breaks may occur when package sources change. this project is updated in spare time and is not actively monitored or maintained.

- [x] x64 Debian GNU/Linux 12 (bookworm) 6.1.0-16-amd64
- [x] x64 Debian GNU/Linux 11 (bullseye) 5.10.0-23-amd64
- [x] _Running Raspberry Pi OS ([64-bit](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-64-bit)) Lite minimal image based on Debian Bullseye - (Kernel 5.15)_
- [x] _Running Raspberry Pi OS ([legacy 32-bit](https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-legacy)) Lite minimal image based on Debian Buster - (Kernel 5.10)_

### NOTES

- A desktop environment such GNOME, KDE is not required. Can run HEADLESS on mimimal Debian install with base system tools.
- Will run on a Raspberry Pi 3 however installation and performance will be slow.
- A Pi 4 or other x64 hardware or virtual machine would be recommended.
- During installation, larger dependencies like Mono may seem to stall or hang, but they will eventually complete (noticable mainly on slower hardware as a Pi 3).
- Bazarr does have Python and other packages requirements.
- Bazarr will configured to run using a Python virtual environment (venv) to prevent dependency issues.
- The removal of applications is only going to work if the PiJARR script was used for the original installation.
- When removing applications anything contained in the `/var/lib/{appname}` or `/opt/{appname}` will be deleted.

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
