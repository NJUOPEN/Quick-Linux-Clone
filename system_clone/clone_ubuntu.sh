#!/bin/bash
#The following command should be run as root

#Prompt to run gparted before clonezilla
echo
echo "Would you like to run gparted before clone?[y/n]"
read choice
if [ "$choice" = "y" ]
then
    gparted
fi

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


#Input the source image name
echo
echo "Please input the image name:(e.g. Ubuntu-image)"
read image_name
if [ -z "$image_name" ]
then
    echo "Using default image: Ubuntu-image"
    image_name="Ubuntu-image"
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

#Backup partition table of target disk(sector 0-63)
echo "Backuping partition table..."
cd /home/partimag/
if [ ! -d "parttable_bak" ]
then
    mkdir parttable_bak
fi
dd if=/dev/sda of=parttable_bak/diskdump_$(date +%Y%m%d%H%M%S) bs=512 count=64
echo "done."
echo

#Change to the directory that contains source image
cd /home/partimag/$image_name

#Write partition name to info file
#cat > parts << EOF
#$target_part
#EOF

#And rename the image file
old_image_name="$(ls *.gz.aa)"
suffix=${old_image_name:4}
new_image_name=$target_part$suffix
mv $old_image_name $new_image_name


#Launch the programme
#clonezilla
/usr/sbin/ocs-sr -e1 auto -e2 -c -t -r -j2 -k -p true restoreparts $image_name $target_part

#Install grub to new disk if needed
echo
echo "Continue to install grub?[y/n]"
read choice
if [ "$choice" = "y" ]
then
    cd /media
    mkdir target-partition
    mount /dev/$target_part target-partition	
    grub-install --boot-directory=target-partition/boot /dev/${target_part:0:3}
    
    mount --bind /dev target-partition/dev
    mount --bind /proc target-partition/proc
    mount --bind /sys target-partition/sys
    chroot target-partition grub-mkconfig -o /boot/grub/grub.cfg
    umount target-partition/sys
    umount target-partition/proc
    umount target-partition/dev
else
    exit 0
fi


#Clean up
umount /dev/$target_part

echo
echo "Installation finished! Reboot now?[y/n]"
read choice
if [ "$choice" = "y" ]
then
    reboot
fi
echo