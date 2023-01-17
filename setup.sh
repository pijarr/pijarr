#!/usr/bin/env bash

set -o errexit
set -o pipefail

# Set valid applications which can be used with this script
# Tested applications are jackett lidarr radarr sonarr readarr prowlarr
readonly VALID_APPS=(jackett lidarr radarr sonarr readarr prowlarr)
readonly OS_CODENAME=$(cat /etc/os-release | grep -oP "VERSION_CODENAME=\K\w+")

if [[ $(uname -m | grep 'armv7l') ]]; then
    readonly OS_ARCH="ARM32"
    readonly SERVARR_ARCH="arm"
elif [[ $(uname -m | grep 'aarch64') ]]; then
    readonly OS_ARCH="ARM64"
    readonly SERVARR_ARCH="arm64"
fi

# Fetch latest jackett ARM32 release from https://github.com/Jackett/Jackett/releases
jackett_releases=`curl -s https://github.com/Jackett/Jackett/releases | awk -F"[><]" '{for(i=1;i<=NF;i++){if($i ~ /a href=.*\//){print "<" $i ">"}}}' | grep ${OS_ARCH}.tar.gz -A 0`
jackett_latest=`echo "${jackett_releases}" | awk 'NR==1' | sed -r 's/.*href="([^"]+).*/\1/g'`
jackett_src_url="https://github.com${jackett_latest}"
# Fetch latest radarr, lidarr and sonarr builds. Links below select latest release.

radarr_src_url="https://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${SERVARR_ARCH}"
lidarr_src_url="https://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${SERVARR_ARCH}"
prowlarr_src_url="http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${SERVARR_ARCH}"
readarr_src_url="http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=${SERVARR_ARCH}"
sonarr_src_url="https://services.sonarr.tv/v1/download/main/latest?version=3&os=linux"

# Function to output PiJARR ascii and details of script.
script_info() {
    cat <<EOF
                                                                      
${RED}▓▓▓▓▓▓▓▓▓▓▓▓▓ ${GREEN}▓▓▓▓${RESET}          ▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓
${RED}▓▓▓▓     ▓▓▓▓     ${RESET}          ▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓     ▓▓▓▓
${RED}▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓${RESET} ▓▓▓▓     ▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓
${RED}▓▓▓▓          ▓▓▓▓${RESET} ▓▓▓▓     ▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓   ▓▓▓▓   ▓▓▓▓   ▓▓▓▓
${RED}▓▓▓▓          ▓▓▓▓${RESET} ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓    ▓▓▓▓▓ ▓▓▓▓    ▓▓▓▓▓

Name:           pijarr/setup.sh
Description:    Raspberry Pi installer for Jackett, Sonarr, Radarr, Lidarr, Readarr and Prowler
Author:         github.com/pijarr
Tested:         Raspberry Pi 3 & 4 running Raspberry Pi OS

Notes:          Requiries sudo/root superuser permissions to run.

                If they are not already installed the required dependencies including 
                Mono (Cross platform, open source .NET framework) may take a while to 
                download and install. 
                
                After initial setup the web interface for the application may need a short time 
                to start before being available on the nominated host port.

EOF
}

# Temporary directory for application sources
temp_dir="/tmp/pijarr"

