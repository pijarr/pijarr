#!/bin/sh
clear

### SET GLOBAL VARIABLES ###

TEMPDIR="/tmp/pijarr"
APPLIST="jackett sonarr lidarr radarr readarr prowlarr"

# Set terminal global variable for colors if supported.
if [ -t 1 ]; then
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


# Temporary directory for application sources
make_temp_dir() {
    task_start "Creating temporary directory ${TEMPDIR}..."
    mkdir -p "${TEMPDIR}" 2> /dev/null
    check_result
}

remove_temp_dir() {
    task_start "Removing temporary directory and files ${TEMPDIR}..."
    rm -Rf "${TEMPDIR}" 2> /dev/null
    check_result
}

task_start() {
    printf "\r[TASK] ${1}$(tput el)"
}

task_fail() {
    printf "\r[${RED}FAIL${RESET}] ${1}\n"
}

task_pass() {
    printf "\r[${GREEN}PASS${RESET}] ${1}\n"
}

task_skip() {
    printf "\r[${BLUE}SKIP${RESET}] ${1}\n"
}

task_info() {
    printf "\r[${CYAN}INFO${RESET}] ${1}$(tput el)\n"
}

task_warn() {
    printf "\r[${CYAN}WARN${RESET}] ${1}$(tput el)\n"
}

task_dbug() {
    printf "\r[${YELLOW}DBUG${RESET}] ${1}$(tput el)\n"
}

title_case() {
    printf "%s" "${1}" | tr '[:upper:]' '[:lower:]' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1'
}

lower_case() {
    printf "%s" "${1}" | tr '[:upper:]' '[:lower:]'
}

upper_case() {
    printf "%s" "${1}" | tr '[:lower:]' '[:upper:]'
}

check_result() {
    if [ $? -eq 0 ]; then
        task_pass
    else
        task_fail
    fi
}

### START CHECK SYSTEM REQUIREMENTS AND ARCHITECTURE ###

if cat /proc/cpuinfo >/dev/null 2>&1; then
    check_cpu=$(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d':' -f2 | xargs)
    check_model=$(cat /proc/cpuinfo | grep Model | head -1 | cut -d':' -f2 | xargs)
    if [ -z "${check_cpu}" ]; then
        result="${check_model}"
    else
        result="${check_cpu}"
    fi
    if [ -n "${result}" ]; then
        cpuBoardInfo="${result}"
    fi
elif sysctl -a >/dev/null 2>&1; then
    result=$(sysctl -a | egrep -i 'hw.model' | sed 's/[^ ]* //')
    if [ -n "${result}" ]; then
        cpuBoardInfo="${result}"
    fi
fi

if command -v lsb_release >/dev/null 2>&1; then
    dist=$(lsb_release -d --short)
    osInfo="${dist}"    
fi
    if $(command -v uname) >/dev/null 2>&1; then
    arch=$(uname -m)
    kernel=$(uname -r)
    kname=$(uname -s)
    if [ -z "${dist}" ]; then
        osInfo="${kname}"
    fi
    kernelInfo="${kernel}"
    archInfo="${arch}"
fi

task_info "Checking hardware requirements..."
task_info "Detected: ${cpuBoardInfo}"
task_info "Detected: ${osInfo} ${kernelInfo}"

systemInfo="${cpuBoardInfo} ${kname} ${osInfo} ${kernelInfo} ${archInfo}"

case "${systemInfo}" in
    *x86_64* | *X86_64* | *amd64* | *AMD64* )   task_pass "Detected: x86 64-Bit Architecture$(tput el)" 
                                                JACKETT_ARCH="AMDx64"
                                                SERVARR_ARCH="x64" ;;
esac

case "${systemInfo}" in
    *aarch64* | *AARCH64* | *arm64* | *ARM64* | *armv8* | *ARMV8* )     task_pass "Detected: ARM 64-Bit Architecture$(tput el)" 
                                                                        JACKETT_ARCH="ARM64" 
                                                                        SERVARR_ARCH="arm64" ;;
esac

case "${systemInfo}" in
    *aarch32* | *AARCH32* | *arm32* | *ARM32* | *armv7l* | *ARMV7L* )   task_pass "Detected: ARM 32-Bit Architecture$(tput el)" 
                                                                        JACKETT_ARCH="ARM32" 
                                                                        SERVARR_ARCH="arm" ;;
esac

