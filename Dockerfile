FROM besn0847/ubuntu32

RUN apt-get install -y \
    wget \
    unzip \
    git

# Download, extract and run fix on the dedicated server files
RUN mkdir -p /opt/nwnserver
WORKDIR /opt/nwnserver
RUN wget http://neverwintervault.org/sites/neverwintervault.org/files/project/1621/files/nwndedicatedserver1.69.zip
RUN unzip -x nwndedicatedserver1.69 -d .
RUN rm nwndedicatedserver1.69.zip \
    macdedserver169.zip \
    nwserver.exe \
    nwupdate.exe \
    Patchw32.dll \
    readme.macserver.txt
RUN tar xzvf linuxdedserver169.tar.gz
RUN chmod -R ug+w * \
    && chmod ug+x fixinstall \
    && ./fixinstall

# Clone nwnx2-linux
WORKDIR /usr/local/src
RUN git clone https://github.com/NWNX/nwnx2-linux.git
WORKDIR /usr/local/src/nwnx2-linux

# Download all plugin dependencies
RUN apt-get update
RUN find . -name apt-dep -exec cat {} \; | xargs sudo apt-get install -y

# Build
RUN mkdir build
WORKDIR /usr/local/src/nwnx2-linux/build
RUN cmake ..
RUN make

# Symlink nwnx2.so to nwnserver, and copy config and run script
WORKDIR /usr/local/src/nwnx2-linux/build/compiled
RUN ln -s $(pwd)/nwnx2.so /opt/nwnserver/nwnx2.so \
    && cp nwnx2.ini nwnstartup.sh /opt/nwnserver

# Prepare to run
WORKDIR /opt/nwnserver
RUN sed -i \
    -e's/YourServerHere/"Docker-loaded server"/g' \
    -e's/YourModuleHere/Contest Of Champions 0492/g' \
    nwnstartup.sh

CMD ["./nwnstartup.sh"]