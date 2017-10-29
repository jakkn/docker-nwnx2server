FROM jakkn/nwnserver:slim

MAINTAINER jakkn <jakobknutsen@gmail.com>

# Build nwnx2-linux
WORKDIR /usr/local/src

# Java used by nwnx_jvm
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386

RUN downloadDeps='git software-properties-common' \
    && apt update \
    && apt install -y $downloadDeps \
    && add-apt-repository ppa:openjdk-r/ppa -y \
    && apt update \
    && git clone https://github.com/NWNX/nwnx2-linux.git \
    && cd nwnx2-linux \
    && buildDeps=`find . -name apt-dep -exec cat {} \;` \
    && apt install -y $buildDeps \
# build in tree because nwnx_jvm does not handle building out of tree
    && cmake . \
# build jvm first because it randomly fails during threaded execution of target all
    && make jvm \
    && make -j4 \
    && mv compiled /usr/local/bin/nwnx2-linux \
# copy jar and class files required by nwnx_jvm
    && cp plugins/jvm/java/bin/org /opt/nwnserver/jvm -r \
    && cp plugins/jvm/java/dist/org.nwnx.nwnx2.jvm.jar /opt/nwnserver/jvm/ \
    && sed -i -e 's/^classpath=\"\/path\/to\/org.nwnx.nwnx2.java.jar\"$/classpath=\"\.\/jvm\"/g' compiled/nwnx2.ini \
    && rm -rf /var/lib/apt/lists/* /usr/local/src/* \
    && buildDeps=`echo $buildDeps | sed -E -e 's/ lib(pq|sqlite|mysql)[a-z1-9]*-dev//g' -e 's/ ruby / /g' -e 's/ openjdk-7-jdk//g'` \
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
