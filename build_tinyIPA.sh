set -x

wget -N http://distro.ibiblio.org/tinycorelinux/6.x/x86_64/release/distribution_files/corepure64.gz
wget -N http://distro.ibiblio.org/tinycorelinux/6.x/x86_64/release/distribution_files/vmlinuz64
wget -N http://tarballs.openstack.org/ironic-python-agent/ironic-python-agent-master.tar.gz
wget -N https://github.com/fujita/tgt/archive/v1.0.51.zip

# Make directory for building in
mkdir tinyipa

# Extract rootfs from .gz file
( cd tinyipa && zcat ../corepure64.gz | sudo cpio -i -H newc -d )

# Install TGT source files into ramdisk
unzip v1.0.51.zip -d tinyipa/tmp

# Create directory for python local mirror
mkdir -p tinyipa/tmp/localpip

# Download get-pip into ramdisk
( cd tinyipa/tmp && wget https://bootstrap.pypa.io/get-pip.py )

# Download all IPA python requirements
pip install --no-use-wheel --download tinyipa/tmp/localpip ironic-python-agent-master.tar.gz

# Download setuptools
pip install --no-use-wheel --download tinyipa/tmp/localpip setuptools

# Download pip
pip install --no-use-wheel --download tinyipa/tmp/localpip pip

# Download wheel
pip install --no-use-wheel --download tinyipa/tmp/localpip wheel

# Download virtualenv
pip install --no-use-wheel --download tinyipa/tmp/localpip virtualenv

# Create directory for builtin extensions
mkdir -p tinyipa/tmp/builtin/optional

# Copy onboot.lst to builtin
cp onboot.lst tinyipa/tmp/builtin/.

# Pull tinycore extensions and deps
cwd=`pwd`
cd tinyipa/tmp/builtin/optional

# Download required tczs
cat ../onboot.lst | sed "s/\(.*\)/http:\/\/distro\.ibiblio\.org\/tinycorelinux\/6\.x\/x86_64\/tcz\/\1/" | xargs wget -N
ls *.tcz | sed "s/\(.*\)/http:\/\/distro\.ibiblio\.org\/tinycorelinux\/6\.x\/x86_64\/tcz\/\1.dep/" | xargs wget -N
files="`comm -23 <(awk 1 *.dep | sed -e "s/\s//" | grep -v ^$ | sort -u) <(ls *.tcz | sort -u)`"

while [ ! -z "$files" ]
do
  # Parse dep files and download missing tczs
  awk 1 *.dep | grep -v ^$ | sort -u | sed "s/\(.*\)/http:\/\/distro\.ibiblio\.org\/tinycorelinux\/6\.x\/x86_64\/tcz\/\1/" | xargs wget -N
  # Pull dep files for downloaded tczs
  ls *.tcz | sed "s/\(.*\)/http:\/\/distro\.ibiblio\.org\/tinycorelinux\/6\.x\/x86_64\/tcz\/\1.dep/" | xargs wget -N
  files="`comm -23 <(awk 1 *.dep | sed -e "s/\s//" | grep -v ^$ | sort -u) <(ls *.tcz | sort -u)`"
done

cd $cwd

# Copy bootlocal.sh to opt
sudo cp bootlocal.sh tinyipa/opt/.

# Disable ZSwap
sudo sed -i '/# Main/a NOZSWAP=1' tinyipa/etc/init.d/tc-config

# Rebuild build directory into gz file
( cd tinyipa && sudo find | sudo cpio -o -H newc | gzip -2 > ../tinyipa.gz )

# Attempt to compress the gz more
advdef -z4 tinyipa.gz
