FROM ubuntu:16.04

RUN apt update &&\
    apt install -y --no-install-recommends eatmydata software-properties-common &&\
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
RUN ldconfig

WORKDIR /usr/local/src/pango
RUN wget http://ftp.gnome.org/pub/GNOME/sources/pango/1.42/pango-1.42.4.tar.xz
RUN tar xvfJ pango-1.42.4.tar.xz
WORKDIR /usr/local/src/pango/pango-1.42.4
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
ENV GI_TYPELIB_PATH "/opt/gtk/lib/x86_64-linux-gnu/girepository-1.0:/opt/gtk/lib/girepository-1.0:/usr/local/lib/x86_64-linux-gnu/girepository-1.0:/usr/lib/x86_64-linux-gnu/girepository-1.0:/usr/lib/girepository-1.0/"
RUN ldconfig

RUN nimble -y install gintro


COPY . /usr/src/zegarek
WORKDIR /usr/src/zegarek

SHELL [ "/bin/bash", "-c" ]

RUN mkdir build
# Generated with DISPLAY=:0 LD_DEBUG=all src/zegarek  2>&1 | grep -e '.*calling init.*' | sed 's/.*: //' | sed 's#$#\\n\\#'
RUN echo $'\
/usr/lib/x86_64-linux-gnu/gtk-3.0/modules/libcanberra-gtk-module.so>gtk-3.0/modules/libcanberra-gtk-module.so\n\
/usr/lib/x86_64-linux-gnu/gtk-3.0/modules/libcanberra-gtk3-module.so>gtk-3.0/modules/libcanberra-gtk3-module.so\n\
/usr/lib/x86_64-linux-gnu/gtk-3.0/modules/libcanberra-gtk-module.so\n\
/usr/lib/x86_64-linux-gnu/gtk-3.0/modules/libcanberra-gtk3-module.so\n\
/usr/lib/x86_64-linux-gnu/librsvg-2.so.2\n\
/usr/local/lib/libharfbuzz.so.0\n\
/usr/local/lib/x86_64-linux-gnu/libepoxy.so.0\n\
/usr/local/lib/x86_64-linux-gnu/libgio-2.0.so.0\n\
/usr/local/lib/x86_64-linux-gnu/libglib-2.0.so.0\n\
/usr/local/lib/x86_64-linux-gnu/libpango-1.0.so.0\n\
/usr/local/lib/x86_64-linux-gnu/libpangocairo-1.0.so.0\n\
/usr/local/lib/x86_64-linux-gnu/libpangoft2-1.0.so.0\n\
/usr/local/lib/x86_64-linux-gnu/libpangoxft-1.0.so.0\n\
/opt/gtk/lib/libgtk-3.so.0\n\
/opt/gtk/lib/libgdk-3.so.0\n\
' > build/requiredLibs
RUN echo $'\
#empty
' > build/excludelist.local

RUN gcc --version &&\
    nimble -y clean &&\ 
    nimble -y build &&\
    nimble -y appimage

# WHY????
# RUN printf '\x00' | dd bs=1 seek=8 count=1 conv=notrunc of=`ls build/Zegarek*AppImage`

LABEL Name=zegarek
