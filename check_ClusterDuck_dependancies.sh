#!/bin/bash
#
# This script checks to make sure that required dependieces are installed
# for the Project Owl ClusterDuck-Prototcol Arduino IDE build system
#
# By: David Mandala Designed by THEM, Copyright 2020 all reights reserved
#     except as licensed by the GPL V2.0 (only) license.
#
# Version 0.0.01 2020-09-01 
#
# The primary purpose of this script is to validate that the required 
# Linux and python applications are installed for the ESP32 Arduino IDE
# build system.  They differ from the normal Arduino IDE build system and 
# may not be installed by default.
#
# On Ubuntu the Arduino IDE normally makes it's sketch directory in the $USER
# home directory

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
	return 1
    else
	ver=$(python -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/') 
	if [ "$ver" -lt 35 ]; then
		let "errors_present++";
    		echo "ClusterDuck-Protocol for the Arduino IDE requires python 3.5 or greater to be installed"
    		echo "and be the default version in use, proceeding."
    		return 2
	else
		echo "python 3.5 or greater is present and is the default python, proceeding."
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

validate_Arduino_IDE(){
	if_present "arduino" "IDE" ; ret=$?
	if [ $ret = 0 ];then
		let Ardino_IDE_INSTALLED=1
		echo "The Arduino IDE appears to be installed, proceeding"
		return 0
	else
		echo "The Arduino IDE does not appear to be installed"
		echo "We recomend instlling the Arduino IDE from tar ball and not use the Online Web Editor."
		echo "You can get the installation tar ball from: https://www.arduino.cc/en/Main/Software" 
		echo "Choose the corect Linux version for your distro, 32 or 64 bit X86 or ARM"
		echo "We recoemend installing the tar ball in /opt/Arduino-[version number] and then"
		echo "adding a symlink 'ln -s /opt/Arduino-[version number] /opt/Arduino for each of updating"
		echo "Then follow the install instructions on the Arduino web site"
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
	validate_Arduino_IDE ; ret=$?
	echo "ret = $ret"
	if [ $ret != 0 ]; then 
		echo "The Arduino IDE must be instlled before preoceeding, if you have not installed the Arduino IDE please do so now."
		echo "If you have the Arduino IDE instlled this script is not detecting it and can't proceed any further, exiting now."
		exit 1
	fi 
	test_software_dependancies ; ret=$?
	if [ $ret != 0 ]; then 
		echo "The Linux binary applications must be installed and correct versions, before preoceeding, please correct all noted errors before proceeding"
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
	git clone https://github.com/Code-and-Response/ClusterDuck-Protocol.git 
	echo "About to git submidule update, the ClusterDuck-Protocol libraries into cd $CDP_INSTALL_DIR"
	cd $CDP_INSTALL_DIR
	git submodule update --init --recursive
	# Now symlink all the directories where they need to be for the Arduino IDE to see them
	# but keep them in place so git will still work for updates
	# and finally us -f so that in the future if more dir's pop up they will 
	# be added.....
	echo "About to symlink the ClusterDuck-Protocol sub libraries from $ARDUINO_LOCAL_LIB_DIR/$CDP_LIB_DIR into $ARDUINO_LOCAL_LIB_DIR"
	cd $ARDUINO_LOCAL_LIB_DIR
	find $CDP_LIB_DIR -maxdepth 1 -mindepth 1 -type d -exec ln -sf {} \;
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/Adafruit_BMP085_Unified
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/Adafruit_Sensor
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/Adafruit_BMP280_Library
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/ArduinoJson
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/arduino-timer
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/AsyncTCP
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/DHT-sensor-library
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/esp8266-oled-ssd1306
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/ESPAsyncWebServer
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/GP2YDustSensor
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/MQSensorsLib
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/pubsubclient
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/RadioLib
	# ln -s $ARDUINO_LOCAL_LIB_DIR/$CDP_INSTALL_DIR/U8g2_Arduino
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
