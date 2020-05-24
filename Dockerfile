FROM ubuntu:18.04

RUN apt update &&\
    apt install -y --no-install-recommends eatmydata software-properties-common &&\
    # add-apt-repository -u ppa:savoury1/fonts &&\
    # add-apt-repository -u ppa:ubuntu-toolchain-r/test &&\
    eatmydata apt -y install gcc build-essential cmake gettext wget curl librsvg2-bin git libgtk-3-dev \
    libgirepository1.0-dev file libcanberra-gtk3-dev libmount-dev \
    ninja-build python3-pip flex bison python3-dev libfribidi-dev libharfbuzz-dev &&\
    rm -rf /var/lib/apt/lists/* &&\
    pip3 install meson &&\
    curl https://nim-lang.org/choosenim/init.sh -sSf > choosenim.sh &&\
    chmod +x ./choosenim.sh &&\
    ./choosenim.sh -y
ENV PATH "/root/.nimble/bin:$PATH"

WORKDIR /usr/local/src/pango
RUN wget http://ftp.gnome.org/pub/GNOME/sources/pango/1.42/pango-1.42.4.tar.xz
RUN tar xvfJ pango-1.42.4.tar.xz
WORKDIR /usr/local/src/pango/pango-1.42.4
RUN meson _build
RUN ninja -C _build
RUN ninja -C _build install
ENV PKG_CONFIG_PATH "/usr/local/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"
ENV LD_LIBRARY_PATH "/usr/local/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
RUN ldconfig

WORKDIR /usr/local/src/glib
RUN wget https://download.gnome.org/sources/glib/2.60/glib-2.60.7.tar.xz
RUN tar xvfJ glib-2.60.7.tar.xz
WORKDIR /usr/local/src/glib/glib-2.60.7
RUN meson _build
RUN ninja -C _build
RUN ninja -C _build install
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
ENV GI_TYPELIB_PATH "/opt/gtk/lib/x86_64-linux-gnu/girepository-1.0:/opt/gtk/lib/girepository-1.0:/usr/local/lib/x86_64-linux-gnu/girepository-1.0:/usr/lib/x86_64-linux-gnu/girepository-1.0"
RUN ldconfig

RUN ls /opt/gtk/lib


COPY . /usr/src/zegarek
WORKDIR /usr/src/zegarek

RUN mkdir build
# Generated with DISPLAY=:0 LD_DEBUG=all src/zegarek  2>&1 | grep -e '.*calling init.*' | sed 's/.*: //' | sed 's#$#\\n\\#'
RUN echo $'\
/usr/lib64/gtk-3.0/modules/libcanberra-gtk-module.so>gtk-3.0/modules/libcanberra-gtk-module.so\n\
/lib64/libpthread.so.0\n\
/lib64/libc.so.6\n\
/lib64/libdl.so.2\n\
/lib64/librt.so.1\n\
/lib64/libm.so.6\n\
/lib64/libpcre.so.1\n\
/lib64/libffi.so.6\n\
/usr/local/lib64/libglib-2.0.so.0\n\
/usr/local/lib64/libgobject-2.0.so.0\n\
/lib64/libselinux.so.1\n\
/lib64/libuuid.so.1\n\
/lib64/libblkid.so.1\n\
/lib64/libresolv.so.2\n\
/lib64/libmount.so.1\n\
/lib64/libz.so.1\n\
/usr/local/lib64/libgmodule-2.0.so.0\n\
/usr/local/lib64/libgio-2.0.so.0\n\
/lib64/libgcc_s.so.1\n\
/lib64/libgraphite2.so.3\n\
/lib64/libXau.so.6\n\
/lib64/libxcb.so.1\n\
/lib64/libX11.so.6\n\
/lib64/libXext.so.6\n\
/lib64/libGLdispatch.so.0\n\
/lib64/libGLX.so.0\n\
/lib64/libpng15.so.15\n\
/lib64/libbz2.so.1\n\
/lib64/libfreetype.so.6\n\
/lib64/libharfbuzz.so.0\n\
/lib64/libexpat.so.1\n\
/lib64/libGL.so.1\n\
/lib64/libXrender.so.1\n\
/lib64/libxcb-render.so.0\n\
/lib64/libxcb-shm.so.0\n\
/lib64/libEGL.so.1\n\
/lib64/libpixman-1.so.0\n\
/lib64/libthai.so.0\n\
/lib64/libfribidi.so.0\n\
/lib64/libpango-1.0.so.0\n\
/lib64/libfontconfig.so.1\n\
/lib64/libpangoft2-1.0.so.0\n\
/lib64/libepoxy.so.0\n\
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
/opt/gtk/lib/libgdk-3.so.0\n\
/lib64/libelf.so.1\n\
/lib64/libattr.so.1\n\
/lib64/liblzma.so.5\n\
/lib64/libdw.so.1\n\
/lib64/libgpg-error.so.0\n\
/lib64/libgcrypt.so.11\n\
/lib64/liblz4.so.1\n\
/lib64/libcap.so.2\n\
/lib64/libsystemd.so.0\n\
/lib64/libdbus-1.so.3\n\
/lib64/libatspi.so.0\n\
/lib64/libatk-1.0.so.0\n\
/lib64/libatk-bridge-2.0.so.0\n\
/opt/gtk/lib/libgtk-3.so.0\n\
/lib64/libxml2.so.2\n\
/lib64/libcroco-0.6.so.3\n\
/lib64/librsvg-2.so.2\n\
/usr/lib64/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-svg.so\n\
' > build/requiredLibs
RUN gcc --version &&\
    nimble -y clean &&\ 
    nimble -y build &&\
    nimble -y appimage

# WHY????
# RUN printf '\x00' | dd bs=1 seek=8 count=1 conv=notrunc of=`ls build/Zegarek*AppImage`

LABEL Name=zegarek
