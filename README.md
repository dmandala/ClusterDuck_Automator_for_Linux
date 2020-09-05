# ClusterDuck_Automator_for_Linux

The script will validate if you have all the Linux binaries installed to work on the Project Owl Cluster Ducks with the Arduino IDE.  Once you have all the necessary binaries installed, you can then use the script to install the CluserDuck libraries (CDP) needed for development.

This guide will help you successfully get a Linux development environment up and running for Project Owl ClusterDucks.  Please note the author of the document and the script knows how to use Debian and Ubuntuor and some of the derivities.  So the code sections are by default approprate for the apt tool set.  If you use a different distrobution please send patches with the correct methods for other distrobutions and I will include them in future versions of this document and script.  I hope this helps make developing for Project Owl Ducks easier.  Thank you for your support.   
 
## Preferred method of setup (Script Install):

### Install the Arduino IDE
1. First please get Arduino IDE Installed.  We recomend the tar-ball installation method, please follow the instructions provided by the Arduino folks, they are pretty good.  They have two scripts to be run that will pretty much install the Arduino IDE on almost every version of Linux.  We do recomend installing into:

		`/opt/Arduino-(version number)`
	
	and then adding a symlink: 
	
		`ln -s /opt/Arduino-(version number) /opt/arduino`.  
	
	That way you will not have to change anything beyond a symlink for upgrades in the future.
 
2. Now that you have installed the Arduino IDE, please open and run it one time and close it out. This populates some required folders and files.
3. Once you have run the Arduino IDE once please continue with step 1 Install Python3 and tools below.

### Install Python3 and tools
1. You will need Python 3 and some tools.  Some earlier versions of Linux are still using Python 2.7 which is now obsolete, so you may need to upgrade. You will also have to make python3 your default python on your machine.  If you are running Debian or Ubuntu or one of the derivities you can do this by running the following in your terminal:

		`sudo apt-get install python3 python3-pip python3-setuptools git`
 
2. Now make Python 3 the default interpreter is possible by running:sudo
		
		`update-alternatives --install /usr/bin/python python /usr/bin/python3 10`
	Note:You must logout of your account and back in for this to take effect

3. You will need to install the pySerial module, a dependency for CDP.  If you are running Debian or Ubuntu or one of the derivities you can do this by running the following in your terminal:
		
		`pip3 install pyserial`

### Install and run ClusterDuck_Automator_for_Linux
1. Next install the ClusterDuck_Automator_for_Linux script.  
	
	`git clone <CDP URL>`

2. Now you need to run the script. It should be executable, but it it's notyou can solve this by doing:

		`chmod u+x check_ClusterDuck_dependancies.sh`

    Once you have done that run the script in a terminal by: 
	
	`./check_ClusterDuck_dependancies.sh`
	
	The output will tell you if you have a clean environment with all the necessary pieces in place.  Resolve any missing software errors by installing them using your distro's tools.  Once that is done you can now proceed to the install.

### Install ClusterDuck-Protocol libraries
1. To install run the script again but with install behind it like this: `./check_ClusterDuck_dependancies.sh install`
2.  You should then see that the script will clone the latest CDP down and set up all necessary libraries in the proper places. Once that has completed you are now ready to use the Clusterduck Protocol and flash some ducks.


