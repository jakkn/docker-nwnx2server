FROM jakkn/nwnserver:slim

MAINTAINER jakkn <jakobknutsen@gmail.com>

# Build nwnx2-linux
WORKDIR /usr/local/src

# Java used by nwnx_jvm
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386

RUN downloadDeps='git' \
    && apt update \
    && apt install -y $downloadDeps \
    && git clone https://github.com/NWNX/nwnx2-linux.git \
    && cd nwnx2-linux \
    && buildDeps=`find . -name apt-dep -exec cat {} \;` \
    && apt install -y --no-install-recommends $buildDeps \
# build in tree because nwnx_jvm does not handle building out of tree
    && cmake . \
# build jvm first because it randomly fails during threaded execution of target all
    && make jvm \
    && make -j4 \
# copy jar and class files required by nwnx_jvm
    && mkdir /opt/nwnserver/jvm \
    && cp plugins/jvm/java/bin/org /opt/nwnserver/jvm/ -r \
    && cp plugins/jvm/java/dist/org.nwnx.nwnx2.jvm.jar /opt/nwnserver/jvm/ \
    && sed -i -e 's/^classpath=\"\/path\/to\/org.nwnx.nwnx2.java.jar\"$/classpath=\"\.\/jvm\"/g' compiled/nwnx2.ini \
# store compiled output
    && mv compiled /usr/local/bin/nwnx2-linux \
    && apt-get purge -y --auto-remove $downloadDeps $buildDeps \
    && apt-get autoremove -y \
    && apt-get clean \
# reinstall all run dependencies
    && runDeps="openjdk-7-jre-headless ruby sqlite postgresql-client mysql-client" \
    && apt install -y $runDeps \
    && rm -rf /var/lib/apt/lists/* /usr/local/src/*

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
