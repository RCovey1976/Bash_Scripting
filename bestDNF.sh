#!/usr/bin/env bash
#
# NAME:
#   bestDNF
# DOB:
#   03/07/2025
# DESCRIPTION:
#   Setup script that displays default (or current) DNF config file, saves this
#	  to a backup file in case of issues, and then appends a new dnf.conf with
#	  optimal settings. This can be reversed by deleting the altered dnf.conf,
#	  and renaming the "dnf.bak" file to "dnf.conf", saving, and running updates.
#	  Found initial script on Fedora forums (will update with link when possible),
#	  and script updated by yours truly.
# DEPENDENCIES:
#   + <none>
# GITHUB:
#   https://github.com/RCovey1976/Bash_Scripting/blob/main/bestDNF.sh
# LICENSE:
#   https://github.com/RCovey1976/Bash_Scripting/blob/main/LICENSE
# CONTRIBUTORS:
#	 @ Fedora Forums
#	 @ RCovey1976 (Raymond Covey)
#

# Start of script; output current DNF config to console, then
# create a backup of original config using 'mv'; save backup to same directory.
echo ''
echo "Updating DNF config file, please wait..."
echo -e "Here is the current DNF config: `n`"
cat /etc/dnf/dnf.conf

# Copy original dnf.conf to a backup file, just in case.
mv /etc/dnf/dnf.conf /etc/dnf/dnf.bak

# Setup array of lines to append to DNF config file.
append_lines=(
	''
	'[main]'
	'gpgcheck=1'
	'installonly_limit=3'
	'clean_requirements_on_remove=True'
	'best=False'
	'skip_if_unavailable=True'
	'fastestmirror=1'
	'max_parallel_downloads=10'
	'defaultyes=True'
	''
)

# For-loop that will write all lines fron append_lines to DNF config file.
for line in "${append_lines[@]}";
do
	echo "$line" >> /etc/dnf/dnf.conf
done

# Print to console the current content of the DNF config file, and prompt
# user to hit [ENTER] once done to progress the script.
echo -e 'Printing new DNF config file, please wait...`n'
cat /etc/dnf/dnf.conf
