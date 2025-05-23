#!/usr/bin/env bash
#
# NAME:
#   setupPWSH
# DOB:
#   05/14/2025
# DESCRIPTION:
#   Simple setup script that will add necessary RHEL repo for PWSH to Fedora
#   host, then update DNF and install PowerShell 7.
# DEPENDENCIES:
#   + curl
# GITHUB:
#   https://github.com/RCovey1976/Bash_Scripting/blob/main/setupPWSH.sh
# LICENSE:
#   https://github.com/RCovey1976/Bash_Scripting/blob/main/LICENSE
# CONTRIBUTORS:
#   @ RCovey1976 (Raymond Covey)
# CHANGELOG (v1.0):
#   + Created script framework
#   + Added setupPWSH() function
#   + Reviewed code
#   + Tested on Fedora host (VM); confirmed working

# Function checkCurl(); will check host to see if Curl is installed, and if not,
# will install it. Written for a Fedora host.
checkCurl() {
	# Check system for curl, and if not present, install using DNF.
	if ! rpm -q curl; then
		echo "Curl not present; installing now.."

		# Install curl via DNF.
		sudo dnf install curl -y

		# Confirm that curl has been installed.
		if rpm -q curl > /dev/null 2>&1; then
			echo "Curl has been successfully installed."
		else
			echo "Curl has not been installed."
		fi
	fi

	# Move onto main function.
	setupPWSH
}

# Function setupPWSH(); will pull repo and add to /etc/yum.repos.d; will then update
# and install PowerShell 7 to the host.
setupPWSH() {
	echo ''
	echo "Setting up PowerShell, please wait..."
	curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
	sudo dnf makecache -y
	sudo dnf install powershell -y

	# Confirm that PowerShell was installed successfully.
	if [ $? -eq 0 ]; then
		echo "Successfully installed PowerShell."
  	else
    	echo "Failed to install PowerShell. Please check logs for further details."
  	fi
}

checkCurl
