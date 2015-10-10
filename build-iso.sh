mkdir -o newiso
cp tinyipa.gz boot/corepure64.gz
cp -a boot newiso
genisoimage -l -r -J -R -V TC-custom -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -o tinyipa.iso newiso
rm -rf newiso
