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

  # Cleans up all log files stores in /var/log, if needed.
  # Can be commented out if not needed.
  sudo rm -rf /var/log/* >> "$LOG_FILE" 2>&1
  echo "Cleaning complete." | tee -a "$LOG_FILE"
}

# New function restart_system(); will prompt user if they would like
# to reboot system after completed all tasks, log response, and complete
# requested action.
restart_system() {
  echo "Please choose one of the following options: "
  echo "1) Shutdown Host"
  echo "2) Restart Host"
  echo "3) Exit Script"
  echo " "

  # Prompt the user for input
  read -p "Enter your choice (1-3): " response

  # Determines actions to be taken, depending on user response.
  case $response in
    1)
      echo "Shutting down host, please wait.." | tee -a "$LOG_FILE"
      sleep 1
      shutdown now
      ;;
    2)
      echo "Restarting host, please wait.." | tee -a "$LOG_FILE"
      sleep 1
      reboot
      ;;
    3)
      echo "Exiting script, please wait.." | tee -a "$LOG_FILE"
      sleep 1
      exit 0
      ;;
    *)
      echo "Invalid response, please choose another option..."
      sleep 1
      restart_system
      ;;
  esac
}

update_system
clean_up
restart_system
