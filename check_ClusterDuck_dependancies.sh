#!/bin/bash
#
# This script checks to make sure that required dependieces are installed
# for the Project Owl ClusterDuck-Prototcol Arduino IDE build system
#
# By: David Mandala Designed by THEM, Copyright 2020 all reights reserved
#     except as licensed by the GPL V2.0 (only) license.
#
# Version 0.0.03 2020-09-04
#
# The primary purpose of this script is to validate that the required 
# Linux and python applications are installed for the ESP32 Arduino IDE
# build system.  They differ from the normal Arduino IDE build system and 
# may not be installed by default.
#
# On Ubuntu the Arduino IDE normally makes it's sketch directory in the $USER
# home directory, this appears to be the case for all Linux installs.
#

# If Arduino changes the location of this file it will break things
# and before changing this file you have to make sure that the Arduino
# IDE is NOT running as it will overwrite the file on shutdown.
ARDUINO_PREFERENCES_FILE="$HOME/.arduino15/preferences.txt"

ARDUINO_VERSION="1.8.13"
ARDUINO_APP_DIR="/opt/arduino-$ARDUINO_VERSION"
ARDUINO_SKETCH_DIR="$HOME/Arduino"
ARDUINO_LOCAL_LIB_DIR="$ARDUINO_SKETCH_DIR/libraries"

CDP_INSTALL_DIR="ClusterDuck-Protocol"
CDP_LIB_DIR="$CDP_INSTALL_DIR/Libraries"

GITHUB_CDP_UPSTREAM_REPO="https://github.com/Code-and-Response/ClusterDuck-Protocol.git"

declare -i CDP_INSTALLED=0
declare -i Ardino_IDE_INSTALLED=0
declare -i errors_present=0;
declare type_of_check="pre"

if_present() {
    if  !  which $1 > /dev/null ; then 
	((++errors_present))
	return 1
    else
	return 0
    fi
}

if_present_binary() {
    if  !  which $1 > /dev/null ; then 
	((++errors_present))
	echo "$1 appears to be missing, we recomend using your distributions installation tools to install $1."
	return 1
    else
	echo "$1 appears to be installed, proceeding."
	return 0
    fi
}

if_python_file_present() {
    if ! pip3 list | grep -c  $1 > /dev/null  ; then
	let "errors_present++";
	echo "The python module --> pyserial <-- is missing, we recomend using 'pip3 install pyserial'."
	return 1
    else
	echo "The python module --> pyserial <-- appears to be installed, proceeding."
	return 0
    fi
}

