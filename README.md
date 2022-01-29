![PiJARR](/pijarr.png)

[![GitHub Repo stars](https://img.shields.io/github/stars/pijarr/pijarr?style=social)](https://github.com/pijarr/pijarr/stargazers)
[![GitHub Repo issues](https://img.shields.io/github/issues/pijarr/pijarr?style=social)](https://github.com/pijarr/pijarr/issues)

A bash shell script to automate the setup and configuration of [Jackett](https://github.com/Jackett/Jackett), [Sonarr](https://github.com/Sonarr/Sonarr), [Radarr](https://github.com/Radarr/Radarr), and [Lidarr](https://github.com/Lidarr/Lidarr) on a **Raspberry Pi**.

**Tested Raspberry Pi 3 & 4**  
*Running Raspberry Pi OS ([32-bit](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit)) Lite minimal image based on Debian Buster - (Kernel 5.10)*

**UPDATE for 2022**  
As requested / raised in issues - added menu system to allow installation and removal of individual applications.  

```
=====================
 PiJARR Menu Options 
=====================

1.  Install ALL applications jackett sonarr lidarr and radarr
2.  Install jackett only
3.  Install sonarr only
4.  Install lidarr only
5.  Install radarr only

6.  Remove ALL applications jackett sonarr lidarr and radarr
7.  Remove jackett only
8.  Remove sonarr only
9.  Remove lidarr only
10. Remove radarr only

11. Check application service status

12. Exit

   Enter option [1-12]: 
```

- During setup dependencies mono install may take some time and slow around 88-90%. It will eventually complete.    
- *The removal of applications is only going to work if the PiJARR script was used for the original installation.*  
- ***When removing applications anything contained in the /var/lib/{appname} or /opt/{appname} will be deleted.***


## Usage
**Method 1 (Quick easy setup):** Just use the curl or wget command lines shown below for quick setup.

`sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/pijarr/pijarr/master/setup.sh)"`

`sudo bash -c "$(wget -O- https://raw.githubusercontent.com/pijarr/pijarr/master/setup.sh)"`

**Method 2:** Clone and run locally. You can edit and modify script to suit using this method.

`git clone https://github.com/pijarr/pijarr.git`

`sudo bash pijarr/setup.sh`

## Default web ports
Once all applications are installed and the services are started they can be accessed at the following port numbers:
```
Jackett   http://<ipaddress>:9117
Sonarr    http://<ipaddress>:8989
Lidarr    http://<ipaddress>:8686
Radarr    http://<ipaddress>:7878
```



