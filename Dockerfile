FROM ubuntu:16.04

RUN apt update &&\
    apt install -y --no-install-recommends eatmydata software-properties-common &&\
    # add-apt-repository -u ppa:savoury1/fonts &&\
    # add-apt-repository -u ppa:ubuntu-toolchain-r/test &&\
    # add-apt-repository ppa:savoury1/backports &&\
    eatmydata apt -y install gcc build-essential cmake gettext wget curl librsvg2-bin git libgtk-3-dev \
    libgirepository1.0-dev gir1.2-rsvg-2.0 file libcanberra-gtk3-dev libmount-dev \
    libegl1-mesa-dev libglu1-mesa-dev freeglut3-dev mesa-common-dev \
    ninja-build/xenial-backports python3-pip flex bison python3-dev libfribidi-dev libharfbuzz-dev &&\
    rm -rf /var/lib/apt/lists/* &&\
    pip3 install meson &&\
    curl https://nim-lang.org/choosenim/init.sh -sSf > choosenim.sh &&\
    chmod +x ./choosenim.sh &&\
    ./choosenim.sh -y
ENV PATH "/root/.nimble/bin:$PATH"

WORKDIR /usr/local/src/libepoxy
RUN wget https://github.com/anholt/libepoxy/releases/download/1.4.1/libepoxy-1.4.1.tar.xz
RUN tar xvf libepoxy-1.4.1.tar.xz
WORKDIR /usr/local/src/libepoxy/libepoxy-1.4.1
RUN meson _build
RUN ninja -C _build
RUN ninja -C _build install
ENV PKG_CONFIG_PATH "/usr/local/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"
ENV LD_LIBRARY_PATH "/usr/local/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH"
RUN ldconfig

WORKDIR /usr/local/src/harfbuzz
RUN wget https://github.com/harfbuzz/harfbuzz/releases/download/1.4.2/harfbuzz-1.4.2.tar.bz2
RUN tar xvf harfbuzz-1.4.2.tar.bz2
WORKDIR /usr/local/src/harfbuzz/harfbuzz-1.4.2
RUN ./configure
RUN make -j$(nproc)
RUN make install
ENV PKG_CONFIG_PATH "/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
ENV LD_LIBRARY_PATH "/usr/local/lib/:$LD_LIBRARY_PATH"
RUN ldconfig

WORKDIR /usr/local/src/glib
RUN wget https://download.gnome.org/sources/glib/2.60/glib-2.60.7.tar.xz
RUN tar xvfJ glib-2.60.7.tar.xz
WORKDIR /usr/local/src/glib/glib-2.60.7
RUN meson _build
RUN ninja -C _build
RUN ninja -C _build install
# ENV PKG_CONFIG_PATH "/usr/local/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"
# ENV LD_LIBRARY_PATH "/usr/local/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
RUN ldconfig

WORKDIR /usr/local/src/pango
RUN wget http://ftp.gnome.org/pub/GNOME/sources/pango/1.42/pango-1.42.4.tar.xz
RUN tar xvfJ pango-1.42.4.tar.xz
WORKDIR /usr/local/src/pango/pango-1.42.4
RUN meson _build
RUN ninja -C _build
RUN ninja -C _build install
# ENV PKG_CONFIG_PATH "/usr/local/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"
# ENV LD_LIBRARY_PATH "/usr/local/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
RUN ldconfig

WORKDIR /usr/local/src/gtk
RUN echo $LD_LIBRARY_PATH
RUN wget https://download.gnome.org/sources/gtk+/3.24/gtk+-3.24.20.tar.xz
RUN tar xvfJ gtk+-3.24.20.tar.xz
WORKDIR /usr/local/src/gtk/gtk+-3.24.20
RUN ./configure --prefix=/opt/gtk
RUN make -j$(nproc)
RUN make install
ENV PKG_CONFIG_PATH "/opt/gtk/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"
ENV LD_LIBRARY_PATH "/opt/gtk/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
RUN ldconfig

WORKDIR /usr/local/src/gobject
RUN wget https://download.gnome.org/sources/gobject-introspection/1.64/gobject-introspection-1.64.1.tar.xz
RUN tar xvfJ gobject-introspection-1.64.1.tar.xz
WORKDIR /usr/local/src/gobject/gobject-introspection-1.64.1
RUN meson _build --prefix=/opt/gtk
RUN ninja -C _build
RUN ninja -C _build install
ENV PKG_CONFIG_PATH "/opt/gtk/lib/pkgconfig:$PKG_CONFIG_PATH"
ENV LD_LIBRARY_PATH "/opt/gtk/lib:$LD_LIBRARY_PATH"
ENV GI_TYPELIB_PATH "/opt/gtk/lib/x86_64-linux-gnu/girepository-1.0:/opt/gtk/lib/girepository-1.0:/usr/local/lib/x86_64-linux-gnu/girepository-1.0:/usr/lib/x86_64-linux-gnu/girepository-1.0:/usr/lib/girepository-1.0/"
RUN ldconfig

RUN ls /opt/gtk/lib


COPY . /usr/src/zegarek
WORKDIR /usr/src/zegarek

RUN mkdir build
# Generated with DISPLAY=:0 LD_DEBUG=all src/zegarek  2>&1 | grep -e '.*calling init.*' | sed 's/.*: //' | sed 's#$#\\n\\#'
RUN echo '\
/usr/lib/x86_64-linux-gnu/gtk-3.0/modules/libcanberra-gtk-module.so>gtk-3.0/modules/libcanberra-gtk-module.so\n\
/usr/lib/x86_64-linux-gnu/gtk-3.0/modules/libcanberra-gtk3-module.so>gtk-3.0/modules/libcanberra-gtk3-module.so\n\
/lib/x86_64-linux-gnu/libpthread.so.0\n\
/lib/x86_64-linux-gnu/libc.so.6\n\
/lib/x86_64-linux-gnu/libdl.so.2\n\
/lib/x86_64-linux-gnu/librt.so.1\n\
/lib/x86_64-linux-gnu/libpcre.so.3\n\
/usr/lib/x86_64-linux-gnu/libffi.so.6\n\
/usr/local/lib/x86_64-linux-gnu/libglib-2.0.so.0\n\
/usr/local/lib/x86_64-linux-gnu/libgobject-2.0.so.0\n\
/lib/x86_64-linux-gnu/libuuid.so.1\n\
/lib/x86_64-linux-gnu/libselinux.so.1\n\
/lib/x86_64-linux-gnu/libblkid.so.1\n\
/lib/x86_64-linux-gnu/libresolv.so.2\n\
/lib/x86_64-linux-gnu/libmount.so.1\n\
/lib/x86_64-linux-gnu/libz.so.1\n\
/usr/local/lib/x86_64-linux-gnu/libgmodule-2.0.so.0\n\
/usr/local/lib/x86_64-linux-gnu/libgio-2.0.so.0\n\
/lib/x86_64-linux-gnu/libbsd.so.0\n\
/usr/lib/x86_64-linux-gnu/libgraphite2.so.3\n\
/usr/lib/x86_64-linux-gnu/libXdmcp.so.6\n\
/usr/lib/x86_64-linux-gnu/libXau.so.6\n\
/lib/x86_64-linux-gnu/libm.so.6\n\
/usr/lib/x86_64-linux-gnu/libpng16.so.16\n\
/usr/lib/x86_64-linux-gnu/libfreetype.so.6\n\
/usr/lib/x86_64-linux-gnu/libharfbuzz.so.0\n\
/usr/lib/x86_64-linux-gnu/libxcb.so.1\n\
/usr/lib/x86_64-linux-gnu/libxcb-render.so.0\n\
/usr/lib/x86_64-linux-gnu/libxcb-shm.so.0\n\
/usr/lib/x86_64-linux-gnu/libpixman-1.so.0\n\
/usr/lib/x86_64-linux-gnu/libX11.so.6\n\
/usr/lib/x86_64-linux-gnu/libXrender.so.1\n\
/lib/x86_64-linux-gnu/libexpat.so.1\n\
/usr/lib/x86_64-linux-gnu/libfribidi.so.0\n\
/usr/local/lib/x86_64-linux-gnu/libpango-1.0.so.0\n\
/usr/lib/x86_64-linux-gnu/libfontconfig.so.1\n\
/usr/local/lib/x86_64-linux-gnu/libpangoft2-1.0.so.0\n\
/usr/lib/x86_64-linux-gnu/libepoxy.so.0\n\
/usr/lib/x86_64-linux-gnu/libXext.so.6\n\
/usr/lib/x86_64-linux-gnu/libcairo.so.2\n\
/usr/lib/x86_64-linux-gnu/libXfixes.so.3\n\
/usr/lib/x86_64-linux-gnu/libXdamage.so.1\n\
/usr/lib/x86_64-linux-gnu/libXcomposite.so.1\n\
/usr/lib/x86_64-linux-gnu/libXcursor.so.1\n\
/usr/lib/x86_64-linux-gnu/libXrandr.so.2\n\
/usr/lib/x86_64-linux-gnu/libXi.so.6\n\
/usr/lib/x86_64-linux-gnu/libXinerama.so.1\n\
/usr/lib/x86_64-linux-gnu/libcairo-gobject.so.2\n\
/usr/lib/x86_64-linux-gnu/libgdk_pixbuf-2.0.so.0\n\
/usr/local/lib/x86_64-linux-gnu/libpangocairo-1.0.so.0\n\
/opt/gtk/lib/libgdk-3.so.0\n\
/lib/x86_64-linux-gnu/libgpg-error.so.0\n\
/lib/x86_64-linux-gnu/libgcrypt.so.20\n\
/usr/lib/x86_64-linux-gnu/liblz4.so.1\n\
/lib/x86_64-linux-gnu/liblzma.so.5\n\
/lib/x86_64-linux-gnu/libsystemd.so.0\n\
/lib/x86_64-linux-gnu/libdbus-1.so.3\n\
/usr/lib/x86_64-linux-gnu/libatspi.so.0\n\
/usr/lib/x86_64-linux-gnu/libatk-1.0.so.0\n\
/usr/lib/x86_64-linux-gnu/libatk-bridge-2.0.so.0\n\
/opt/gtk/lib/libgtk-3.so.0\n\
/lib/x86_64-linux-gnu/libgcc_s.so.1\n\
/usr/lib/x86_64-linux-gnu/libstdc++.so.6\n\
/usr/lib/x86_64-linux-gnu/libicudata.so.60\n\
/usr/lib/x86_64-linux-gnu/libicuuc.so.60\n\
/usr/lib/x86_64-linux-gnu/libxml2.so.2\n\
/usr/lib/x86_64-linux-gnu/libcroco-0.6.so.3\n\
/usr/lib/x86_64-linux-gnu/librsvg-2.so.2\n\
/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-svg.so\n\
/usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-png.so\n\
' > build/requiredLibs
RUN gcc --version &&\
    nimble -y clean &&\ 
    nimble -y build &&\
    nimble -y appimage

# WHY????
# RUN printf '\x00' | dd bs=1 seek=8 count=1 conv=notrunc of=`ls build/Zegarek*AppImage`

LABEL Name=zegarek
