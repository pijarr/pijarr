![PiJARR](/pijarr.png)

[![GitHub Repo stars](https://img.shields.io/github/stars/pijarr/pijarr)](https://github.com/pijarr/pijarr/stargazers)
[![GitHub Repo issues](https://img.shields.io/github/issues/pijarr/pijarr)](https://github.com/pijarr/pijarr/issues)
[![GitHub Repo issues](https://img.shields.io/github/issues-closed/pijarr/pijarr)](https://github.com/pijarr/pijarr/issues?q=is%3Aissue+is%3Aclosed)

A shell script to automate the setup and configuration of [Jackett](https://github.com/Jackett/Jackett), [Sonarr](https://github.com/Sonarr/Sonarr), [Radarr](https://github.com/Radarr/Radarr), [Lidarr](https://github.com/Lidarr/Lidarr), [Readarr](https://github.com/Readarr/Readarr), [Prowlarr](https://github.com/Prowlarr/Prowlarr), and [Bazarr](https://github.com/morpheus65535/bazarr) on a **Raspberry Pi** and Intel/AMD x64 systems running Debian based distros.

### WHAT ARR THEY?  
  
[Jackett](https://github.com/Jackett/Jackett) (API Support for your favorite torrent trackers), [Sonarr](https://github.com/Sonarr/Sonarr) (an Internet PVR for Usenet and torrents), [Radarr](https://github.com/Radarr/Radarr) (a movie collection manager for Usenet and BitTorrent users), [Lidarr](https://github.com/Lidarr/Lidarr) (a music collection manager for Usenet and BitTorrent users), [Readarr](https://github.com/Readarr/Readarr) (a ebook collection manager for Usenet and BitTorrent users), [Prowlarr](https://github.com/Prowlarr/Prowlarr) (an indexer manager/proxy built on the popular *arr .net/reactjs base stack to integrate apps including Sonarr, Radarr, Lidarr and Readarr), and [Bazarr](https://github.com/morpheus65535/bazarr) ( a companion application to Sonarr and Radarr to manages and download subtitles.)

### June 2023 UPDATE 

- [x] Added support for Bazarr installation. *Note: Requires Python3 and other packages.*
- [x] Clean up code, and introduced more validation.
- [x] Tested on Debian GNU/Linux 12 (bookworm) 6.1.0-9-amd64 

### 2023 UPDATE 
- [x] Modified to support 64-bit Raspberry Pi OS ARM sources.  
- [x] Now also supports x64 Intel and AMD systems running Debian based distros.
- [x] Added Readarr and Prowlarr to application list.

### PREVIOUSLY TESTED 

- [x] *Running Raspberry Pi OS ([64-bit](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-64-bit)) Lite minimal image based on Debian Bullseye - (Kernel 5.15)*
- [x] *Running Raspberry Pi OS ([legacy 32-bit](https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-legacy)) Lite minimal image based on Debian Buster - (Kernel 5.10)*
- [x] *Intel i7 running Debian GNU/Linux 11 (bullseye) 5.10.0-23-amd64

### NOTES
- During setup dependencies mono install may take some time (especially on the Raspberry Pi v3). Larger dependency install may slow around 88-90% however it will eventually complete.    
- The removal of applications is only going to work if the PiJARR script was used for the original installation.  
- When removing applications anything contained in the `/var/lib/{appname}` or `/opt/{appname}` will be deleted.

### EXAMPLE - MENU OPTIONS

```
                                                               
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

9.  Remove ALL (jackett sonarr lidarr radarr readarr prowlarr bazarr)
10. Remove jackett only
11. Remove sonarr only
12. Remove lidarr only
13. Remove radarr only
14. Remove readarr only
15. Remove prowlarr only
16. Remove bazarr only

17. Show active services
18. Show application default ports
19. Show application source urls

20. Exit

```

### DEFAULT APP PORT NUMBERS
Once all applications are installed and the services are started they can be accessed at the following port numbers:
```
Jackett:    http://hostip:9117
Sonarr:     http://hostip:8989
Lidarr:     http://hostip:8686
Radarr:     http://hostip:7878
Readarr:    http://hostip:8787
Prowlarr:   http://hostip:9696
Bazarr:     http://hostip:6767
```

### USAGE 
#### **Method 1 (Quick easy setup):** 
Use the curl or wget command lines shown below for quick setup.

```
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/pijarr/pijarr/master/setup.sh)"
```

```
sudo sh -c "$(wget -O- https://raw.githubusercontent.com/pijarr/pijarr/master/setup.sh)"
```

#### **Method 2:** Clone and run locally. 
(Optional) You can edit and modify script to suit using this method.

```
git clone https://github.com/pijarr/pijarr.git
sudo sh pijarr/setup.sh
```
