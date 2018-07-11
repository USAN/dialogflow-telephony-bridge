FROM ubuntu:14.04
ENV build_date 2018-06-27

# pull in build & run dependencies
WORKDIR /tmp
RUN apt-get update && \
    apt-get install -y \
        autoconf \
        automake \
        build-essential \
        curl \
        g++ \
        gcc \
        gettext-base \
        git \
        git-core \
        libasound2-dev \
        libjansson-dev \
        libncurses5-dev \
        libneon27-dev \
        libogg-dev \
        libspandsp-dev \
        libsqlite3-dev \
        libtool \
        libvorbis-dev \
        libxml2-dev \
        openssl \
        pkg-config \
        sqlite \
        sqlite3 \
        subversion \
        unixodbc \
        unixodbc-dev \
        unzip \
        uuid \
        uuid-dev \
        wget

# download, make, & install protobuffer
RUN wget https://github.com/google/protobuf/releases/download/v3.5.1/protobuf-cpp-3.5.1.tar.gz
RUN tar -x -z -f protobuf-cpp-3.5.1.tar.gz
WORKDIR /tmp/protobuf-3.5.1
RUN ./configure --prefix=/usr && \
                make && \
                make install

# download, make, & install gRPC
WORKDIR /tmp
ARG GRPC_VERSION=v1.12.x
RUN git clone -b ${GRPC_VERSION} https://github.com/grpc/grpc
WORKDIR /tmp/grpc
RUN git submodule update --init && \
    prefix=/usr make && \
    prefix=/usr make install && \
    ldconfig

# copy in libdfegrpc code from submodule & build/install
COPY libdfegrpc/ /tmp/libdfegrpc/
WORKDIR /tmp/libdfegrpc
RUN make && make install

# download asterisk
WORKDIR /tmp
ARG ASTERISK_VERSION=asterisk-13.21.1
RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/old-releases/${ASTERISK_VERSION}.tar.gz
RUN tar -v -x -z -f ${ASTERISK_VERSION}.tar.gz

# copy in new modules
COPY res_speech_gdfe/ /tmp/res_speech_gdfe/
COPY res_speech_gdfe/res/ ${ASTERISK_VERSION}/res/

# patch configure to pick up libdfegrpc
WORKDIR /tmp/${ASTERISK_VERSION}
RUN printf "\nDFEGRPC_INCLUDE=@DFEGRPC_INCLUDE@\nDFEGRPC_LIB=@DFEGRPC_LIB@\n" >> makeopts.in
RUN printf "\nDFEGRPC=@PBX_DFEGRPC@\n" >> build_tools/menuselect-deps.in
RUN patch -p0 < /tmp/res_speech_gdfe/configure.ac.diff

# bootstrap configure
RUN ./bootstrap.sh

# run configure
# use bundled pjproject
# disable native build
# try to keep lean, disable some stuff we don't need
RUN ./configure --with-pjproject-bundled && \
    make menuselect.makeopts && \
    menuselect/menuselect \
      --disable BUILD_NATIVE \
      --disable chan_mobile \
      --disable res_config_mysql \
      --disable app_mysql \
      --disable cdr_mysql \
      --disable app_db \
      --disable-category MENUSELECT_CHANNELS \
      --disable chan_sip \
      --disable chan_iax2 \
      --enable chan_pjsip \
      --disable-category MENUSELECT_TESTS

# make asterisk
RUN make && \
    make install

# copy container startup script & config
WORKDIR /tmp
COPY ./etc_asterisk ./etc_asterisk
COPY ./entrypoint.sh ./

EXPOSE 5060/udp
EXPOSE 5060/tcp

CMD ["/bin/bash", "/tmp/entrypoint.sh"]
