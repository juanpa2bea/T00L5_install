#!/bin/bash

NOW=$(date +"-%b-%d-%y-%H%M%S")

clear
##figlet -f slant Install MSF Console! -c
echo '                ____           __        ____   __  ________ ______'
echo '               /  _/___  _____/ /_____ _/ / /  /  |/  / ___// ____/'
echo '               / // __ \/ ___/ __/ __ `/ / /  / /|_/ /\__ \/ /_    '
echo '             _/ // / / (__  ) /_/ /_/ / / /  / /  / /___/ / __/    '
echo '            /___/_/ /_/____/\__/\__,_/_/_/  /_/  /_//____/_/       '
                                                                   
echo '                      ______                       __     __'
echo '                     / ____/___  ____  _________  / /__  / /'
echo '                    / /   / __ \/ __ \/ ___/ __ \/ / _ \/ / '
echo '                   / /___/ /_/ / / / (__  ) /_/ / /  __/_/  '
echo '                   \____/\____/_/ /_/____/\____/_/\___(_)   '
                                                            
echo
echo
echo
echo
echo "	...........:[Yo! script to install MSF]:............."	
echo "By Juan_Pablo_BARRIGA"
echo "Version 0.1.0"
echo "	porquesiempretu  "
echo
echo
echo
echo
echo
###################################

function print_good ()
{
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

###################################

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

###################################

function print_status ()
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

###################################

function check_root ()
{
    if [ "$(id -u)" != "0" ]; then
	print_error "You must run this script with root privileges"
	exit 1
    fi
}

###################################

function install_ruby ()
{
    if [[ ! -e ~/.rbenv/plugins/ruby-build ]]; then
	print_status "Installing RVM"
	##(JP) creating directory where git clone rbenv will be done
	git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    fi
    
    if [[ $? -eq 0 ]]; then
	print_good "Git clone done"
	print_status "Doing export from PATH in .bashrc"

	echo 'export PATH="$HOME/.rbenv/bin:$PATH' >> ~/.bashrc
	echo 'eval "$(rbenv init -)"' >> ~/.bashrc
	
	if [[ $? -eq 0 ]]; then
	    print_good "The bashrc has been modified"
	    ## TODO: les lignes ont été ajoutées dans le bashrc maintenant faut git et installer les plugins
	    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
	    
	    if [[ $? -eq 0 ]]; then
		print_good "The git clone https://github.com/rbenv/ruby-build.git in ~/.rbenv/plugins/ruby-build was done"
	    else
		print_error "It was a problem check your repertories ~/.rbenv/plugins/ruby-build"
	    fi
	    
	    ## TODO: I think this two line below must be into if condition above 
	    print_status "Adding path into bashrc"	
	    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc

	else
	    print_error "Something was wrong, maybe rights or permissions on file"
	fi	
    else
	print_error "It seems you have already installed rbenv, check it...!"
    fi
}

###################################

function install_verion ()
{
    print_status "installing rbenv verion 2.4.1"
    print_status "change version in script"
    ### You can change rbenv version, choose your version in $ rbenv install -l
    ### rbenv install [version here]
    rbenv install 2.4.1
    
    if [[ $? -eq 0 ]]; then
	print_good "the rbenv 2.4.1 was installed"
	print_status "changing as global variable rbenv 2.4.1"
	global rbenv 2.4.1
	## To be sure about rbenv install, write out the next command line "rbenv -v"  
	## TODO: continue here try to put another condition to verify if global variable was changed
	if ! [ -x "$(command -v rbenv)" ]; then
  	   print_error "rbenv is not installed or not found"
  	   exit 1
	else
	   commande=$(rbenv -v)
	   print_good "La version actuelle est $commande"
	fi

	## Istalling Bundler with gem
	print_status "Installing Bundler with gem"

        if ! [ -x "$(command -v gem)" ]; then
           print_error "gem is not installed or not found"
           exit 1
        else
           #commande=$(rbenv -v)
           #print_good "La version actuelles est $commande"
	   sudo gem install bundler

	   if ! [ -x "$(command -v bundler)" ]; then
              print_error "bundler is not installed or not found"
              exit 1
	   else
	      varBundler=$(bundler -v)
	      print_good "La version actuelle est $varBundler"
	   fi	
	   
        fi

    else
	print_error "the version was not installed, check version availability"
	exit 1
    fi
}


###################################

function install_metasploit()
{
    print_status "Installing Metasploit Framework from GitHub Repository"

   if [[ ! -d /opt/metasploit-framework ]]; then
       print_status "Cloning latest version of Metasploit Framework"
       if [ "$(id -u)" != "0" ]; then
	  sudo git clone https://github.com/rapid7/metasploit-framework.git /opt/metasploit-framework
	  sudo chown -R `whoami` /opt/metasploit-framework
       else
	  git clone https://github.com/rapid7/metasploit-framework.git /opt/metasploit-framework
       fi

       print_status "Making link metasploit commands"
       cd /opt/metasploit-framework
       ## ici installation du bundle	
       bundle install

       for MSF in $(ls msf*); do
	   print_status "Link $MSF command"
	   if [ "$(id -u)" != "0" ]; then
	      sudo ln -s /opt/metasploit-framework/$MSF /usr/local/bin/$MSF
	   else
	      ln -s /opt/metasploit-framework/$MSF /usr/local/bin/$MSF
	   fi
      done
   else
      print_status "Metasploit already presnt"
   fi   
}

###################################

function install_deps_deb
{
   print_status "Installing dependencies for Metasploit Framework"
   sudo apt-get -y update >> $LOGFILE 2>&1
   sudo apt-get -y install build-essential libreadline-dev libssl-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev openjdk-7-jre subversion git-core autoconf postgresql pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev vncviewer libyaml-dev ruby1.9.3 sqlite3 ruby-pcaprub ruby-dev libgdbm-dev libncurses5-dev libtool bison libffi-dev>> $LOGFILE 2>&1
   if [ $? -eq 1 ]; then
      echo "---- Failed to download and install dependencies ----" >> $LOGFILE 2>&1
      print_error "Failed to download and install the dependencies for running Metasploit Framework"
      print_error "Make sure you have the proper permissions and able to download and install packages"
      print_error "for the distribution you are using."
      exit 1
   fi
   
   print_status "Finished installing the dependencies."

}

###################################
########## MAIN ###########

#Variable with log file location for trobleshooting
LOGFILE="/tmp/msfinstall$NOW.log"

echo "[+] Install the Metasploit Framework on Ubuntu Linux now? (y/n)"; read -s -n 1 whx
	if [[ $whx = "" ]]; then
	   print_status "We are going to start with installations"
	   install_deps_deb
	   install_ruby
	   install_verion
	   install_metasploit
	elif [[ $whx == "y" ]]; then
	   echo "We are going to start with installations"
	   install_deps_deb
           install_ruby
           install_verion
           install_metasploit
	else
	   print_error "Installation aborted"
	   exit 1
	fi
	





# end script
