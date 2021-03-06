#!/bin/bash
# PURPOSE  : lazy combined RHEL/CentOS/Fedora install including dependencies and setcap
# FILENAME : install.sh
# AUTHOR   : jczyz, 2015-12-11

# Ensure running as root/sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Must be run as root or via sudo." >&2
    exit 1
fi

exit_if_failed () {
    ECODE=$?
    if [ $ECODE -ne 0 ]; then
        exit $ECODE
    fi;
}

#use alternate, local cmake if exists
if [ -f /usr/local/bin/cmake ]; then
    CMAKE=/usr/local/bin/cmake
else
    CMAKE=`which cmake`
fi

if [[ "$OSTYPE" == "darwin"* ]]; then 
    OS="OSX"
    echo "This OS not yet supported by this script. Install manually."; exit 1
elif grep -q CentOS /etc/*-release; then 
    OS="CENTOS"
    yum -y install cmake gmp-devel gengetopt libpcap-devel flex byacc json-c-devel libunistring-devel
    exit_if_failed
elif grep -q AMI /etc/*-release; then 
    OS="AMI"
    echo "This OS not yet supported by this script. Install manually."; exit 1
elif grep -q Ubuntu /etc/*-release; then 
    OS="UBUNTU"
    echo "This OS not yet supported by this script. Install manually."; exit 1
elif grep -q Fedora /etc/*-release; then 
    OS="FEDORA"
    yum -y install cmake gmp-devel gengetopt libpcap-devel flex byacc json-c-devel libunistring-devel
    exit_if_failed
else
    OS="UNKNOWN"
    echo "This OS not yet supported by this script. Install manually."; exit 1
fi

$CMAKE -DWITH_JSON=ON -DENABLE_LOG_TRACE=OFF -DWITH_REDIS=OFF -DWITH_MONGO=OFF -DRESPECT_INSTALL_PREFIX_CONFIG=ON . && make -j4 && sudo make install \

if which zmap &>/dev/null ; then
    ZMAP=`which zmap`
else
    ZMAP=/usr/local/sbin/zmap
fi

setcap cap_net_raw=ep $ZMAP && \
echo "Installed zmap version is: `$ZMAP -V`" >&2

#EOF
