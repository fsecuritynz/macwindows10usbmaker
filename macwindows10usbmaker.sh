#!/bin/bash

clear

welcome() {
	echo "############################################################"
	echo " macOS Windows10 USB disk maker"
	echo " "
	echo "https://github.com/fsecuritynz/macwindows10usbmaker"
	echo "Version $mw10usbdmver"
        echo " "
	echo "You will need to ensure your account is enabled with sudo "
	echo "https://support.apple.com/en-au/HT204012"
	echo " "
        echo "############################################################"
        echo " "
        echo " "
	echo "NOTE: PLEASE ENSURE THAT ONLY THE USB YOU WISH TO USE IS PLUGGED IN"
	echo ""
        echo " "
}


dependencies() {
	brewlocation=$(ls /usr/local/bin | grep brew)
	if [[ $brewlocation = brew ]]; then
		brewinstalled=yes
	fi
	if [[ $brewinstalled = no ]]; then
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	else
		echo "brew is already installed"
	fi
        echo "############################################################"
	echo "Updating brew and installing wimlib..."
	brew install wimlib
}


usbstatus() {
        echo " "
	diskname=$(diskutil list external | grep "0\:" | awk {'print $5'})
	disksize=$(diskutil list external | grep "0\:" | awk {'print $3'} | cut -c 2-100)
        echo "############################################################"
	echo "Disk available $diskname $disksize/GB"
}

whereiswindows() {
        echo " "
        echo "############################################################"
	echo "Please download the Windows 10 image from "
	echo "https://www.microsoft.com/en-us/software-download/windows10ISO "
        echo "############################################################"
	echo "Drag the Windows 10 iso into the terminal and hit ENTER"
	read isolocation
	sudo hdiutil mount $isolocation
	volname=$(ls /Volumes | grep CCCO)
}

prepareusb() {
        echo " "
        echo "############################################################"
	echo "***** WARNING: THIS WILL ERASE YOUR USB DRIVE /dev/$diskname"
        echo "############################################################"
	echo ""
	sleep 2
	echo "Do you wish to procede? [y/n]"
	read proceedask
        echo ""
	if [[ $proceedask = y ]]; then
		diskutil eraseDisk MS-DOS "WIN10USB" MBR /dev/$diskname 
	else 
		echo "Disk was not erased"
	fi
}

copyfiles() {
	clear
        echo " "
        echo "############################################################"
        echo "***** WARNING: THIS WILL COPY THE ISO TO USB"
        echo "############################################################"
        echo " "
	sleep 2
        echo "Do you wish to procede? [y/n]"
        read copyproc
        if [[ $copyproc = y ]]; then
		rsync -vha --exclude=sources/install.wim /Volumes/$volname/ /Volumes/WIN10USB/
		wimlib-imagex split /Volumes/$volname/sources/install.wim /Volumes/WIN10USB/sources/install.swm 4000
		echo ""
	        echo "############################################################"
		echo "***** COPY FINISHED - PLEASE EJECT THE DISK
                echo "############################################################"
	else
		echo "You chose not to copy... Goodbye"

}



welcome
dependencies
usbstatus
whereiswindows
prepareusb
copyfiles
