# This file is part of MXE.
# See index.html for further information.

PKG             := sox
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 14.4.1
$(PKG)_CHECKSUM := 71f05afc51e3d9b03376b2f98fd452d3a274d595
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := http://$(SOURCEFORGE_MIRROR)/project/$(PKG)/$(PKG)/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc file flac libgomp libsndfile libltdl vorbis

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://sourceforge.net/projects/sox/files/sox/' | \
    $(SED) -n 's,.*/\([0-9][^"]*\)/".*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    # set pkg-config cflags and libs
    $(SED) -i 's,^\(Cflags:.*\),\1 -fopenmp,' '$(1)/sox.pc.in'
    $(SED) -i '/Libs.private/d'               '$(1)/sox.pc.in'
    echo Libs.private: @MAGIC_LIBS@ \
        `grep sox_LDADD '$(1)/src/optional-fmts.am' | \
         $(SED) 's, sox_LDADD += ,,g' | tr -d '\n'` >>'$(1)/sox.pc.in'

    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --disable-debug \
        --with-libltdl \
        --with-magic \
        --without-png \
        --without-ladspa \
        --without-amrwb \
        --without-amrnb \
        --without-ffmpeg \
        --with-flac \
        --with-oggvorbis \
        --with-sndfile \
        --without-wavpack \
        --without-mad \
        --without-id3tag \
        --without-lame \
        --without-twolame \
        --with-waveaudio \
        --without-alsa \
        --without-ao \
        --without-coreaudio \
        --without-oss \
        --without-pulseaudio \
        --without-sndio \
        --without-sunaudio

    $(MAKE) -C '$(1)' -j '$(JOBS)' bin_PROGRAMS= EXTRA_PROGRAMS=
    $(MAKE) -C '$(1)' -j 1 install

    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(2).c' -o '$(PREFIX)/$(TARGET)/bin/test-sox.exe' \
        `'$(TARGET)-pkg-config' sox --cflags --libs`
endef