if_python_version_present() {
    if ! which python > /dev/null ; then
	let "errors_present++";
	echo "python 3 is needed and python appears not installed at all." 
	echo "We recomend using your distributions installation tools to install python 3."
	echo "And make it the default python for your system."
	echo ""
	echo "If you are runningn Ubuntu or Debian the below command should make python3"
	echo "the system default.  Remember after you run the command you must log out and"
	echo "log back in for it to take effect for you:"
	echo "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10"
	return 1
    else
	ver=$(python -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/') 
	if [ "$ver" -lt 35 ]; then
		let "errors_present++";
    		echo "ClusterDuck-Protocol for the Arduino IDE requires python 3.5 or greater to be installed"
    		echo "and must be the default version in use, proceeding."
    		return 2
	else
		echo "python 3.5 or greater is present and is appears to be the default python, proceeding."
		return 0
	fi
    fi
}

test_software_dependancies() {
	if_present_binary "git" ; ret=$?
	if_present_binary "wget" ; ret=$?	
	if_python_version_present ; ret=$?
	if_present_binary "pip3" ; ret=$?
	if_python_file_present "pyserial" ; ret=$?
	return
}

if_dir_present() {
    verbose=$2
    if [ -d "$1/" ]; then 
	if [ -L "$1" ]; then
    		# It is a symlink!
		if [ verbose = 1 ]; then
			echo "$1 is a symlink, that is OK, proceeding"
		fi
		return 0
	else
		# It's a directory!
		if [ verbose = 1 ]; then
			echo "$1 is a directory, that is OK, proceeding"
		fi
		return 0
	fi
	return 0
    else
	echo "$1 is missing."
	return 1
    fi
}

if_file_present() {
	if [ -f "$1" ]; then
	    echo "$1 exists."
	    return 0
	else 
	    echo "$1 does not exist."
	    return 1
	fi
}

test_directories_present() {
	(if_dir_present "$ARDUINO_SKETCH_DIR" 1) ; ret=$?
	if [ $ret != 0 ]; then
		if [ Arduino_IDE_INSTALLED = 0 ]; then
			echo "You don't appear to have the Arduino IDE installed, $ARDUINO_SKETCH_DIR will be installed the first time you run the IDE"
		else
			echo "You appear to have the Arduino IDE installed, have you run it yet? If not the $ARDUINO_SKETCH_DIR will be created when you run the IDE."
			echo "Hoever if you have assigned a different path for your Arduino Sketch directory, then we recomend making $ARDUINO_SKETCH_DIR your"
			echo "Arduino Sketch directory going forward, otherwise this script can't help you will the install of the ClusterDuck-Protocol, you are on your own."
		fi
	fi
	if_dir_present $ARDUINO_LOCAL_LIB_DIR 1 ; ret=?
	if_dir_present $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR 1 ; ret=$?
	if [ $ret != 0 ]; then
		if [ $CDP_INSTALLED = 0 ]; then
			echo "You don't appear to have the ClusterDuck-Protocol libraries installed," 
			echo "$ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR will be created when you install it."
		fi
	fi

	if_dir_present $ARDUINO_LOCAL_LIB_DIR/$CDP_LIB_DIR 1 ; ret=$?
	if [ $ret != 0 ]; then
		if [ $CDP_INSTALLED = 0 ]; then
			echo "You don't appear to have the ClusterDuck-Protocol libraries installed," 
			echo "$ARDUINO_LOCAL_LIB_DIR/$CDP_LIB_DIR will be created when you install it."
		fi
	fi
	return
}

if_Arduino_running_exit() {
	(ps a | grep -v grep | grep -v bash | grep -iq arduino) ; ret=$?
	if [ $ret = 0 ]; then
		echo "The Arduino IDE appears to be running, this script can not be run"
		echo "while the IDE is running, the script will exit now. Please stop the"
		echo "Arduino IDE and re-run this script"
		exit 1
	fi
}

fixup_Arduino_preferences() {
	if_Arduino_running_exit
	# This awk command will add the urls correctly to the preferences file.
	awk -v key='boardsmanager.additional.urls' -v val='https://dl.espressif.com/dl/package_esp32_index.json,https://adafruit.github.io/arduino-board-index/package_adafruit_index.json' 'BEGIN {
	   FS=OFS="="
	}
	$1 == key {
	   $2 = ($2 ~ /^[[:blank:]]*$/ ? "" : $2 ",") val
	   p = 1
	}
	END {
	   if (!p)
	      print key, val
	} 1' $ARDUINO_PREFERENCES_FILE > $ARDUINO_PREFERENCES_FILE.new && \
	mv $ARDUINO_PREFERENCES_FILE $ARDUINO_PREFERENCES_FILE.bak && \
	mv $ARDUINO_PREFERENCES_FILE.new $ARDUINO_PREFERENCES_FILE

	echo "We have added the ESP32 URL's to your boardsmanager in the Arduino IDE"
	echo "when you start the IDE, please make sure to go to 'Tools->Board:->Boards Manager'"
	echo "and search for and install ESP32."
	echo""
	return 0
}

validate_Arduino_IDE() {
	if_present "arduino" "IDE" ; ret=$?
	if [ $ret = 0 ];then
		let Ardino_IDE_INSTALLED=1
		echo "The Arduino IDE appears to be installed, proceeding"
		if_file_present $ARDUINO_PREFERENCES_FILE ; ret=$?
		if [ $ret = 0 ]; then
			echo "It looks like you have run the Arduino IDE at least once since it was installed."
			echo "The configuration file is present."
		else
			echo "It looks like you have not run the Arduino IDE since you installed it"
			echo "Please start the IDE once, and shut it down so it puts the local"
			echo "configuration file into your home directory, run the script again"
			echo "once you have done so."
			return 1
		fi
		return 0
	else
		echo "The Arduino IDE does not appear to be installed"
		echo "We recomend instlling the Arduino IDE from tar ball and not use the Online Web Editor."
		echo "You can get the installation tar ball from: https://www.arduino.cc/en/Main/Software" 
		echo "Choose the corect Linux version for your distro, 32 or 64 bit X86 or ARM"
		echo "We recoemend installing the tar ball in /opt/Arduino-[version number] and then"
		echo "adding a symlink 'ln -s /opt/Arduino-[version number] /opt/Arduino for each of updating"
		echo "Then follow the install instructions on the Arduino web site"
		echo "Once you have completed the install start and exit the IDE once before running this"
		echo "script again, that will make sure all of the Arduino config files are present."
		return 1
	fi
}

#
# Everything above this line should be functions and global var's  Everything below this line should be the program code

