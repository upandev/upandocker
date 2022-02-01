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

RUN useradd -ms /bin/bash $USER && echo "$USER:dev" | chpasswd
RUN usermod -aG sudo $USER
USER $USER

WORKDIR $HOME

RUN echo "dev" >> $HOME/.sudopw
RUN chmod 600 $HOME/.sudopw
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