# Function to set terminal colors if supported.
term_colors() {
    if [[ -t 1 ]]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        MAGENTA=$(printf '\033[35m')
        CYAN=$(printf '\033[36m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[0m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        MAGENTA=""
        CYAN=""
        BOLD=""
        RESET=""
    fi
}

# Function to output colored or bold terminal messages.
# Usage examples: term_message "This is a default color and style message"
#                 term_message rb "This is a red bold message"
term_message() {
    local set_color=""
    local set_style=""
    [[ -z "${2}" ]] && echo -ne "${1}" >&2 && return
    [[ ${1:0:1} == "d" ]] && set_color=${RESET}
    [[ ${1:0:1} == "r" ]] && set_color=${RED}
    [[ ${1:0:1} == "g" ]] && set_color=${GREEN}
    [[ ${1:0:1} == "y" ]] && set_color=${YELLOW}
    [[ ${1:0:1} == "b" ]] && set_color=${BLUE}
    [[ ${1:0:1} == "m" ]] && set_color=${MAGENTA}
    [[ ${1:0:1} == "c" ]] && set_color=${CYAN}
    [[ ${1:1:2} == "b" ]] && set_style=${BOLD}
    echo -e "${set_color}${set_style}${2}${RESET}" >&2 && return
}

# Displays a box containing a dash and message
task_start() {
    echo -ne "[-] ${1}"
}

# Displays a box containing a green tick and optional message if required.
task_done() {
    echo -e "\r[\033[0;32m\xE2\x9C\x94\033[0m] ${1}"
}

# Displays a box containing a red cross and optional message if required.
task_fail() {
    echo -e "\r[\033[0;31m\xe2\x9c\x98\033[0m] ${1}"
}

# Function to pause script and check if the user wishes to continue.
check_continue() {
    local response
    while true; do
        read -r -p "Do you wish to continue (y/N)? " response
        case "${response}" in
        [yY][eE][sS] | [yY])
            echo
            break
            ;;
        *)
            echo
            exit
            ;;
        esac
    done
}

# Function to check if superuser or running using sudo
check_superuser() {
    if [[ $(id -u) -ne 0 ]] >/dev/null 2>&1; then
        term_message rb "Script must be run by superuser or using sudo command\n"
        exit 1
    fi
}

# Function to for ARM arch
check_arch() {
    if [[ -z "${OS_ARCH}" ]] >/dev/null 2>&1; then
        term_message rb "Script requires a Raspberry Pi with ARM Architecture\n"
        exit 1
    fi
}


pkg_update() {
    term_message cb "Updating packages using apt update..."
    apt update -y
}

pkg_upgrade() {
    term_message cb "Upgrading packages using apt upgrade..."
    apt upgrade -y
}

pkg_cleanup() {
    term_message cb "Running package clean-up using apt autoclean and autoremove..."
    apt autoclean -y
    apt autoremove -y
}

# Function to check if packages are installed and install them if they are not found.
pkg_install() {
    for pkg in "${@}"; do
        task_start "Checking for required package > ${pkg}"
        if [[ $(dpkg -s "${pkg}") == *"Status: install ok installed"* ]] &>/dev/null; then
            task_done
        else
            task_fail "Package ${pkg} not found.$(tput el)"
            term_message c "Attempting to install ${pkg} package with apt..."
            apt install -y "${pkg}"
            if [[ $(dpkg -s "${pkg}") == *"Status: install ok installed"* ]] &>/dev/null; then
                term_message g "Package ${pkg} is now installed."
            else
                term_message rb "Unable to install package ${pkg}"
            fi
        fi
    done
}

# Function to check if a service is active will return green tick or red cross.
is_active() {
    if [[ $(systemctl is-active "$1") == "active" ]] &>/dev/null; then
        task_done
    else
        task_fail
    fi
}

# Function to remove the temporary directory and files.
remove_temp() {
    task_start "Removing temporary files from ${temp_dir}..."
    rm -Rf ${temp_dir} &>/dev/null || true
    task_done
}

# Function to install all the dependencies including packages and server keys.
setup_dependencies() {
    term_message db "Setup Dependencies"
    term_message c "Installing required dependencies..."
    pkg_install apt-transport-https dirmngr gnupg ca-certificates
    term_message c "Installing mono, sqlite3 and supporting libraries..."
    pkg_install mono-complete mediainfo sqlite3 libmono-cil-dev libchromaprint-tools
}

