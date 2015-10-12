set -ex
cwd=`pwd`
builddir="tinyipabuild"

# Log into sudo so that it can be used throughout the script
sudo -v

# If an old build directory exists remove it
if [ -d "$builddir" ]; then
  sudo rm -rf $builddir
fi

# Download and cache required files from tinycorelinux
cd build_files
wget -N http://distro.ibiblio.org/tinycorelinux/6.x/x86_64/release/distribution_files/corepure64.gz
wget -N http://distro.ibiblio.org/tinycorelinux/6.x/x86_64/release/distribution_files/vmlinuz64
wget -N http://tarballs.openstack.org/ironic-python-agent/ironic-python-agent-master.tar.gz
wget -N https://github.com/fujita/tgt/archive/v1.0.51.zip
cd $cwd

# Make directory for building in
mkdir $builddir

# Extract rootfs from .gz file
( cd $builddir && zcat ../build_files/corepure64.gz | sudo cpio -i -H newc -d )

# Install TGT source files into ramdisk
unzip build_files/v1.0.51.zip -d $builddir/tmp

# Create directory for python local mirror
mkdir -p $builddir/tmp/localpip

# Download get-pip into ramdisk
( cd $builddir/tmp && wget https://bootstrap.pypa.io/get-pip.py )

# Download all IPA python requirements
pip install --no-use-wheel --download $builddir/tmp/localpip build_files/ironic-python-agent-master.tar.gz

# Download setuptools
pip install --no-use-wheel --download $builddir/tmp/localpip setuptools

# Download pip
pip install --no-use-wheel --download $builddir/tmp/localpip pip

# Download wheel
pip install --no-use-wheel --download $builddir/tmp/localpip wheel

# Download virtualenv
pip install --no-use-wheel --download $builddir/tmp/localpip virtualenv

# Create directory for builtin extensions
mkdir -p $builddir/tmp/builtin/optional

# Copy onboot.lst to builtin
cp build_files/onboot.lst $builddir/tmp/builtin/.

# Pull tinycore extensions and deps
cd $builddir/tmp/builtin/optional

# Download required tczs
cat ../onboot.lst | sed "s/\(.*\)/http:\/\/distro\.ibiblio\.org\/tinycorelinux\/6\.x\/x86_64\/tcz\/\1/" | xargs wget -N -nv --progress=bar
set +e
ls *.tcz | sed "s/\(.*\)/http:\/\/distro\.ibiblio\.org\/tinycorelinux\/6\.x\/x86_64\/tcz\/\1.dep/" | xargs wget -N -q
set -e
files="`comm -23 <(awk 1 *.dep | sed -e "s/\s//" | grep -v ^$ | sort -u) <(ls *.tcz | sort -u)`"

while [ ! -z "$files" ]
do
  # Parse dep files and download missing tczs
  awk 1 *.dep | grep -v ^$ | sort -u | sed "s/\(.*\)/http:\/\/distro\.ibiblio\.org\/tinycorelinux\/6\.x\/x86_64\/tcz\/\1/" | xargs wget -N --progress=bar 
  # Pull dep files for downloaded tczs
  set +e
  ls *.tcz | sed "s/\(.*\)/http:\/\/distro\.ibiblio\.org\/tinycorelinux\/6\.x\/x86_64\/tcz\/\1.dep/" | xargs wget -N -q
  set -e
  files="`comm -23 <(awk 1 *.dep | sed -e "s/\s//" | grep -v ^$ | sort -u) <(ls *.tcz | sort -u)`"
done
cd $cwd

# Copy bootlocal.sh to opt
sudo cp build_files/bootlocal.sh $builddir/opt/.

# Disable ZSwap
sudo sed -i '/# Main/a NOZSWAP=1' $builddir/etc/init.d/tc-config

# Rebuild build directory into gz file
( cd $builddir && sudo find | sudo cpio -o -H newc | gzip -2 > ../tinyipa.gz )

# Attempt to compress the gz more
advdef -z4 tinyipa.gz

# Copy vmlinuz to new name
cp build_files/vmlinuz64 ./tinyipa.vmlinuz

# Remove builddir now that its been compressed
# sudo rm -rf $builddir