case "${systemInfo}" in
    *linux* | *Linux* | *LINUX*)    task_pass "Detected: Linux based OS$(tput el)" ;;
    *)                              task_fail "Linux required. Not detected. Exiting...$(tput el)"
                                    echo ""
                                    exit 1 ;;
esac

### END CHECK SYSTEM REQUIREMENTS AND ARCHITECTURE ###

# Fetch latest jackett release from https://github.com/Jackett/Jackett/releases
jackett_releases=$(curl -s https://github.com/Jackett/Jackett/releases | awk -F"[><]" '{for(i=1;i<=NF;i++){if($i ~ /a href=.*\//){print "<" $i ">"}}}' | grep Linux${JACKETT_ARCH}.tar.gz -A 0)
jackett_latest=$(echo "${jackett_releases}" | awk 'NR=1' | sed -r 's/.*href="([^"]+).*/\1/g')
jackett_src_url="https://github.com${jackett_latest}"

# Fetch latest radarr, lidarr and sonarr builds. Links below select latest release.
radarr_src_url="https://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${SERVARR_ARCH}"
lidarr_src_url="https://lidarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${SERVARR_ARCH}"
prowlarr_src_url="http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${SERVARR_ARCH}"
readarr_src_url="http://readarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=${SERVARR_ARCH}"
sonarr_src_url="https://services.sonarr.tv/v1/download/main/latest?version=3&os=linux"

check_sources() {
    task_info "Application Installation Source URLs"
    for app in ${APPLIST}; do
        src_url=${app}\_src_url
        src_url=$(eval echo \$"$src_url")
        task_info "${app} src: ${src_url}"
    done
}

# Function to pause script and check if the user wishes to continue.
check_continue() {
    local response
    while true; do
        read -r -p "[${GREEN}USER${RESET}] Do you wish to continue (y/N)? " response
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

press_any_key() {
    echo ""
    printf "%s " "[${GREEN}USER${RESET}] Press enter to continue..."
    read ans
}

# Function to check if superuser or running using sudo
check_superuser() {
    if [ "$(id -u)" -ne 0 ]; then
        task_fail "Script must be run by superuser or using sudo command\n"
        exit 1
    fi
}

pkg_updates() {
    task_info "Updating and upgrading packages using apt..."
    apt update
    apt upgrade -y
    apt autoclean -y 2> /dev/null
    apt autoremove -y 2> /dev/null
}

# Function to check if packages are installed and install them if they are not found.
pkg_install() {
    for pkg in "${@}"; do
        task_start "Checking for required package > ${pkg}"
        pkgStatus=$(dpkg -s "${pkg}" 2> /dev/null)
        result=$?
        if [ "${result}" -ne 0 ]; then
            task_warn "Package ${pkg} not installed.$(tput el)"
            task_info "Installing ${pkg}..."
            apt install -y "${pkg}"
        else
            task_pass "Package ${pkg} already installed.$(tput el)"
        fi
    done
}

# Function to install all the dependencies including packages and server keys.
setup_dependencies() {
    task_info "Installing required dependencies..."
    pkg_install apt-transport-https dirmngr gnupg ca-certificates
    task_info "Installing mono, sqlite3 and supporting libraries..."
    pkg_install mono-complete mediainfo sqlite3 libmono-cil-dev libchromaprint-tools
}

# Function to output PiJARR ascii and details of script.
banner_info() {
    printf '%s\n' "                                                               
    ${RED}▓▓▓▓▓▓▓▓▓▓▓▓▓ ${GREEN}▓▓▓▓${RESET}          ▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓
    ${RED}▓▓▓▓     ▓▓▓▓     ${RESET}          ▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓     ▓▓▓▓
    ${RED}▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓${RESET} ▓▓▓▓     ▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓
    ${RED}▓▓▓▓          ▓▓▓▓${RESET} ▓▓▓▓     ▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓   ▓▓▓▓   ▓▓▓▓   ▓▓▓▓
    ${RED}▓▓▓▓          ▓▓▓▓${RESET} ▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓     ▓▓▓▓ ▓▓▓▓    ▓▓▓▓▓ ▓▓▓▓    ▓▓▓▓▓
    "
}

script_info() {
    banner_info
    printf '%s\n' "
    Description:    Installer for Jackett, Sonarr, Radarr, Lidarr, Readarr and Prowler
                    Tested with Raspberry Pi 3 & 4 32-Bit or 64-Bit running offical Raspberry Pi OS
                    Compatibility with other Intel AMD x64 (64-bit only) Debian based Linux distros

    Author:         github.com/pijarr

    Notes:          Requiries sudo/root superuser permissions to run.

                    Commands \"apt update upgrade autoclean autoremove\" will be run upon continue.
                    This is to ensure all packages are up to date and latest versions are used.

                    If they are not already installed the required dependencies including 
                    Mono (Cross platform, open source .NET framework) may take a while to 
                    download and install. 
                    
                    After initial setup the web interface for the application may need a short time 
                    to start before being available on the nominated host port.

"
}

# Primary function to install and configure the applications.
# Function can take one or more apps ie. setup_app jackett sonarr lidarr radarr
setup_app() {
    clear
    make_temp_dir
    setup_dependencies
    for app in "${@}"; do
        if [ $(systemctl is-active "${app}") = "active" ]; then
            task_skip "A service for ${app} is already exists."
            continue
        fi
        date_stamp="$(date '+%Y-%m-%d %H%M')"
        app_name="$(lower_case ${app})"
        app_user="${app_name}"
        app_group="${app_user}"
        src_url=${app_name}\_src_url
        src_url=$(eval echo \$"$src_url")
        src_file="$(basename \$"${src_url}")"
        new_file="${app_name}.tar.gz"
        task_info "Commencing install for ${app_name}..."
        task_start "Adding service user account..."
        useradd -s /usr/sbin/nologin -d /var/lib/"${app_user}" -r -m -U "${app_user}" 2> /dev/null
        check_result
        task_info "Download source URL: ${src_url}"
        wget -O "${temp_dir}"/"${new_file}" -q --show-progress --progress=bar:force "${src_url}" 2>&1 &&
        task_pass "Source file downloaded. SHA256: $(sha256sum ${temp_dir}/${new_file} | cut -d ' ' -f 1)$(tput el)"
        task_start "Exacting ${temp_dir}/${new_file} to /opt/$(title_case ${app_name})..."
        tar -xf "${temp_dir}"/"${new_file}" -C /opt/
        check_result
        task_start "Setting user permissions on /opt/$(title_case ${app_name})..."
        chown -R "${app_user}":"${app_group}" /opt/"$(title_case ${app_name})"/
        check_result
        # Just in case some apps have permission problems with their /var/lib config working directories.
        task_start "Creating /var/lib config files..."
        mkdir -p /var/lib/"${app_name}"/.config/"$(title_case ${app_name})"
        check_result
        task_start "Setting user permissions on /var/lib/${app_name}/.config/$(title_case ${app_name})..."
        chown -R "${app_user}":"${app_group}" /var/lib/"${app_name}"/.config/"$(title_case ${app_name})"/ && 
        check_result
        # Begin writting out the service configuration file. Minor change needed for Jackett.
        if [ "${app_name}" = "jackett" ]; then
            app_exec="ExecStart=/opt/$(title_case ${app_name})/${app_name}_launcher.sh"
        elif [ "${app_name}" = "sonarr" ]; then
            app_exec="ExecStart=/usr/bin/mono --debug /opt/$(title_case ${app_name})/$(title_case ${app_name}).exe -nobrowser"
        else
            app_exec="ExecStart=/opt/$(title_case ${app_name})/$(title_case ${app_name})"
        fi
        task_start "Writing service configuration file /etc/systemd/system/${app_name}.service..."
        tee /etc/systemd/system/"${app_name}".service 1>/dev/null <<EOF
# Generated by PiJARR ${date_stamp}
[Unit]
Description=$(title_case ${app_name}) Daemon
After=syslog.target network.target
[Service]
SyslogIdentifier=${app_name}
Restart=always
RestartSec=5
Type=simple
User=${app_user}
Group=${app_group}
WorkingDirectory=/opt/$(title_case ${app_name})
${app_exec}
TimeoutStopSec=20
[Install]
WantedBy=multi-user.target
EOF
        check_result
        task_start "Reloading systemctl daemon..."
        systemctl daemon-reload 2> /dev/null
        check_result
        task_start "Enabling auto start for ${app_name} service..."
        systemctl enable "${app_name}" 2> /dev/null
        check_result
        task_start "Starting ${app_name} service..."
        systemctl start "${app_name}" 2> /dev/null
        check_result
        check_service ${app_name}
        task_info "Completed install for ${app_name}\n"
    done
    remove_temp_dir
}

# Function to assist in removing the applications and their configuration files
# Function can take one or more apps ie. remove_app jackett sonarr lidarr radarr
remove_app() {
    clear
    for app in "${@}"; do
        app=$(lower_case ${app})
        task_warn "You are about to delete all settings and files for ${app}..."
        check_continue
        task_info "Deleting existing settings or files for ${app}..."
        task_start "Stopping ${app} service..."
        systemctl stop "${app}" 2> /dev/null
        task_pass
        task_start "Removing /opt/$(title_case ${app})..."
        rm -Rf /opt/"$(title_case ${app})" 2> /dev/null
        task_pass
        task_start "Removing /var/lib/${app}..."
        rm -Rf /var/lib/"${app}" 2> /dev/null
        task_pass
        task_start "Removing service config /etc/systemd/system/${app}.service..."
        rm /etc/systemd/system/"${app}.service"* 2> /dev/null
        task_pass
        task_info "Removing ${app} service user account..."
        deluser "${app}" 2> /dev/null
        task_start "Reloading systemctl daemon..."
        systemctl daemon-reload 2> /dev/null
        task_pass
        task_info "${app} deleted.\n"
    done
}


active_services() {
    task_info "Active Services"
    for app in ${APPLIST}; do
        if [ $(systemctl is-active "${app}") = "active" ]; then
            task_pass "${app} service is active and running."
        fi
    done
}


check_service() {
    task_start "Checking service status for ${1}..."
    if [ $(systemctl is-active "$1") = "active" ]; then
        task_pass
    else
        task_fail
    fi
}

default_ports() {
    task_info "Default Application Ports"
    task_info "Jackett:    http://hostip:9117"
    task_info "Sonarr:     http://hostip:8989"
    task_info "Lidarr:     http://hostip:8686"
    task_info "Radarr:     http://hostip:7878"
    task_info "Readarr:    http://hostip:8787"
    task_info "Prowlarr:   http://hostip:9696"
}

# Display a list of menu items for selection
display_menu () {
    clear
    banner_info
    echo "=============="                         
    echo " Menu Options "
    echo "=============="
    echo
    printf "1.  Install ALL (jackett sonarr lidarr radarr readarr prowlarr)\n"
    printf "2.  Install jackett only\n"
    printf "3.  Install sonarr only\n"
    printf "4.  Install lidarr only\n"
    printf "5.  Install radarr only\n"
    printf "6.  Install readarr only\n"
    printf "7.  Install prowlarr only\n"
    printf "\n8.  Remove ALL (jackett sonarr lidarr radarr readarr prowlarr)\n"
    printf "9.  Remove jackett only\n"
    printf "10. Remove sonarr only\n"
    printf "11. Remove lidarr only\n"
    printf "12. Remove radarr only\n"
    printf "13. Remove readarr only\n"
    printf "14. Remove prowlarr only\n"
    printf "\n15. Show active services\n"
    printf "16. Show application default ports\n"
    printf "17. Show application source urls\n"
    printf "\n18. Exit\n"
    echo
    printf "    Enter option [1-18]: "

    while :
    do
    read choice
    case ${choice} in
        1)  setup_app jackett sonarr lidarr radarr readarr prowlarr
            ;;
        2)  setup_app jackett
            ;;
        3)  setup_app sonarr
            ;;
        4)  setup_app lidarr
            ;;
        5)  setup_app radarr
            ;;
        6)  setup_app readarr
            ;;
        7)  setup_app prowlarr
            ;;
        8)  remove_app jackett sonarr lidarr radarr readarr prowlarr
            ;;
        9)  remove_app jackett
            ;;
        10) remove_app sonarr
            ;;
        11) remove_app lidarr
            ;;
        12) remove_app radarr
            ;;
        13) remove_app readarr
            ;;
        14) remove_app prowlarr
            ;;
        15) clear
            active_services
            ;;
        16) clear
            default_ports
            ;;
        17) clear
            check_sources
            ;;
        18) printf "\nExiting...\n"
            exit
            ;;
        *)  clear
            display_menu
            ;;
    esac
    printf "\nSelection [${choice}] completed.\n"
    press_any_key
    clear
    display_menu
    done
}

main() {
    check_sources
    script_info
    check_superuser
    check_continue
    pkg_updates
    check_status
    display_menu
}

main
