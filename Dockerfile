FROM ubuntu:14.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt upgrade -y
RUN apt install -y build-essential libffi-dev git pkg-config gcc-multilib autoconf gperf bison flex texinfo wget help2man gawk libtool libncurses5-dev
RUN apt install -y python libpython2.7-dev
RUN git clone --recursive https://github.com/nicovell3/esp-open-sdk.git /tools
RUN useradd tools
RUN sed -i '/GNU bash, version/s@4@4|5|6@' /tools/crosstool-NG/configure.ac && \
    sed -i '/# Check for libtool /,+13d' /tools/crosstool-NG/configure.ac && \
    mkdir -p /tools/crosstool-NG/.build/tarballs/ && \
    wget --no-check-certificate -O /tools/crosstool-NG/.build/tarballs/isl-0.14.tar.xz https://sourceforge.net/projects/libisl/files/isl-0.14.tar.xz/download && \
    wget --no-check-certificate -O /tools/crosstool-NG/.build/tarballs/expat-2.1.0.tar.gz https://sourceforge.net/projects/expat/files/expat/2.5.0/expat-2.5.0.tar.gz/download

RUN chown -R tools /tools
USER tools
WORKDIR /tools
RUN make

## Stage 2
FROM ubuntu:14.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt upgrade -y
RUN apt install -y make autoconf automake libtool git
RUN apt install -y python python-serial
COPY --from=0 /tools/xtensa-lx106-elf /tools/xtensa-lx106-elf
ENV PATH=/tools/xtensa-lx106-elf/bin:/bin:/usr/bin
RUN mkdir /usr/lib/esp-open-sdk
COPY install-wrapper /usr/bin/install-wrapper
COPY esp-open-sdk /usr/lib/esp-open-sdk/esp-open-sdk