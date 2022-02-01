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

cd $CROSS_COMPILE_SRC

wget https://ftp.gnu.org/gnu/gcc/gcc-4.9.2/gcc-4.9.2.tar.gz && tar -xzvf gcc-4.9.2.tar.gz && rm gcc-4.9.2.tar.gz
wget https://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz && tar -xzvf binutils-2.24.tar.gz && rm binutils-2.24.tar.gz
wget https://libisl.sourceforge.io/isl-0.12.2.tar.gz && tar -xzvf isl-0.12.2.tar.gz && rm isl-0.12.2.tar.gz
wget -O cloog-0.18.3.tar.gz "http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-0.18.3.tar.gz" && tar -xzvf cloog-0.18.3.tar.gz && rm cloog-0.18.3.tar.gz
wget https://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.bz2 && bunzip2 gmp-6.0.0a.tar.bz2 && tar -xvf gmp-6.0.0a.tar && rm gmp-6.0.0a.tar
wget https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.3.tar.gz && tar -xzvf mpfr-3.1.3.tar.gz && rm mpfr-3.1.3.tar.gz
wget https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz && tar -xzvf mpc-1.0.3.tar.gz && rm mpc-1.0.3.tar.gz
wget https://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz && tar -xzvf libiconv-1.14.tar.gz && rm libiconv-1.14.tar.gz

cp -rf isl-0.12.2 binutils-2.24/isl
cp -rf cloog-0.18.3 binutils-2.24/cloog
mkdir build-binutils
sleep 1
(cd binutils-2.24/isl && touch aclocal.m4 configure Makefile.in Makefile.am)
(cd binutils-2.24/cloog && touch aclocal.m4 configure Makefile.in Makefile.am)
(cd build-binutils && ../binutils-2.24/configure --target=$CROSS_TARGET --prefix="$CROSS_PREFIX" --with-sysroot --disable-nls --disable-werror && make && make install)

mv libiconv-1.14 gcc-4.9.2/libiconv
mv gmp-6.0.0 gcc-4.9.2/gmp
mv mpfr-3.1.3 gcc-4.9.2/mpfr
mv mpc-1.0.3 gcc-4.9.2/mpc
mv isl-0.12.2 gcc-4.9.2/isl
mv cloog-0.18.3 gcc-4.9.2/cloog

patch gcc-4.9.2/gcc/cp/cfns.h cfns.patch
sleep 1
(cd gcc-4.9.2/isl && touch aclocal.m4 configure Makefile.in Makefile.am)
(cd gcc-4.9.2/cloog && touch aclocal.m4 configure Makefile.in Makefile.am)
(cd gcc-4.9.2/gcc && touch aclocal.m4 configure Makefile.in)

mkdir build-gcc
(cd build-gcc && ../gcc-4.9.2/configure --target=$CROSS_TARGET --prefix="$CROSS_PREFIX" --disable-nls --enable-languages=c,c++ --without-headers && make all-gcc && make install-gcc && make all-target-libgcc && make install-target-libgcc)

rm -rf $CROSS_COMPILE_SRC/*
