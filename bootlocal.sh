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

(cd /tmp/localpip && tar xzfv setuptools-18.3.2.tar.gz && cd /tmp/localpip/setuptools-18.3.2 && python setup.py install)

python /tmp/get-pip.py --no-index --find-links=file:///tmp/localpip
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip virtualenv
virtualenv /tmp/ipa

. /tmp/ipa/bin/activate
echo "$PATH"

pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/pbr-1.8.0.tar.gz
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/traceback2-1.4.0.tar.gz
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/six-1.10.0.tar.gz
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/argparse-1.4.0.tar.gz
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/ironic-python-agent-master.tar.gz

ironic-python-agent &
