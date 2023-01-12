![PiJARR](/pijarr.png)

[![GitHub Repo stars](https://img.shields.io/github/stars/pijarr/pijarr)](https://github.com/pijarr/pijarr/stargazers)
[![GitHub Repo issues](https://img.shields.io/github/issues/pijarr/pijarr)](https://github.com/pijarr/pijarr/issues)
[![GitHub Repo issues](https://img.shields.io/github/issues-closed/pijarr/pijarr)](https://github.com/pijarr/pijarr/issues?q=is%3Aissue+is%3Aclosed)

A bash shell script to automate the setup and configuration of [Jackett](https://github.com/Jackett/Jackett), [Sonarr](https://github.com/Sonarr/Sonarr), [Radarr](https://github.com/Radarr/Radarr), [Lidarr](https://github.com/Lidarr/Lidarr), [Readarr](https://github.com/Readarr/Readarr) and [Prowlarr](https://github.com/Prowlarr/Prowlarr) on a **Raspberry Pi**.


### 2023 UPDATE  
- [x] Modified to support 64-bit Raspberry Pi OS ARM sources.  
- [x] Added Readarr and Prowlarr to application list.

### TESTED 

- [x] *Running Raspberry Pi OS ([64-bit](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-64-bit)) Lite minimal image based on Debian Bullseye - (Kernel 5.15)*
- [x] *Running Raspberry Pi OS ([legacy 32-bit](https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-legacy)) Lite minimal image based on Debian Buster - (Kernel 5.10)*


### MENU OPTIONS

```
==============
 Menu Options 
==============

1.  Install ALL (jackett sonarr lidarr radarr readarr prowlarr)
2.  Install jackett only
3.  Install sonarr only
4.  Install lidarr only
5.  Install radarr only
6.  Install readarr only
7.  Install prowlarr only

8.  Remove ALL (jackett sonarr lidarr radarr readarr prowlarr)
9.  Remove jackett only
10. Remove sonarr only
11. Remove lidarr only
12. Remove radarr only
13. Remove readarr only
14. Remove prowlarr only

15. Check application service status

16. Exit

    Enter option [1-16]:
```


### NOTES
- During setup dependencies mono install may take some time and slow around 88-90%. It will eventually complete.    
- *The removal of applications is only going to work if the PiJARR script was used for the original installation.*  
- ***When removing applications anything contained in the /var/lib/{appname} or /opt/{appname} will be deleted.***


### USAGE 
- **Method 1 (Quick easy setup):** Just use the curl or wget command lines shown below for quick setup.

`sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/pijarr/pijarr/master/setup.sh)"`

`sudo bash -c "$(wget -O- https://raw.githubusercontent.com/pijarr/pijarr/master/setup.sh)"`

- **Method 2:** Clone and run locally. You can edit and modify script to suit using this method.

`git clone https://github.com/pijarr/pijarr.git`

`sudo bash pijarr/setup.sh`

### DEFAULT APP PORT NUMBERS
Once all applications are installed and the services are started they can be accessed at the following port numbers:
```
Jackett     http://<ipaddress>:9117
Sonarr      http://<ipaddress>:8989
Lidarr      http://<ipaddress>:8686
Radarr      http://<ipaddress>:7878
Readarr     http://<ipaddress>:8787
Prowlarr    http://<ipaddress>:9696
```
