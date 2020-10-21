# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers
# Edit for A10 by @chatur27 on XDA
## AnyKernel setup
# begin properties
properties() { '
kernel.string=
do.devicecheck=0
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
'; } # end properties

# shell variables
block=/dev/block/platform/13500000.dwmmc0/by-name/boot;
dtboblock=/dev/block/platform/13500000.dwmmc0/by-name/dtbo;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

# Change permissions
chmod 755 /system/bin/busybox;

ui_print "- Preparing device for new kernel";

## AnyKernel install
split_boot;

ui_print "- Installing new kernel";

write_boot;

mount /system/
mount /system_root/
mount -o rw,remount -t auto /system >/dev/null;

## Enable Spectrum Support
ui_print " ";
ui_print "- Configuring Spectrum support";
cp /tmp/anykernel/tools/init.spectrum.rc /system_root/init.spectrum.rc;
chmod 644 /system_root/init.spectrum.rc;
cp /tmp/anykernel/tools/init.spectrum.sh /system_root/init.spectrum.sh;
chmod 755 /system_root/init.spectrum.sh;

insert_line /system_root/init.rc "import /init.spectrum.rc" after "import /prism/etc/init/init.rc" "import /init.spectrum.rc";

cp /tmp/anykernel/tools/init.spectrum.rc /system/init.spectrum.rc;
chmod 644 /system/init.spectrum.rc;
cp /tmp/anykernel/tools/init.spectrum.sh /system/init.spectrum.sh;
chmod 755 /system/init.spectrum.sh;

insert_line /system/init.rc "import /init.spectrum.rc" after "import /prism/etc/init/init.rc" "import /init.spectrum.rc";


## Copy changelog to internal storage
cp /tmp/anykernel/tools/a10_changelog.txt /data/media/0/a10_changelog.txt;
chmod 755 /data/media/0/a10_changelog.txt;

umount /system;
umount /system_root;

ui_print "- Installation of kernel and spectrum finished";
ui_print " ";

ui_print "- Full changelog has been copied to your internal";
ui_print "  storage under the name of a10_changelog";
ui_print " ";

ui_print "- If you get stuck on A10 logo, force restart your";
ui_print "  phone. It will boot up fine then. Thank you :)";

## end install
