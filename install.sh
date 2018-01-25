#!/usr/bin/env bash
# BeEF/install.sh

# install.sh
#	Install BeEF
#	Based on: https://github.com/beefproject/beef/wiki/Installation
# Tested on:
#	Kali:
#		2018.1
# TODO: 
# 	Test on Debian


set -eo pipefail
# -e exit if any command returns non-zero status code
# -o pipefail force pipelines to fail on first non-zero status code


FATAL="\\033[1;31mFATAL\\033[0m"
WARNING="\\033[1;33mWARNING\\033[0m"
PASS="\\033[1;32mPASS\\033[0m"
INFO="\\033[1;36mINFO\\033[0m"


function check_compatibility {

	# Check if Distribution is Kali
	# Check if Kali version is 2018.1

	local supported_version
	local distribution_id
	local os_version_id
	supported_version="2018.1"
	distribution_id="$(lsb_release -i | awk '{print $3}')"
	os_version_id="$(grep "VERSION_ID" /etc/os-release | awk -F '"' '{print $2}')"

	echo -e "[${INFO}] Checking OS compatability"

	if [[ ! "${distribution_id}" == "Kali" ]]; then
		echo -e "[${FATAL}] Only tested on Kali Linux"
		exit 1
	else
		echo -e "[${INFO}] Checking Kali version compatability"

		if [[ ! "${os_version_id}" == "${supported_version}" ]]; then
			echo -e "[${WARNING}] Only tested on Kali Rolling 2018.1"
		else
			echo -e "[${PASS}] Sucessfully completed compatability check"
		fi
	fi
}


function install_dependencies {

	# Install curl, git and nodejs via apt

	sudo apt update
	
	if ! [ -x "$(command -v curl)" ] || ! [ -x "$(command -v git)" ] || ! [ -x "$(command -v nodejs)" ] ; then
		echo -e "[${INFO}] Installing curl, git and nodejs "
		sudo apt install -y curl git nodejs
	else
		echo -e "[${PASS}] curl, git and nodejs already installed"
	fi

}


function install_rvm {

	# Fetch RVM PGP signing key, add it to keyring
	# Install RVM via https://get.rvm.io
	# Install Ruby version 2.3.0 via RVM
	# Set Ruby 2.3.0 as default for RVM 

	local ruby_version
	ruby_version="2.3.0"

	if ! [ -x "$(command -v rvm)" ]; then

		echo -e "[${INFO}] Installing RVM, this will take a while..."
		if gpg --list-keys | grep "409B6B1796C275462A1703113804BB82D39DC0E3" ; then
			echo -e "[${INFO}] RVM signing key already in keyring"
		else

			echo -e "[${INFO}] Getting RVM signing key"
			if curl -sSL https://rvm.io/mpapis.asc | gpg --import - ; then
				echo "[] Sucessfully imported RVM signing key"
			else
				echo -e "[${FATAL}] Failed to get and/or import RVM signing key"
				exit 1
			fi
		fi
		echo -e "[${INFO}] Getting RVM"
		if curl -sSL https://get.rvm.io | bash -s stable ; then
			echo -e "[${PASS}] Installed RVM"
			
			if grep -q "source /etc/profile.d/rvm.sh" "${HOME}/.bashrc" ; then
				echo -e "[${PASS}] 'source /etc/profile.d/rvm.sh' already in '~/.bashrc'"
			else
				echo "source /etc/profile.d/rvm.sh" >> ~/.bashrc
				source "${HOME}"/.bashrc
			fi

		else
			echo -e "[${FATAL}] Failed to install RVM"
			exit 1
		fi
	
	else
		echo -e "[${PASS}] RVM already installed"
	fi

	source "/etc/profile.d/rvm.sh"

	if rvm list default 2.3.0 | grep -q "${ruby_version}" ; then
		echo -e "[${PASS}] RVM Ruby version already ${ruby_version}"
	else
		echo -e "[${INFO}] Installing Ruby 2.3.0"
		if rvm install 2.3.0 ; then
			echo -e "[${PASS}] Ruby ${ruby_version} installed"
    		rvm use 2.3.0 -- default
    	else
    		echo -e "[${FATAL}] Failed to install Ruby ${ruby_version}"
    	fi
    fi
}


function get_beef {

	# Check for existing 'beef' directory
	# Rename existing 'beef' directory
	# Clone github.com/beefproject/beef into 'beef'

	local move_time
	local old_beef_dir_name
	move_time=$(date +%b%d-%H:%M-%Z)
	old_beef_dir_name="beef.old.${move_time}"

	if [ -d "beef" ]; then
		echo -e "[${INFO}] Renaming existing 'beef' directory to '${old_beef_dir_name}'"
		mv -f "beef" "${old_beef_dir_name}"
	fi

	echo -e "[${INFO}] Cloning BeEF source"
	if git clone "git://github.com/beefproject/beef.git" ; then
		echo -e "[${PASS}] Sucessfully cloned BeEF source into 'beef'"
	else
		echo -e "[${FATAL}] Failed clone BeEF source"
		exit 1
	fi
}


function install_beef {

	# Change directory to 'beef'
	# Source '/etc/profile.d/rvm.sh' again just to be sure
	# Install Bundler via gem
	# Install BeEF via bundle[r]

	cd beef || exit

	source "/etc/profile.d/rvm.sh"

	echo -e "[${INFO}] Installing Bundler"
    gem install bundler

    if bundle install ; then
    	echo -e "[${PASS}] Sucessfully installed BeEF"
    else
    	echo -e "[${FATAL}] Failed to install BeEF"
    	exit 1
    fi
}


function main {
	
	check_compatibility
	install_dependencies
	install_rvm
	get_beef
	install_beef
}


main "$@"