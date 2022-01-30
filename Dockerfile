FROM ubuntu:focal
RUN apt-get update

ENV TZ "Asia/Singapore"
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y tzdata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN echo $TZ > /etc/timezone

RUN apt-get -y install vim
RUN apt-get -y install wget
RUN apt-get -y install sudo
RUN apt-get -y install build-essential
RUN apt-get -y install libgmp-dev
RUN apt-get -y install bison libopts25 libselinux1-dev autogen m4 autoconf help2man libopts25-dev flex libfont-freetype-perl automake autotools-dev libfreetype6-dev texinfo
RUN apt-get -y install git
RUN apt-get -y install zip
RUN apt-get -y install python
RUN apt-get -y install gdisk
RUN apt-get -y install kpartx
RUN apt-get -y install dosfstools
RUN apt-get -y install cmake
RUN apt-get -y install bridge-utils
RUN apt-get -y install net-tools
RUN apt-get -y install iproute2
RUN apt-get -y install iputils-ping
RUN apt-get -y install ssh
RUN apt-get -y install rsyslog
RUN apt-get -y install qemu-system-x86

ENV USER "upandev"
ENV HOME "/home/$USER"
ENV PREFIX "$HOME/opt/cross"
ENV PATH "$PREFIX/bin:$PATH"
ENV WORKSPACE "$HOME/workspace"
ENV UPAN_SRC "$WORKSPACE/src"
ENV UPANIX_HOME "$UPAN_SRC/upanix"
ENV UPANAPPS_HOME "$UPAN_SRC/upanapps"
ENV UPANLIBS_HOME "$UPAN_SRC/upanlibs"
ENV UPANTOOLS_HOME "$UPAN_SRC/upantools"
ENV UPANIX_TOOLS "$WORKSPACE/tools"
ENV CROSS_COMPILE_SRC "$WORKSPACE/cross-compile"

RUN useradd -ms /bin/bash $USER && echo "$USER:dev" | chpasswd
RUN usermod -aG sudo $USER
USER $USER

WORKDIR $HOME

RUN echo "dev" >> $HOME/.sudopw
RUN chmod 600 $HOME/.sudopw
COPY .common_shrc $HOME/
RUN echo "source $HOME/.common_shrc" >> $HOME/.bashrc

RUN mkdir -p $WORKSPACE
COPY bootstrap_upanix.sh $WORKSPACE
RUN mkdir -p $CROSS_COMPILE_SRC
RUN mkdir -p $UPANIX_TOOLS

WORKDIR $CROSS_COMPILE_SRC

ENV TARGET i686-elf

RUN wget https://ftp.gnu.org/gnu/gcc/gcc-4.9.2/gcc-4.9.2.tar.gz && tar -xzvf gcc-4.9.2.tar.gz && rm gcc-4.9.2.tar.gz
RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz && tar -xzvf binutils-2.24.tar.gz && rm binutils-2.24.tar.gz
RUN wget https://libisl.sourceforge.io/isl-0.12.2.tar.gz && tar -xzvf isl-0.12.2.tar.gz && rm isl-0.12.2.tar.gz
RUN wget -O cloog-0.18.3.tar.gz "http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-0.18.3.tar.gz" && tar -xzvf cloog-0.18.3.tar.gz && rm cloog-0.18.3.tar.gz
RUN wget https://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.bz2 && bunzip2 gmp-6.0.0a.tar.bz2 && tar -xvf gmp-6.0.0a.tar && rm gmp-6.0.0a.tar
RUN wget https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.3.tar.gz && tar -xzvf mpfr-3.1.3.tar.gz && rm mpfr-3.1.3.tar.gz
RUN wget https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz && tar -xzvf mpc-1.0.3.tar.gz && rm mpc-1.0.3.tar.gz
RUN wget https://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz && tar -xzvf libiconv-1.14.tar.gz && rm libiconv-1.14.tar.gz

RUN cp -rf isl-0.12.2 binutils-2.24/isl
RUN cp -rf cloog-0.18.3 binutils-2.24/cloog
RUN (cd binutils-2.24/isl && touch aclocal.m4 configure Makefile.in Makefile.am)
RUN (cd binutils-2.24/cloog && touch aclocal.m4 configure Makefile.in Makefile.am)
RUN mkdir build-binutils
RUN (cd build-binutils && ../binutils-2.24/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror && make && make install)

