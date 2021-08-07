![PiJARR](/pijarr.png)

A bash shell script to automate the setup and configuration of [Jackett](https://github.com/Jackett/Jackett), [Sonarr](https://github.com/Sonarr/Sonarr), [Radarr](https://github.com/Radarr/Radarr), and [Lidarr](https://github.com/Lidarr/Lidarr) on a **Raspberry Pi**.

**Tested August 2021 Raspberry Pi 3 & 4**  
*Running Raspberry Pi OS ([32-bit](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit)) Lite minimal image based on Debian Buster - May 7th 2021 (Kernel 5.10)*

## Usage
**Method 1:** Clone and run locally. You can edit and modify script to suit using this method.

`git clone https://github.com/piscripts/pijarr.git`

`sudo bash pijarr/pijarr-setup.sh`

**Method 2 (Quick easy setup):** Just use the curl or wget command lines shown below for a one-step install.

`sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/piscripts/pijarr/master/pijarr-setup.sh)"`

`sudo bash -c "$(wget -O- https://raw.githubusercontent.com/piscripts/pijarr/master/pijarr-setup.sh)"`

## Default web ports
Once all applications are installed and the services are started they can be accessed at the following port numbers:
```
Jackett   http://<ipaddress>:9117
Sonarr    http://<ipaddress>:8989
Lidarr    http://<ipaddress>:8686
Radarr    http://<ipaddress>:7878
```

## Troubleshooting
The required dependencies including [Mono](https://github.com/mono/mono) (Cross platform, open source .NET framework) may take a while to download and install. Be patient.
Otherwise try installing dependencies manually using the commands below and then re-run the script:

1. `sudo apt -y install apt-transport-https dirmngr gnupg ca-certificates`

2. `sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF`

3. `echo "deb https://download.mono-project.com/repo/debian stable-raspbianbuster main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list`

4. `sudo apt -y update`

5. `sudo apt -y install mono-devel mediainfo sqlite3 libmono-cil-dev libchromaprint-tools`



