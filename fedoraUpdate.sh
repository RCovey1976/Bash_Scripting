#!/usr/bin/env bash
#
# NAME:
#   fedoraUpdate
# DOB:
#   03/07/2025
# DESCRIPTION:
# 	Update script for Fedora hosts; will run through both DNF and FlatPak updates,
# 	cleanup old or unused packages, cleanup /var/log, and prompt user to shutdown
#	or restart host, view update log file, or exit script.
# DEPENDENCIES:
#   + Oh-My-ZSH (https://ohmyz.sh/)
#   + FlatPak (https://flatpak.org/setup/Fedora)
# GITHUB:
#	  https://github.com/RCovey1976/Bash_Scripting/blob/main/fedoraUpdate.sh
# LICENSE:
#   https://github.com/RCovey1976/Bash_Scripting/blob/main/LICENSE
# CONTRIBUTORS:
#	  @ RCovey1976 (Raymond Covey)
#

# Verify user has sudo permissions; if not, inform user and exit script.
if [ $EUID != 0 ];
then
        echo "You must run this as root $0"
        exit 1
fi

# Define log file location
LOG_FILE="/path/to/logfiles/$(date +'%m-%d-%Y')_updates.log"

# Create or clear the log file.
> "$LOG_FILE"

# Creating new function update_system()
updateSystem() {
  #Updating system with DNF
  echo "Update started at $(date)" | tee -a "$LOG_FILE"
  dnf update -y >> "$LOG_FILE" 2>&1
  omz update >> "$LOG_FILE" 2>&1

  # Updating Flatpak packages
  echo "Updating Flatpak packages..." | tee -a "$LOG_FILE"
  flatpak update -y >> "$LOG_FILE" 2>&1

  echo "Updates completed; output written to "$LOG_FILE"" | tee -a "$LOG_FILE"
  cleanUp
}

# New function clean(); will remove old packages and clean /var/log
cleanUp() {
  echo "Cleaning up system; please wait..." | tee -a "$LOG_FILE"
  sudo dnf autoremove -y >> "$LOG_FILE" 2>&1
  sudo dnf clean all >> "$LOG_FILE" 2>&1

  # Prompt user if they would like to remove old log files from
  # /var/log; removes logs on y/Y, continues to next portion of script
  # on n/N.
  read -p "Would you like to clean the logs (rm -rf /var/log/*)? (y/n): " choice

  if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
      # Run the cleaning commands
      echo "Cleaning logs..." | tee -a "$LOG_FILE"
      rm -rf /var/log/* >> "$LOG_FILE" 2>&1
      echo "Cleaning complete." | tee -a "$LOG_FILE"
  else
      # Skip the cleaning commands and continue
      echo "Skipping log cleaning." | tee -a "$LOG_FILE"
      restartSystem
  fi
}

# New function restart_system(); will prompt user if they would like
# to reboot system after completed all tasks, log response, and complete
# requested action.
restartSystem() {
  echo
  echo "Please choose one of the following options: "
  echo "1) Shutdown Host"
  echo "2) Restart Host"
  echo "3) View Log File"
  echo "4) Exit Script"
  echo " "

  # Prompt the user for input
  read -p "Enter your choice (1-4): " response

  # Determines actions to be taken, depending on user response.
  case $response in
    1)
      echo "Shutting down host, please wait.." | tee -a "$LOG_FILE"
      shutdown now
      ;;
    2)
      echo "Restarting host, please wait.." | tee -a "$LOG_FILE"
      reboot
      ;;
    3)
      echo "Loading log file, please wait.." | tee -a "$LOG_FILE"
      cat $LOG_FILE
      restartSystem
      ;;
    4)
      echo "Exiting script, please wait.." | tee -a "$LOG_FILE"
      exit 0
      ;;
    *)
      echo "Invalid response, please choose another option..."
      restartSystem
      ;;
  esac
}

updateSystem
