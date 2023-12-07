# Copyright (c) 2023-2024 iiPython
# Based off of https://github.com/cdrx/docker-pyinstaller
# Now uses Arch Linux and includes various other improvements

FROM archlinux:latest

# Configuration
ARG PYTHON_VERSION=3.12.0
ARG PYINSTALLER_VERSION=6.2
ARG UPX_VERSION=4.2.1
ARG PACMAN_URL=https://gist.githubusercontent.com/iiPythonx/9c932cc08a3e65b99a9863becadcdb21/raw/7392ddc954d0cc676e370a76db742f35986ef613/pacman.conf

# Install everything
RUN set -x \
    && curl -o /etc/pacman.conf $PACMAN_URL \
    && pacman-key --init \
    && pacman -Sy wget perl-rename wine samba cabextract unzip --noconfirm \
    && wget -nv https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x winetricks \
    && mv winetricks /usr/local/bin

# Basic wine settings
ENV WINEARCH win64
ENV WINEDEBUG fixme-all
ENV WINEPREFIX /wine

# Download UPX
RUN set -x \
    && winetricks win7 \
    && cd /wine/drive_c \
    && wget "https://github.com/upx/upx/releases/download/v$UPX_VERSION/upx-$UPX_VERSION-win64.zip" \
    && unzip "upx-$UPX_VERSION-win64.zip" \
    && mv "upx-$UPX_VERSION-win64/upx.exe" . \
    && rm -rf "upx-$UPX_VERSION-win64*"

# Install Python via wine
RUN set -x \
    && for msifile in `echo core dev exe lib path pip tcltk`; do \
        wget -nv "https://www.python.org/ftp/python/$PYTHON_VERSION/amd64/${msifile}.msi"; \
        wine msiexec /i "${msifile}.msi" /qb TARGETDIR=C:/Python$PYTHON_VERSION; \
        rm ${msifile}.msi; \
    done \
    && cd /wine/drive_c/Python$PYTHON_VERSION \
    && echo 'wine "C:\Python3.12.0\python.exe" "$@"' > /usr/bin/python \
    && echo 'wine "C:\Python3.12.0\Scripts\pip.exe" "$@"' > /usr/bin/pip \
    && echo 'wine "C:\Python3.12.0\Scripts\pyupdater.exe" "$@"' > /usr/bin/pyupdater \
    && echo 'wine "C:\Python3.12.0\Scripts\pyinstaller.exe" "$@"' > /usr/bin/pyinstaller \
    && echo "assoc .py=PythonScript" | wine cmd \
    && echo 'ftype PythonScript=c:\Python3.12.0\python.exe "%1" %*' | wine cmd \
    && while pgrep wineserver >/dev/null; do sleep 1; done \
    && chmod +x /usr/bin/python /usr/bin/pip /usr/bin/pyinstaller /usr/bin/pyupdater \
    && (pip install -U pip wheel || true) \
    && rm -rf /tmp/.wine-*

ENV W_DRIVE_C=/wine/drive_c
ENV W_WINDIR_UNIX="$W_DRIVE_C/windows"
ENV W_SYSTEM64_DLLS="$W_WINDIR_UNIX/system32"
ENV W_TMP="$W_DRIVE_C/windows/temp/_$0"

# Install Microsoft Visual C++ Redistributable for Visual Studio 2017 dll files
RUN set -x \
    && rm -f "$W_TMP"/* \
    && wget -P "$W_TMP" https://download.visualstudio.microsoft.com/download/pr/11100230/15ccb3f02745c7b206ad10373cbca89b/VC_redist.x64.exe \
    && cabextract -q --directory="$W_TMP" "$W_TMP"/VC_redist.x64.exe \
    && cabextract -q --directory="$W_TMP" "$W_TMP/a10" \
    && cabextract -q --directory="$W_TMP" "$W_TMP/a11" \
    && cd "$W_TMP" \
    && perl-rename 's/_/\-/g' *.dll \
    && cp "$W_TMP"/*.dll "$W_SYSTEM64_DLLS"/

# Install pyinstaller
RUN /usr/bin/pip install pyinstaller==$PYINSTALLER_VERSION

# Link up the src/ folder inside of wine
RUN mkdir /src/ && ln -s /src /wine/drive_c/src
VOLUME /src/
WORKDIR /wine/drive_c/src/
RUN mkdir -p /wine/drive_c/tmp

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
