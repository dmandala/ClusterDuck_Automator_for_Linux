# ClusterDuck_Automator_for_Linux
A script to validate if you have all the Linux binaries installed to work on the Project Owl Cluster Ducks with the Arduino IDE

## This guide will help you successfully get a Linux dev environment up and running:

### Preferred method of setup (Script Install): 
  1. First please get [Arduino IDE](https://www.arduino.cc/en/main/software) Installed. Once you have it successfully installed please open and run it just one time and close it out, This populates some folders and required pieces.

  1. Now you have the IDE installed, you will now need to install Python 3 and make it your default Python on your machine. You can do this by running the following in your terminal: 
      `sudo apt-get install python3 python3-pip python3-setuptools` | Now make Python 3 the default interpreter is possible by running:`sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10>` **Note:You must logout of your account and back in for this to take effect**

  1. Great now we have Python 3 and Arduino IDE installed we are getting closer to completing the environment setup. You will need to install PySerial a dependency for CDP. Install it by running this in a terminal: `pip3 install pyserial`

 1. Now please go and get the ClusterDuck_Automator_for_Linux script. If the .sh is not executable yet you can solve this by running `chmod u+x check_ClusterDuck_dependancies.sh` | Once you have done that run the script by `./check_ClusterDuck_dependancies.sh` it will tell you if you have a clean environment and all the necessary pieces in place. If it does not give you any errors you can now proceed to the install. 

 1. To finish up this install run the script again but with install behind it like this: `./check_ClusterDuck_dependancies.sh install` | you should then see that it will clone the latest CDP down and set up all necessary libraries. Once that has completed you are now ready to use the Clusterduck Protocol and flash some ducks. 
