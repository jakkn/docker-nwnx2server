FROM jakkn/nwnserver:slim

MAINTAINER jakkn <jakobknutsen@gmail.com>

# Build nwnx2-linux
WORKDIR /usr/local/src
RUN downloadDeps='git software-properties-common' \
    && apt update \
    && apt install -y $downloadDeps \
    && add-apt-repository ppa:openjdk-r/ppa -y \
    && apt update \
    && git clone https://github.com/NWNX/nwnx2-linux.git \
    && cd nwnx2-linux \
    && buildDeps=`find . -name apt-dep -exec cat {} \;` \
    && apt install -y $buildDeps \
    && export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386 \
    && mv plugins/jvm . \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j5 \
    && mv compiled /usr/local/bin/nwnx2-linux \
    && cd .. \
    && mv jvm plugins \
    && cmake . \
    && make jvm \
    && mv compiled/nwnx_jvm.so /usr/local/bin/nwnx2-linux/ \
    && rm -rf /var/lib/apt/lists/* /usr/local/src/* \
    && buildDeps=`echo $buildDeps | sed -E 's/ lib(pq|sqlite|mysql)[a-z1-9]*-dev//g'` \
    && apt-get purge -y --auto-remove $downloadDeps $buildDeps \
    && apt-get autoremove -y \
    && apt-get clean

# Symlink nwnx2.so and copy config and run script
WORKDIR /usr/local/bin/nwnx2-linux
RUN ln -s $(pwd)/nwnx2.so /opt/nwnserver/nwnx2.so \
    && cp nwnx2.ini nwnstartup.sh /opt/nwnserver

# Prepare to run
WORKDIR /opt/nwnserver
RUN sed -i \
    -e's/YourServerHere/"Containerized nwnx2-linuxserver"/g' \
    -e's/YourModuleHere/module/g' \
    nwnstartup.sh

# Copy over script for use with docker-compose
ADD ["docker/scripts/*", "./"]

CMD ["./nwnstartup.sh"]
