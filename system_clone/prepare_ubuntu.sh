#!/bin/bash
#The following command should be run as root
#Note: 
#   1.The .deb files of clonezilla is assumed to stored together with source images, under the
#     root of specified parition.

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
    if uname -a | grep "i.86" > /dev/null 2>&1 || uname -a | grep -i "ia32" > /dev/null 2>&1
    then
        #32-bit system
        dpkg -i *86.deb *_all.deb
    else
        #64-bit system
        dpkg -i *64.deb *_all.deb
    fi
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


#Launch the program - partclone
/usr/sbin/ocs-sr -q2 -c -j2 -z1p -i 10000 -p true saveparts $image_name $target_part


#Clean up
umount /dev/$target_part

echo
echo "Preparation finished! "
echo
