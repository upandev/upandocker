#!/bin/bash
#  Upanix - An x86 based Operating System
#  Copyright (C) 2011 'Prajwala Prabhakar' 'srinivasa.prajwal@gmail.com'
#  
#  I am making my contributions/submissions to this project solely in
#  my personal capacity and am not conveying any rights to any
#  intellectual property of any third parties.
#   																	 
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#   																	 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#   																	 
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/

set -e

mkdir -p $UPAN_SRC

if [ ! -d "$UPAN_SRC/upanlibs" ]
then
  (cd $UPAN_SRC && git clone https://github.com/upandev/upanlibs.git)
fi

if [ ! -d "$UPAN_SRC/upanix" ]
then
  (cd $UPAN_SRC && git clone https://github.com/upandev/upanix.git)
fi

(cd $UPAN_SRC/upanix && mkdir -p USBImage/mnt)

IMAGE_DIR=$UPAN_SRC/upanix/USBImage/
dd if=/dev/zero of=$IMAGE_DIR/300MUSB.img bs=512 count=614400
dd if=/dev/zero of=$IMAGE_DIR/300MUSB_xhci.img bs=512 count=614400

#create 2 partitions with gdisk - one 200 MB for uefi fat32 boot partition and another for upanix (will be formatted in mosfs)
sgdisk -n 1:2048:200M -n 2:: $IMAGE_DIR/300MUSB.img
sgdisk -n 1:2048:200M -n 2:: $IMAGE_DIR/300MUSB_xhci.img

echo $IMAGE_DIR

MOUNTP=`sudo kpartx -av $IMAGE_DIR/300MUSB.img | head -1 | cut -d" " -f3`

echo "Mount Device: $MOUNTP"
LOOP_DEV=${MOUNTP::-2}
echo "Loop Device: $LOOP_DEV"

sudo mkdosfs -F32 /dev/mapper/$MOUNTP

sudo mount /dev/mapper/$MOUNTP $IMAGE_DIR/mnt/
(cd $IMAGE_DIR/mnt && sudo mkdir -p efi)
sudo cp -rf $UPANIX_TOOLS/grub_boot/. $IMAGE_DIR/mnt/efi/boot

sudo umount $IMAGE_DIR/mnt

sudo dmsetup remove /dev/mapper/${LOOP_DEV}p1
sudo dmsetup remove /dev/mapper/${LOOP_DEV}p2
sudo losetup -d /dev/$LOOP_DEV
