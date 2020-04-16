##################################################################
			PROVEN STEPS
##################################################################

make rock-pi-4_defconfig && make -j 16 && make -j 16 u-boot.itb

tools/mkimage -n rk3399 -T rksd -d /home/agajjar/workspace/mainline/rkbin/bin/rk33/rk3399_ddr_800MHz_v1.17.bin idbloader.img
cat /home/agajjar/workspace/mainline/rkbin/bin/rk33/rk3399_miniloader_v1.15.bin >> idbloader.img
/home/agajjar/workspace/mainline/rkbin/tools/loaderimage --pack --uboot ./u-boot-dtb.bin u-boot.img 0x200000
/home/agajjar/workspace/mainline/rkbin/tools/trust_merger trust.ini

tools/mkimage -n rk3399 -T rksd -d tpl/u-boot-tpl.bin idbloader.img
cat spl/u-boot-spl.bin >> idbloader.img

sudo dd if=idbloader.img of=/dev/sdc seek=64 conv=notrunc
sudo dd if=u-boot.img of=/dev/sdc seek=16384 conv=notrunc
sudo dd if=trust.img of=/dev/sdc seek=24576 conv=notrunc

##################################################################

##################################################################

make rock-pi-4b-rk3399_defconfig all

tools/mkimage -n rk3399 -T rksd -d ../rkbin/bin/rk33/rk3399_ddr_800MHz_v1.14.bin idbloader.img

cat spl/u-boot-spl.bin >> idbloader.img
../rkbin/tools/loaderimage --pack --uboot ./u-boot-dtb.bin uboot.img 0x200000
../rkbin/tools/trust_merger trust.ini

sudo dd if=idbloader.img of=/dev/sdb seek=64 conv=notrunc
sudo dd if=uboot.img of=/dev/sdb seek=16384 conv=notrunc
sudo dd if=trust.img of=/dev/sdb seek=24576 conv=notrunc

##################################################################
			BOOT COMMAND
##################################################################

ip=dhcp

setenv bootargs 'earlycon=uart8250,mmio32,0xff1a0000 console=ttyS2,1500000n8 swiotlb=1 panic=10 init=/sbin/init cohereent_pool=1M cgroup_enaable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1 rw root=/dev/mmcblk0p5 rootwait rootfstype=ext4 log_level=7 initcall_debug=0'

ext4load mmc 1:5 ${kernel_addr_r} boot/Image;ext4load mmc 1:5 ${fdt_addr_r} boot/rockpi-4b-linux.dtb;booti ${kernel_addr_r} - ${fdt_addr_r}

##################################################################
			Mainline Kernel
##################################################################

setenv bootargs 'console=ttyS2,1500000n8 rw panic=10 init=/sbin/init root=/dev/mmcblk0p2 rootwait rootfstype=ext4 log_level=7'

ext4load mmc 1:2 ${kernel_addr_r} boot/Image;ext4load mmc 1:2 ${fdt_addr_r} boot/rk3399-rock-pi-4.dtb;booti ${kernel_addr_r} - ${fdt_addr_r}

setenv bootargs 'swiotlb=1 rw panic=10 init=/sbin/init cohereent_pool=1M ethaddr=32:30:91:0f:ef:3b eth1addr=serial=d372be676639601 cgroup_enaable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1 root=/dev/mmcblk0p2 rootwait rootfstype=ext4 log_level=7'

ext4load mmc 1:2 ${kernel_addr_r} boot/4.4.154/Image;ext4load mmc 1:2 ${fdt_addr_r} boot/4.4.154/rockpi-4b-linux.dtb;booti ${kernel_addr_r} - ${fdt_addr_r}

setenv bootargs 'swiotlb=1 earlyprintk video=1024x768@60,noedid rw panic=10 init=/sbin/init cohereent_pool=1M ethaddr=32:30:91:0f:ef:3b cgroup_enaable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1 root=/dev/mmcblk1p2 rootwait rootfstype=ext4 log_level=7'

ext4load mmc 1:2 ${kernel_addr_r} /boot/Image;ext4load mmc 1:2 ${fdt_addr_r} /boot/rk3399-rock-pi-4.dtb;booti ${kernel_addr_r} - ${fdt_addr_r}

video=1024x768@60,noedid

setenv bootcmd 'sysboot mmc 1:2 any ${scriptaddr} /boot/extlinux/extlinux.conf'
sysboot mmc 1:2 any ${scriptaddr} /boot/extlinux/extlinux.conf

##################################################################

iw dev wlan0 scan | egrep "signal|SSID"
ifconfig wlan0 up
sudo iw dev wlan0 connect 'Internet hub jio'
iw dev wlan0 connect 'hacker'
wpa_supplicant -B -i wlan0 -c wpa_supplicant.conf
iw dev wlan0 link

dhclient wlan0

##################################################################

sudo apt-get purge xorg
== Mainline Linux Kernel ==
user@user]~$ mkdir workspace
user@user]~$ cd workspace
user@user]~$ git clone https://github.com/torvalds/linux.git
user@user]~$ cd linux
user@user]~$ export ARCH=arm64
user@user]~$ export CROSS_COMPILE=/opt/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
user@user]~$ make defconfig
user@user]~$ make all -j 16

setenv bootargs 'earlycon=uart8250,mmio32,0xff1a0000 init=/sbin/init root=/dev/mmcblk0p5 rw panic=10 rootwait rootfstype=ext4'
setenv bootargs 'earlycon=uart8250,mmio32,0xff1a0000 console=ttyS2,1500000n8 rw root=/dev/mmcblk1p5 rootfstype=ext4 init=/sbin/init rootwait'
ext4load mmc 1:5 ${kernel_addr_r} boot/Image;ext4load mmc 1:5 ${fdt_addr_r} boot/rk3399-rock-pi-4.dtb;booti ${kernel_addr_r} - ${fdt_addr_r}

fatload mmc 1:4 ${kernel_addr_r} Image_5.1;fatload mmc 1:4 ${fdt_addr_r} rk3399-rock-pi-4.dtb;booti ${kernel_addr_r} - ${fdt_addr_r}

echo mem > /sys/power/state

# stress test
sysbench cpu --cpu-max-prime=20000 --threads=6 run
sysbench --test=cpu --cpu-max-prime=90000 run

make distclean &&
make rockpro64-rk3399_defconfig && 
make -j 16 && make -j 16 u-boot.itb

