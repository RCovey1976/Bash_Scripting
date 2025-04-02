#!/usr/bin/env bash
#
# NAME:
#   debUpdate
# DOB:
#   04/01/2025
# USAGE:
#   $ sudo ./debUpdate.sh
# DESCRIPTION:
#   Update script for Debian-based hosts; will run through both DNF and FlatPak updates,
#   cleanup old or unused packages, cleanup /var/log, and prompt user to shutdown
#   or restart host, view update log file, or exit script.
#   Script is the same as fedoraUpdate.sh (in same repository), modified for DEB-based hosts.
# DEPENDENCIES:
#   + Oh-My-ZSH (https://ohmyz.sh/)
#   + FlatPak/FlatHub (https://flathub.org/setup/Debian) <- Check for your Ubuntu or DEB-based OS on Flathub.org for setup instructions.
# GITHUB:
#   https://github.com/RCovey1976/Bash_Scripting/blob/main/debUpdate.sh
# LICENSE:
#   https://github.com/RCovey1976/Bash_Scripting/blob/main/LICENSE
# CONTRIBUTORS:
#   @ RCovey1976 (Raymond Covey)
# NOTES (DEVELOPER-USE ONLY):
#   + Add firmware updates (fwupdmgr)?
#   + Renamed and revamped restartSystem(); now renamed mainMenu()

# Verify user has sudo permissions; if not, inform user and exit script.
if [ $EUID != 0 ];
then
        echo "You must run this as root $0"
        exit 1
fi

# Define log file location
LOG_FILE="/home/rcovey/Documents/Coding/LogFiles/Updates/$(date +'%m-%d-%Y')_updates.log"

# Create or clear the log file.
> "$LOG_FILE"

# Creating new function update_system()
updateSystem() {
  #Updating system with DNF
  echo "Update started at $(date)" | tee -a "$LOG_FILE"
  apt-get update -y >> "$LOG_FILE" 2>&1
  apt-get upgrade -y >> "$LOG_FILE" 2>&1
  apt-get dist-upgrade -y >> "$LOG_FILE" 2>&1
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
  apt-get autoremove -y >> "$LOG_FILE" 2>&1
  apt-get autoclean >> "$LOG_FILE" 2>&1

  # Prompt user if they would like to remove old log files from
  # /var/log; removes logs on y/Y, continues to next portion of script
  # on n/N.
  read -p "Would you like to clean the logs (rm -rf /var/log/*)? (y/n): " choice

  if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
      # Run the cleaning commands
      echo "Cleaning logs..." | tee -a "$LOG_FILE"
      rm -rf /var/log/* >> "$LOG_FILE" 2>&1
      echo "Cleaning complete." | tee -a "$LOG_FILE"
      mainMenu
  else
      # Skip the cleaning commands and continue
      echo "Skipping log cleaning." | tee -a "$LOG_FILE"
      mainMenu
  fi
}

# New function restart_system(); will prompt user if they would like
# to reboot system after completed all tasks, log response, and complete
# requested action.
mainMenu() {
  echo
  echo "Please choose one of the following options: "
  echo "1) Start Script"
  echo "2) View LogFile"
  echo "3) View Script"
  echo "4) Exit Script"
  echo "5) Restart Host"
  echo "6) Shutdown Host"
  echo

  # Prompt the user for input
  read -p " >> Enter your choice (1-4): " response

  # Determines actions to be taken, depending on user response.
  case $response in
    1)
      echo "Starting script, please wait..." | tee -a "$LOG_FILE"
      updateSystem
      ;;
    2)
      echo "Printing log file, please wait.." | tee -a "$LOG_FILE"
      cat $LOG_FILE
      mainMenu
      ;;
    3)
      echo "Printing script file, please wait.." | tee -a "$LOG_FILE"
      cat /home/rcovey/Documents/Coding/Bash/fedoraUpdate.sh
      mainMenu
      ;;
    4)
      echo "Exiting script. Goodbye!" | tee -a "$LOG_FILE"
      exit 0
      ;;
    5)
      echo "Rebooting host, please wait.." | tee -a "$LOG_FILE"
      reboot
      ;;
    6)
      echo "Shutting down host, please wait.." | tee -a "$LOG_FILE"
      shutdown now
      ;;
    *)
      echo "Invalid response, please choose another option..."
      mainMenu
      ;;
  esac
}

mainMenu
