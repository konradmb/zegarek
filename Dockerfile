FROM fedora:30
# Tried with CentOS, but GTK is too old

RUN dnf -y install gcc gettext  wget librsvg2-tools git gtk3-devel \
    gobject-introspection-devel file libcanberra-gtk3 &&\
    dnf clean all &&\
    rm -rf /var/cache/yum &&\
    curl https://nim-lang.org/choosenim/init.sh -sSf > choosenim.sh &&\
    chmod +x ./choosenim.sh &&\
    ./choosenim.sh -y &&\
    echo 'export PATH=/root/.nimble/bin:$PATH' >> ~/.bashrc

COPY . /usr/src/zegarek
WORKDIR /usr/src/zegarek

RUN mkdir build
# Generated with DISPLAY=:0 LD_DEBUG=all src/zegarek  2>&1 | grep -e '.*calling init.*' | sed 's/.*: //' | sed 's#$#\\n\\#'
RUN echo $'\
/lib64/libpthread.so.0\n\
/lib64/libc.so.6\n\
/lib64/libdl.so.2\n\
/lib64/librt.so.1\n\
/lib64/libm.so.6\n\
/lib64/libpcre.so.1\n\
/lib64/libffi.so.6\n\
/lib64/libglib-2.0.so.0\n\
/lib64/libgobject-2.0.so.0\n\
/lib64/libpcre2-8.so.0\n\
/lib64/libuuid.so.1\n\
/lib64/libblkid.so.1\n\
/lib64/libresolv.so.2\n\
/lib64/libselinux.so.1\n\
/lib64/libmount.so.1\n\
/lib64/libz.so.1\n\
/lib64/libgmodule-2.0.so.0\n\
/lib64/libgio-2.0.so.0\n\
/lib64/libgraphite2.so.3\n\
/lib64/libXau.so.6\n\
/lib64/libdatrie.so.1\n\
/lib64/libbz2.so.1\n\
/lib64/libpng16.so.16\n\
/lib64/libfreetype.so.6\n\
/lib64/libharfbuzz.so.0\n\
/lib64/libexpat.so.1\n\
/lib64/libxcb.so.1\n\
/lib64/libX11.so.6\n\
/lib64/libXrender.so.1\n\
/lib64/libxcb-render.so.0\n\
/lib64/libxcb-shm.so.0\n\
/lib64/libpixman-1.so.0\n\
/lib64/libthai.so.0\n\
/lib64/libfribidi.so.0\n\
/lib64/libpango-1.0.so.0\n\
/lib64/libfontconfig.so.1\n\
/lib64/libpangoft2-1.0.so.0\n\
/lib64/libepoxy.so.0\n\
/lib64/libXext.so.6\n\
/lib64/libcairo.so.2\n\
/lib64/libwayland-client.so.0\n\
/lib64/libwayland-egl.so.1\n\
/lib64/libwayland-cursor.so.0\n\
/lib64/libxkbcommon.so.0\n\
/lib64/libXfixes.so.3\n\
/lib64/libXdamage.so.1\n\
/lib64/libXcomposite.so.1\n\
/lib64/libXcursor.so.1\n\
/lib64/libXrandr.so.2\n\
/lib64/libXi.so.6\n\
/lib64/libXinerama.so.1\n\
/lib64/libcairo-gobject.so.2\n\
/lib64/libgdk_pixbuf-2.0.so.0\n\
/lib64/libpangocairo-1.0.so.0\n\
/lib64/libgdk-3.so.0\n\
/lib64/libgpg-error.so.0\n\
/lib64/libgcc_s.so.1\n\
/lib64/libgcrypt.so.20\n\
/lib64/liblz4.so.1\n\
/lib64/liblzma.so.5\n\
/lib64/libsystemd.so.0\n\
/lib64/libdbus-1.so.3\n\
/lib64/libatspi.so.0\n\
/lib64/libatk-1.0.so.0\n\
/lib64/libatk-bridge-2.0.so.0\n\
/lib64/libgtk-3.so.0\n\
/usr/lib64/gio/modules/libgiognomeproxy.so\n\
/lib64/libgmp.so.10\n\
/lib64/libnettle.so.6\n\
/lib64/libhogweed.so.4\n\
/lib64/libtasn1.so.6\n\
/lib64/libunistring.so.2\n\
/lib64/libidn2.so.0\n\
/lib64/libp11-kit.so.0\n\
/lib64/libgnutls.so.30\n\
/usr/lib64/gio/modules/libgiognutls.so\n\
/lib64/libstdc++.so.6\n\
/lib64/libmodman.so.1\n\
/lib64/libproxy.so.1\n\
/usr/lib64/gio/modules/libgiolibproxy.so\n\
/usr/lib64/gio/modules/libdconfsettings.so\n\
/lib64/libcrypt.so.2\n\
/lib64/libogg.so.0\n\
/lib64/libvorbis.so.0\n\
/lib64/libltdl.so.7\n\
/lib64/libtdb.so.1\n\
/lib64/libvorbisfile.so.3\n\
/lib64/libcanberra.so.0\n\
/lib64/libgthread-2.0.so.0\n\
/lib64/libcanberra-gtk3.so.0\n\
/usr/lib64/gtk-3.0/modules/libcanberra-gtk-module.so>gtk-3.0/modules/libcanberra-gtk-module.so\n\
/lib64/libxml2.so.2\n\
/lib64/libcroco-0.6.so.3\n\
/lib64/librsvg-2.so.2\n\
/usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-svg.so\n\
/lib64/libvorbisenc.so.2\n\
/lib64/libFLAC.so.8\n\
/lib64/libgsm.so.1\n\
/lib64/libcap.so.2\n\
/lib64/libasyncns.so.0\n\
/lib64/libsndfile.so.1\n\
/lib64/libXtst.so.6\n\
/lib64/libICE.so.6\n\
/lib64/libSM.so.6\n\
/lib64/libX11-xcb.so.1\n\
/usr/lib64/pulseaudio/libpulsecommon-12.2.so\n\
/lib64/libpulse.so.0\n\
/usr/lib64/libcanberra-0.30/libcanberra-pulse.so\n\
' > build/requiredLibs
RUN /bin/bash -c 'source $HOME/.bashrc; \
    nimble -y clean &&\ 
    nimble -y build &&\
    nimble -y appimage'

# WHY????
# RUN printf '\x00' | dd bs=1 seek=8 count=1 conv=notrunc of=`ls build/Zegarek*AppImage`

LABEL Name=zegarek
