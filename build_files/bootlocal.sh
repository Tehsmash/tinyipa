#!/bin/sh
# put other system startup commands here

exec > /tmp/installlogs 2>&1
set -x

export HOME=/root

# Install setuptools
(cd /tmp/localpip && tar xzfv setuptools-*.tar.gz && cd /tmp/localpip/setuptools-* && python setup.py install)

# Install pip and initial IPA virtualenv
python /tmp/get-pip.py --no-index --find-links=file:///tmp/localpip
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip virtualenv
virtualenv /tmp/ipa

# Activate IPA virtualenv
. /tmp/ipa/bin/activate

# Install IPA and dependecies
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/pbr*.tar.gz
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/six*.tar.gz
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/argparse*.tar.gz
pip install --no-index --no-use-wheel --find-links=file:///tmp/localpip /tmp/localpip/ironic-python-agent*.tar.gz

# Run IPA
ironic-python-agent &
