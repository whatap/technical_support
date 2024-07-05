#!/bin/bash

# Function for Ubuntu
install_ubuntu() {
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y curl
}

# Function for CentOS/RedHat/Rocky
install_centos_redhat_rocky() {
    echo "Installing for CentOS/RedHat/Rocky..."
     yum install -y curl
}

# Function for Amazon Linux
install_amazon_linux() {
    echo "Installing for Amazon Linux..."
    yum install -y curl
}


# Download Telegraf binary 
download_dependencies() {
    # Detect the distribution
    . /etc/os-release
    echo "os ID: $ID"
    case $ID in
        ubuntu)
            install_ubuntu
            ;;
        centos|rhel|rocky)
            install_centos_redhat_rocky
            ;;
        amzn)
            install_amazon_linux
            ;;
        *)
            echo "Unsupported Linux distribution."
            exit 1
            ;;
    esac

    echo "Downloading Telegraf binary..."

    # Determine OS architecture
    ARCH=$(uname -m)
    case $ARCH in
        amd64|x86_64)
            TELEGRAF_URL="http://210.122.10.41/telegraf/dev/amd64/telegraf"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    feature_prefix=.
    # Download Telegraf
    curl $TELEGRAF_URL -o $feature_prefix/telegraf
    chmod +x $feature_prefix/telegraf
    
}


create_license(){

    cat <<EOF > ./TELEGRAF_MIT_LICENSE.txt
The MIT License (MIT)

Copyright (c) 2015-2024 InfluxData Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

}



create_license
download_dependencies