RUN mv libiconv-1.14 gcc-4.9.2/libiconv
RUN mv gmp-6.0.0 gcc-4.9.2/gmp
RUN mv mpfr-3.1.3 gcc-4.9.2/mpfr
RUN mv mpc-1.0.3 gcc-4.9.2/mpc
RUN mv isl-0.12.2 gcc-4.9.2/isl
RUN mv cloog-0.18.3 gcc-4.9.2/cloog
COPY cfns.patch .
RUN patch gcc-4.9.2/gcc/cp/cfns.h cfns.patch
RUN echo "hello"
RUN (cd gcc-4.9.2/isl && touch aclocal.m4 configure Makefile.in Makefile.am)
RUN (cd gcc-4.9.2/cloog && touch aclocal.m4 configure Makefile.in Makefile.am)

RUN mkdir build-gcc
RUN (cd build-gcc && ../gcc-4.9.2/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers && make all-gcc && make install-gcc && make all-target-libgcc && make install-target-libgcc)

RUN wget https://www.nasm.us/pub/nasm/releasebuilds/2.11.08/nasm-2.11.08.tar.gz && tar -xzvf nasm-2.11.08.tar.gz && rm nasm-2.11.08.tar.gz
RUN (cd nasm-2.11.08/ && ./configure --target=$TARGET --prefix="$PREFIX" && make all && make install)

RUN wget https://ftp.gnu.org/gnu/grub/grub-2.06.tar.gz && tar -xzvf grub-2.06.tar.gz && rm grub-2.06.tar.gz
RUN cp -rf grub-2.06 grub-2.06_32bit
ENV EFI_ARCH i386
RUN (cd grub-2.06_32bit && ./configure --with-platform=efi --target=${EFI_ARCH} --program-prefix="" --disable-grub-mkfont --disable-werror && make)
RUN (cd grub-2.06_32bit/grub-core && ../grub-mkimage -O ${EFI_ARCH}-efi -d . -o grub.efi -p "" part_gpt part_msdos ntfs ntfscomp hfsplus fat ext2 normal chain boot configfile linux multiboot)

RUN cp -rf grub-2.06 grub-2.06_64bit
ENV EFI_ARCH x86_64
RUN (cd grub-2.06_64bit && ./configure --with-platform=efi --target=${EFI_ARCH} --program-prefix="" --disable-grub-mkfont --disable-werror && make)
RUN (cd grub-2.06_64bit/grub-core && ../grub-mkimage -O ${EFI_ARCH}-efi -d . -o grub.efi -p "" part_gpt part_msdos ntfs ntfscomp hfsplus fat ext2 normal chain boot configfile linux multiboot)

WORKDIR $UPANIX_TOOLS

RUN mkdir -p $UPANIX_TOOLS/grub_boot
RUN mkdir -p $UPANIX_TOOLS/grub_boot/i386-efi
RUN mkdir -p $UPANIX_TOOLS/grub_boot/x86_64-efi
RUN mkdir -p $UPANIX_TOOLS/grub_boot/fonts
RUN (cd $CROSS_COMPILE_SRC/grub-2.06_32bit/grub-core/ && cp *.mod *.lst $UPANIX_TOOLS/grub_boot/i386-efi/)
RUN (cd $CROSS_COMPILE_SRC/grub-2.06_32bit/grub-core/ && cp grub.efi $UPANIX_TOOLS/grub_boot/bootia32.efi)

RUN (cd $CROSS_COMPILE_SRC/grub-2.06_64bit/grub-core/ && cp *.mod *.lst $UPANIX_TOOLS/grub_boot/x86_64-efi/)
RUN (cd $CROSS_COMPILE_SRC/grub-2.06_64bit/grub-core/ && cp grub.efi $UPANIX_TOOLS/grub_boot/bootx64.efi)
COPY grub.cfg $UPANIX_TOOLS/grub_boot/
COPY unicode.pf2 $UPANIX_TOOLS/grub_boot/fonts/

RUN mkdir -p ovmf.64 ovmf.32
RUN wget -O ovmf.64/ovmf.zip https://sourceforge.net/projects/edk2/files/OVMF/OVMF-X64-r15214.zip/download
RUN wget -O ovmf.32/ovmf.zip https://sourceforge.net/projects/edk2/files/OVMF/OVMF-IA32-r15214.zip/download
RUN (cd ovmf.64 && unzip ovmf.zip && rm ovmf.zip)
RUN (cd ovmf.32 && unzip ovmf.zip && rm ovmf.zip)

RUN rm -rf $CROSS_COMPILE_SRC

WORKDIR $HOME
