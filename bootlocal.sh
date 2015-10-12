#!/bin/sh
# put other system startup commands here

# Sleep for 5 seconds waiting for things to get ready
sleep 5

set -x
exec > /tmp/installlogs 2>&1

echo "`pwd`"
echo "`ls /tmp/localpip`"
echo "$PATH"
echo "$HOME"
export HOME=/root

(cd /tmp/tgt-1.0.51 && make install)

(cd /tmp/localpip && tar xzfv setuptools-*.tar.gz && cd /tmp/localpip/setuptools-* && python setup.py install)

python /tmp/get-pip.py --no-index --find-links=file:///tmp/localpip
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip virtualenv
virtualenv /tmp/ipa

. /tmp/ipa/bin/activate
echo "$PATH"

pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/pbr*.tar.gz
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/traceback2*.tar.gz
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/six*.tar.gz
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/argparse*.tar.gz
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/ironic-python-agent*.tar.gz

ironic-python-agent &
