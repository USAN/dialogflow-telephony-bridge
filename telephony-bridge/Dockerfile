FROM ubuntu:14.04 as grpc_build

ARG GRPC_VERSION=v1.12.x

RUN apt-get update && \
    apt-get install -y \
        autoconf \
        g++ \
        gcc \
        git \
        libtool \
        make \
        wget

# download, make, & install protobuffer
WORKDIR /tmp
RUN wget https://github.com/google/protobuf/releases/download/v3.5.1/protobuf-cpp-3.5.1.tar.gz && tar -x -z -v -f protobuf-cpp-3.5.1.tar.gz
WORKDIR /tmp/protobuf-3.5.1
RUN ./configure --prefix=/usr && \
                make && \
                make install

# download, make, & install gRPC
RUN git clone -b ${GRPC_VERSION} https://github.com/grpc/grpc /tmp/grpc
WORKDIR /tmp/grpc
RUN git submodule update --init && \
    prefix=/usr make && \
    prefix=/usr make install

# produces /usr/lib/libproto* /usr/lib/libgrpc* /usr/include/google/protobuf/* /usr/include/grpc*/* /usr/bin/protoc /usr/bin/grpc_cpp_plugin
RUN tar -f /tmp/grpc_build.tgz -z -v -c \
    /usr/lib/libproto* \
    /usr/lib/libgrpc* \
    /usr/include/google/protobuf/* \
    /usr/include/grpc* \
    /usr/bin/protoc \
    /usr/bin/grpc_cpp_plugin

FROM ubuntu:14.04 as asterisk_build

# pull in build & run dependencies
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
        libcurl4-openssl-dev \
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

# copy and expand the grpc/protobuffer artifacts
COPY --from=grpc_build /tmp/grpc_build.tgz /tmp/grpc_build.tgz
RUN tar -C / -f /tmp/grpc_build.tgz -x -z -v

# copy in libdfegrpc code from submodule & build/install
COPY libdfegrpc/ /tmp/libdfegrpc/
WORKDIR /tmp/libdfegrpc
RUN make && make install

# download asterisk
WORKDIR /tmp
ARG ASTERISK_VERSION=asterisk-13.21.1
RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/old-releases/${ASTERISK_VERSION}.tar.gz && tar -v -x -z -f ${ASTERISK_VERSION}.tar.gz

# copy in new modules
COPY res_speech_gdfe/ /tmp/res_speech_gdfe/
COPY res_speech_gdfe/res/ ${ASTERISK_VERSION}/res/

# patch configure to pick up libdfegrpc
WORKDIR /tmp/${ASTERISK_VERSION}
RUN printf "\nDFEGRPC_INCLUDE=@DFEGRPC_INCLUDE@\nDFEGRPC_LIB=@DFEGRPC_LIB@\n" >> makeopts.in \ 
    && printf "\nDFEGRPC=@PBX_DFEGRPC@\n" >> build_tools/menuselect-deps.in \
    && patch -p0 < /tmp/res_speech_gdfe/configure.ac.diff

# bootstrap configure, then...
# run it
#   use bundled pjproject
#   disable native build
#   try to keep lean, disable some stuff we don't need
# then... make it & install it
RUN ./bootstrap.sh && ./configure --with-pjproject-bundled && \
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
      --disable-category MENUSELECT_TESTS \
    && make \
    && make install

RUN tar -f /tmp/asterisk-binaries.tgz -z -v -c \
    /usr/sbin/ast* \
    /usr/sbin/safe_asterisk \
    /usr/include/asterisk.h \
    /usr/include/asterisk/*.h \
    /var/lib/asterisk \
    /usr/lib/asterisk \
    /usr/lib/libast* \
    /usr/lib/libdfegrpc*

FROM ubuntu:14.04

RUN apt-get update && \
    apt-get install -y \
        curl \
        gettext-base \
        libasound2-dev \
        libjansson-dev \
        libncurses5-dev \
        libneon27-dev \
        libogg-dev \
        libspandsp-dev \
        libsqlite3-dev \
        libvorbis-dev \
        libxml2-dev \
        openssl \
        pkg-config \
        sqlite \
        sqlite3 \
        unixodbc \
        unixodbc-dev \
        unzip \
        uuid \
        uuid-dev \
        wget

# copy and expand the grpc/protobuffer artifacts
COPY --from=grpc_build /tmp/grpc_build.tgz /tmp/grpc_build.tgz
RUN tar -C / -f /tmp/grpc_build.tgz -x -z -v

# copy in libdfegrpc code from submodule (required for compliance)
COPY libdfegrpc/ /tmp/libdfegrpc/

# copy in asterisk module code from submodule
COPY res_speech_gdfe/ /tmp/res_speech_gdfe/

COPY --from=asterisk_build /tmp/asterisk-binaries.tgz /tmp/asterisk-binaries.tgz
RUN tar -C / -f /tmp/asterisk-binaries.tgz -x -z -v

# copy container startup script & config
WORKDIR /tmp
COPY ./etc_asterisk ./etc_asterisk
COPY ./entrypoint.sh ./

EXPOSE 5060/udp
EXPOSE 5060/tcp

CMD ["/bin/bash", "/tmp/entrypoint.sh"]
