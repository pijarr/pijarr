![PiJARR Terminal Screenshot](/terminal.png)

## pijarr-setup.sh
Bash shell script for Raspberry Pi to automate the setup and configuration of Jackett, Sonarr, Radarr, and Lidarr

**Tested August 2021 Raspberry Pi 3 & 4 Raspberry Pi OS**  
- Raspberry Pi OS (32-bit) Lite minimal image based on Debian Buster - May 7th 2021 (Kernel 5.10)

## Usage
**Method 1:** Clone and run locally. You can edit and modify script to suit using this method.

`git clone https://github.com/piscripts/pijarr.git`

`sudo bash pijarr/pijarr-setup.sh`

**Method 2 (Quick easy setup):** Just use the curl or wget command lines shown below for a one-step install.

`sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/piscripts/pijarr/master/pijarr-setup.sh)"`

`sudo bash -c "$(wget -O- https://raw.githubusercontent.com/piscripts/pijarr/master/pijarr-setup.sh)"`

## Troubleshooting
Version of packages used are at the top of the script with the exception of Sonarr which will get the latest version for Linux.The initial required foundation packages such and Mono (Cross platform, open source .NET framework) may take a while to download and install. When you see installing mono-devel, be patient.

Otherwise try installing dependencies manually using the commands below and then re-run the script:

1. `sudo apt -y install apt-transport-https dirmngr gnupg ca-certificates`

2. `sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF`

3. `echo "deb https://download.mono-project.com/repo/debian stable-raspbianbuster main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list`

4. `sudo apt -y update`

5. `sudo apt -y install mono-devel mediainfo sqlite3 libmono-cil-dev libchromaprint-tools`



