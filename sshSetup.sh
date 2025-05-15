#!/usr/bin/env bash
#
# NAME:
#   sshSetup
# DOB:
#   05/14/2025
# DESCRIPTION:
#   Simple script to check if SSH is installed on a Fedora host, and if not,
#   will install and configure the settings in order for SSH to work properly.
# DEPENDENCIES:
#   - <none>
# GITHUB:
#   https://github.com/RCovey1976/Bash_Scripting/blob/main/sshSetup.sh
# LICENSE:
#   https://github.com/RCovey1976/Bash_Scripting/blob/main/LICENSE
# CONTRIBUTORS:
#   @ RCovey1976 (Raymond Covey)
# CHANGELOG (v1.3):
#   + Created script framework
#   + Added sshSetup() function
#   + Tested script on Fedora host (VM); confirmed working

sshSetup() {
	# Start by verifying that OpenSSH is installed, and if not, trigger the
	# installation.
	if ! rpm -q openssh-clients; then
		echo "SSH setup started; please wait..."

		# Install the openssh client
		sudo dnf install -y openssh-clients

		# Enable and start the SSH service.
		sudo systemctl enable sshd
		sudo systemctl start sshd

		# Configure firewall to allow SSH.
		sudo firewall-cmd --add-service=ssh --permanent
		sudo firewall-cmd --reload
		echo "SSH setup completed"
	fi
}

sshSetup