# Primary function to install and configure the applications.
# Function can take one or more apps ie. setup_app jackett sonarr lidarr radarr
setup_app() {
    for app in "${@}"; do
        local date_stamp="$(date '+%Y-%m-%d %H%M')"
        local app_name="${app,,}"
        local app_user="${app_name}"
        local app_group="${app_user}"
        local src_url=${app_name}\_src_url
        local src_url=${!src_url}
        local src_file="${src_url##*/}"
        local new_file="${app_name}.tar.gz"
        if [[ ! "${VALID_APPS[*]}" =~ ${app} ]]; then
            term_message rb "${app} is not a valid application which can be installed.\n"
            exit
        fi
        task_start "Creating temporary directory for sources ${temp_dir}"
        mkdir -p "${temp_dir}" &>/dev/null || true
        task_done
        term_message cb "\nCommencing install for ${app_name}"
        task_start "Adding user for daemon service username: ${app_user}"
        useradd -s /usr/sbin/nologin -d /var/lib/"${app_user}" -r -m -U "${app_user}" &>/dev/null || true
        task_done
        term_message c "Fetching ${app_name} source file..."
        term_message d "Source URL: ${src_url}"
        wget -O "${temp_dir}"/"${new_file}" -q --show-progress --progress=bar:force "${src_url}" 2>&1 &&
            task_done "Source file downloaded. SHA256: $(sha256sum ${temp_dir}/${new_file} | cut -d ' ' -f 1)$(tput el)"
        term_message c "Extracting ${new_file} to /opt/..."
        tar -xf "${temp_dir}"/"${new_file}" -C /opt/
        task_start "Set user permissions on /opt/${app_name^}"
        chown -R "${app_user}":"${app_group}" /opt/"${app_name^}"/ && task_done
        # Just in case some apps have permission problems with their /var/lib config working directories.
        task_start "Creating other /var/lib config directories and setting permissions"
        mkdir -p /var/lib/"${app_name}"/.config/"${app_name^}"
        chown -R "${app_user}":"${app_group}" /var/lib/"${app_name}"/.config/"${app_name^}"/ && task_done
        # Begin writting out the service configuration file. Minor change needed for Jackett.
        task_start "Configuring system service"
        if [[ "${app_name}" == "jackett" ]]; then
            app_exec="ExecStart=/opt/${app_name^}/${app_name}_launcher.sh"
        elif [[ "${app_name}" == "sonarr" ]]; then
            app_exec="ExecStart=/usr/bin/mono --debug /opt/${app_name^}/${app_name^}.exe -nobrowser"
        else
            app_exec="ExecStart=/opt/${app_name^}/${app_name^}"
        fi
        tee /etc/systemd/system/"${app_name}".service &>/dev/null <<EOF
# Generated by PiJARR ${date_stamp}
[Unit]
Description=${app_name^} Daemon
After=syslog.target network.target

[Service]
SyslogIdentifier=${app_name}
Restart=always
RestartSec=5
Type=simple
User=${app_user}
Group=${app_group}
WorkingDirectory=/opt/${app_name^}
${app_exec}
TimeoutStopSec=20

[Install]
WantedBy=multi-user.target
EOF
        task_done
        task_start "Reloading daemon and enabling ${app_name} service"
        systemctl daemon-reload &>/dev/null
        systemctl enable "${app_name}" &>/dev/null
        systemctl start "${app_name}" &>/dev/null
        task_done
        task_start "Check if service is active"
        is_active "${app_name}"
    done
}

check_status() {
    term_message cb "\nChecking service status..."
    local hostip=$(hostname -I | awk '{print $1}')
    task_start "Jackett:    http://${hostip}:9117" && is_active jackett
    task_start "Sonarr:     http://${hostip}:8989" && is_active sonarr
    task_start "Lidarr:     http://${hostip}:8686" && is_active lidarr
    task_start "Radarr:     http://${hostip}:7878" && is_active radarr
    task_start "Readarr:    http://${hostip}:8787" && is_active readarr
    task_start "Prowlarr:   http://${hostip}:9696" && is_active prowlarr
}

