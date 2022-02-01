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

FROM ubuntu:focal

ENV TZ "Asia/Singapore"

COPY install_packages.sh .
RUN ./install_packages.sh
RUN rm -f install_packages.sh

ENV USER "upandev"
ENV HOME "/home/$USER"
ENV CROSS_PREFIX "$HOME/opt/cross"
ENV CROSS_TARGET "i686-elf"
ENV PATH "$CROSS_PREFIX/bin:$PATH"
ENV WORKSPACE "$HOME/workspace"
ENV UPAN_SRC "$WORKSPACE/src"
ENV UPANIX_HOME "$UPAN_SRC/upanix"
ENV UPANAPPS_HOME "$UPAN_SRC/upanapps"
ENV UPANLIBS_HOME "$UPAN_SRC/upanlibs"
ENV UPANTOOLS_HOME "$UPAN_SRC/upantools"
ENV UPANIX_TOOLS "$WORKSPACE/tools"
ENV CROSS_COMPILE_SRC "$WORKSPACE/cross-compile"

RUN useradd -ms /bin/bash $USER && echo "$USER:$USER" | chpasswd
RUN usermod -aG sudo $USER
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER $USER

WORKDIR $HOME

COPY common_shrc $HOME/.common_shrc
RUN echo "source $HOME/.common_shrc" >> $HOME/.bashrc

RUN mkdir -p $WORKSPACE
RUN mkdir -p $UPANIX_TOOLS

WORKDIR $UPANIX_TOOLS

RUN mkdir -p grub_boot/i386-efi && mkdir -p grub_boot/x86_64-efi && mkdir -p grub_boot/fonts

COPY grub.cfg grub_boot/
COPY unicode.pf2 grub_boot/fonts/

RUN mkdir -p ovmf.64 ovmf.32
RUN wget -O ovmf.64/ovmf.zip https://sourceforge.net/projects/edk2/files/OVMF/OVMF-X64-r15214.zip/download
RUN wget -O ovmf.32/ovmf.zip https://sourceforge.net/projects/edk2/files/OVMF/OVMF-IA32-r15214.zip/download
RUN (cd ovmf.64 && unzip ovmf.zip && rm ovmf.zip)
RUN (cd ovmf.32 && unzip ovmf.zip && rm ovmf.zip)

RUN mkdir -p $CROSS_COMPILE_SRC
WORKDIR $CROSS_COMPILE_SRC

COPY cfns.patch $CROSS_COMPILE_SRC/
COPY build_cross_compiler.sh $CROSS_COMPILE_SRC/
RUN ./build_cross_compiler.sh

COPY build_nasm.sh $CROSS_COMPILE_SRC/
RUN ./build_nasm.sh

COPY build_grub.sh $CROSS_COMPILE_SRC/
RUN ./build_grub.sh

COPY bootstrap_upanix.sh $WORKSPACE

WORKDIR $HOME
