#!/usr/bin/env bash
#
# Update script for Fedora hosts.
# Will run through updates (for both DNF and FlatPaks), write output to LogFile,
# cleanup unused packages, clean up /var/log, and prompt user to restart.
#
# Written by Raymond Covey - 03/07/2025

# Define log file location
LOG_FILE="/path/to/logfile/update_$(date +'%m-%d-%Y').log"

# Create or clear the log file.
> "$LOG_FILE"

# Creating new function update_system()
update_system() {
  #Updating system with DNF
  echo "Update started at $(date)" | tee -a "$LOG_FILE"
  sudo dnf update -y >> "$LOG_FILE" 2>&1

  # Updating Flatpak packages
  echo "Updating Flatpak packages..." | tee -a "$LOG_FILE"
  flatpak update -y >> "$LOG_FILE" 2>&1

  echo "Updates completed; output written to "$LOG_FILE"" | tee -a "$LOG_FILE"
}

# New function clean(); will remove old packages and clean /var/log
clean_up() {
  echo "Cleaning up system; please wait..." | tee -a "$LOG_FILE"
  sudo dnf autoremove -y >> "$LOG_FILE" 2>&1
  sudo dnf clean all >> "$LOG_FILE" 2>&1
  sudo rm -rf /var/log/* >> "$LOG_FILE" 2>&1
  echo "Cleaning complete." | tee -a "$LOG_FILE"
}

# New function restart_system(); will prompt user if they would like
# to reboot system after completed all tasks, and log response.
restart_system() {
  # Ask user if they'd like to restart.
  read -p "Would you like to restart your system now? [Y/n]: " response

  # Determines actions to be taken, pending on user response.
  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "System update complete. Restarting system..." | tee -a "$LOG_FILE"
    reboot -h now
  else
    echo "System update complete. No restart performed." | tee -a "$LOG_FILE"
  fi
}

update_system
clean_up
restart_system
