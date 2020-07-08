FROM konradmb/docker-gtk-compile

RUN curl https://nim-lang.org/choosenim/init.sh -sSf > choosenim.sh &&\
    chmod +x ./choosenim.sh &&\
    ./choosenim.sh -y
ENV PATH "/root/.nimble/bin:$PATH"

# RUN nimble -y install gintro

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
