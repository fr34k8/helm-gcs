#!/bin/sh

# Find correct archive name
unameOut="$(uname -s)"

case "${unameOut}" in
    Linux*)     os=Linux;;
    Darwin*)    os=Darwin;;
    CYGWIN*)    os=Cygwin;;
    MINGW*)     os=windows;;
    *)          os="UNKNOWN:${unameOut}"
esac

arch=`uname -m`
url=`curl --silent https://api.github.com/repos/nouney/helm-gcs/releases/latest | awk '/browser_download_url/ { print $2 }' | sed 's/"//g' | grep ${os}_${arch}`

if [ "$url" = "" ]
then
    echo "Unsupported OS / architecture: ${os}_${arch}"
    exit 1
fi

filename=`echo ${url} | sed -e "s/^.*\///g"`

# Download archive
if [ -n $(command -v curl) ]
then
    curl -sSL -O $url
elif [ -n $(command -v wget) ]
then
    wget $url
else
    echo "Need curl or wget"
    exit -1
fi

# Install bin
rm -rf bin && mkdir bin && tar xzvf $filename -C bin > /dev/null && rm -f $filename

echo "helm-gcs is correctly installed."
echo

echo "Init a new repository:"
echo "  helm gcs init gs://bucket/path"
echo

echo "Add your repository to Helm:"
echo "  helm repo add repo-name gs://bucket/path"
echo

echo "Push a chart to your repository:"
echo "  helm gcs push chart.tar.gz repo-name"
echo

echo "Update Helm cache:"
echo "  helm repo update"
echo

echo "Get your chart:"
echo "  helm fetch repo-name/chart"
echo