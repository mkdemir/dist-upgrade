#!/bin/bash

# Author: mkdemir

version="v1.0.0"

# Functions

# Function to provide feedback to the user in case of an error
display_error() {
    echo -e "[-] Error: $1\n" >&2
    exit 1
}

# Function to provide feedback to the user if the operation is successful
display_success() {
    echo -e "[+] $1\n"
}

# Function to display the title of the script
show_title() {
    echo -e """
 ██████╗ ██████╗  █████╗  ██████╗██╗  ██╗██╗   ██╗██████╗ 
██╔════╝ ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██║   ██║██╔══██╗
██║█████╗██████╔╝███████║██║     █████╔╝ ██║   ██║██████╔╝
██║╚════╝██╔══██╗██╔══██║██║     ██╔═██╗ ██║   ██║██╔═══╝ 
╚██████╗ ██████╔╝██║  ██║╚██████╗██║  ██╗╚██████╔╝██║     
 ╚═════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝      
                    ===================================
                    = Version: $version                 
                    = Date: $(date '+%Y-%m-%dT%H:%M:%S')
                    ===================================\n
    """
}

# Main script

# Display the title of the script
show_title

# Get the backup directory from the user
backup_directory="$1"

backup_directory="${backup_directory%/}"  # Remove trailing slash if present

# Check if the backup directory is provided
if [ -z "$backup_directory" ]; then
    display_error "Backup directory not specified.\n[+] Example: bash $1 /path"
fi

# Check if an old backup_files directory exists
if [ -d "$backup_directory/backup_files" ]; then
    display_error "Old backup_files directory exists."
    exit
fi

# Create the backup_files directory
backup_files_directory="$backup_directory/backup_files"
mkdir -p "$backup_files_directory" || display_error "Failed to create backup directory."

# Step 0: Get Disk Information
display_success "Step 0: Getting Disk Information"
disk_info="$backup_files_directory/disk_info.txt"
echo "==================== df -h ====================" >> "$disk_info"
df -h >> "$disk_info"
echo "===============================================" >> "$disk_info"
echo "" >> "$disk_info"
echo "==================== du -h ====================" >> "$disk_info"
du -h "$backup_files_directory" >> "$disk_info"
echo "===============================================" >> "$disk_info"
echo "" >> "$disk_info"
echo "==================== lsblk ====================" >> "$disk_info"
lsblk >> "$disk_info"
echo "===============================================" >> "$disk_info"
echo "" >> "$disk_info"
echo "==================== fdisk ====================" >> "$disk_info"
sudo fdisk -l >> "$disk_info"
echo "===============================================" >> "$disk_info"
echo "" >> "$disk_info"
echo "==================== parted ===================" >> "$disk_info"
sudo parted -l 2>/dev/null >> "$disk_info"
echo "===============================================" >> "$disk_info"

# Step 1: Get Operating System Information
display_success "Step 1: Getting Operating System Information"
os_info=$(lsb_release -d)
os_release=$(cat /etc/os-release)
info_name=$(uname -a)
general_os_info="$backup_files_directory/general_os_info.txt"

# Step 2: Check System Logs
display_success "Step 2: Checking System Logs"
echo "==================== lsb_release -d ====================" >> "$general_os_info"
echo "$os_info" >>  "$general_os_info"
echo "" >> "$general_os_info"
echo "==================== os_release ====================" >> "$general_os_info"
echo "$os_release" >>  "$general_os_info"
echo "" >> "$general_os_info"
echo "==================== info_name ====================" >> "$general_os_info"
echo "$info_name" >>  "$general_os_info"

syslog_file="/var/log/syslog"
dpkg_log="/var/log/dpkg.log"
apt_history="/var/log/apt/history.log"
error_log="$backup_files_directory/error_messages.txt"
grep -i "error" $syslog_file $dpkg_log $apt_history > "$error_log"

# Step 3: Check Network Connection
display_success "Step 3: Checking Network Connection"
network_status=$(curl --output /dev/null --silent --head --fail google.com &> /dev/null && echo "Internet connection available." || echo "No internet connection.")
echo "Network Connection Status: $network_status" >> "$backup_files_directory/network_status.txt"
echo -e "$network_status\n"

# Step 4: Check Repository Information
display_success "Step 4: Checking Repository Information"
repository_settings="/etc/apt/sources.list"
additional_repositories="/etc/apt/sources.list.d/*"

if [ ! "$(ls -A /etc/apt/sources.list.d/)" ]; then
    echo "Warning: Additional repository files not found." >&2
else
    source_list_directory="$backup_files_directory/sources.list.d"
    mkdir -p "$source_list_directory"
    cp /etc/apt/sources.list.d/* "$source_list_directory" || display_error "Failed to copy repository files."
fi

display_success "Step 5: Getting List of Installed Packages"

# Step 5: Get List of Installed Packages
installed_packages="$backup_files_directory/installed_packages.txt"
dpkg --get-selections > "$installed_packages" || display_error "Failed to list installed packages."

# Step 6: Get Service Status
display_success "Step 6: Getting Service Status"
service_status="$backup_files_directory/service_status.txt"
systemctl list-units --type=service > "$service_status" || display_error "Failed to get service status."

# Copy repository settings
cp "$repository_settings" "$backup_files_directory" || display_error "Failed to copy repository settings."

# Step 7: Generate Timestamp
display_success "Step 7: Generating Timestamp"
timestamp=$(date '+%Y-%m-%d_%H-%M-%S')

# Step 8: Compress Backup Directory
display_success "Step 8: Compressing Backup Directory"
backup_filename="$backup_directory/backup_$timestamp.tar.gz"
tar -czvf "$backup_filename" -C "$backup_files_directory" . || display_error "An error occurred during backup."
echo ""

# Step 9: Backup Completed
display_success "Step 9: Backup Completed"
echo ""

# Prompt user for confirmation
read -p "[?] Warning: You are about to delete $backup_files_directory directory. Do you want to continue? (Y/N): " confirm_delete

if [ "${confirm_delete^^}" == "Y" ]; then
    # Delete the backup directory
    rm -r "$backup_files_directory"
    display_success "Successfully deleted $backup_files_directory directory."
fi

display_success "Backup completed: $backup_filename"
