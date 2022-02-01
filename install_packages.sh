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

apt-get update
(DEBIAN_FRONTEND="noninteractive" apt-get install -y tzdata)
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone 

apt-get -y install vim
apt-get -y install wget
apt-get -y install sudo
apt-get -y install build-essential
apt-get -y install libgmp-dev
apt-get -y install bison libopts25 libselinux1-dev autogen m4 autoconf help2man libopts25-dev flex libfont-freetype-perl automake autotools-dev libfreetype6-dev texinfo
apt-get -y install git
apt-get -y install zip
apt-get -y install python
apt-get -y install gdisk
apt-get -y install kpartx
apt-get -y install dosfstools
apt-get -y install cmake
apt-get -y install bridge-utils
apt-get -y install net-tools
apt-get -y install iproute2
apt-get -y install iputils-ping
apt-get -y install ssh
apt-get -y install rsyslog
apt-get -y install qemu-system-x86

apt-get clean
rm -rf /var/lib/apt/lists/*