if  [[ $# -eq 0 ]] ; then
	# set this to help when there is a help section.
	type_of_check="pre"
else
	#lower case the incoming command line var
	type_of_check="${1,,}"
fi

if [ $type_of_check = "help" ]; then
	# add a help section here
	echo "This will become a help section"
elif [ $type_of_check = "pre" ]; then
	# test for the pressence of needed binaries and some python software
	# just tell the person what they need to install....
	validate_Arduino_IDE
	echo "About to test software dependacies"
 	test_software_dependancies
 	echo "about to check dir's"
	test_directories_present
elif [ $type_of_check = "post" ]; then
	# check if everything is installed or report out what is missing
	#if_present "arduino" "IDE" ; ret=$?
	validate_Arduino_IDE ; ret=$?
	test_software_dependancies
	echo  "test for librarys installed here, test not written yet."
	# would be nice if someone would wrote this test.
	# soemthing like find $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR -maxdepth 2 -name README.md if find empty; libs not populated
	# in the 14 libraries installed in the ClusterDuck-Protocol the only file that seems consistantly present is README.md for 
	# testing, if the directory is present but not populated the git clone was executed but not the git submodule update!
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/Adafruit_BMP085_Unified/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/Adafruit_Sensor/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/Adafruit_BMP280_Library/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/ArduinoJson/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/arduino-timer/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/AsyncTCP/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/DHT-sensor-library/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/esp8266-oled-ssd1306/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/ESPAsyncWebServer/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/GP2YDustSensor/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/MQSensorsLib/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/pubsubclient/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/RadioLib/README.md
	# Arduino/libraries/ClusterDuck-Protocol/Libraries/U8g2_Arduino/README.md
elif [ $type_of_check = "install" ]; then
	# The Arduino IDE can NOT be running during the install.  We check this several times during the install.
	if_Arduino_running_exit
	# Now validate the IDE is present
	validate_Arduino_IDE ; ret=$?
	echo "ret = $ret"
	if [ $ret != 0 ]; then 
		echo "The Arduino IDE must be instlled before preoceeding, if you have not installed the Arduino IDE please do so now."
		echo "If you have the Arduino IDE instlled this script is not detecting it and can't proceed any further, exiting now."
		exit 1
	fi 
	test_software_dependancies ; ret=$?
	if [ $ret != 0 ]; then 
		echo "The Linux binary applications must be installed and correct versions, before proceeding, please correct all noted errors before proceeding"
		echo "If you have all the binaries installed this script is not detecting it and can't proceed any further, exiting now."
		exit 2
	fi 
	echo "About to git clone the ClusterDuck-Protocol libraries into $ARDUINO_LOCAL_LIB_DIR"
	if_dir_present $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR 0 ; ret=$?
	if [ $ret = 0 ]; then
		echo "You appear to have the ClusterDuck-Protocol libraries installed, Exiting Now" 
		exit 3
	fi
	cd $ARDUINO_LOCAL_LIB_DIR
	git clone https://github.com/Code-and-Response/ClusterDuck-Protocol.git > /dev/null
	echo "About to git submidule update, the ClusterDuck-Protocol libraries into cd $CDP_INSTALL_DIR"
	cd $CDP_INSTALL_DIR
	git submodule update --init --recursive > /dev/null
	# Now symlink all the directories where they need to be for the Arduino IDE to see them
	# but keep them in place so git will still work for updates
	# and finally us -f so that in the future if more dir's pop up they will 
	# be added.....
	echo "About to symlink the ClusterDuck-Protocol sub libraries from $ARDUINO_LOCAL_LIB_DIR/$CDP_LIB_DIR into $ARDUINO_LOCAL_LIB_DIR"
	cd $ARDUINO_LOCAL_LIB_DIR
	find $CDP_LIB_DIR -maxdepth 1 -mindepth 1 -type d -exec ln -sf {} \;
	# Now to insert the boardsmanager text into the Arduino preferences.txt file
	# test that the IDE is not running before doing that.
	echo "About to install the URL's needed for the ESP32 boards in the boards manager setup." 
	fixup_Arduino_preferences
	echo ""
	echo "At this point, you should the necessary Cluster Duck libraries installed"
	echo "and ESP32 settings set so you can start developing for Project Owl ClusterDucks"
	echo ""
	exit 0
else
	echo "None of the script options were choosen: pre, post, install"
fi

if [ $errors_present -eq 0 ] ; then
	echo "Software needed for ESP32 Arduino development appears to be installed"
else
	echo "Please correct above noted errors before proceeding with the rest of the install"
	exit 1
fi

exit 0
