#!/bin/bash
#The following command should be run as root

#Input the source partition which contains the image
echo
echo "Please input the source partition name:(e.g. sdb1)"
read source_part
if [ -z "$source_part" ]
then
	echo "Using default partition: sdb1"
	source_part="sdb1"
fi

#Umount the source partition, then re-mount it at /home/partimag
umount /dev/$source_part
mkdir /home/partimag
mount /dev/$source_part /home/partimag


#Check if clonezilla has already been installed
if [ -z "$(dpkg -l | grep clonezilla)" ]
then
	#Install .deb package of clonezilla
	cd /home/partimag/clonezilla-deb
	dpkg -i *.deb
fi


#Input the target partition name in order to rename the image
echo
echo "Please input the target partition name:(e.g. sda3)"
read target_part
if [ -z "$target_part" ]
then
	echo "Cannot continue without target partition. Abort."
	echo
	exit 0
fi

#Input the source image name
echo
echo "Please input the image name:(e.g. Ubuntu-image)"
read image_name
if [ -z "$image_name" ]
then
	echo "Using default image: Ubuntu-image"
	image_name="Ubuntu-image"
fi


#Launch the programme
#clonezilla
/usr/sbin/ocs-sr -q2 -c -j2 -z1p -i 10000 -p true saveparts $image_name $target_part