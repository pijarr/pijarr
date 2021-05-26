#!/usr/bin/env bash

set -o errexit
set -o pipefail

# Set valid applications which can be used with this script
# Tested applications are jackett lidarr radarr sonarr
readonly VALID_APPS=(jackett lidarr radarr sonarr)

# Application sources towards top to make them easier to update
jackett_src_url='https://github.com/Jackett/Jackett/releases/download/v0.18.155/Jackett.Binaries.LinuxARM32.tar.gz'
radarr_src_url='https://github.com/Radarr/Radarr/releases/download/v3.2.0.5048/Radarr.master.3.2.0.5048.linux.tar.gz'
lidarr_src_url='https://github.com/lidarr/Lidarr/releases/download/v0.8.1.2135/Lidarr.master.0.8.1.2135.linux.tar.gz'
sonarr_src_url='https://services.sonarr.tv/v1/download/phantom-develop/latest?version=3&os=linux'

# Function to output PiJARR ascii and details of script.
script_info() {
    cat <<EOF

${RED}▓▓▓▓▓▓▓▓▓▓▓▓▓ ${GREEN}▓▓▓▓${RESET}          ▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓
${RED}▓▓▓▓     ▓▓▓▓     ${RESET}          ▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓     ▓▓▓▓
${RED}▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓${RESET} ▓▓▓▓     ▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓
${RED}▓▓▓▓          ▓▓▓▓${RESET} ▓▓▓▓     ▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓   ▓▓▓▓   ▓▓▓▓   ▓▓▓▓
${RED}▓▓▓▓          ▓▓▓▓${RESET} ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓    ▓▓▓▓▓ ▓▓▓▓    ▓▓▓▓▓

Name:           pijarr-setup.sh
Description:    Raspberry Pi installer for Jackett, Sonarr, Radarr, and Lidarr
Author:         github.com/piscripts
Tested:         Raspberry Pi 3 & 4 running Raspbian Buster
Usage:          sudo bash pijarr-setup.sh
Notes:          Requiries sudo/root superuser permissions to run.

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
#                 term_message nb "This is a default color bold message"
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
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF >/dev/null 2>&1
    echo "deb https://download.mono-project.com/repo/debian stable-raspbianbuster main" | tee /etc/apt/sources.list.d/mono-official-stable.list >/dev/null 2>&1
    term_message c "Updating packages to include newly added sources..."
    pkg_update
    term_message c "Installing mono, sqlite3 and supporting libraries..."
    pkg_install mono-devel mediainfo sqlite3 libmono-cil-dev libchromaprint-tools
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
        wget -O "${temp_dir}"/"${new_file}" -q --show-progress --progress=bar:force "${src_url}" 2>&1 &&
            task_done "Source file downloaded.$(tput el)"
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
        else
            app_exec="ExecStart=/usr/bin/mono --debug /opt/${app_name^}/${app_name^}.exe -nobrowser"
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

final_info() {
    term_message gb "\nSetup script has completed.\n"
    local hostip=$(hostname -I | awk '{print $1}')
    task_start "Jackett:    http://${hostip}:9117" && is_active jackett
    task_start "Sonarr:     http://${hostip}:8989" && is_active sonarr
    task_start "Lidarr:     http://${hostip}:8686" && is_active lidarr
    task_start "Radarr:     http://${hostip}:7878" && is_active radarr
    term_message c "\nThe web services may need a short period of time to start after setup.\n"
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

# One function to rule them all.
main() {
    clear
    term_colors
    script_info
    check_superuser
    check_continue
    pkg_update
    pkg_upgrade
    pkg_cleanup
    #remove_app jackett sonarr lidarr radarr
    setup_dependencies
    setup_app jackett sonarr lidarr radarr
    remove_temp
    final_info
}

main "${@}"