# Function to assist in removing the applications and their configuration files
# Function can take one or more apps ie. remove_app jackett sonarr lidarr radarr
remove_app() {
    for app in "${@}"; do
        local app="${app,,}"
        if [[ ! "${VALID_APPS[*]}" =~ ${app} ]]; then
            term_message rb "${app} is not a valid which can be deleted.\n"
            exit
        fi
        term_message rb "You are about to delete all settings and files for ${app}..."
        check_continue
        task_start "Deleting any existing settings or files for ${app}..."
        systemctl stop "${app}" &>/dev/null || true
        deluser "${app}" &>/dev/null || true
        rm -Rf /opt/"${app^}" &>/dev/null || true
        rm -Rf /var/lib/"${app}" &>/dev/null || true
        rm /etc/systemd/system/"${app}.service"* &>/dev/null || true
        systemctl daemon-reload &>/dev/null || true
        task_done "\n"
    done
}

# Pause and wait for any key to be pressed
any_key() {
    echo ""
    read -n 1 -s -r -p "Press any key to continue."
}

# Display a list of menu items for selection
display_menu () {
    echo "=============="                         
    echo " Menu Options "
    echo "=============="
    echo
    echo -e "1.  Install ALL (jackett sonarr lidarr radarr readarr prowlarr)"
    echo -e "2.  Install jackett only"
    echo -e "3.  Install sonarr only"
    echo -e "4.  Install lidarr only"
    echo -e "5.  Install radarr only"
    echo -e "6.  Install readarr only"
    echo -e "7.  Install prowlarr only"
    echo -e "\n8.  Remove ALL (jackett sonarr lidarr radarr readarr prowlarr)"
    echo -e "9.  Remove jackett only"
    echo -e "10. Remove sonarr only"
    echo -e "11. Remove lidarr only"
    echo -e "12. Remove radarr only"
    echo -e "13. Remove readarr only"
    echo -e "14. Remove prowlarr only"
    echo -e "\n15. Check application service status"
    echo -e "\n16. Exit"
    echo
    echo -n "    Enter option [1-16]: "

    while :
    do
    read choice
    case ${choice} in
    1)  echo -e "\nInstalling all six applications (jackett sonarr lidarr radarr readarr prowlarr)..."
        setup_app jackett sonarr lidarr radarr readarr prowlarr
        remove_temp
        check_status
        ;;
    2)  echo -e "\nInstalling jackett..."
        setup_app jackett
        remove_temp
        check_status
        ;;
    3)  echo -e "\nInstalling sonarr..."
        setup_app sonarr
        remove_temp
        check_status
        ;;
    4)  echo -e "\nInstalling lidarr..."
        setup_app lidarr
        remove_temp
        check_status
        ;;
    5)  echo -e "\nInstalling radarr..."
        setup_app radarr
        remove_temp
        check_status
        ;;
    6)  echo -e "\nInstalling readarr..."
        setup_app readarr
        remove_temp
        check_status
        ;;
    7)  echo -e "\nInstalling prowlarr..."
        setup_app prowlarr
        remove_temp
        check_status
        ;;
    8)  echo -e "\nRemoving all six applications (jackett sonarr lidarr radarr readarr prowlarr)..."
        remove_app jackett sonarr lidarr radarr readarr prowlarr
        check_status
        ;;
    9)  echo -e "\nRemoving jackett..."
        remove_app jackett
        check_status
        ;;
    10)  echo -e "\nRemoving sonarr..."
        remove_app sonarr
        check_status
        ;;
    11)  echo -e "\nRemoving lidarr..."
        remove_app lidarr
        check_status
        ;;
    12) echo -e "\nRemoving radarr..."
        remove_app radarr
        check_status
        ;;
    13)  echo -e "\nRemoving readarr..."
        remove_app readarr
        check_status
        ;;
    14) echo -e "\nRemoving prowlarr..."
        remove_app prowlarr
        check_status
        ;;
    15) check_status
        ;;
    16) echo -e "\nExiting...\n"
        exit
        ;;
    *)  clear
        display_menu
        ;;
    esac
    echo -e "\nSelection [${choice}] completed."
    any_key
    clear
    display_menu
    done
}

# One function to rule them all.
main() {
    clear
    term_colors
    script_info
    check_superuser
    check_arch
    check_continue
    pkg_update
    pkg_upgrade
    pkg_cleanup
    setup_dependencies
    clear
    display_menu
}

main "${@}"
