#!/usr/bin/env bash
# BeEF/install.sh

# install.sh
#	Install BeEF
#	Based on: https://github.com/beefproject/beef/wiki/Installation
# Tested on:
#	Kali:
#		2018.1
#	Debian:
#		9 (stretch) 


set -eo pipefail
# -e exit if any command returns non-zero status code
# -o pipefail force pipelines to fail on first non-zero status code
# Cannot use -u, it causes 'source ${HOME}/.rvm/scripts/rvm' to fail
# 	Error: ${HOME}/.rvm/scripts/functions/support/: line 182: _system_name: unound variable


FATAL="\\033[1;31mFATAL\\033[0m"
WARNING="\\033[1;33mWARNING\\033[0m"
PASS="\\033[1;32mPASS\\033[0m"
INFO="\\033[1;36mINFO\\033[0m"


function check_compatibility {

	# Check if Distribution is Kali or Debian
	# If Kali check if version is 2018.1 
	# If Debian check if version 9 (stretch)
	# Set target_os to Kali or Debian

	local kali_supported_version
	local debian_supported_version
	local distribution_id
	local os_version_id

	target_os=""
	kali_supported_version="2018.1"
	debian_supported_version="9"
	distribution_id="$(lsb_release -i | awk '{print $3}')"
	os_version_id="$(grep "VERSION_ID" /etc/os-release | awk -F '"' '{print $2}')"

	echo -e "[${INFO}] Checking OS compatability"

	if [[ "${distribution_id}" == "Kali" ]]; then

		echo -e "[${INFO}] Checking Kali version compatability"
		
		if [[ ! "${os_version_id}" == "${kali_supported_version}" ]]; then
			echo -e "[${WARNING}] Only tested on Kali Rolling ${kali_supported_version}"
			target_os="Kali"
			sleep 2
		else
			echo -e "[${PASS}] Sucessfully completed compatability check"
			target_os="Kali"
		fi
	
	elif [[ "${distribution_id}" == "Debian" ]]; then 

		echo -e "[${INFO}] Checking Debian version compatability"

		if [[ ! "${os_version_id}" == "${debian_supported_version}" ]]; then
			echo -e "[${WARNING}] Only tested on Debian ${debian_supported_version}"
			target_os="Debian"
			sleep 2
		else
			echo -e "[${PASS}] Sucessfully completed compatability check"
			target_os="Debian"
		fi
		
	else

		echo -e "[${FATAL}] Only tested on Kali/ Debian"
		exit 1
	fi
}


function install_dependencies {

	# Install curl, git and nodejs via apt
	# Install python3 and python3-pip via apt
	
	deps=(curl git nodejs python3)

	echo -e "[${INFO}] Checking if dependencies are present" 

	# apt update runs even if all deps are present 
	sudo apt -qq update
	
	for package in "${deps[@]}"; do
		if ! [ -x "$(command -v "${package}")" ]; then
			sudo apt -qq install -y "${package}"
		else 
			echo -e "[${PASS}] ${package} already installed"
		fi
	done

	if ! [ -x "$(command -v pip3)" ]; then
		# Package name differs from binary
		sudo apt -qq install -y python3-pip
	else
		echo -e "[${PASS}] python3-pip already installed"
	fi

	# Clean up any redundant dependencies
	sudo apt -qq autoremove
}


function source_rvm {

	if [[ "${target_os}" == "Kali" ]]; then 
		# shellcheck disable=SC1091
		source "/etc/profile.d/rvm.sh"

	elif [[ "${target_os}" == "Debian" ]]; then
		# shellcheck disable=SC1090
		source "${HOME}/.rvm/scripts/rvm"

	else 
		echo -e "[${FATAL}] Compatibility issue"
		exit 1
	fi
}


function install_rvm {

	# Fetch RVM PGP signing key, add it to keyring
	# Install RVM via https://get.rvm.io

	if ! [ -x "$(command -v rvm)" ]; then

		echo -e "[${INFO}] Installing RVM, this will take a while..."
		if gpg --list-keys | grep -q "409B6B1796C275462A1703113804BB82D39DC0E3" ; then
			echo -e "[${INFO}] RVM signing key already in keyring"
		else

			echo -e "[${INFO}] Getting RVM signing key"
			if curl -sSL https://rvm.io/mpapis.asc | gpg --import - ; then
				echo -e "[${PASS}] Sucessfully imported RVM signing key"
			else
				echo -e "[${FATAL}] Failed to get or import RVM signing key"
				exit 1
			fi
		fi

		echo -e "[${INFO}] Getting RVM"
		if curl -sSL https://get.rvm.io | bash -s stable ; then
			echo -e "[${PASS}] Installed RVM"
			source_rvm
		else

			echo -e "[${FATAL}] Compatibility issue"
			exit 1
		fi

	else
		echo -e "[${PASS}] RVM already installed"
	fi
}

function install_ruby {

	# Install Ruby version 2.3.0 via RVM
	# Set Ruby 2.3.0 as default for RVM 

	local ruby_version
	ruby_version="2.3.0"

	if [[ "${target_os}" == "Kali" ]]; then 
		# shellcheck disable=SC1091
		source "/etc/profile.d/rvm.sh"

	elif [[ "${target_os}" == "Debian" ]]; then
		# shellcheck disable=SC1090
		source "${HOME}/.rvm/scripts/rvm"

	else 
		echo -e "[${FATAL}] Compatibility issue"
		exit 1
	fi


	if rvm list default | grep -q "${ruby_version}" ; then
		echo -e "[${PASS}] RVM Ruby version already ${ruby_version}"
	else
		echo -e "[${INFO}] Installing Ruby ${ruby_version}"
		if rvm install "${ruby_version}" ; then
			echo -e "[${PASS}] Ruby ${ruby_version} installed"
    		rvm use "${ruby_version}" -- default
    	else
    		echo -e "[${FATAL}] Failed to install Ruby ${ruby_version}"
    		exit 1
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

	source_rvm

		exit 1
	fi

	echo -e "[${INFO}] Installing Bundler"
	gem install bundler

	if bundle install --without test development ; then
		echo -e "[${PASS}] Sucessfully installed BeEF"
		exit 0
	else
		echo -e "[${FATAL}] Failed to install BeEF"
		exit 1
	fi
}


function main {
	
	check_compatibility
	install_dependencies
	install_rvm
	install_ruby
	get_beef
	install_beef
}


main "$@"