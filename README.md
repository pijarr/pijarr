# pijarr-setup.sh
Simple automated setup and configuration of Jackett, Sonarr, Lidarr and Radarr on Raspberry Pi Raspbian OS

[ Tested January 2020 Raspberry Pi 3 Raspbian Buster ]

Version of packages used are at the top of the script with the exception of Sonarr which will get the latest version for Linux.The initial required foundation packages such and Mono (Cross platform, open source .NET framework) may take a while to download and install. When you see installing mono-devel, be patient.

Otherwise try installing manually using the commands below and then re-run the script:

1. `sudo apt-get -y install apt-transport-https dirmngr gnupg ca-certificates`

2. `sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF`

3. `echo "deb https://download.mono-project.com/repo/debian stable-raspbianbuster main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list`

4. `sudo apt-get -y update`

5. `sudo apt-get -y install mono-devel mediainfo sqlite3 libmono-cil-dev libchromaprint-tools`

With minor modification the script would likely work for other Debian or Ubuntu linux systems. To do this some sources may need to be changed as the the LinuxARM32 version is currently used for Jackett.

# Usage
**Method 1:** Clone and run locally. You can edit and modify script to suit using this method.

`git clone https://github.com/piscripts/pijarr.git`

`sudo bash pijarr/pijarr-setup.sh`

**Method 2:** Just use the curl or wget command lines shown below for a one-step install.

`sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/piscripts/pijarr/master/pijarr-setup.sh)"`

`sudo bash -c "$(wget -O- https://raw.githubusercontent.com/piscripts/pijarr/master/pijarr-setup.sh)"`
