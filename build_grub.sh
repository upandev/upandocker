#!/bin/bash

set -e

cd $CROSS_COMPILE_SRC

wget https://ftp.gnu.org/gnu/grub/grub-2.06.tar.gz && tar -xzvf grub-2.06.tar.gz && rm grub-2.06.tar.gz

cp -rf grub-2.06 grub-2.06_32bit
export GRUB_EFI_ARCH=i386

sleep 1
(cd grub-2.06_32bit && touch aclocal.m4 configure Makefile.in Makefile.am)
(cd grub-2.06_32bit && ./configure --with-platform=efi --target=${GRUB_EFI_ARCH} --program-prefix="" --disable-grub-mkfont --disable-werror && make)
(cd grub-2.06_32bit/grub-core && ../grub-mkimage -O ${GRUB_EFI_ARCH}-efi -d . -o grub.efi -p "" part_gpt part_msdos ntfs ntfscomp hfsplus fat ext2 normal chain boot configfile linux multiboot)

cp -rf grub-2.06 grub-2.06_64bit
export GRUB_EFI_ARCH=x86_64

sleep 1
(cd grub-2.06_64bit && touch aclocal.m4 configure Makefile.in Makefile.am)
(cd grub-2.06_64bit && ./configure --with-platform=efi --target=${GRUB_EFI_ARCH} --program-prefix="" --disable-grub-mkfont --disable-werror && make)
(cd grub-2.06_64bit/grub-core && ../grub-mkimage -O ${GRUB_EFI_ARCH}-efi -d . -o grub.efi -p "" part_gpt part_msdos ntfs ntfscomp hfsplus fat ext2 normal chain boot configfile linux multiboot)

(cd $CROSS_COMPILE_SRC/grub-2.06_32bit/grub-core/ && cp *.mod *.lst $UPANIX_TOOLS/grub_boot/i386-efi/)
(cd $CROSS_COMPILE_SRC/grub-2.06_32bit/grub-core/ && cp grub.efi $UPANIX_TOOLS/grub_boot/bootia32.efi)

(cd $CROSS_COMPILE_SRC/grub-2.06_64bit/grub-core/ && cp *.mod *.lst $UPANIX_TOOLS/grub_boot/x86_64-efi/)
(cd $CROSS_COMPILE_SRC/grub-2.06_64bit/grub-core/ && cp grub.efi $UPANIX_TOOLS/grub_boot/bootx64.efi)

rm -rf $CROSS_COMPILE_SRC/*

unset GRUB_EFI_ARCH
